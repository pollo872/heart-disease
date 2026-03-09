class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }
}