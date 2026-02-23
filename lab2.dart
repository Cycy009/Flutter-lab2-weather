import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

final Random _random = Random();

class WeatherSnapshot {
  final String condition;
  final int temperature;
  final int humidity;

  const WeatherSnapshot({
    required this.condition,
    required this.temperature,
    required this.humidity,
  });
}

class ForecastEntry {
  final DateTime date;
  final String condition;

  const ForecastEntry({required this.date, required this.condition});
}

class WeatherBundle {
  final WeatherSnapshot current;
  final List<ForecastEntry> dailyForecast;
  final List<int> hourlyTemperatures;

  const WeatherBundle({
    required this.current,
    required this.dailyForecast,
    required this.hourlyTemperatures,
  });
}

void maybeThrowRandomError(
  String action, {
  required bool enabled,
  double chance = 0.2,
}) {
  if (!enabled) return;
  if (_random.nextDouble() < chance) {
    throw Exception('Simulated error while fetching $action.');
  }
}

Future<String> fetchCurrentWeather({
  String? liveCondition,
  bool simulateErrors = false,
}) async {
  print('Fetching current weather...');
  await Future.delayed(const Duration(seconds: 2));
  maybeThrowRandomError('current weather', enabled: simulateErrors);
  return liveCondition ?? 'Sunny';
}

Future<int> fetchTemperature({
  int? liveTemperature,
  bool simulateErrors = false,
}) async {
  await Future.delayed(const Duration(seconds: 1));
  maybeThrowRandomError('temperature', enabled: simulateErrors);
  return liveTemperature ?? 28;
}

Future<int> fetchHumidity({
  int? liveHumidity,
  bool simulateErrors = false,
}) async {
  await Future.delayed(const Duration(seconds: 1));
  maybeThrowRandomError('humidity', enabled: simulateErrors);
  return liveHumidity ?? 65;
}

Future<void> displayWeatherReport({
  WeatherSnapshot? liveCurrent,
  bool simulateErrors = false,
}) async {
  final results = await Future.wait<dynamic>([
    fetchCurrentWeather(
      liveCondition: liveCurrent?.condition,
      simulateErrors: simulateErrors,
    ),
    fetchTemperature(
      liveTemperature: liveCurrent?.temperature,
      simulateErrors: simulateErrors,
    ),
    fetchHumidity(
      liveHumidity: liveCurrent?.humidity,
      simulateErrors: simulateErrors,
    ),
  ]);

  final weather = results[0] as String;
  final temp = results[1] as int;
  final humidity = results[2] as int;

  print('\n=== Weather Report ===');
  print('Current Weather: $weather');
  print('Temperature: $temp C');
  print('Humidity: $humidity%');
  print('======================');
}

Stream<String> forecastStream([List<String>? customForecasts]) async* {
  final forecasts = <String>[
    ...(customForecasts ??
        const ['Partly Cloudy', 'Rainy', 'Sunny', 'Cloudy', 'Sunny']),
  ];

  while (forecasts.length < 5) {
    forecasts.add('Sunny');
  }

  for (final forecast in forecasts.take(5)) {
    await Future.delayed(const Duration(seconds: 1));
    yield forecast;
  }
}

Stream<int> temperatureStream([List<int>? customHourlyTemps]) async* {
  final hourlyTemps = <int>[
    ...(customHourlyTemps ?? const [28, 27, 27, 26, 26, 25]),
  ];

  for (final temp in hourlyTemps.take(6)) {
    await Future.delayed(const Duration(milliseconds: 700));
    yield temp;
  }
}

Future<T> runWithSpinner<T>(
  Future<T> operation, {
  String label = 'Loading',
}) async {
  const frames = ['|', '/', '-', r'\'];
  var frameIndex = 0;
  stdout.write('$label ');

  final timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
    stdout.write('\r$label ${frames[frameIndex % frames.length]}');
    frameIndex++;
  });

  try {
    return await operation;
  } finally {
    timer.cancel();
    stdout.write('\r$label done.   \n');
  }
}

String weatherCodeToLabel(int code) {
  if (code == 0) return 'Clear';
  if ([1, 2, 3].contains(code)) return 'Partly Cloudy';
  if ([45, 48].contains(code)) return 'Foggy';
  if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
  if ([61, 63, 65, 66, 67].contains(code)) return 'Rainy';
  if ([71, 73, 75, 77].contains(code)) return 'Snowy';
  if ([80, 81, 82].contains(code)) return 'Rain Showers';
  if ([95, 96, 99].contains(code)) return 'Thunderstorm';
  return 'Unknown';
}

String formatShortDate(DateTime date) {
  const months = [
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

Future<WeatherBundle?> fetchLiveWeatherBundle() async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': '40.7128',
    'longitude': '-74.0060',
    'current': 'temperature_2m,relative_humidity_2m,weather_code',
    'daily': 'weather_code',
    'hourly': 'temperature_2m',
    'forecast_days': '5',
    'timezone': 'auto',
  });

  final client = HttpClient();

  try {
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.userAgentHeader, 'dart-weather-lab/1.0');

    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode} from Open-Meteo.');
    }

    final body = await utf8.decoder.bind(response).join();
    final decoded = jsonDecode(body) as Map<String, dynamic>;

    final current = decoded['current'] as Map<String, dynamic>?;
    final daily = decoded['daily'] as Map<String, dynamic>?;
    final hourly = decoded['hourly'] as Map<String, dynamic>?;

    if (current == null || daily == null || hourly == null) {
      throw const FormatException('Missing weather sections in API response.');
    }

    final currentCode = (current['weather_code'] as num).toInt();
    final currentTemp = (current['temperature_2m'] as num).round();
    final currentHumidity = (current['relative_humidity_2m'] as num).round();

    final times = (daily['time'] as List<dynamic>).cast<String>();
    final codes = (daily['weather_code'] as List<dynamic>)
        .map((v) => (v as num).toInt())
        .toList();

    final forecastCount = min(5, min(times.length, codes.length));
    final forecast = <ForecastEntry>[];
    for (var i = 0; i < forecastCount; i++) {
      forecast.add(
        ForecastEntry(
          date: DateTime.parse(times[i]),
          condition: weatherCodeToLabel(codes[i]),
        ),
      );
    }

    final hourlyTemps = (hourly['temperature_2m'] as List<dynamic>)
        .take(6)
        .map((v) => (v as num).round())
        .toList();

    return WeatherBundle(
      current: WeatherSnapshot(
        condition: weatherCodeToLabel(currentCode),
        temperature: currentTemp,
        humidity: currentHumidity,
      ),
      dailyForecast: forecast,
      hourlyTemperatures: hourlyTemps,
    );
  } catch (e) {
    print('Live API unavailable, using fallback sample data. ($e)');
    return null;
  } finally {
    client.close(force: true);
  }
}

Future<void> displayForecast({List<ForecastEntry>? liveForecast}) async {
  final customConditions = liveForecast
      ?.map((entry) => entry.condition)
      .toList();

  print('\n=== 5-Day Forecast ===');
  var day = 1;
  await for (final forecast in forecastStream(customConditions)) {
    final date = (liveForecast != null && day <= liveForecast.length)
        ? liveForecast[day - 1].date
        : DateTime.now().add(Duration(days: day - 1));
    print('Day $day (${formatShortDate(date)}): $forecast');
    day++;
  }
  print('Forecast complete!');
}

Future<void> displayTemperatureStream({List<int>? hourlyTemps}) async {
  print('\n=== Hourly Temperature Stream (Bonus) ===');
  var hour = 1;
  await for (final temp in temperatureStream(hourlyTemps)) {
    print('Hour $hour: $temp C');
    hour++;
  }
  print('Hourly stream complete!');
}

Future<void> main() async {
  print('=== Weather App ===');

  const useLiveApi = true;
  const simulateErrors = false;

  WeatherBundle? liveBundle;
  if (useLiveApi) {
    liveBundle = await runWithSpinner(
      fetchLiveWeatherBundle(),
      label: 'Loading live weather',
    );
  }

  try {
    await displayWeatherReport(
      liveCurrent: liveBundle?.current,
      simulateErrors: simulateErrors,
    );

    await displayForecast(liveForecast: liveBundle?.dailyForecast);

    await displayTemperatureStream(hourlyTemps: liveBundle?.hourlyTemperatures);

    print('Weather app completed!');
  } catch (e) {
    print('Error fetching weather data: $e');
  }
}
