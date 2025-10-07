import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Abstraction for components that trigger order submission queue processing.
abstract class OrderSubmissionQueueTrigger {
  Future<void> start();
  Future<void> dispose();
}

/// Connectivity-based trigger that resumes pending order submissions when
/// network connectivity becomes available.
class ConnectivityOrderSubmissionQueueTrigger
    implements OrderSubmissionQueueTrigger {
  ConnectivityOrderSubmissionQueueTrigger({
    required Connectivity connectivity,
    required JobQueueService<OrderSubmissionJob> queueService,
    Future<List<ConnectivityResult>> Function()? connectivityCheck,
    Stream<List<ConnectivityResult>>? connectivityStream,
  })  : _queueService = queueService,
        _connectivityCheck =
            connectivityCheck ?? (() => connectivity.checkConnectivity()),
        _connectivityStream =
            connectivityStream ?? connectivity.onConnectivityChanged;

  static final Logger _logger =
      Logger('ConnectivityOrderSubmissionQueueTrigger');

  final JobQueueService<OrderSubmissionJob> _queueService;
  final Future<List<ConnectivityResult>> Function() _connectivityCheck;
  final Stream<List<ConnectivityResult>> _connectivityStream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;

  @override
  Future<void> start() async {
    if (_started) {
      return;
    }

    _started = true;

    try {
      final initialStatus = await _connectivityCheck();
      if (_anyOnline(initialStatus)) {
        _logger.fine(
          'Initial connectivity: $initialStatus. Triggering order queue processing.',
        );
        unawaited(_queueService.triggerProcessing());
      }
    } on MissingPluginException catch (error, stackTrace) {
      _logger.warning(
        'Connectivity plugin not available; skipping connectivity-triggered retries.',
        error,
        stackTrace,
      );
      unawaited(_queueService.triggerProcessing());
      return;
    } catch (error, stackTrace) {
      _logger.severe('Failed to obtain initial connectivity status', error, stackTrace);
    }

    try {
      _subscription = _connectivityStream.listen((statuses) {
        if (_anyOnline(statuses)) {
          _logger.info(
            'Connectivity restored ($statuses). Triggering order queue processing.',
          );
          unawaited(_queueService.triggerProcessing());
        } else {
          _logger.fine('Connectivity lost ($statuses). Waiting for restoration.');
        }
      });
    } on MissingPluginException catch (error, stackTrace) {
      _logger.warning(
        'Connectivity plugin not available for stream updates; stopping trigger.',
        error,
        stackTrace,
      );
      await _subscription?.cancel();
      _subscription = null;
      return;
    }
  }

  bool _anyOnline(List<ConnectivityResult> statuses) {
    return statuses.any((status) =>
        status == ConnectivityResult.wifi ||
        status == ConnectivityResult.mobile ||
        status == ConnectivityResult.ethernet ||
        status == ConnectivityResult.vpn);
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
  _subscription = null;
    _started = false;
  }
}
