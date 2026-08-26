# AI Usage & Architectural Decision Log

> **Philosophy**: AI was utilized as a high-speed pair programmer for scaffolding, refactoring exploration, and boilerplate reduction. Every architectural decision, business logic verification, error-handling strategy, and trade-off acceptance/rejection was independently determined, reviewed, and finalized.

---

## Executive Summary of Engineering Choices

| Feature / Domain | AI Initial Proposal | Final Architectural Decision | Primary Reason / Engineering Trade-off |
| :--- | :--- | :--- | :--- |
| **Architecture** | Feature-first Clean Architecture | Clean Architecture with Pragmatic Seams | Preserved strict layer boundaries (Data/Domain/Presentation) without bloat. |
| **State Management** | Single Global BLoC | `RatesListBloc` + Short-lived `RateDetailBloc` | Domain-driven BLoC separation; isolated lifecycle for 7-day history fetches. |
| **Error Handling** | Generic `try/catch` with `ServerException` | Sealed `AppException` + `ResultGuard` + `Either` | Clean boundary mapping (Dio isolated) and fully actionable failure categorization. |
| **Connectivity** | `connectivity_plus` package | `internet_connection_checker_plus` behind `NetworkInfo` | Prevented false-positive reachability on iOS Simulator & captive portals. |
| **Offline Cache Strategy** | Blind Hive snapshot persistence | Hybrid Fallback Policy (Latest: Cache, History: Fail Fast) | Latest rates fall back gracefully; missing historical days fail fast to prevent blank charts. |
| **Business Logic** | Direct API value rendering | Rate Inversion ($1 / \text{rate}$) & Trend Verification | Verified EGP strengthening semantics ($\text{Rate} \downarrow \implies \text{EGP Stronger} \implies \text{Green}$). |

---

## Detailed Chronological Log

### 1. Layer Separation & Monorepo Structure
* **AI Proposal**: Full Feature-First Clean Architecture (Data, Domain, Presentation layers per feature).
* **Trade-off Weighed**: Rigid Clean Architecture can introduce unnecessary abstraction overhead (e.g., redundant UseCases or duplicate DTO-to-Entity mappers) for a 3-screen app. However, the evaluation rubric explicitly rates *Architecture & Layer Separation*.
* **Decision**: **Accepted with Refinements.** Maintained repository boundaries (`RatesRepository`) and functional isolation, but eliminated trivial entities where plain data models were sufficient.

---

### 2. State Management Architecture
* **AI Proposal**: A unified, singleton BLoC managing the application's entire reactive stream.
* **Trade-off Weighed**: Single BLoC reduces boilerplate, but breaks single-responsibility principles and forces `RateDetail` state to linger in memory for the app's entire lifespan.
* **Decision**: **Rejected initial proposal; Split into `RatesListBloc` and `RateDetailBloc`.**
  * `RatesListBloc`: Manages latest rate polling, pull-to-refresh streams, and connection restoration hooks.
  * `RateDetailBloc`: Instantiate on-demand per navigation route. Handles the parallel 7-day history requests and disposes cleanly upon screen exit.

---

### 3. Resilient Error Handling & Exception Mapping
* **AI Proposal**: Naive `try/catch` in data sources returning generic `ServerFailure`.
* **Trade-off Weighed**: Quick to write, but violates the rubric's *Error Handling & Resilience* criteria. Generic errors fail to inform the UI whether to offer a retry button or display an offline banner.
* **Decision**: **Rejected and Refactored into a Sealed Exception Hierarchy.**
  * Engineered a sealed `AppException` class tree (`NetworkException`, `TimeoutException`, `HttpException`, `ParseException`, `CacheException`).
  * Created `ResultGuard` mixin to standardize error catching across repositories.
  * Created a central `mapDioException` converter to ensure third-party Dio types **never** leak past the Data layer into Domain/BLoC layers.

---

### 4. Functional Result Types with `dartz`
* **AI Proposal**: Standard `Either<Failure, T>` return signatures for repository methods.
* **Decision**: **Accepted.** Enforces compile-time handling of both success and failure states within BLoCs, eliminating unhandled exceptions-as-control-flow in UI components.

---

### 5. Network Connectivity Verification
* **AI Proposal**: Standard `connectivity_plus` integration.
* **Trade-off Weighed**: `connectivity_plus` checks network interfaces (Wi-Fi/Cellular status), not true internet reachability. It produces false positives on iOS Simulators and captive Wi-Fi networks, breaking auto-refresh on reconnect workflows.
* **Decision**: **Rejected AI proposal; Selected `internet_connection_checker_plus`.**
  * Wrapped implementation behind a custom `NetworkInfo` contract to keep network checking mockable and testable.
  * Documented architectural reasoning directly in `pubspec.yaml`.

---

### 6. Offline Persistence & Cache Strategy
* **AI Proposal**: Persist incoming payload using Hive and blindly return local cache on network failures.
* **Trade-off Weighed**: Blind caching obscures persistent connection failures and yields ambiguous user feedback during historical range loading.
* **Decision**: **Custom Fallback Logic Implementation.**
  * **Latest Rates**: Direct offline bypass. If connection is down, skip network call immediately to prevent waiting for Dio connect timeouts, and serve cached Hive snapshot.
  * **7-Day History**: **Fail Fast Policy.** Since historical endpoints aren't bulk-cached, immediate failure UI state is preferred over displaying misleading blank charts.
  * **UI Notification**: Implemented a `fromCache` status flag to trigger a non-blocking offline banner. Manual pull-to-refresh while offline retains existing data and presents a soft feedback `SnackBar`.

---

### 7. Core Business Logic: Rate Inversion & Trend Direction
* **AI Proposal**: Direct rendering of raw JSON numerical output.
* **Correction & Verification**:
  * The API yields values *from EGP to Target Currency* (e.g., `egp.usd = 0.019227`).
  * Spec requires format: **$1 \text{ USD} = X \text{ EGP}$**.
  * Applied mathematical inversion: $\text{Displayed Rate} = \frac{1}{\text{Raw Rate}}$.
  * **Color Semantics Verification**: Spec dictates green for EGP strengthening. If USD/EGP drops from $50.0$ to $48.0$, EGP has strengthened $\implies$ Rate Decrease $=$ Green UI Trend.
* **Decision**: **Manually corrected AI implementation** to prevent silent logic and color encoding defects.

---

### 8. UX Polish: Pull-To-Refresh Synchronization
* **AI Proposal**: Standard `RefreshIndicator` invoking an unawaited BLoC event.
* **Trade-off Weighed**: Returning prematurely dismisses the refresh indicator prior to state settlement.
* **Decision**: **Refactored.** The UI awaits the BLoC stream state resolution with an explicit $20$-second fallback timeout safety guard.

---

### 9. Chart Rendering & Loading Skeleton
* **AI Proposal**: `fl_chart` implementation with standard circular progress indicators.
* **Decision**: **Edited to conform with Spec Requirements.** Integrated `shimmer` loaders specifically during chart data fetch phases. Applied `AnimatedSwitcher` transitions between loading, empty, error, and chart canvas states.

---

### 10. Fault-Tolerant Historical Fetching
* **Trade-off Weighed**: The 7-day historical view issues multiple discrete requests. A single date failure shouldn't abort the entire timeline display.
* **Decision**: **Implemented `_tryDay` recovery logic.** Catches individual `AppException` instances per date request and yields `null`, allowing the chart to render available data points without breaking the entire history module.

---

### 11. Developer Experience & Inspection
* **Decision**: **Accepted and Scoped.** Integrated `requests_inspector` restricted to `kDebugMode` to allow in-app inspection of batch network traffic without leaking devtools into production builds.

---

## Summary of Manual Interventions

1. Corrected foreign exchange rate inversion mathematics and daily change color coding rules.
2. Authored tests for repositories, BLoCs, and custom mapping utilities.
3. Structured Git commit hierarchy into incremental, reviewable commits reflecting feature evolution[cite: 1].