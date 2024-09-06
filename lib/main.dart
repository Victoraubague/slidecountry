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
    const CountriesListScreen(), 
    const LikePage(),            
    const SlidePage(),            
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purpleAccent, Colors.white],
              ),
            ),
          ),
          _pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 169, 8, 197),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_rounded, size: 28),
            label: 'Pays',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on, size: 28),
            label: 'Tinder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 28),
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
  bool isSortedAscending = true; 
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


  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCountries = countries.where((country) {
        final countryName = country['name']['common'].toLowerCase();
        return countryName.contains(query);
      }).toList();
    });
  }


  void _sortCountries() {
    setState(() {
      filteredCountries.sort((a, b) {
        return isSortedAscending
            ? a['name']['common'].compareTo(b['name']['common'])
            : b['name']['common'].compareTo(a['name']['common']);
      });
      isSortedAscending = !isSortedAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CloudAppBarClipper(),
              child: Container(
                height: 150, 
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color.fromARGB(255, 186, 28, 214)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    
                    children: [
                      const Text(
                        'Liste pays',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSortedAscending
                              ? Icons.sort_by_alpha
                              : Icons.sort_by_alpha_outlined,
                          color: Colors.black,
                        ),
                        onPressed: _sortCountries,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 130, 
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          Padding(
            padding: const EdgeInsets.only(top: 200), 
            child: filteredCountries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = filteredCountries[index];
                      return _buildCountryCard(country); 
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCard(dynamic country) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Image.network(
          country['flags']['png'],
          width: 50,
          height: 50,
        ),
        title: Text(country['name']['common'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Capitale: ${country['capital'] != null ? country['capital'][0] : 'N/A'}\n'
          'Nom officiel: ${country['name']['official'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

class CloudAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 40); 
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height - 30);
    var secondControlPoint = Offset(size.width * 0.75, size.height - 70);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0); 
    path.close(); 
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
