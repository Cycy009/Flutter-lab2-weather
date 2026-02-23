import 'dart:async';

Future<String> fetchCurrentWeather() async {
  print('Fetching current weather...');
  await Future.delayed(Duration(seconds: 2));
  return 'Sunny';
}

Future<int> fetchTemperature() async {
  await Future.delayed(Duration(seconds: 1));
  return 28;
}

Future<int> fetchHumidity() async {
  await Future.delayed(Duration(seconds: 1));
  return 65;
}

Stream<String> forecastStream() async* {
  var forecasts = [
    'Partly Cloudy',
    'Rainy',
    'Sunny',
    'Cloudy',
    'Sunny',
  ];

  for (var forecast in forecasts) {
    await Future.delayed(Duration(seconds: 1));
    yield forecast;
  }
}

Future<void> main() async {
  try {
    String weather = await fetchCurrentWeather();
    print('Current Weather: $weather');

    // Parallel execution
    var results = await Future.wait([
      fetchTemperature(),
      fetchHumidity(),
    ]);

    int temp = results[0];
    int humidity = results[1];

    print('Temperature: ${temp}°C');
    print('Humidity: $humidity%');

    print('\n=== 5-Day Forecast ===');

    int day = 1;
    await for (String forecast in forecastStream()) {
      print('Day $day: $forecast');
      day++;
    }

    print('Forecast complete!');
  } catch (e) {
    print('Error fetching weather: $e');
  }
}