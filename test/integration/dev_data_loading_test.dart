import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import '../../lib/app/test_service_locator.dart';
import '../../lib/app/fixtures/dev_fixture_orchestrator.dart';

void main() {
  group('Dev Data Loading Performance', () {
    setUpAll(() async {
      // Ensure proper test environment
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Set up test service locator with Environment.test
      await TestServiceLocator.setup();
    });

    tearDownAll(() async {
      // Clean up after tests
      await TestServiceLocator.tearDown();
    });

    testWidgets('should load dev fixtures quickly', (WidgetTester tester) async {
      // Arrange
      final orchestrator = DevFixtureOrchestratorFactory.create();
      final stopwatch = Stopwatch();

      // Act
      stopwatch.start();
      final result = await orchestrator.createFullDevDataset();
      stopwatch.stop();

      // Assert
      final loadTimeSeconds = stopwatch.elapsedMilliseconds / 1000;
      print('Dev data loaded in $loadTimeSeconds seconds');
      print('Result: ${result.message}');
      
      // Should be successful
      expect(result.success, isTrue);
      
      // Should load in under 10 seconds for good developer experience
      expect(loadTimeSeconds, lessThan(10.0));
    });
  });
}
