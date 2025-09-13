import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/global_test_manager.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await GlobalTestManager.instance.initializeGlobal();
  
  try {
    await testMain();
  } finally {
    await GlobalTestManager.instance.disposeGlobal();
  }
}
