# Plot View Screen — Wireframe & Implementation Plan

---

## Entry Point

`dashboard_screen.dart` → `_buildTabBar()` row gets a **"Plot View →"** text button on the right side.

```
┌─────────────────────────────────────────────────────┐
│  [ Inventory ]  [ Commissions ]  [ Tasks ]  Plot View→│
└─────────────────────────────────────────────────────┘
```

Tapping "Plot View →" pushes `PlotViewScreen` via `Navigator.push`.

---

## Screen: PlotViewScreen

### Full Wireframe

```
┌─────────────────────────────────────────────────────┐
│ ←   Plot View                                        │  ← AppBar
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Category ▼    Subcategory ▼    Project ▼   City ▼  │  ← Filter Row (4 dropdowns)
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  ● Available   ● Hold   ● Sold          87 plots     │  ← Legend + count
└─────────────────────────────────────────────────────┘

┌──────────┐ ┌──────────┐ ┌──────────┐
│  A 22    │ │  A 23    │ │  A 24    │
│ 153 sqyd │ │ 153 sqyd │ │ 153 sqyd │
│ ● Active │ │ ● Hold   │ │ ● Active │
└──────────┘ └──────────┘ └──────────┘
┌──────────┐ ┌──────────┐ ┌──────────┐
│  A 25    │ │  A 26    │ │  A 27    │
│ 153 sqyd │ │ 153 sqyd │ │ 153 sqyd │
│ ● Active │ │ ● Sold   │ │ ● Active │
└──────────┘ └──────────┘ └──────────┘
  ... (GridView, 3 columns, scrollable)

┌─────────────────────────────────────────────────────┐
│  ← Previous          Page 1 of 4          Next →    │  ← Pagination (30 per page)
└─────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [Plot image if available]   Plot A 22        ● Active
                              Size: 153 sqyd
                              Price: ₹12,876
                              Facing: West
                              Road Width: 9M
                              Corner: No
                              ┌──────────────────────┐
                              │   Hold This Unit     │
                              └──────────────────────┘
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    ↑ Bottom Sheet (slides up on tile tap)
```

---

## Filter Dropdowns — Data Source

```
GET /categories  →  categoriesProvider  (new, simple AsyncNotifier)

Level 1 — Category:     Plots / Farmhouses / Flats-Housing / Agricultural Land / Township / Society
Level 2 — Subcategory:  children of selected L1  (e.g. Plots → Residential, Commercial, Industrial)
Level 3 — Project:      children of selected L2  (e.g. Residential → Raja Ram Aero City)
Level 4 — City:         unique cities from filtered inventory items (normalized lowercase)

Cascade rule:
  Select Category   → reset Subcategory, Project, City
  Select Subcategory → reset Project, City
  Select Project    → reset City
  Select City       → no reset
```

---

## Grid Tile Colors — from AppColors (no hardcoding)

```
ACTIVE  →  AppColors.plotActive   (green tint background)
HOLD    →  AppColors.plotHold     (orange tint background)
SOLD    →  AppColors.plotSold     (red tint background)
TAPPED  →  AppColors.primary tint (blue, selected state)
```

---

## Pagination

- Page size: **30 plots per page** (client-side slice of filtered list)
- Previous / Next buttons at bottom
- Shows "Page X of Y" and total count
- Resets to page 1 when any filter changes

---

## Bottom Sheet (on tile tap)

```
┌─────────────────────────────────────────────────────┐
│  ▬▬▬  (drag handle)                                  │
│                                                      │
│  [image]    Plot A 22              ● ACTIVE          │
│             153 sqyd  |  ₹12,876                     │
│  ─────────────────────────────────────────────────  │
│  Plot Number      A 22                               │
│  Plot Size        153 sqyd                           │
│  Length & Width   62ft × 24ft                        │
│  Facing           West                               │
│  Corner Plot      No                                 │
│  Road Width       9M                                 │
│  Gated            Yes                                │
│  Approval         In Process                         │
│  ─────────────────────────────────────────────────  │
│  [ Hold This Unit ]   ← disabled + lock if HOLD/SOLD │
└─────────────────────────────────────────────────────┘
```

- Rendered as `DraggableScrollableSheet` (same pattern as lead detail)
- "Hold This Unit" → `Navigator.push(HoldPropertyScreen)` → on pop, `inventoryProvider.invalidateSelf()` → grid auto-updates

---

## New Files

```
lib/features/dashboard/screens/plot_view_screen.dart   ← main screen + grid + bottom sheet
lib/providers/categories_provider.dart                 ← GET /categories, simple cache
```

---

## Changes to Existing Files

| File | Change |
|------|--------|
| `lib/core/constants/app_colors.dart` | Add `plotActive`, `plotHold`, `plotSold` colors |
| `lib/core/constants/app_strings.dart` | Add `plotView`, `choosePlots`, `available`, `hold`, `sold`, `noPlots` strings |
| `lib/core/api/api_endpoints.dart` | Add `static const categories = '/categories'` |
| `lib/models/app_models.dart` | Parse `sub_subcategory` object + `subcategory_id`, `sub_subcategory_id` fields |
| `lib/features/dashboard/screens/dashboard_screen.dart` | Add "Plot View →" button next to tab bar |

---

## Data Flow

```
App start
  └─ inventoryProvider loads 130 items (already done)
  └─ categoriesProvider loads /categories tree (new, one-time fetch)

User opens Plot View
  └─ PlotViewScreen reads both providers
  └─ Default: no filter selected → show all 130 items page 1

User selects Category = "Plots"
  └─ Filter inventory where category_id == 37
  └─ Subcategory dropdown shows: Commercial, Residential, Industrial

User selects Subcategory = "Residential"
  └─ Filter inventory where subcategory_id == 44
  └─ Project dropdown shows: Raja Ram Aero City

User selects Project = "Raja Ram Aero City"
  └─ Filter inventory where sub_subcategory_id == 57
  └─ Result: ~87 plots → paginate 30 per page → 3 pages

User taps a tile
  └─ Bottom sheet slides up with full plot details
  └─ Hold button → HoldPropertyScreen
  └─ On return → inventoryProvider already invalidated → tile color updates
```

---

## AppColors to Add

```dart
static const plotActive = Color(0xFF4CAF50);   // green
static const plotHold   = Color(0xFFFF9800);   // orange
static const plotSold   = Color(0xFFF44336);   // red
// tile background = color.withValues(alpha: 0.12)
// tile border     = color.withValues(alpha: 0.4)
// tile text       = color (dark enough to read)
```

---

## AppStrings to Add

```dart
static const plotView      = 'Plot View';
static const choosePlots   = 'Choose Plots';
static const available     = 'Available';
static const plotHoldLabel = 'Hold';
static const soldLabel     = 'Sold';
static const allCategories = 'All Categories';
static const noPlots       = 'No plots match the selected filters.';
static const plotViewBtn   = 'Plot View →';
```

---

## Summary: What to Build

1. `AppColors` — 3 new colors
2. `AppStrings` — 7 new strings
3. `ApiEndpoints` — 1 new endpoint
4. `InventoryModel` — parse `sub_subcategory`, `subcategory_id`, `sub_subcategory_id`
5. `categories_provider.dart` — fetch + cache `/categories` tree
6. `plot_view_screen.dart` — full screen with filters + grid + pagination + bottom sheet
7. `dashboard_screen.dart` — add "Plot View →" entry point
