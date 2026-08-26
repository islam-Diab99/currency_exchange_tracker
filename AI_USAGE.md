# AI Usage Log

This document records how I used AI assistance while building the Currency
Exchange Tracker. Rather than transcribe raw prompts, I've written it as a log
of the **decisions and trade-offs** I worked through with the model — what it
proposed, where I agreed, where I pushed back, and why. The intent is to show
the judgment applied to the output, not the keystrokes.

I used AI as a pair-programmer and reviewer: fast at scaffolding boilerplate and
surfacing options, but every architectural and correctness decision below was
mine to accept, edit, or reject. The entries roughly follow the commit order.

---

## 1. Overall architecture & layer separation

**What AI proposed:** A clean-architecture layout (data / domain / presentation)
with a feature-first folder structure.

**Trade-off I weighed:** Full clean architecture adds ceremony (entities vs
models, use cases, repository interfaces) that can feel heavy for a 3-screen
app. The alternative was a leaner service+bloc structure.

**Decision — accepted, with edits.** The assessment explicitly grades
"Architecture & Layer Separation," and the app has real seams (remote + local
data sources, offline fallback) that benefit from a repository boundary. I kept
the layering but resisted over-engineering — e.g. no needless abstractions where
a plain entity sufficed.

## 2. State management — one BLoC vs one per screen

**What AI proposed:** A single shared BLoC for the whole rates feature.

**Trade-off I weighed:** One BLoC is less wiring, but the list screen and the
detail/history screen have genuinely different state shapes and lifecycles.

**Decision — edited.** I split into `RatesListBloc` and `RateDetailBloc`
(domain-driven separation, as the rubric calls out). The detail BLoC is created
per-navigation so its 7-day history load is scoped to the screen and disposed
with it, rather than living for the app's lifetime.

## 3. Error handling — from ad-hoc to categorized

**What AI proposed initially:** Simple `try/catch` in the repository mapping a
generic `ServerException` to a `ServerFailure`.

**Trade-off I weighed:** That's quick, but "Error Handling & Resilience
(Exception categorization)" is a scored criterion, and a generic server error
gives the user nothing actionable. The cost of categorization is more types to
maintain.

**Decision — rejected the first version, refactored.** I moved to a `sealed`
`AppException` hierarchy (network, timeout, 401/403/404/422/429, server, parse,
cache, unknown) with a matching `Failure` hierarchy, plus:
- a **single** `mapDioException` — the one boundary that translates Dio errors
  into typed `AppException`s (the data source catches `DioException` and hands it
  straight there), so HTTP types never leak past the data layer;
- a `ResultGuard` mixin so repositories map thrown exceptions to `Failure`s in
  one consistent place instead of repeating `try/catch` blocks.

This landed as a dedicated refactor commit rather than being smeared across the
feature commits.

## 4. Functional error handling with `dartz`

**What AI proposed:** Returning `Either<Failure, T>` from the repository/use
cases.

**Decision — accepted.** It forces the presentation layer to handle both
branches explicitly and keeps error state out of exceptions-as-control-flow. I
accepted the pattern but kept the `Either` handling confined to the BLoCs so
widgets stay declarative.

## 5. Connectivity detection — the one I pushed back on

**What AI proposed:** `connectivity_plus` to detect offline state.

**Trade-off I weighed:** `connectivity_plus` only reports the *network interface*
(wifi/cellular/none). It returns "connected" for captive portals and, notably,
gives false positives on the iOS simulator — which would break the offline
demo and, worse, the auto-refresh-on-reconnect behavior.

**Decision — rejected, chose an alternative.** I used
`internet_connection_checker_plus`, which actually verifies reachability. I
wrapped it behind a `NetworkInfo` interface so the rest of the app never depends
on the plugin directly and it stays mockable in tests. The reasoning is recorded
as a comment in `pubspec.yaml` so the next reader understands the choice.

## 6. Offline cache strategy

**What AI proposed:** Persist the last snapshot (Hive) and serve it when
offline.

**Trade-off I weighed:** *How aggressively* to fall back. Blindly serving cache
can hide real errors; failing hard defeats the point of a cache.

**Decision — edited into a deliberate policy:**
- **Latest rates:** if offline, don't even hit the network (it would just hang
  until the Dio connect timeout) — serve the last good snapshot immediately.
  Any load failure also falls back to cache if present.
- **7-day history:** *fail fast* when offline. There's no history cache to fall
  back on, so surfacing a clear network error beats a misleading blank chart.
- A `fromCache` flag drives the "last updated" offline banner, and a *manual*
  pull-to-refresh that comes back as cache is treated as a soft failure (keep
  the data, fire a snackbar) — an initial load stays silent because the banner
  already communicates it.

## 7. Rate inversion & change direction — verifying against the spec

**What AI proposed:** Display the API value directly.

**Trade-off / correctness check:** The API returns rates *from* EGP
(`egp.usd = 0.0192…`), but the UI must show "1 USD = X EGP," which requires
inverting (`1 / rate`). I also had to get the color semantics right: the spec
says green when **EGP strengthens**. Since a *falling* EGP-per-foreign-unit rate
means EGP buys more, "rate went down" = EGP stronger = green.

**Decision — corrected.** I verified the inversion and the trend direction
against the spec's worked example rather than trusting the first output, since a
flipped sign here would be a silent, high-visibility bug.

## 8. Pull-to-refresh that tells the truth

**What AI proposed:** A standard `RefreshIndicator` that returns immediately.

**Trade-off I weighed:** Returning immediately makes the spinner lie — it
vanishes before the refresh actually completes.

**Decision — edited.** The indicator awaits the BLoC stream until the refresh
settles, with a 20s timeout as a safety net so it can never hang forever.

## 9. Chart & loading state

**What AI proposed:** `fl_chart` for the 7-day line chart.

**Decision — accepted**, and used the `shimmer` package for the chart's loading
state specifically because the spec requires a **shimmer, not a spinner**. Chart
states (loading / data / error / empty) cross-fade via `AnimatedSwitcher` for
polish.

## 10. Tolerating missing historical days

**Trade-off I weighed:** A single historical date occasionally returns nothing.
Should that fail the whole load?

**Decision — edited, at both call sites.** The daily-change computation and the
7-day chart each depend on older dates that can individually 404, so both
swallow a single day's `AppException` and treat it as `null`:
- **Daily change** (`getLatestRates`): `_tryDay` guards *yesterday's* fetch, so a
  missing yesterday just drops the change badge instead of failing today's rates.
- **7-day history** (`getRateHistory`): each older day is fetched concurrently
  and a failed one is skipped, so one gap just won't plot rather than failing the
  whole chart.

In both cases *today's* value is still required — if the anchor day fails, the
load fails, because there's nothing meaningful to show without it.

## 11. Parallelizing the latest + previous-day fetch

**What AI proposed:** Fetch today from `/latest/`, then — once today's date is
known — fetch the previous day sequentially to compute the daily change.

**Trade-off I weighed:** Sequential is the most *correct* (yesterday is anchored
to the server's actual latest date), but it's two round-trips back-to-back.
Deriving yesterday's date from the device clock instead makes the two requests
independent, so they can run together under one `Future.wait` — at the cost that,
on a day the provider hasn't published yet, clock-yesterday may not line up with
the server's latest date, so the change badge can fall back to `—`.

**Decision — edited to concurrent.** `getLatestRates` now computes yesterday
from the clock and fires both requests together via `Future.wait`; `_tryDay`
still swallows a missing yesterday. I accepted the small accuracy trade for the
latency win, since the badge already degrades gracefully. The 7-day history
keeps the *opposite* choice on purpose: it needs the server's real anchor date to
derive six correct dates, so it fetches the anchor first, then parallelizes the
remaining days with `Future.wait`.

## 12. Debug tooling

**Decision — accepted, scoped.** I added `requests_inspector` as an in-app
network inspector to make the two-call latest/yesterday flow and the 7 history
calls easy to verify during development. It's debug-facing tooling and doesn't
affect production behavior.

## 13. Testing — logic and resilience over UI

**What AI proposed:** A unit-test suite using `mocktail` and `bloc_test`,
mocking at the data-source, use-case and connectivity boundaries.

**Trade-off I weighed:** Widget/golden tests would cover the UI, but the rubric
weights *meaningful* coverage, and the correctness risk lives in the logic —
rate inversion, trend direction, exception categorization, the offline
fallback policy, and BLoC transitions. Those are also cheaper to test reliably
than pixels.

**Decision — accepted, scoped to logic.** The suite covers the `ExchangeRate`
math/trend, `RateFormatter`, response parsing, the cache round-trip, both
exception mappers, the repository's inversion + offline-fallback +
history-fail-fast + single-day tolerance, and both BLoCs (including the
reconnect auto-refresh and the refresh-returns-cache soft failure). I
deliberately left widget/golden tests out for now rather than add shallow ones.

---

## Where I did *not* lean on AI

- The final call on every trade-off above, and the correctness checks against
  the spec's worked examples (rate inversion, color direction).
- Deciding the commit boundaries so the git history reads as incremental,
  reviewable steps.
