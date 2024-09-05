import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CountryInfoScreen(),
    );
  }
}

class CountryInfoScreen extends StatefulWidget {
  @override
  _CountryInfoScreenState createState() => _CountryInfoScreenState();
}

class _CountryInfoScreenState extends State<CountryInfoScreen> {
  late Map<String, dynamic> countryData;

  Future<void> fetchCountryInfo() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/name/france'));

    if (response.statusCode == 200) {
      setState(() {
        countryData = json.decode(response.body)[0];
      });
    } else {
      throw Exception('Failed to load country data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCountryInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Information'),
      ),
      body: countryData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Country: ${countryData['name']['common']}'),
                  Text('Capital: ${countryData['capital'][0]}'),
                  Text('Population: ${countryData['population']}'),
                  Text('Region: ${countryData['region']}'),
                  Text('Subregion: ${countryData['subregion']}'),
                  Text('Currency: ${countryData['currencies'].values.first['name']}'),
                  Image.network(countryData['flags']['png']),
                ],
              ),
            ),
    );
  }
}
