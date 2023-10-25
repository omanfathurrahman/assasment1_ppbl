import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

class StockPrice {
  final DateTime timestamp;
  final double high;  // Mengganti 'price' menjadi 'high'

  StockPrice(this.timestamp, this.high);

  factory StockPrice.fromJson(Map<String, dynamic> json) {
    return StockPrice(
      DateTime.fromMillisecondsSinceEpoch(json['t'] * 1000),
      json['h'].toDouble(),  // Menggunakan atribut "h" (harga tertinggi)
    );
  }
}



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pergerakan Harga Saham'),
        ),
        body: StockPriceChart(),
      ),
    );
  }
}

class StockPriceChart extends StatefulWidget {
  @override
  _StockPriceChartState createState() => _StockPriceChartState();
}

class _StockPriceChartState extends State<StockPriceChart> {
  List<StockPrice> stockPrices = [];

  @override
  void initState() {
    super.initState();
    loadStockPrices();
  }

  Future<void> loadStockPrices() async {
    final response = await http.get(
        Uri.parse(
            'https://api.polygon.io/v2/aggs/ticker/F/range/1/day/2023-01-09/2023-02-09?adjusted=true&sort=asc&limit=120&apiKey=aTTEHjJyh3hMjWDkp0cADrVhkFp7UdID'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body)['results'];
      List<StockPrice> prices = jsonList.map((e) => StockPrice.fromJson(e)).toList();

      setState(() {
        stockPrices = prices;
      });
    } else {
      throw Exception('Gagal memuat data harga saham');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Kode Saham F', style: TextStyle(fontSize: 18)),
        ElevatedButton(
          onPressed: () {
            loadStockPrices();
          },
          child: Text('Refresh'),
        ),
        Expanded(
          child: charts.TimeSeriesChart(
            [
              charts.Series<StockPrice, DateTime>(
                
                id: 'Harga Tertinggi',
                domainFn: (StockPrice price, _) => price.timestamp,
                measureFn: (StockPrice price, _) => price.high, // Menggunakan atribut "h" (harga tertinggi)
                data: stockPrices,
              ),
            ],
            animate: true,
          ),
        ),
      ],
    );
  }
}