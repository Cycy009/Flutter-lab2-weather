# Lab 2 - Dart Async Weather App

This project demonstrates an asynchronous weather application in Dart.  
It fetches current weather data and displays a 5-day forecast using async/await, Futures, and Streams.

## Run

```bash
dart run lab2.dart
```

## What is implemented

- `Future` + `async/await` weather fetch functions
- `try-catch` error handling in `main()`
- `Future.wait` parallel loading
- formatted weather report output
- `Stream`-based 5-day forecast with dates
- Bonus:
  - live weather data from Open-Meteo API (with fallback values)
  - extra `temperatureStream()` for hourly temperatures
  - loading spinner while async work runs
  - random error simulation support (toggle with `simulateErrors`)

## Notes

- If API access fails, the app automatically uses sample fallback data.
- To test random errors, set `simulateErrors` to `true` in `main()`.

## Future Work

- Add multi-location support.
- Integrate with mobile UI (Flutter).
- Improve error handling with retry logic.

