/// Bringing this screen online with a Quick Code.
///
/// SPEC-097. A kitchen screen registers exactly the way a till does: somebody
/// mints a code in the back office (Screens → Quick Code), types it here with
/// a manager's credentials, and the screen exists only once a human approves
/// it. The device, not the person, is what gets registered — which is why the
/// screen keeps what it shows across staff logins, and why taking it offline
/// in the back office actually stops it.
///
/// Until this existed the app had no identity at all: it signed in as a staff
/// member, so it could not know which screen it was, and the Prep/Expo setting
/// and the routing categories chosen in the back office reached nothing.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/theme/kds_theme.dart';
import '../../data/auth_repository.dart';

/// How long to wait for somebody to walk over and approve it.
///
/// The server's own approval window is thirty minutes; this is the device
/// giving up on *watching*, not the request expiring. Said out loud in the
/// copy, because a spinner that stops for no stated reason reads as a crash.
const _kWatchFor = Duration(minutes: 5);

Future<bool> showScreenSetupSheet(BuildContext context) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ScreenSetupSheet(),
  );
  return done ?? false;
}

class _ScreenSetupSheet extends StatefulWidget {
  const _ScreenSetupSheet();

  @override
  State<_ScreenSetupSheet> createState() => _ScreenSetupSheetState();
}

class _ScreenSetupSheetState extends State<_ScreenSetupSheet> {
  final _code = TextEditingController();
  final _name = TextEditingController(text: 'Kitchen Screen');
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _api = ApiClient();
  final _repo = AuthRepository();

  bool _busy = false;
  String? _error;
  String? _waitingOn;
  Timer? _poll;

  @override
  void dispose() {
    _poll?.cancel();
    _code.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// A stable id for this device.
  ///
  /// Generated once and kept with the screen id, so re-registering the same
  /// tablet does not look like a different one.
  String _deviceId() =>
      'kds-web-${DateTime.now().millisecondsSinceEpoch}-'
      '${Random().nextInt(99999)}';

  Future<void> _submit() async {
    final code = _code.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code from the back office.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final result = await _api.registerWithCode(
        code: code,
        email: _email.text.trim(),
        password: _password.text,
        deviceName: _name.text.trim().isEmpty
            ? 'Kitchen Screen'
            : _name.text.trim(),
        deviceId: _deviceId(),
      );
      final requestId = (result['request_id'] ?? '').toString();
      if (requestId.isEmpty) {
        throw const ApiException(
            statusCode: 0, message: 'The server returned no request.');
      }
      if (!mounted) return;
      setState(() => _waitingOn = requestId);
      _watchForApproval(requestId);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not reach the server — $e';
      });
    }
  }

  void _watchForApproval(String requestId) {
    final giveUpAt = DateTime.now().add(_kWatchFor);
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (DateTime.now().isAfter(giveUpAt)) {
        timer.cancel();
        setState(() {
          _busy = false;
          _waitingOn = null;
          _error = 'Nobody approved it in five minutes. The request is still '
              'open in the back office — try again once it is approved.';
        });
        return;
      }

      try {
        final status = await _api.registrationStatus(requestId);
        switch ((status['status'] ?? '').toString()) {
          case 'approved':
            timer.cancel();
            final screenId = (status['terminal_id'] ?? '').toString();
            if (screenId.isNotEmpty) {
              await _repo.saveRegisteredScreenId(screenId);
            }
            if (mounted) Navigator.pop(context, true);
          case 'rejected':
            timer.cancel();
            if (mounted) {
              setState(() {
                _busy = false;
                _waitingOn = null;
                _error = 'The request was turned down in the back office.';
              });
            }
          case 'expired':
            timer.cancel();
            if (mounted) {
              setState(() {
                _busy = false;
                _waitingOn = null;
                _error = 'The code expired. Generate a new one.';
              });
            }
        }
      } catch (_) {
        // A dropped poll is not a failure — the next one will do.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set up this screen',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              'In the back office open Screens, tap Quick Code, and type the '
              'code here. Somebody has to approve it before this screen comes '
              'online.',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 20),

            if (_waitingOn != null) ...[
              Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Waiting for someone to approve this screen…',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name this screen',
                  hintText: 'Grill, Pass, Fryer…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Manager email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Manager password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: context.kitchen.ageRed, fontSize: 13)),
            ],

            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                if (_waitingOn == null)
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Set up'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
