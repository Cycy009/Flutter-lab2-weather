void main() {
  print("=== Weather App ===");
  print("Fetching current weather...");


  String currentWeather = "Sunny";
  int temperature = 28;
  int humidity = 65;

  print("=== Weather Report ===");
  print("Current Weather: $currentWeather");
  print("Temperature: $temperature°C");
  print("Humidity: $humidity%");

  print("=== 5-Day Forecast ===");


  var forecastItmean = [
    "Day 1 (Feb 23): Partly Cloudy",
    "Day 2 (Feb 24): Rainy",
    "Day 3 (Feb 25): Sunny",
    "Day 4 (Feb 26): Cloudy",
    "Day 5 (Feb 27): Sunny"
  ];


  for (String forecast in forecastItmean) {
    print(forecast);
  }

  print("Forecast complete! Weather app completed!");
}