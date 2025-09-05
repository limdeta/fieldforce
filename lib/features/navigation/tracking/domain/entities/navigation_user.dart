// TODO вот тут не понятно. ФИО не очень к месту, нужно подумать о более подходящих методах
abstract class NavigationUser {
  int get id;
  String? get lastName;
  String? get firstName;
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}';
}