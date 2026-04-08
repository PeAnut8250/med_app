import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String doctorName;
  final String doctorType;
  final String doctorImage;
  DateTime date;
  TimeOfDay time;
  String status; // 'Upcoming', 'Completed', 'Cancelled'

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorType,
    required this.doctorImage,
    required this.date,
    required this.time,
    required this.status,
  });

  String get formattedDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day}${_getDaySuffix(date.day)} ${months[date.month - 1]}, ${date.year}';
  }

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}
