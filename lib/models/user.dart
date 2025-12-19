/// User model representing the app user
class User {
  final String name;
  final String registrationNumber;
  final String? profileImagePath;

  User({
    required this.name,
    required this.registrationNumber,
    this.profileImagePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'registrationNumber': registrationNumber,
      'profileImagePath': profileImagePath,
    };
  }

  User copyWith({
    String? name,
    String? registrationNumber,
    String? profileImagePath,
  }) {
    return User(
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  static User defaultUser() {
    return User(name: 'Ahmad Ali Raza', registrationNumber: 'FA22-BSE-062');
  }
}
