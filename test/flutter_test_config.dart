import 'dart:async';
import 'helpers/global_test_manager.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await GlobalTestManager.instance.initializeGlobal();
  
  try {
    await testMain();
  } finally {
    await GlobalTestManager.instance.disposeGlobal();
  }
}
