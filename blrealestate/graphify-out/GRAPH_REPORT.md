# Graph Report - .  (2026-04-30)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 755 nodes · 868 edges · 34 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 36 edges
2. `package:flutter_riverpod/flutter_riverpod.dart` - 29 edges
3. `../../../core/constants/app_colors.dart` - 21 edges
4. `../../../core/constants/app_strings.dart` - 18 edges
5. `../../../providers/app_providers.dart` - 16 edges
6. `package:flutter/services.dart` - 12 edges
7. `../models/app_models.dart` - 11 edges
8. `../../../core/utils/app_snackbar.dart` - 9 edges
9. `AppDelegate` - 8 edges
10. `../../../core/widgets/premium_widgets.dart` - 8 edges

## Surprising Connections (you probably didn't know these)
- `fl_register_plugins()` --calls--> `my_application_activate()`  [INFERRED]
  linux\flutter\generated_plugin_registrant.cc → linux\runner\my_application.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux\runner\main.cc → linux\runner\my_application.cc
- `RegisterPlugins()` --calls--> `OnCreate()`  [INFERRED]
  windows\flutter\generated_plugin_registrant.cc → windows\runner\flutter_window.cpp
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\runner\win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\runner\win32_window.cpp

## Communities

### Community 0 - "Community 0"
Cohesion: 0.03
Nodes (74): ../../../core/constants/app_strings.dart, ../../../core/utils/date_formatter.dart, ../../../core/utils/price_formatter.dart, ../../../core/widgets/data_refresh_header.dart, ../../../core/widgets/shimmer_loading.dart, build, DealDetailScreen, Icon (+66 more)

### Community 1 - "Community 1"
Cohesion: 0.03
Nodes (67): ../core/api/api_client.dart, ../../../core/constants/app_colors.dart, ../../../core/utils/app_snackbar.dart, ../../../core/utils/responsive_helper.dart, ../../../core/widgets/premium_widgets.dart, build, dispose, GestureDetector (+59 more)

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (58): api_endpoints.dart, api_provider.dart, auth_provider.dart, ../core/api/api_endpoints.dart, core/services/push_notification_service.dart, core/theme/app_theme.dart, ApiClient, clearToken (+50 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (41): ../constants/app_colors.dart, AppColors, background, cardBorder, inputFill, shimmerBase, surface, textPrimary (+33 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (42): build, ClipRRect, Container, dispose, FadeTransition, GlassContainer, initState, PremiumButton (+34 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (33): _AttrRow, _btn, build, _buildSearchAndFilterStrip, Center, _chip, Column, Container (+25 more)

### Community 6 - "Community 6"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 7 - "Community 7"
Cohesion: 0.07
Nodes (26): build, dispose, GestureDetector, initState, _onChanged, _onKeyEvent, _OtpBox, _OtpBoxState (+18 more)

### Community 8 - "Community 8"
Cohesion: 0.07
Nodes (26): build, Card, _divider, _EmptyLeads, _formatDate, GestureDetector, Icon, _infoRow (+18 more)

### Community 9 - "Community 9"
Cohesion: 0.08
Nodes (25): ../../auth/screens/login_screen.dart, build, _buildAppBar, Divider, _ErrorView, GlassContainer, Icon, ListTile (+17 more)

### Community 10 - "Community 10"
Cohesion: 0.08
Nodes (23): AdvancedFilterSheet, _AdvancedFilterSheetState, _apply, build, ChoiceChip, _clear, Column, Container (+15 more)

### Community 11 - "Community 11"
Cohesion: 0.1
Nodes (20): commission_screen.dart, _BottomNav, build, Container, DashboardScreen, Expanded, GestureDetector, LeadListScreen (+12 more)

### Community 12 - "Community 12"
Cohesion: 0.11
Nodes (18): build, _buildAmenityChip, _buildDetailGrid, Column, Container, _detailRow, Icon, InventoryDetailScreen (+10 more)

### Community 13 - "Community 13"
Cohesion: 0.12
Nodes (16): build, _buildFilterSummary, Container, dispose, GestureDetector, _getStatusColor, Icon, initState (+8 more)

### Community 14 - "Community 14"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 15 - "Community 15"
Cohesion: 0.2
Nodes (9): getChildAspectRatio, getCrossAxisCount, getFontSize, getHorizontalPadding, isLargeScreen, isMediumScreen, isSmallScreen, ResponsiveHelper (+1 more)

### Community 16 - "Community 16"
Cohesion: 0.22
Nodes (3): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate

### Community 17 - "Community 17"
Cohesion: 0.22
Nodes (8): CommissionModel, DealModel, _extractPropertyType, InventoryModel, LeadModel, _normalizeName, NotificationModel, TaskModel

### Community 18 - "Community 18"
Cohesion: 0.29
Nodes (6): format, formatCompact, formatFull, formatWithRupee, PriceFormatter, _trim

### Community 19 - "Community 19"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 20 - "Community 20"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 21 - "Community 21"
Cohesion: 0.4
Nodes (2): RunnerTests, XCTestCase

### Community 22 - "Community 22"
Cohesion: 0.4
Nodes (4): ApiEndpoints, holdProperty, leadStatus, taskStatus

### Community 23 - "Community 23"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 24 - "Community 24"
Cohesion: 0.5
Nodes (3): PropertyCategoryNode, PropertyHierarchy, PropertyTypeNode

### Community 25 - "Community 25"
Cohesion: 0.5
Nodes (3): DateFormatter, format, formatWithTime

### Community 26 - "Community 26"
Cohesion: 0.67
Nodes (3): Channel Partner API Checker Hits every known + missing endpoint and reports exa, run(), status_color()

### Community 28 - "Community 28"
Cohesion: 0.5
Nodes (2): fetch_data(), Fetch latest inventory data from API

### Community 29 - "Community 29"
Cohesion: 0.67
Nodes (2): extract_type(), normalize()

### Community 30 - "Community 30"
Cohesion: 0.67
Nodes (1): GeneratedPluginRegistrant

### Community 31 - "Community 31"
Cohesion: 0.67
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 32 - "Community 32"
Cohesion: 0.67
Nodes (2): FlutterSceneDelegate, SceneDelegate

### Community 37 - "Community 37"
Cohesion: 1.0
Nodes (1): MainActivity

### Community 38 - "Community 38"
Cohesion: 1.0
Nodes (1): AppStrings

## Knowledge Gaps
- **472 isolated node(s):** `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `DefaultFirebaseOptions`, `UnsupportedError` (+467 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 21`** (5 nodes): `RunnerTests.swift`, `RunnerTests.swift`, `RunnerTests`, `.testExample()`, `XCTestCase`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 23`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 28`** (4 nodes): `analyze_counts()`, `fetch_data()`, `get_inventory_counts.py`, `Fetch latest inventory data from API`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 29`** (4 nodes): `extract_type()`, `normalize()`, `trace_types.py`, `req()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (3 nodes): `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant`, `.registerWith()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (3 nodes): `GeneratedPluginRegistrant.m`, `GeneratedPluginRegistrant`, `-registerWithRegistry`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (3 nodes): `FlutterSceneDelegate`, `SceneDelegate.swift`, `SceneDelegate`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 37`** (2 nodes): `MainActivity.kt`, `MainActivity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 38`** (2 nodes): `AppStrings`, `app_strings.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 3` to `Community 0`, `Community 1`, `Community 2`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 15`?**
  _High betweenness centrality (0.177) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 1` to `Community 0`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Why does `../../../core/constants/app_colors.dart` connect `Community 1` to `Community 0`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **What connects `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _472 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._