import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_circle, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Cek Cuaca v1.0",
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Dibuat oleh Jeriko,\ndibantu oleh Yanto si AI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}