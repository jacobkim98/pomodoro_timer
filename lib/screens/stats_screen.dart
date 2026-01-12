import 'package:flutter/material.dart';
import '../models/focus_record.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  FocusRecord? _todayRecord;
  List<FocusRecord> _weeklyRecords = [];
  int _weeklyMinutes = 0;
  int _monthlyMinutes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final today = await _databaseService.getTodayRecord();
      final weekly = await _databaseService.getRecentRecords(7);
      final weeklyMinutes = await _databaseService.getWeeklyFocusMinutes();
      final monthlyMinutes = await _databaseService.getMonthlyFocusMinutes();

      setState(() {
        _todayRecord = today;
        _weeklyRecords = weekly;
        _weeklyMinutes = weeklyMinutes;
        _monthlyMinutes = monthlyMinutes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${mins}분';
    }
    return '${mins}분';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '통계',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 오늘 통계
                  _buildTodayCard(),
                  const SizedBox(height: 16),

                  // 요약 카드들
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: '이번 주',
                          value: _formatMinutes(_weeklyMinutes),
                          icon: Icons.calendar_view_week,
                          color: AppColors.shortBreak,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: '이번 달',
                          value: _formatMinutes(_monthlyMinutes),
                          icon: Icons.calendar_month,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 최근 기록
                  Text(
                    '최근 7일',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyChart(),
                  const SizedBox(height: 16),

                  // 기록 리스트
                  ..._weeklyRecords.map((record) => _buildRecordTile(record)),
                ],
              ),
            ),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                '오늘',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _todayRecord != null
                ? _formatMinutes(_todayRecord!.focusMinutes)
                : '0분',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '완료한 세션: ${_todayRecord?.completedSessions ?? 0}회',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // 최근 7일 데이터를 막대 그래프로 표시
    final maxMinutes = _weeklyRecords.isEmpty
        ? 60
        : _weeklyRecords
            .map((r) => r.focusMinutes)
            .reduce((a, b) => a > b ? a : b);
    final chartMax = maxMinutes > 0 ? maxMinutes : 60;

    // 날짜 리스트 생성 (최근 7일)
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      return today.subtract(Duration(days: 6 - i));
    });

    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final record = _weeklyRecords.firstWhere(
            (r) =>
                r.date.year == day.year &&
                r.date.month == day.month &&
                r.date.day == day.day,
            orElse: () => FocusRecord(
              date: day,
              focusMinutes: 0,
              completedSessions: 0,
            ),
          );

          final height = record.focusMinutes > 0
              ? (record.focusMinutes / chartMax * 100).clamp(10.0, 100.0)
              : 4.0;

          final isToday = day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;

          return Column(
            children: [
              Container(
                width: 24,
                height: height,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayNames[day.weekday - 1],
                style: TextStyle(
                  color: isToday ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordTile(FocusRecord record) {
    final today = DateTime.now();
    final isToday = record.date.year == today.year &&
        record.date.month == today.month &&
        record.date.day == today.day;

    final dateStr = isToday
        ? '오늘'
        : '${record.date.month}/${record.date.day}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                dateStr,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMinutes(record.focusMinutes),
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${record.completedSessions}회 완료',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
