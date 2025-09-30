import 'package:fieldforce/app/database/repositories/session_repository_impl.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and restores rememberMe session across instances', () async {
    const repository = SessionRepositoryImpl();

    final phone = PhoneNumber.create('79991112233').getOrElse(() {
      throw StateError('Failed to create phone number');
    });

    final user = User.create(
      externalId: 'user_1',
      role: UserRole.user,
      phoneNumber: phone,
      hashedPassword: 'hashed_password',
    ).getOrElse(() {
      throw StateError('Failed to create user');
    });

    final session = UserSession.create(
      user: user,
      rememberMe: true,
    ).getOrElse(() {
      throw StateError('Failed to create session');
    });

    final saveResult = await repository.saveSession(session);
    expect(saveResult.isRight(), isTrue, reason: 'session should be saved successfully');

    const newRepository = SessionRepositoryImpl();
    final restoredResult = await newRepository.getCurrentSession();
    expect(restoredResult.isRight(), isTrue, reason: 'reading session should succeed');

    final restoredSession = restoredResult.getOrElse(() => null);
    expect(restoredSession, isNotNull, reason: 'session should be restored');
    expect(restoredSession!.rememberMe, isTrue);
    expect(restoredSession.user.phoneNumber.value, equals(phone.value));
  });

}
