String formatShortDate(DateTime date) {
  const months = <String>[
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
  return '${months[date.month - 1]} ${date.day}';
}

void main() {
  final forecastConditions = <String>[
    'Partly Cloudy',
    'Rainy',
    'Sunny',
    'Cloudy',
    'Sunny',
  ];
  final today = DateTime.now();

  print('=== Weather App ===');
  print('');
  print('Fetching current weather...');
  print('');
  print('=== Weather Report ===');
  print('Current Weather: Sunny');
  print('Temperature: 28\u00B0C');
  print('Humidity: 65%');
  print('==================== 5-Day Forecast ===');

  for (var i = 0; i < forecastConditions.length; i++) {
    final date = today.add(Duration(days: i));
    final formattedDate = formatShortDate(date);
    print('Day ${i + 1} ($formattedDate): ${forecastConditions[i]}');
  }

  print('Forecast complete!Weather app completed!');
}
