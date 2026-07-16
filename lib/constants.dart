const String siteUrl = 'https://kevmoo.com';
const String siteTitle = 'kevmoo @ Work';
const String siteSubtitle =
    'Googler working on Dart and Flutter web technology';
const String authorName = 'Kevin Moore';
const String homePageTitle =
    '$authorName | Google Product Manager | Flutter & Dart';

String formatReadableDate(DateTime date, {bool shortMonth = false}) {
  const shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const longMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final months = shortMonth ? shortMonths : longMonths;
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
