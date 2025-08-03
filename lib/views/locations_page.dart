import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  List<String> _savedCities = [];
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  // Fungsi untuk memuat daftar kota dari penyimpanan lokal
  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities = prefs.getStringList('saved_cities') ?? [];
    });
  }

  // Fungsi untuk menyimpan kota baru
  Future<void> _addCity(String cityName) async {
    if (cityName.isEmpty || _savedCities.map((c) => c.toLowerCase()).contains(cityName.toLowerCase())) {
      // Jangan tambahkan jika kosong atau sudah ada
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _savedCities.add(cityName);
    await prefs.setStringList('saved_cities', _savedCities);
    _loadCities(); // Muat ulang untuk update UI
  }

  // Fungsi untuk menghapus kota
  Future<void> _removeCity(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _savedCities.removeAt(index);
    await prefs.setStringList('saved_cities', _savedCities);
    _loadCities();
  }

  // Menampilkan dialog untuk menambah kota
  void _showAddCityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          title: const Text('Tambah Kota Favorit', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _cityController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Masukkan nama kota...',
              hintStyle: TextStyle(color: Colors.white54)
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                _addCity(_cityController.text);
                _cityController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Daftar Lokasi"),
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCityDialog,
        child: const Icon(Icons.add),
      ),
      body: _savedCities.isEmpty
          ? const Center(
              child: Text("Anda belum punya lokasi tersimpan.", style: TextStyle(color: Colors.white70)),
            )
          : ListView.builder(
              itemCount: _savedCities.length,
              itemBuilder: (context, index) {
                final city = _savedCities[index];
                return ListTile(
                  title: Text(city, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removeCity(index),
                  ),
                  onTap: () {
                    // Kirim nama kota kembali ke halaman utama
                    Navigator.of(context).pop(city);
                  },
                );
              },
            ),
    );
  }
}