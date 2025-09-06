import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/attendance_data_service.dart';
import '../widgets/attendance/date_navigator.dart';
import '../widgets/attendance/staff_selector.dart';
import '../widgets/attendance/time_entry_form.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime currentDate = DateTime.now();
  Map<String, List<WorkingStaff>> staffData = {};

  // 従業員管理システムから取得する想定のマスターデータ
  final List<MasterStaff> masterStaffList = [
    MasterStaff(id: '001', name: '田中 太郎', department: '営業部', employeeId: 'EMP001'),
    MasterStaff(id: '002', name: '佐藤 花子', department: '営業部', employeeId: 'EMP002'),
    MasterStaff(id: '003', name: '山田 次郎', department: 'マーケティング部', employeeId: 'EMP003'),
    MasterStaff(id: '004', name: '鈴木 美咲', department: 'マーケティング部', employeeId: 'EMP004'),
    MasterStaff(id: '005', name: '高橋 健一', department: '技術部', employeeId: 'EMP005'),
    MasterStaff(id: '006', name: '小林 由美', department: '技術部', employeeId: 'EMP006'),
    MasterStaff(id: '007', name: '渡辺 大樹', department: '人事部', employeeId: 'EMP007'),
    MasterStaff(id: '008', name: '加藤 恵', department: '人事部', employeeId: 'EMP008'),
    MasterStaff(id: '009', name: '井上 慎也', department: '経理部', employeeId: 'EMP009'),
    MasterStaff(id: '010', name: '斎藤 麻衣', department: '経理部', employeeId: 'EMP010'),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedData = await AttendanceDataService.loadStaffData();
    setState(() {
      staffData = loadedData;
    });
  }

  List<WorkingStaff> _getCurrentWorkingStaff() {
    final dateKey = AttendanceDataService.getDateKey(currentDate);
    return staffData[dateKey] ?? [];
  }

  void _updateWorkingStaff(List<WorkingStaff> newWorkingStaff) {
    print('🔍 _updateWorkingStaff called with ${newWorkingStaff.length} staff');
    final dateKey = AttendanceDataService.getDateKey(currentDate);
    print('📅 Date key: $dateKey');
    setState(() {
      staffData[dateKey] = newWorkingStaff;
    });
    print('💾 Staff data updated: ${staffData[dateKey]?.length ?? 0} staff for $dateKey');
    AttendanceDataService.saveStaffData(staffData);
  }

  void _onDateChange(DateTime newDate) {
    setState(() {
      currentDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkingStaff = _getCurrentWorkingStaff();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // ヘッダー
                Column(
                  children: [
                    const Text(
                      '勤怠管理',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '出勤スタッフの勤務時間を記録',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 日付ナビゲーター
                DateNavigator(
                  currentDate: currentDate,
                  onDateChange: _onDateChange,
                ),
                // スタッフ選択
                StaffSelector(
                  masterStaffList: masterStaffList,
                  workingStaffList: currentWorkingStaff,
                  onUpdateWorkingStaff: _updateWorkingStaff,
                ),
                // 勤務時間入力
                TimeEntryForm(
                  workingStaffList: currentWorkingStaff,
                  onUpdateStaff: _updateWorkingStaff,
                ),
                const SizedBox(height: 32),
                // フッター情報
                Text(
                  'データは端末に自動保存されます',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
