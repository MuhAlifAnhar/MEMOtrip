/// MEMOtrip — Date/Time Formatting Utilities (Indonesian Locale)
class DateFormatter {
  DateFormatter._();

  static const List<String> _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const List<String> _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// "Rabu, 22 April 2026"
  static String fullDate(DateTime d) {
    return '${_dayNames[d.weekday - 1]}, ${d.day} ${_monthNames[d.month - 1]} ${d.year}';
  }

  /// "22 Apr 2026"
  static String shortDate(DateTime d) {
    return '${d.day} ${_monthShort[d.month - 1]} ${d.year}';
  }

  /// "16:30 WITA"
  static String timeWita(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m WITA';
  }

  /// "16:30"
  static String time24(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Relative time: "3 menit lalu", "2 jam lalu", "Kemarin", etc.
  static String relative(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.isNegative) return shortDate(d);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return shortDate(d);
  }

  /// Returns greeting based on hour: Selamat Pagi / Siang / Sore / Malam
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  /// Day label for schedule: "Hari Ini", "Besok", or formatted date
  static String dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return 'Kemarin';
    return shortDate(d);
  }
}
