Created 3 todos

Starting (1/3) *Check current queue support*

Searched text for `Queue` (`**/lib/**`), 2 results

Completed (1/3) *Check current queue support*

Starting (2/3) *Outline mobile-friendly queue design*

Starting (3/3) *Map implementation steps*

Completed (3/3) *Map implementation steps*

Looked through the repo and there isn’t any existing order queue or retry loop yet (aside from GPS batches), so we’ll need to introduce one. Here’s a mobile-friendly approach that fits the current architecture and the new `OrderSubmissionService`.

## queue concept for Flutter
- **Persistence:** add a Drift table (e.g. `order_jobs`) with columns like `jobId`, `orderId`, `payloadJson`, `status` (`queued/pending/retry/error/done`), `attempts`, `nextRunAt`, `failureReason`. This keeps jobs alive across app restarts and lets us resume after crashes or reboots.
- **Domain contracts:**  
  - `OrderQueueRepository` (CRUD for `order_jobs`).  
  - `OrderQueueService` (enqueue, markRunning, markSuccess, markError, scheduleNextAttempt).  
  - Reuse `OrderSubmissionService` to actually hit the API; it already handles pending/confirmed/error transitions using the mock API abstraction.
- **Processing loop:**  
  - A singleton `OrderQueueProcessor` that:  
    1. Grabs the next due job (respecting `nextRunAt`).  
    2. Loads the order, calls `OrderSubmissionService.submit`.  
    3. On success → marks job `done`, order `confirmed`.  
    4. On `NetworkFailure` → increments attempts, sets `nextRunAt` with exponential backoff, leaves order in `pending`.  
    5. On other failures → moves job to `error`, sets order to `error` with `failureReason`.  
  - Trigger it in three situations: immediately after enqueue, on app start, and when connectivity changes (use `connectivity_plus`). For periodic background tries you can later wire `workmanager`/`background_fetch`, but a foreground scheduler is enough for MVP.
- **Job enqueue flow:** update `SubmitOrderUseCase` so the BLoC does:  
  1. Use `OrderSubmissionService`’s `submit` result to get a `pending` order (it already ensures `canSubmit`).  
  2. Persist/refresh the order via `OrderRepository`.  
  3. Call `OrderQueueService.enqueue(order)` which stores the job and kicks the processor.  
  4. Return a fresh `draft` cart (copy of `Order.createDraft`).

## suggested implementation steps
1. **Schema & models:** create Drift table and domain entity (`OrderJob`, `OrderJobStatus`, maybe reuse `OrderState` values). Add repository/service interfaces in domain.
2. **Infrastructure wiring:** implement `OrderQueueRepositoryImpl` using Drift; register in DI alongside `OrderRepository`.
3. **Submission service reuse:** adjust `OrderSubmissionService.submit` to accept an `Order` and optional payload override; keep the existing retry semantics.
4. **Use case & BLoC:** update `SubmitOrderUseCase` to enqueue jobs, store pending orders, and return `SubmitOrderResult` with the updated order plus a new draft. Have the UI react by showing pending/error/confirmed states from `Order.state`.
5. **Processor loop:** implement `OrderQueueProcessor` (probably in services). Provide methods to `start()`, `stop()`, and `processNext()`. For the first pass you can drive it via `Timer.periodic` while app is in foreground.
6. **Connectivity hook:** add a lightweight `ConnectivityWatcher` (or reuse existing tracking services) to call `OrderQueueProcessor.trigger()` when the network becomes available.
7. **Tests:** follow the TDD approach—start with tests for repository persistence and for processor behavior (happy path, network failure retry, terminal error). Reuse the mock `OrderApiService` you already built.
8. **Optional background scheduling:** once the foreground loop works, evaluate `workmanager` (Android) or `background_fetch`/push notifications (iOS) for periodic background attempts. Be mindful of platform battery policies.

With this structure you get Symfony-messenger–style reliability: jobs are persisted, retried with backoff, and can be inspected or replayed. Let me know when you’re ready to start coding the Drift table or wiring the processor—I can help scaffold the tests next.