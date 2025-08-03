import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:cek_cuaca/models/forecast_model.dart';
import 'package:cek_cuaca/models/weather_model.dart';
import 'package:cek_cuaca/services/weather_service.dart';
import 'package:cek_cuaca/views/about_page.dart';
import 'package:cek_cuaca/views/forecast_detail_page.dart';
import 'package:cek_cuaca/views/locations_page.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cek Cuaca by Jeriko',
      debugShowCheckedModeBanner: false,
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});
  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('dbb6bc4b33a4405f9a403da62cc232c5');
  Weather? _weather;
  List<Forecast> _forecast = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCurrentLocation();
  }

  Gradient _getBackgroundGradient() {
    if (_weather == null) return const LinearGradient(colors: [Color(0xff2c3e50), Color(0xff34495e)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    switch (_weather!.mainCondition.toLowerCase()) {
      case 'clear': return const LinearGradient(colors: [Color(0xff4a90e2), Color(0xff81c7f5)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'clouds': return const LinearGradient(colors: [Color(0xff54717a), Color(0xff94a6ab)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'rain': case 'drizzle': case 'shower rain': return const LinearGradient(colors: [Color(0xff2c3e50), Color(0xff34495e)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'thunderstorm': return const LinearGradient(colors: [Color(0xff232526), Color(0xff414345)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      default: return const LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }
  }
  
  _fetchWeather({String? cityName, double? lat, double? lon}) async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      Weather weatherData;
      List<Forecast> forecastData;
      if (cityName != null) {
        weatherData = await _weatherService.getCurrentWeatherByCity(cityName);
        // Kita perlu koordinat untuk forecast, jadi kita ambil dari data cuaca saat ini
        Map<String, dynamic> rawWeatherData = await _weatherService.getRawWeatherByCity(cityName);
        final coords = rawWeatherData['coord'];
        forecastData = await _weatherService.getFiveDayForecastByCoordinates(coords['lat'], coords['lon']);
      } else if (lat != null && lon != null) {
        weatherData = await _weatherService.getCurrentWeatherByCoordinates(lat, lon);
        forecastData = await _weatherService.getFiveDayForecastByCoordinates(lat, lon);
      } else {
        throw Exception("Lokasi tidak valid");
      }
      setState(() {
        _weather = weatherData;
        _forecast = forecastData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal mendapatkan data. Periksa koneksi atau nama kota.";
        _isLoading = false;
      });
    }
  }

  _fetchWeatherForCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _fetchWeather(cityName: 'Jakarta');
    } else {
      Position position = await Geolocator.getCurrentPosition();
      _fetchWeather(lat: position.latitude, lon: position.longitude);
    }
  }

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
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(gradient: _getBackgroundGradient()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Cek Cuaca Jeriko,Yanto"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final searchResult = await showSearch<String>(context: context, delegate: CitySearchDelegate());
                if (searchResult != null && searchResult.isNotEmpty) {
                  _fetchWeather(cityName: searchResult);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _fetchWeatherForCurrentLocation,
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xff1e1e1e).withOpacity(0.9),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xff2c2c2c)),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.cloud, color: Colors.white),
                title: const Text('Cek Cuaca', style: TextStyle(color: Colors.white)),
                onTap: () { Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.location_city, color: Colors.white),
                title: const Text('Daftar Lokasi', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final selectedCity = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const LocationsPage()));
                  if (selectedCity != null && selectedCity.isNotEmpty) {
                    _fetchWeather(cityName: selectedCity);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.white),
                title: const Text('Tentang Aplikasi', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _errorMessage.isNotEmpty
                    ? Text(_errorMessage, style: const TextStyle(color: Colors.yellow, fontSize: 16))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox.shrink(),
                          Column(
                            children: [
                              Text(_weather?.cityName ?? "Memuat...", style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                              BoxedIcon(_getWeatherIcon(_weather?.mainCondition), size: 64, color: Colors.white),
                              Text('${_weather?.temperature.round() ?? 0}°C', style: const TextStyle(fontSize: 64, color: Colors.white, fontWeight: FontWeight.w200)),
                              Text(_weather?.mainCondition ?? "", style: const TextStyle(fontSize: 20, color: Colors.white70)),
                            ],
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, duration: 500.ms),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text("Prakiraan Cuaca", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  itemCount: _forecast.length,
                                  itemBuilder: (context, index) {
                                    final item = _forecast[index];
                                    return GestureDetector(
                                      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ForecastDetailPage(forecastItem: item))); },
                                      child: Container(
                                        width: 100,
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(DateFormat('HH:mm').format(item.dateTime), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            BoxedIcon(_getWeatherIcon(item.mainCondition), size: 32, color: Colors.white),
                                            Text('${item.temperature.round()}°C', style: const TextStyle(color: Colors.white, fontSize: 18)),
                                            Text(DateFormat('d MMM').format(item.dateTime), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Text('Dibuat oleh Jeriko, dibantu oleh Yanto si AI jelek dari Gemini', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white38)),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class CitySearchDelegate extends SearchDelegate<String> {
  final weatherService = WeatherService('MASUKKAN_API_KEY_OPENWEATHERMAP_ANDA');
  
  @override
  String get searchFieldLabel => 'Cari kota di Indonesia...';
  
  @override
  ThemeData appBarTheme(BuildContext context) { return Theme.of(context).copyWith(scaffoldBackgroundColor: Colors.blueGrey[900], appBarTheme: const AppBarTheme(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white), inputDecorationTheme: const InputDecorationTheme(hintStyle: TextStyle(color: Colors.white70)), textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white)); }
  
  @override
  List<Widget>? buildActions(BuildContext context) { return [IconButton(icon: const Icon(Icons.clear), onPressed: () { query = ''; })]; }
  
  @override
  Widget? buildLeading(BuildContext context) { return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { close(context, ''); }); }
  
  @override
  Widget buildResults(BuildContext context) { if (query.isNotEmpty) { close(context, query); } return Container(); }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) { return Container(color: Colors.blueGrey[900], child: const Center(child: Text('Mulai ketik untuk mencari kota.', style: TextStyle(color: Colors.white54)))); }
    return FutureBuilder<List<dynamic>>(
      future: weatherService.getCitySuggestions(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator()); }
        if (!snapshot.hasData || snapshot.data!.isEmpty) { return Container(color: Colors.blueGrey[900], child: const Center(child: Text('Kota tidak ditemukan.', style: TextStyle(color: Colors.white54)))); }
        return Container(
          color: Colors.blueGrey[900],
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final city = snapshot.data![index];
              return ListTile(
                title: Text(city['name'], style: const TextStyle(color: Colors.white)),
                onTap: () { close(context, city['name']); },
              );
            },
          ),
        );
      },
    );
  }
}