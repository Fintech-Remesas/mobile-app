import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String email;

  const UserProfile({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}
