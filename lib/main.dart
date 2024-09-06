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
  List<dynamic> filteredCountries = [];
  bool isSorted = false;
  bool isSearching = false;
  late AnimationController _controller;
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

    if (response.statusCode == 200) {
      setState(() {
        countries = json.decode(response.body);
        filteredCountries = countries;
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void sortCountries() {
    setState(() {
      if (!isSorted) {
        filteredCountries.sort((a, b) => a['name']['common'].compareTo(b['name']['common']));
      } else {
        filteredCountries.shuffle();
      }
      isSorted = !isSorted;
    });

    _controller.forward(from: 0.0);
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase(); 
    setState(() {
      filteredCountries = countries.where((country) {
        final countryName = country['name']['common'].toLowerCase();
        return countryName.contains(query); 
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? const Text('Liste des pays')
            : TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un pays...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  filteredCountries = countries; 
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: sortCountries,
          ),
        ],
      ),
      body: filteredCountries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];
                return ListTile(
                  leading: Image.network(
                    country['flags']['png'],
                    width: 50,
                    height: 50,
                  ),
                  title: Text(country['name']['common']),
                  subtitle: Text(
                    'Capital: ${country['capital'] != null ? country['capital'][0] : 'N/A'}\n'
                    'Official: ${country['name']['official'] ?? 'N/A'}',
                  ),
                );
              },
            ),
    );
  }
}
