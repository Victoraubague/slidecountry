import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CountriesListScreen(),
    );
  }
}

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({super.key});

  @override
  _CountriesListScreenState createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> with SingleTickerProviderStateMixin {
  List<dynamic> countries = [];
  bool isSorted = false;
  late AnimationController _controller;

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

  //tout ce code avant sert à cherccher les données


  @override
  void initState() {
    super.initState();
    fetchCountries();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void sortCountries() {
    setState(() {
      if (!isSorted) {
        countries.sort((a, b) => a['name']['common'].compareTo(b['name']['common']));
      } else {
        countries.shuffle(); 
      }
      isSorted = !isSorted;
    });


    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries of the World'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: sortCountries,
          ),
        ],
      ),

    
      body: countries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : AnimatedList(
              initialItemCount: countries.length,
              itemBuilder: (context, index, animation) {
                final country = countries[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: ListTile(
                    leading: Image.network(
                      country['flags']['png'],
                      width: 50,
                      height: 50,
                    ),
                    title: Text(country['name']['common']),
                    subtitle: Text('Capital: ${country['capital'] != null ? country['capital'][0] : 'N/A'}'),
                  ),
                );
              },
            ),
    );
  }
}
