# Universal Rules — Flutter (Riverpod + Dio) Frontend Audit

> Phase-gated audit: **each phase must pass before moving to the next.**  
> Grep alone is not enough — every rule requires reading the surrounding context.

---

## Phase 0 — AI Agent Directives (MANDATORY STARTING POINT)

- **Maintain State:** You MUST create a `todo_audit.md` artifact to track which files you have audited. Do not rely on your conversational memory.
- **Tool Strictness:** You MUST use exact search tools (like `grep_search`) to find violations across the codebase before making assumptions.
- **Cold Import Tracing:** Before auditing a file's logic, trace every imported symbol and destructured variable to ensure it is actually used.

---

## Phase 0.1 — Consistency Protocol (Every AI Model Must Follow Identical Steps)

> **Purpose:** Claude reads semantically. ChatGPT reads structurally. Without this forced mechanical process, different AI models find different bugs. This protocol forces every AI to use identical steps, producing identical results.

For **every single file**, follow this exact sequence in order:

1. **Run Grep First:** Before opening the file, run global grep commands scoped to that file (e.g., checking for raw `Colors.` usage). Record the exact output.
2. **Read Import Block:** Open the file. For each imported symbol, run `grep_search` to confirm it is referenced at least once in the file body. Flag dead imports.
3. **Read Each Widget/Class Top-to-Bottom:** 
   - Every `Padding`/`Text`/`SizedBox`: verify it uses `const` where possible.
   - Every `build` method: verify no business logic or API calls exist inside.
   - Every `onPressed`: verify it delegates to a Riverpod notifier.
4. **Record Findings Only After Tool Verification:** Do not write a bug report line until you have tool-verified it (see Phase 0.2).

---

## Phase 0.2 — Bug Verification Protocol (Zero Hallucination Policy)

> **Purpose:** Prevent AI from reporting hallucinated bugs based on assumptions rather than actual code content.

**A bug CANNOT be reported unless ALL THREE conditions are met:**

**Condition 1 — Tool Proof:**
You must have run a `view_file` or `grep_search` call and seen the violating code in your own tool output. You cannot report a bug from memory or pattern inference.

**Condition 2 — Rule Citation:**
You must cite the exact rule number and name from this document (e.g., `Rule 1.1 — The const Guarantee`).

**Condition 3 — Exact Line Quote:**
You must write the exact violating line of code. `"Line 47: color: Colors.red"`. "Around line 47" is NOT accepted.

### Mandatory Bug Report Format
Every reported bug MUST use this exact format. Incomplete reports are rejected:
```
BUG #[N]
File:            lib/screens/home/home_screen.dart
Line:            47
Violating Code:  color: Colors.red
Rule Violated:   Rule 4.1 — Zero Hardcoded Colors
Tool Used:       view_file (lines 44–50)
Severity:        HIGH | MEDIUM | LOW
```

---

## Phase 0.3 — Optimization & Trade-off Protocol

> **Purpose:** The AI must separate strict rule violations (bugs) from architectural optimizations (suggestions). The AI must never rewrite architecture just to be "smart."

**1. Explicit Perfection Affirmation**
If a file strictly passes all phases, explicitly state: *"This module is 100% optimized and rule-compliant. No architectural updates needed."* Do not invent unnecessary improvements.

**2. Mandatory Optimization Proposal Format**
If suggesting an architectural change, use this format:

```markdown
### OPTIMIZATION PROPOSAL: [Pattern Name]
**Where it is needed:** [List specific files or folders]
**The Concept:** [1-2 sentences explaining the idea]

**Impact Before:** [Current state description]
**Impact After Fix:** [Future state description]
**Performance Impact:** [FPS / Rebuild differences]
**Code Quality:** [Maintainability / Cleanliness gains]
**What We Lose (Cons/Risks):** [Trade-offs, boilerplate added, etc.]
```

**3. Flutter Modernization Targets Checklist**
Aggressively hunt for the following and suggest them using the proposal format:
- **Widget Tree Flattening:** Identify deeply nested `Column`/`Row`/`Container` blocks and suggest extracting them or flattening them.
- **Provider Scoping:** Look for globally scoped Riverpod providers that manage UI state. Suggest locally scoping them via `ProviderScope(overrides:)`.
- **List Optimization:** Look for standard `ListView` or `Column` used for large lists and suggest converting to `ListView.builder` or `SliverList` for memory performance.

---

## Phase 1 — Widget Tree & Performance Strictness

Gate: **All Phase 0 checks must pass.**

### 1.1 The `const` Guarantee
- Every stateless widget, padding, sized box, and text widget MUST use the `const` keyword if its properties are immutable.
- This tells the Flutter engine to skip rebuilding this node, preventing 60fps frame drops.
- A missing `const` on an immutable widget is a MEDIUM severity bug.

### 1.2 Build Method Discipline
- No `build` method can exceed 50-70 lines.
- If it does, extract complex nested trees into their own separate widget classes.
- **Forbidden:** Do not extract UI into helper methods within the same class (e.g., `Widget _buildHeader()`). Always extract into proper Flutter widget classes (`class HeaderWidget extends StatelessWidget`). Helper methods defeat Flutter's widget caching mechanism.

### 1.3 `setState` Usage Restriction
- Since Riverpod is used, `StatefulWidget` and `setState` should be avoided for global, complex, or API-driven state.
- Exception: Highly localized, ephemeral UI state (e.g., a simple button hover effect, a local text field controller) may use `StatefulWidget` or `flutter_hooks`.

---

## Phase 2 — State Management (Riverpod) Discipline

Gate: **All Phase 1 checks must pass.**

### 2.1 No Business Logic in UI
- A widget's `build` method or `onPressed`/`onTap` callbacks must NEVER contain `if/else` business logic, complex data transformations, or raw API calls.
- UI callbacks must only trigger intents: e.g., `ref.read(authProvider.notifier).login(email, password)`.

### 2.2 `ref.watch` vs `ref.read` Discipline
- Inside the `build` method, you MUST use `ref.watch()` to reactively listen to state changes.
- Inside callbacks (`onPressed`, `onTap`, `initState`), you MUST use `ref.read()`.
- **CRITICAL VIOLATION:** Using `ref.watch()` inside a callback function. This will cause memory leaks or unexpected provider behaviors.

### 2.3 Exhaustive AsyncValue Handling
- Every Riverpod `AsyncValue` must explicitly handle all states using `.when()` or `.map()`.
- Example:
  ```dart
  providerState.when(
    data: (data) => _buildUI(data),
    loading: () => const CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
  )
  ```
- Blank loading screens or silently swallowed errors are a CRITICAL violation.

### 2.4 Code Generation over Legacy Providers
- In 2026, manually writing `final provider = StateNotifierProvider(...)` is considered legacy and prone to memory leaks.
- You MUST enforce the use of `@riverpod` annotations and `riverpod_generator`.
- Any usage of `StateNotifier` or `ChangeNotifier` must be flagged as a HIGH severity architectural bug. Enforce the use of modern `Notifier` and `AsyncNotifier`.

### 2.5 Strict Linting (`riverpod_lint`)
- The project must use `riverpod_lint` to prevent "stale notifier references" and improper state caching.
- If `riverpod_lint` is missing from `pubspec.yaml` or `analysis_options.yaml`, flag it as a configuration bug.

---

## Phase 3 — The API & Network Layer (Dio + Models)

Gate: **All Phase 2 checks must pass.**

### 3.1 The Model Contract (Safe Null Fallbacks)
- Dart models must strictly handle `null` payloads from the backend.
- If the backend (Strapi) can send a null boolean, the model must parse it safely: `isActive: json['is_active'] ?? false`.
- If the backend sends a null array, parse it as an empty list: `items: json['items'] ?? []`.
- Never trust the backend perfectly; frontend parsing crashes are fatal to user experience.

### 3.2 No Raw Dio/HTTP in UI or Notifiers
- A widget or a Riverpod Notifier must NEVER import `dio` or execute raw `dio.get()` calls directly.
- All network calls must be executed inside a strictly typed `Repository` or `Service` class.
- The flow MUST be: UI -> Notifier -> Repository -> Dio.

### 3.3 Centralized Error Catching
- Network exceptions (e.g., `SocketException`, `DioException`, 401 Unauthorized) must be caught in a centralized interceptor or within the Repository layer.
- The Repository must return standardized error objects (e.g., using `fpdart` Either, or custom Result classes) that the Notifier can cleanly translate into UI error states.

### 3.4 Strict Dio Interceptors (No Token Logic in Services)
- Manually injecting Bearer tokens or handling 401 token refreshes inside individual `service/` files is strictly forbidden.
- All Auth tokens, Token Refreshes, and network logging MUST be handled globally by a centralized `DioInterceptor` inside `lib/core/`.
- Flag any `service/` file that manually sets `Authorization: Bearer`.

### 3.5 Type-Safe API Generation (Retrofit)
- Manual JSON mapping and writing raw HTTP paths (`dio.get('/users')`) inside services is error-prone.
- The 2026 standard mandates the use of `retrofit` for Dio.
- AI should enforce the use of `@RestApi()` annotations and generated `.g.dart` files for the API client to guarantee type safety between the frontend and the `api.md` spec.

---

## Phase 4 — Modern Theming & Centralization (Zero Hardcodings)

Gate: **All Phase 3 checks must pass.**

### 4.1 Zero Hardcoded Colors & Typography
- Absolutely no hardcoded colors like `Color(0xFFE2E2E2)` or `Colors.red` inside UI widgets.
- No raw `TextStyle(fontSize: 16, fontWeight: FontWeight.bold)` inside widgets.
- The app MUST fully support **Light & Dark Mode**. Every color and text style MUST be pulled dynamically from the theme: `Theme.of(context).colorScheme.primary` and `Theme.of(context).textTheme.bodyLarge`.

### 4.2 Centralized Assets & Strings (0 Hardcodings)
- **Strings:** Never hardcode UI text (`Text('Welcome')`). All UI text must come from an `AppStrings` class or localization file.
- **Errors:** Never hardcode error messages in services or UI. They must come from an `ErrorStrings` class.
- **Images/Icons:** Never use raw asset paths (`Image.asset('assets/logo.png')`). All assets must be referenced through an `AppAssets` constant class (e.g., `Image.asset(AppAssets.logo)`).

### 4.3 Mandatory "Description + Why" Comment Format
- Every Repository method, Riverpod Provider, and complex Core Widget MUST have a comment block above it.
- It must be written in easy-to-understand language so anyone in 5 years can understand what it does.
- The "Why" (business context) is strictly required.
```dart
// Description: Fetches the paginated list of chat messages from the Strapi API.
// Why: The chat screen uses this to display history; paginated to save device memory.
Future<List<Message>> fetchMessages() async { ... }
```

---

## Phase 5 — Holistic Audit & Architecture

Gate: **All Phase 4 checks must pass.**

### 5.0 Strict Directory Structure Enforcement
The `lib/` folder must strictly adhere to the following separation of concerns. If a file is in the wrong place, it is a structural bug:
- `core/`: Global configurations, theme, Dio network setup, Firebase init, `AppStrings`, `AppAssets`, routing.
- `model/`: Plain Dart data classes for JSON parsing (must match `api.md`).
- `service/` / `repository/`: Dio network calls and Firebase logic. Absolutely no UI code here.
- `provider/`: Riverpod Notifiers and State definitions.
- `screens/`: Entire page layouts.
- `widgets/`: Reusable, isolated UI components used across screens.

### 5.1 Dead Code & Magic Strings
- Find and remove unused imports, dead parameters, and empty classes.
- No magic strings for route names (`Navigator.pushNamed(context, '/home')`). Use a `Routes` constant class or type-safe routing (like `go_router`).

### 5.2 Clean Log Output
- `print()` is strictly forbidden in production code. Use a logging package (like `logger` or `talker`).
- Log strings must be plain text. Emojis (`✅`, `❌`) break log aggregators like Datadog/Sentry and are forbidden in log messages.

### 5.3 Scaffold / Todo Comment Cleanup
- Delete `// TODO:`, `// Fix this later`, or `// (Step 3)` comments unless they are attached to an active Jira/GitHub issue number. Comments should explain the final code, not the development journey.

---

## Phase 6 — Holistic Audit (The Manager Way)

Gate: **All Phase 5 checks must pass.**

This is the final pass — a ruthless, line-by-line interrogation of every remaining file. Do not rely on grep. Read every line.

### 6.1 Existence Justification
- Why does this Widget or Function exist? What UI/business problem does it solve?
- If you can't answer in one sentence, or if it is a widget that merely wraps a single child without adding any meaningful padding, styling, or logic → inline it and delete the class.

### 6.2 Guard Clause Discipline
- If you have 40 lines of UI logic nested inside an `if (isDataReady)` block → flip it, use an early return `if (!isDataReady) return const LoadingWidget();`, and flatten the main widget tree.
- Reduce nesting depth in `build` methods wherever possible.

### 6.3 Bloated Conditionals
- `if/else if/else if` chains with 4+ branches inside a `build` method (e.g., returning different icons based on a string) → should be converted to a `Map<String, IconData>` lookup to keep the widget tree clean.

### 6.4 Wrapper Widgets That Add Nothing
- Does this custom widget just return a `Container(child: child)` with no decoration or constraints?
- Inline it at the call site and remove the wrapper widget to save the Flutter framework an unnecessary element in the tree.

### 6.5 The "Extract to Widget" Fallacy Check
- Did the developer extract a 3-line widget into a separate class, resulting in more boilerplate than actual UI code?
- If an extracted widget is only used exactly once and has virtually no complex logic, inline it back into its parent unless the parent's `build` method is approaching the 50-line limit. Over-abstraction hurts readability just as much as under-abstraction.

---

## Phase 7 — Elite Flutter Gotchas (Side Effects & Dirty Architecture)

Gate: **All Phase 6 checks must pass.**

Flutter allows developers to write dirty "hacks" to bypass framework limitations. The AI must aggressively hunt for these anti-patterns and flag them as CRITICAL architectural bugs.

### 7.1 The "Post Frame" Dirty Hack
- **Violation:** `WidgetsBinding.instance.addPostFrameCallback((_) { ... })` or `Future.microtask(...)` used inside a `build()` method.
- **Why:** Developers use this to trigger state changes during a build phase because they mapped their Riverpod state incorrectly. This is a severe architectural flaw. State changes should be triggered by user intents (onPressed) or Provider initialization, NEVER as a side-effect of rendering the UI.

### 7.2 Global Variable Pollution
- **Violation:** Variables or functions floating outside of a class declaration (e.g., `bool isGlobalLoading = false;` at the top of a file).
- **Why:** Dart allows top-level variables, but in Flutter, this causes untrackable state mutations and breaks Hot Reload. All state MUST live inside Riverpod Notifiers.

### 7.3 BuildContext Across Async Gaps
- **Violation:** Using `context.read()`, `Navigator.of(context)`, or `Theme.of(context)` after an `await` without checking if the widget is still mounted.
- **Why:** If the user closes the screen while the API call is in flight, accessing the context will crash the app.
- **Fix:** AI must enforce `if (!context.mounted) return;` immediately after any `await` before touching the `BuildContext`.

### 7.4 Controller/Listener Memory Leaks
- **Violation:** A `StatefulWidget` or `flutter_hooks` widget creates a `TextEditingController`, `ScrollController`, or `FocusNode` but does not explicitly `dispose()` of it.
- **Why:** This is the #1 cause of silent memory leaks that eventually crash Flutter apps on low-RAM devices.

### 7.5 Unawaited Futures in Repositories
- **Violation:** Calling an async function (e.g., `analytics.logEvent()`) without `await` or `unawaited()` wrapper.
- **Why:** Swallows errors silently and causes unpredictable execution order.
# Project Rules: Fabrix

This document outlines the core principles and development standards for the **Fabrix** project. All contributors must adhere to these rules to maintain high quality and consistency.

## 1. Core Principles
- **Simple, Clean & Minimal**: Keep the codebase and UI/UX straightforward.
- **No Over-engineering**: Avoid complex abstractions where simple solutions suffice.
- **No Complex or Bloated Code**: Prioritize readability over cleverness.
- **Fast & Smooth**: Target 120Hz performance. Smooth transitions are non-negotiable.

## 2. Architecture & Patterns
- **Clean Architecture**: Maintain a clear separation of concerns.
- **Centralized Core**: All shared utilities, themes, and services must reside in the `lib/core` folder.
- **Riverpod**: Use Riverpod for state management. Follow best practices for provider scoping.
- **Lazy Loading**: Implement lazy loading for all lists and heavy assets to ensure responsiveness.

## 3. UI/UX Standards
- **Zero UI Breaks**: Use loaders/spinners for every asynchronous operation.
- **Shimmer Effects**: Use Shimmers for content loading states to improve perceived performance.
- **Theme Support**: Full support for both **Light** and **Dark** modes from day one.
- **Aesthetic Excellence**: Follow the wireframes and design guidelines strictly.

## 4. Development Constraints
- **0 Hardcoding Tolerance**: All strings, colors, dimensions, and API endpoints must be centralized in constants or theme files.
- **Dummy Data First**: Right now, the app is a dummy version for client demonstration. Focus on high-fidelity UI and smooth flow.

## 5. Performance
- **120Hz Ready**: Optimize widget builds and animations to maintain a high refresh rate.
- **Efficient Builds**: Use `const` constructors wherever possible and avoid unnecessary rebuilds.

---
*Failure to follow these rules will require refactoring before any PR is merged.*
