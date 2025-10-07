import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/app/jobs/job_record.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_queue_trigger.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestJobQueueService implements JobQueueService<OrderSubmissionJob> {
  int triggerProcessingCalls = 0;

  @override
  Future<JobRecord<OrderSubmissionJob>> enqueue(
    OrderSubmissionJob job, {
    DateTime? runAt,
  }) {
    throw UnimplementedError('enqueue is not used in these tests');
  }

  @override
  Future<void> triggerProcessing() async {
    triggerProcessingCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityOrderSubmissionQueueTrigger', () {
    late _TestJobQueueService queueService;
    late StreamController<List<ConnectivityResult>> connectivityStream;
    late List<ConnectivityResult> initialStatuses;
    late ConnectivityOrderSubmissionQueueTrigger trigger;

    setUp(() {
      queueService = _TestJobQueueService();
      connectivityStream = StreamController<List<ConnectivityResult>>.broadcast();
      initialStatuses = const <ConnectivityResult>[];

      trigger = ConnectivityOrderSubmissionQueueTrigger(
        connectivity: Connectivity(),
        queueService: queueService,
        connectivityCheck: () async => initialStatuses,
        connectivityStream: connectivityStream.stream,
      );
    });

    tearDown(() async {
      await trigger.dispose();
      await connectivityStream.close();
    });

    test('triggers processing when initial connectivity is online', () async {
      initialStatuses = const [ConnectivityResult.wifi];

      await trigger.start();

      expect(queueService.triggerProcessingCalls, 1);
    });

    test('listens to connectivity changes and triggers on reconnection', () async {
      initialStatuses = const [ConnectivityResult.none];

      await trigger.start();
      expect(queueService.triggerProcessingCalls, 0);

      connectivityStream.add(const [ConnectivityResult.mobile]);
      await pumpEventQueue();

      expect(queueService.triggerProcessingCalls, 1);
    });

    test('does not double-start when start is called twice', () async {
      initialStatuses = const [ConnectivityResult.ethernet];

      await trigger.start();
      await trigger.start();

      expect(queueService.triggerProcessingCalls, 1);
    });
  });
}
