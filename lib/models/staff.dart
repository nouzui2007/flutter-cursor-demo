class MasterStaff {
  final String id;
  final String name;
  final String department;
  final String employeeId;

  MasterStaff({
    required this.id,
    required this.name,
    required this.department,
    required this.employeeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'employeeId': employeeId,
    };
  }

  factory MasterStaff.fromJson(Map<String, dynamic> json) {
    return MasterStaff(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      employeeId: json['employeeId'],
    );
  }
}

class WorkingStaff extends MasterStaff {
  final String startTime;
  final String endTime;
  final bool isSelected;

  WorkingStaff({
    required super.id,
    required super.name,
    required super.department,
    required super.employeeId,
    required this.startTime,
    required this.endTime,
    required this.isSelected,
  });

  WorkingStaff copyWith({
    String? startTime,
    String? endTime,
    bool? isSelected,
  }) {
    return WorkingStaff(
      id: id,
      name: name,
      department: department,
      employeeId: employeeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'startTime': startTime,
      'endTime': endTime,
      'isSelected': isSelected,
    };
  }

  factory WorkingStaff.fromJson(Map<String, dynamic> json) {
    return WorkingStaff(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      employeeId: json['employeeId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      isSelected: json['isSelected'],
    );
  }

  factory WorkingStaff.fromMasterStaff(MasterStaff masterStaff) {
    return WorkingStaff(
      id: masterStaff.id,
      name: masterStaff.name,
      department: masterStaff.department,
      employeeId: masterStaff.employeeId,
      startTime: '',
      endTime: '',
      isSelected: true,
    );
  }
}
