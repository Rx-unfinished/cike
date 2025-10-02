import 'package:flutter/material.dart';

enum DateTimeMode {
  dateOnly,     // 只选择日期
  dateTime,     // 日期和时间都选择
}

class DateTimeSelectorWidget extends StatelessWidget {
  final DateTime selectedDateTime;
  final Function(DateTime) onChanged;
  final DateTimeMode mode;
  final String? placeholder;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  const DateTimeSelectorWidget({
    super.key,
    required this.selectedDateTime,
    required this.onChanged,
    this.mode = DateTimeMode.dateTime,
    this.placeholder,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _selectDateTime(context) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.white : Colors.grey[100],
        ),
        child: Row(
          children: [
            Icon(
              mode == DateTimeMode.dateOnly ? Icons.calendar_today : Icons.schedule,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDateTime(),
                style: TextStyle(
                  fontSize: 14,
                  color: enabled ? Colors.black87 : Colors.grey[500],
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // 格式化显示日期时间
  String _formatDateTime() {
    if (mode == DateTimeMode.dateOnly) {
      return '${selectedDateTime.year}年${selectedDateTime.month.toString().padLeft(2, '0')}月${selectedDateTime.day.toString().padLeft(2, '0')}日';
    } else {
      return '${selectedDateTime.year}年${selectedDateTime.month.toString().padLeft(2, '0')}月${selectedDateTime.day.toString().padLeft(2, '0')}日 ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // 选择日期时间
  Future<void> _selectDateTime(BuildContext context) async {
    if (!context.mounted) return;
    
    if (mode == DateTimeMode.dateOnly) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2101),
      );
      if (picked != null && context.mounted) {
        onChanged(picked);
      }
    } else {
      // 先选择日期
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2101),
      );
      
      if (pickedDate != null && context.mounted) {
        // 再选择时间
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );
        
        if (pickedTime != null && context.mounted) {
          final DateTime finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          onChanged(finalDateTime);
        }
      }
    }
  }
}