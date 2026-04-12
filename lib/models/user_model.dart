class UserModel {
  final String username;
  final String email;
  final String? phone;
  final String? address;
  final String? profileImage;
  final double? balance;

  UserModel({
    required this.username,
    required this.email,
    this.phone,
    this.address,
    this.profileImage,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
    address: json['address'],
    profileImage: json['profileImage'],
    balance: (json['balance'] as num?)?.toDouble(),
  );
}
