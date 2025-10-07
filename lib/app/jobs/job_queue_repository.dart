import 'job.dart';
import 'job_record.dart';
import 'job_status.dart';

abstract class JobQueueRepository<J extends Job> {
  Future<JobRecord<J>> save(JobRecord<J> record);

  Future<JobRecord<J>?> findById(String id);

  Future<JobRecord<J>?> dequeueDueJob({DateTime? now});

  Future<JobRecord<J>> updateStatus(
    String id,
    JobStatus status, {
    int? attempts,
    DateTime? nextRunAt,
    String? failureReason,
  });

  Future<List<JobRecord<J>>> list({JobStatus? status, int limit = 50});

  Future<void> delete(String id);
}
