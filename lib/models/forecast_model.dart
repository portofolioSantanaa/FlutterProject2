class Forecast {
  final DateTime dateTime;
  final double temperature;
  final String mainCondition;
  final String description;
  final double feelsLike;
  final int humidity;
  final double windSpeed;

  Forecast({
    required this.dateTime,
    required this.temperature,
    required this.mainCondition,
    required this.description,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true).toLocal(),
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}