class UserModel {
  final String name;
  final String email;
  final String phoneNumber;

  UserModel({required this.name, required this.email,required this.phoneNumber});

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['email'] ?? '',
    );
  }

  // Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber':phoneNumber
    };
  }
}
