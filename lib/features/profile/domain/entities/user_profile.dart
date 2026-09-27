import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String email;
  final bool allowTestRecharge;

  const UserProfile({
    required this.name,
    required this.email,
    this.allowTestRecharge = false,
  });

  @override
  List<Object?> get props => [name, email, allowTestRecharge];
}
