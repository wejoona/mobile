/// Sub-business entity (department, branch, subsidiary)
class SubBusiness {
  final String id;
  final String name;
  final String? description;
  final double balance;
  final SubBusinessType type;
  final int staffCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubBusiness({
    required this.id,
    required this.name,
    this.description,
    required this.balance,
    required this.type,
    required this.staffCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubBusiness.fromJson(Map<String, dynamic> json) {
    return SubBusiness(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      balance: (json['balance'] as num).toDouble(),
      type: SubBusinessType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SubBusinessType.department,
      ),
      staffCount: json['staffCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'balance': balance,
        'type': type.name,
        'staffCount': staffCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

enum SubBusinessType {
  department,
  branch,
  subsidiary,
  team,
}

/// Staff member of a sub-business
class StaffMember {
  final String id;
  final String subBusinessId;
  final String userId;
  final String name;
  final String phoneNumber;
  final StaffRole role;
  final DateTime addedAt;
  final bool isActive;

  const StaffMember({
    required this.id,
    required this.subBusinessId,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.addedAt,
    this.isActive = true,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      subBusinessId: json['subBusinessId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.viewer,
      ),
      addedAt: DateTime.parse(json['addedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subBusinessId': subBusinessId,
        'userId': userId,
        'name': name,
        'phoneNumber': phoneNumber,
        'role': role.name,
        'addedAt': addedAt.toIso8601String(),
        'isActive': isActive,
      };
}

enum StaffRole {
  owner, // Full access
  admin, // Manage + transfer
  viewer, // View only
}

extension StaffRoleExtension on StaffRole {
  bool get canTransfer => this == StaffRole.owner || this == StaffRole.admin;
  bool get canManageStaff => this == StaffRole.owner;
  bool get canViewTransactions => true;
}
