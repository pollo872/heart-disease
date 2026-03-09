import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthResponseModel extends AuthEntity {
  const AuthResponseModel({
    required super.token,
    required super.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'];
    if (patient == null) {
      throw Exception('Patient data missing');
    }
    

    return AuthResponseModel(
      token: json['token'],
      user: UserEntity(
        id: patient['id'],
        email: patient['email'],
        name: '${patient['firstName']} ${patient['lastName']}',
      ),
    );
  }
}
