class UserModel {
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl; // Keep it final for immutability

  UserModel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }

  // Convert UserModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create a copy with updated fields (for immutability)
  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
