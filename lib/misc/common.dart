import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final poppinsFont = TextStyle(
  fontFamily: GoogleFonts.poppins().fontFamily,
);

class MainColors {
  static const Color primary = Color(0xff202020);
  static const Color accent = Color(0xfffb8000);
  static const Color background = Color(0xffffffff);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFB6B6B6);
}

class ButtonColors {
  static const Color primary = Color(0xfffb7900);
  static const Color attention = Color(0xfff20b0b);
}

class CommonUtils {
  static String formatDate(String date) {
    Map<String, int> months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    List<String> parts = date.split(' ');
    String month = parts[1];
    String day = parts[2];
    String year = parts[3];
    String time = parts[4];

    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    int? monthNumber = months[month];

    DateTime dateTime = DateTime.utc(
        int.parse(year), monthNumber!, int.parse(day), hour, minute, second);

    String formattedDate = "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year.toString().padLeft(4, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";

    return formattedDate;
  }
}
