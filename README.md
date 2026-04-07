<p align="center">
  <img src="assets/images/xe_logo.svg" alt="Xeboki" width="120" />
</p>

<h1 align="center">Xeboki KDS</h1>

<p align="center">
  Real-time kitchen display system for <a href="https://xeboki.com/xe-pos">Xeboki POS</a> subscribers.<br/>
  Live orders on every kitchen screen — zero wiring, zero polling, zero config.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey" />
  <img src="https://img.shields.io/badge/License-Xeboki%20Subscriber-6366F1" />
</p>

---

## What is this?

A production-ready kitchen display system that connects directly to your **Xeboki POS** in real time. Deploy it on any Android tablet, iPad, or browser-based kitchen screen. Orders appear the moment they are placed at the POS — no polling, no refresh, no printer tickets required.

**What kitchen staff see:**
- Live order cards with items, modifiers, cooking preferences, and special instructions
- Color-coded age timers: green → amber (15 min) → red (30 min)
- Pulsing NEW ORDER alert banner on each incoming ticket
- Priority flags (Normal / High / Urgent) per order card
- Full-width allergy banner when allergen info is set
- Hold & Fire — course 1 items are live, courses 2+ are held until fired
- Station routing — each KDS screen can be pinned to a specific kitchen station

**Three view modes (all persisted per device):**

| Mode | Best for |
|------|----------|
| Grid | Standard kitchen boards — 2 to 5 configurable columns |
| Table View | Full-service restaurants — orders grouped and scrollable per table |
| Expo / Pass | Expo station — flat item list across all active orders with status dots |

**Order actions:**
- Bump order → status moves to `bumped`, order leaves active board
- Recall bumped order → status moves to `recalled`, order returns to board
- Fire course → releases held items to the active preparation queue
- Priority boost → cycles Normal → High → Urgent, persisted to Firestore
- Kitchen ticket print → ESC/POS chit with table, order number, items, modifiers, course headers, and allergy block

---

## Requirements

| | |
|---|---|
| **Xeboki POS subscription** | **Paid plan required.** Free plan accounts are blocked at login — both client-side and server-side. |
| Flutter SDK | ≥ 3.22 — [install guide](https://docs.flutter.dev/get-started/install) |
| Xeboki POS staff credentials | Any active staff account on the subscriber's POS |
| Android tablet / iPad / browser | Landscape orientation (enforced by the app) |

No API key file. No Firebase config file. No `google-services.json`. The KDS receives its entire configuration (including Firebase credentials) from the POS API at login.

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/xeboki/kds.git
cd kds

# 2. Run on a connected tablet (development)
flutter run --dart-define=XEBOKI_API_URL=http://your-pos-api:8002

# 3. Build Android APK for a kitchen tablet
flutter build apk --release \
  --dart-define=XEBOKI_API_URL=https://api.xeboki.com \
  --dart-define=XEBOKI_ENV=production
```

On first launch, staff enter their regular **Xeboki POS email and password**. The app fetches the location list, Firebase config, and subscription status from the API and initialises the Firestore listener automatically.

The session is persisted to `SharedPreferences` — the tablet reconnects automatically on every restart without requiring staff to log in again.

---

## Configuration

The only build-time setting is the API URL:

```bash
--dart-define=XEBOKI_API_URL=https://your-api-host
--dart-define=XEBOKI_ENV=production   # optional, defaults to development
```

Everything else — Firebase project, locations, station assignment, column count, view mode — is set at runtime.

### VS Code

Four run configurations are pre-configured in `.vscode/launch.json`:

| Configuration | Use |
|---|---|
| Xeboki KDS (dev) | Daily development against localhost API |
| Xeboki KDS (profile) | Performance profiling |
| Xeboki KDS (release) | Release mode on device |
| Xeboki KDS (web) | Chrome / browser kitchen screen |

---

## Login Flow

The KDS uses staff email + password — no separate API key is needed:

```
Staff enters email + password
       ↓
POST /login → POS API validates credentials
       ↓
Response includes: JWT · Firebase custom token · Firebase project config
       ↓
KDS initialises Firebase dynamically (no google-services.json)
       ↓
Firestore listener streams kitchen_orders in real time
```

The session (JWT + Firebase config) is persisted locally. On the next cold start the tablet re-initialises Firebase from the stored config and resumes the live stream with no staff interaction.

---

## Subscription Gate

Subscription is validated at login and enforced server-side. Free-plan and inactive accounts are shown a blocking screen — staff cannot access the live board. Plan changes take effect immediately.

To upgrade: sign in to the **Xeboki Manager app** or visit [xeboki.com/xe-pos](https://xeboki.com/xe-pos). After upgrading, sign out of the KDS and sign back in to activate.

---

## Station Routing

Each KDS screen can be pinned to a named kitchen station (Grill, Cold Prep, Bar, etc.). When a station is set, the board shows only orders that contain items routed to that station. Items with no station assignment appear on all screens.

Station assignment is set in the app header after login. The selected station is persisted via `SharedPreferences` and survives app restarts.

---

## Kitchen Ticket Printing

The KDS prints ESC/POS tickets to any network or Bluetooth kitchen printer configured in the POS. Tickets include:

- Table number and order number
- All items with quantities and modifiers
- Course group headers (Appetiser / Main / Dessert)
- Priority banner for Urgent orders
- Full allergy information block

Configure printers from the **Xeboki POS Manager → Printing**.

---

## Building

```bash
# Android APK (sideload / direct install on tablet)
flutter build apk --release \
  --dart-define=XEBOKI_API_URL=https://api.xeboki.com \
  --dart-define=XEBOKI_ENV=production

# Android AAB (Google Play)
flutter build appbundle --release \
  --dart-define=XEBOKI_API_URL=https://api.xeboki.com \
  --dart-define=XEBOKI_ENV=production

# iOS (macOS + Xcode required)
flutter build ios --release \
  --dart-define=XEBOKI_API_URL=https://api.xeboki.com \
  --dart-define=XEBOKI_ENV=production

# Web (browser-based kitchen screen)
flutter build web --release \
  --dart-define=XEBOKI_API_URL=https://api.xeboki.com \
  --dart-define=XEBOKI_ENV=production
```

Change your **App ID / Bundle ID** before distributing:
- Android: `android/app/build.gradle.kts` → `applicationId`
- iOS: Xcode → Runner target → Bundle Identifier

---

## Project Structure

```
kds/
├── assets/
│   ├── images/xe_logo.svg           ← Xeboki brand logo
│   └── audio/                       ← Alert sounds
│
└── lib/
    ├── main.dart                     ← App entry, landscape lock, Firebase placeholder init
    ├── router/
    │   └── app_router.dart           ← GoRouter: /login · /subscription-gate · /kds
    │
    ├── core/
    │   ├── config/app_config.dart    ← Build-time constants (API URL, env)
    │   ├── models/firebase_config.dart
    │   ├── providers/app_providers.dart
    │   ├── services/
    │   │   ├── api_client.dart       ← HTTP client (POST /login, GET /sync/business-config)
    │   │   └── firebase_init_service.dart ← Dynamic Firebase initialisation from login response
    │   └── theme/app_theme.dart      ← Dark theme (Xeboki indigo + traffic-light age colours)
    │
    └── features/
        ├── auth/
        │   ├── data/auth_repository.dart         ← Login, session persist/restore, logout
        │   ├── domain/models/kds_session.dart     ← Session model (JWT, Firebase config, subscription)
        │   └── presentation/
        │       ├── providers/auth_providers.dart  ← sessionProvider, authStatusProvider
        │       └── screens/
        │           ├── login_screen.dart          ← Staff email + password login
        │           └── subscription_gate_screen.dart ← Free-plan blocking screen
        │
        └── kds/
            ├── data/repositories/
            │   └── kitchen_repository_firestore.dart ← Firestore CRUD for kitchen orders
            ├── domain/
            │   ├── models/kitchen_order.dart      ← Freezed model (order + items + status)
            │   └── repositories/kitchen_repository.dart
            └── presentation/
                ├── providers/kitchen_providers.dart ← kitchenOrdersProvider, columnCountProvider, viewModeProvider
                ├── screens/kds_screen.dart          ← Main board (Grid / Table / Expo views)
                └── widgets/
                    ├── order_card.dart              ← Per-order card with bump, recall, priority, fire
                    ├── item_tile.dart               ← Per-item row with modifiers and status
                    └── timer_badge.dart             ← Elapsed time with traffic-light colour
```

---

## Full Feature List

See **[FEATURES.md](FEATURES.md)** for the complete breakdown of implemented features and the P0–P3 roadmap benchmarked against Toast, Square, Lightspeed, and other commercial KDS systems.

---

## Support

- **Subscription & billing:** [xeboki.com/xe-pos](https://xeboki.com/xe-pos)
- **Technical issues:** [Open an issue](https://github.com/xeboki/kds/issues)
- **POS Manager:** [pos.xeboki.com](https://pos.xeboki.com)
- **Developer docs:** [docs.xeboki.com](https://docs.xeboki.com)
