import 'package:flutter/material.dart';
import 'package:havadurumuproje/services/weather_service.dart';
import 'package:havadurumuproje/models/weather_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<WeatherModels>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherService().getWeather();
  }

  void _retry() {
    setState(() {
      _weatherFuture = WeatherService().getWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: FutureBuilder<List<WeatherModels>>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hata: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              );
            } else if (snapshot.hasData) {
              final weatherData = snapshot.data!;
              return ListView.builder(
                itemCount: weatherData.length,
                itemBuilder: (context, index) {
                  final WeatherModels weather = weatherData[index];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Image.network(weather.ikon, width: 100),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 25),
                          child: Text(
                            '${weather.gun}\n ${weather.durum.toUpperCase()} ${weather.derece}°C',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Min: ${weather.min}°C'),
                                Text('Max: ${weather.max}°C'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Gece: ${weather.gece}°C'),
                                Text('Nem: ${weather.nem}%'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Text('Veri bulunamadı.');
            }
          },
        ),
      ),
    );
  }
}
