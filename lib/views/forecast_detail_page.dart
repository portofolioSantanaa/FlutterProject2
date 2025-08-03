import 'package:flutter/material.dart';
import 'package:cek_cuaca/models/forecast_model.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class ForecastDetailPage extends StatelessWidget {
  final Forecast forecastItem;

  const ForecastDetailPage({super.key, required this.forecastItem});

  // Fungsi untuk mendapatkan ikon
  IconData _getWeatherIcon(String? mainCondition) {
    if (mainCondition == null) return WeatherIcons.day_cloudy;
    switch (mainCondition.toLowerCase()) {
      case 'clouds': return WeatherIcons.cloudy;
      case 'rain': return WeatherIcons.rain;
      case 'drizzle': return WeatherIcons.sprinkle;
      case 'shower rain': return WeatherIcons.showers;
      case 'thunderstorm': return WeatherIcons.thunderstorm;
      case 'clear': return WeatherIcons.day_sunny;
      default: return WeatherIcons.day_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(forecastItem.dateTime);
    final formattedTime = DateFormat('HH:mm').format(forecastItem.dateTime);

    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        title: Text('Detail Prakiraan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView( // Menggunakan ListView agar bisa di-scroll jika layar kecil
          children: [
            Text(formattedDate, style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Pukul $formattedTime WIB', style: TextStyle(fontSize: 18, color: Colors.white70)),
            
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  BoxedIcon(_getWeatherIcon(forecastItem.mainCondition), size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    '${forecastItem.temperature.round()}°C',
                    style: TextStyle(fontSize: 72, color: Colors.white, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    'Terasa seperti ${forecastItem.feelsLike.round()}°C',
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  Text(
                    // Mengubah huruf pertama setiap kata menjadi besar
                    toBeginningOfSentenceCase(forecastItem.description) ?? forecastItem.description,
                    style: TextStyle(fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoTile(WeatherIcons.humidity, 'Kelembapan', '${forecastItem.humidity}%'),
                _buildInfoTile(WeatherIcons.strong_wind, 'Angin', '${forecastItem.windSpeed.toStringAsFixed(1)} m/s'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Column(
      children: [
        BoxedIcon(icon, size: 28, color: Colors.white),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}