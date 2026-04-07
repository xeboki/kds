# Xeboki KDS — Feature Implementation List

Benchmarked against: **Toast KDS · Square KDS · Lightspeed · TouchBistro · Aloha/NCR · Oracle MICROS · Revel · Clover**

---

## ✅ Already Implemented

| Feature | Details |
|---|---|
| Real-time order stream | Firestore live updates via `kitchenOrdersStreamProvider` |
| Order cards with items + modifiers | Full modifier display with add / remove / sub / extra / light actions |
| Color-coded age timers | Green → amber (15 min) → red (30 min), configurable thresholds |
| New order visual alert | Pulsing orange banner, 5-second auto-dismiss |
| Bump order | Full order bump to `bumped` status |
| Recall bumped orders | `recalled` status, re-enters active board |
| Priority boost | Normal → High → Urgent, flag icon cycles, persisted to Firestore |
| Allergy banner | Full-width red banner when `allergyInfo` is set |
| Hold & Fire (courses) | Items `courseNumber ≥ 2` held, FIRE button per course group |
| Station routing | Items routed by `stationId`, station filter in header |
| 86'd items | `is86d` flag on `KitchenOrderItem` |
| Grid / Table / Expo views | 3 view modes, persisted via SharedPreferences |
| Configurable columns | 2 / 3 / 4 columns, gear icon bottom sheet |
| Table-consolidated view | Groups orders by table, horizontal scroll per table |
| Expo / pass view | Flat item list with status dots + order/table tags |
| Kitchen ticket printing | ESC/POS chit — table, order #, items, modifiers, course headers, allergy block |
| Special instructions | Per-order and per-item notes displayed on card |
| Cooking preference | `cookingPreference` field (rare / medium / well-done) |
| Station management model | `KitchenStation` with type, color, category routing, printer flag |
| Analytics panel | Ticket time + throughput via `_showAnalytics()` |
| Multi-course model | `courseNumber` on items (1 = Appetiser · 2 = Main · 3 = Dessert) |
| Scheduled order support | `schedulesEndingSoonProvider` — ending-soon banner (30 min window) |

---

## 🔴 P0 — Production Blockers

> Every competing KDS ships these on day one.

### 1. Auto-Bump / Smart Timer
- Configurable per-station auto-bump when countdown expires
- Separate timers per station type (bar faster than grill)
- Visual countdown ring on card before auto-bump fires

### 2. Sound Alerts
- Configurable audio per event: new order, urgent threshold crossed, order bumped
- Per-station volume and sound toggle
- Custom sound profiles (chime, beep, ding)
- "Do Not Disturb" hours with visual-only fallback

### 3. Bump Bar / Hardware Button Support
- Physical bump bar integration via USB HID
- Keyboard shortcut mapping (Space = bump top order, Backspace = recall)
- Configurable key bindings per station

### 4. Reprint Kitchen Ticket
- Reprint button on any active order card
- Auto-reprint when POS modifies a live order
- Reprint count badge so staff see that an item was updated

### 5. Item-Level Bump
- Tap individual item to mark it complete independently of the order
- Auto-bump full order when all items are completed
- Visual strikethrough on completed items within the card

### 6. Order Status Back-Sync to POS
- KDS bump → POS order status updates to `ready`
- All items ready → server notification on POS terminal
- `served` status synced back when expo clears the order

### 7. Void / Cancel Display
- Cancelled items shown with strikethrough and red tint — not silently removed
- Cancelled orders flash briefly then fade out so staff register the change
- Void reason displayed on card

---

## 🟠 P1 — Competitive Parity

### 8. Online Order Integration Display
- Order source badge per card: Dine-In / Takeaway / Delivery / Online / DoorDash / Uber Eats
- Estimated pickup or delivery time countdown on card
- Scheduled orders queue — fires to active board at configured lead time
- Separate "Future Orders" lane pinned to top of board

### 9. Seat-Level Display
- Seat number per item (not just table number)
- Items visually grouped by seat within a card
- Layout: "Seat 1: Burger, Fries  ·  Seat 2: Salad"

### 10. Device Pairing (Location + Station)
- QR-code or PIN pairing of a KDS screen to a specific location and station
- Screen identifier shown in header (e.g. "Grill Station — Main Kitchen")
- Unpaired screen shows setup wizard, not the live board

### 11. Rush Mode
- One-tap "Rush" toggle — pauses auto-bump and highlights all active orders
- Rush duration timer with auto-release
- Visual differentiation of rush-mode cards (pulsing border)

### 12. Filtered Views by Order Type
- Filter chips: All · Dine-In · Takeaway · Delivery · Online
- Filter preference persisted per station

### 13. Item 86 Management (proper flow)
- 86 item from KDS → propagates back to POS as out-of-stock
- 86 count badge (e.g. "3 items 86'd today")
- Un-86 when restock is confirmed

### 14. Recall History Panel
- Slide-in panel showing last N bumped orders (configurable, default 10)
- Search by order number
- One-tap recall from history

### 15. Order Edit Notification
- POS modifies a live order → card pulses and shows "UPDATED" badge
- Diff view: added items in green, removed items in red strikethrough
- Edit timestamp shown on card

### 16. Guest Count Display
- Party size shown on dine-in cards (e.g. "Table 4 — 6 guests")
- Large parties highlighted differently for pacing

---

## 🟡 P2 — Differentiating Features

### 17. Prep Time Targets per Category
- Configure target prep time per product category (e.g. Burgers: 8 min, Salads: 3 min)
- Item timer turns amber when target is exceeded
- Station SLA dashboard shows compliance percentage

### 18. Server Call / Ready Notification
- "Call Server" button on card when order is ready
- Server receives notification on POS terminal
- Customer-facing screen integration (order ready display board)

### 19. Duplicate Item Consolidation
- Same item ordered across multiple tables in a short window → grouped as "×4 Burger" card
- Toggle on/off per station preference

### 20. Shift-Level Analytics Dashboard
- Average ticket time — current shift vs last 7 days
- Orders per hour graph
- Item throughput per station
- Slowest items ranked by prep time
- Peak time heatmap
- Today vs same weekday last week comparison

### 21. Station Staff Assignment
- Staff member clocks in to a station via PIN
- Items show initials of who started prep
- Accountability log: who bumped what and when

### 22. Configurable Card Information Density
- Compact mode — item names and quantity only
- Standard mode — modifiers and instructions
- Expanded mode — full detail with timing bar
- Auto-compact when board exceeds N active orders

### 23. Print-on-Bump
- Auto-print expo ticket when order is bumped to ready
- Configurable per station (expo prints, grill does not)

### 24. Drive-Through / QSR Mode
- Linear FIFO lane view instead of grid
- Target time countdown per order (e.g. "Drive-Through target: 3 min")
- Red overlay when target is exceeded

### 25. Theme Options
- Dark (default for low-light kitchens)
- High-contrast for bright kitchen environments
- Custom accent colour per station (colour-code grill vs bar vs cold prep)

---

## 🔵 P3 — Advanced / Enterprise

### 26. AI Prep Time Prediction
- Model trained on historical prep data per item and time of day
- Dynamic target times based on current queue depth
- "Predicted ready at 14:32" shown on card

### 27. Cross-Station Pacing
- Expo view identifies which station is the bottleneck
- Auto-delay fast stations when a slow station is behind
- Alert: "Hold Desserts — Mains not ready on T7"

### 28. Offline Mode with Local Queue
- SQLite local queue when Firestore connection is lost
- Auto-sync on reconnect with conflict resolution
- Offline indicator banner showing queued order count

### 29. Customer Facing Display (CFD) Integration
- "Order Ready" board driven by KDS bumps
- Customer sees their order number appear when ready
- Branded display with store name and order list

### 30. Catering / Large Order Mode
- Flag orders above N items as catering
- Dedicated catering lane with extended timers
- Batch prep grouping across multiple catering orders

### 31. Webhook / Integration Events
- Events: `order.kitchen.ready` · `order.kitchen.bumped` · `item.86d`
- Connects to third-party delivery platforms (auto-accept on KDS ready)
- Slack / Teams alert for urgent orders exceeding threshold

### 32. KDS Configuration from POS Admin
- Station setup UI in POS Admin (name, type, categories, colour, printer) — model exists, needs screen
- Per-station threshold config (urgent / very-urgent minutes)
- Global KDS settings: auto-bump, sounds, card density

---

## Priority Summary

| Priority | Count | Notes |
|---|---|---|
| ✅ Done | 22 features | Shipped — bump, recall, courses, expo, printing, analytics |
| 🔴 P0 — Production blockers | 7 features | Sound alerts, item-level bump, back-sync, auto-bump |
| 🟠 P1 — Competitive parity | 9 features | Online orders, device pairing, rush mode, 86 flow |
| 🟡 P2 — Differentiating | 9 features | Analytics dashboard, staff assignment, QSR mode |
| 🔵 P3 — Advanced / Enterprise | 7 features | AI prediction, CFD, offline queue, webhooks |

**Start with P0 items 2 (sound alerts), 5 (item-level bump), 6 (back-sync to POS), and 1 (auto-bump)** — these four are the baseline every kitchen operator expects from any KDS on day one.
