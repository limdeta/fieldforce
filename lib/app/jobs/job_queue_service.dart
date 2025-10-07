import 'job.dart';
import 'job_record.dart';

abstract class JobQueueService<J extends Job> {
  Future<JobRecord<J>> enqueue(J job, {DateTime? runAt});

  Future<void> triggerProcessing();
}
