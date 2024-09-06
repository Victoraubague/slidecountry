import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'LikePage.dart';  
import 'SlidePage.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CountriesListScreen(),  // Country list page
    const LikePage(),             // Tinder-style page
    const SlidePage(),            // Ranking page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Text('🚩', style: TextStyle(fontSize: 24)),
            label: 'Pays',
          ),
          BottomNavigationBarItem(
            icon: Text('⚡️', style: TextStyle(fontSize: 24)),
            label: 'Tinder',
          ),
          BottomNavigationBarItem(
            icon: Text('❤️', style: TextStyle(fontSize: 24)),
            label: 'Classement',
          ),
        ],
      ),
    );
  }
}

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({super.key});

  @override
  _CountriesListScreenState createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  List<dynamic> countries = [];
  List<dynamic> filteredCountries = [];
  bool isSortedAscending = true; // Track sorting order
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
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter countries based on search input
  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCountries = countries.where((country) {
        final countryName = country['name']['common'].toLowerCase();
        return countryName.contains(query);
      }).toList();
    });
  }

  // Sort countries alphabetically
  void _sortCountries() {
    setState(() {
      filteredCountries.sort((a, b) {
        return isSortedAscending
            ? a['name']['common'].compareTo(b['name']['common'])
            : b['name']['common'].compareTo(a['name']['common']);
      });
      isSortedAscending = !isSortedAscending; // Toggle sorting order
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des pays'),
        actions: [
          IconButton(
            icon: Icon(isSortedAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
            onPressed: _sortCountries,
          ),
          
          
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un pays...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
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
                    'Capitale: ${country['capital'] != null ? country['capital'][0] : 'N/A'}\n'
                    'Nom officiel: ${country['name']['official'] ?? 'N/A'}',
                  ),
                );
              },
            ),
    );
  }
}
