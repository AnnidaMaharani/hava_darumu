import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HavaDetayEkran extends StatefulWidget {
  final String sehir;

  const HavaDetayEkran({super.key, required this.sehir});

  @override
  _HavaDetayEkranState createState() => _HavaDetayEkranState();
}

class _HavaDetayEkranState extends State<HavaDetayEkran> {
  Map<String, dynamic>? havaDurumu;

  @override
  void initState() {
    super.initState();
    _getHavaDurumu(widget.sehir);
  }

  Future<void> _getHavaDurumu(String sehir) async {
    const apiKey = 'dc81df4ae32d4c0c8ff65037250901';
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$sehir&days=5&aqi=no&alerts=no');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          havaDurumu = json.decode(response.body);
        });
      } else {
        throw Exception('Hava durumu bilgisi alınamadı.');
      }
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  Widget _buildCurrentWeather() {
    final current = havaDurumu!['current'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueAccent.withOpacity(0.2),
      ),
      child: Row(
        children: [
          Image.network(
            'https:${current['condition']['icon']}',
            width: 80,
            height: 80,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${current['temp_c']}°C',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              Text(
                current['condition']['text'],
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecast() {
    final forecastDays = havaDurumu!['forecast']['forecastday'];
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: forecastDays.length,
      separatorBuilder: (context, index) => const Divider(height: 20),
      itemBuilder: (context, index) {
        final day = forecastDays[index];
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Row(
            children: [
              Image.network(
                'https:${day['day']['condition']['icon']}',
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day['date'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${day['day']['avgtemp_c']}°C - ${day['day']['condition']['text']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sehir} Detayları'),
      ),
      body: havaDurumu == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şu Anki Hava Durumu',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildCurrentWeather(),
                  const SizedBox(height: 20),
                  const Text(
                    '5 Günlük Tahmin',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildForecast(),
                ],
              ),
            ),
    );
  }
}
