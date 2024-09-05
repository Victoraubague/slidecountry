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
      home: CountriesListScreen(),
    );
  }
}

class CountriesListScreen extends StatefulWidget {
  @override
  _CountriesListScreenState createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  List<dynamic> countries = [];

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

    if (response.statusCode == 200) {
      setState(() {
        countries = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tout les pays'),
      ),
      body: countries.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  leading: Image.network(
                    country['flags']['png'],
                    width: 50,
                    height: 50,
                  ),
                  title: Text(country['name']['common']),
                  subtitle: Text('Capital: ${country['capital'] != null ? country['capital'][0] : 'N/A'}'),
                );
              },
            ),
    );
  }
}
