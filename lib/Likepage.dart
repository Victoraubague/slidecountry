import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  List<dynamic> countries = [];
  List<dynamic> filteredCountries = [];
  List<String> continents = ['All', 'Africa', 'Europe', 'Asia', 'Americas', 'Oceania'];
  String selectedContinent = 'All';
  int currentIndex = 0;
  double sliderValue = 0.5; 
  int roundNumber = 1;

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
  }

  void _filterByContinent(String continent) {
    setState(() {
      selectedContinent = continent;
      if (continent == 'All') {
        filteredCountries = countries;
      } else {
        filteredCountries = countries.where((country) {
          return country['continents'].contains(continent);
        }).toList();
      }

      currentIndex = 0;
      roundNumber = 1;
    });
  }

  void _onSwipe(dynamic country) {
    setState(() {
      filteredCountries.remove(country);

      if (filteredCountries.length == 1) {
        _showWinner(filteredCountries.first);
      }
      if (currentIndex + 1 >= filteredCountries.length) {
     
        currentIndex = 0;
        roundNumber++;
      }
    });
  }

  void _onSliderChange(double value) {
    setState(() {
      sliderValue = value;

     
      if (sliderValue <= 0.1) {
        _onButtonSelection(true);
        sliderValue = 0.5; 
      } else if (sliderValue >= 0.9) {
        _onButtonSelection(false); 
        sliderValue = 0.5; 
      }
    });
  }

  void _onButtonSelection(bool isCountry1) {
    setState(() {
      if (isCountry1) {
        _onSwipe(filteredCountries[currentIndex + 1]); 
      } else {
        _onSwipe(filteredCountries[currentIndex]); 
      }

      currentIndex += 2;

      if (currentIndex >= filteredCountries.length - 1) {
        currentIndex = 0;
        roundNumber++;
      }
    });
  }

  void _showWinner(dynamic country) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gagnant!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                country['flags']['png'],
                width: 100,
                height: 60,
              ),
              const SizedBox(height: 10),
              Text(
                country['name']['common'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Concours de Pays - Round $roundNumber'),
        actions: [
          DropdownButton<String>(
            value: selectedContinent,
            icon: const Icon(Icons.public, color: Colors.white),
            dropdownColor: Colors.blue,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _filterByContinent(newValue);
              }
            },
            items: continents.map<DropdownMenuItem<String>>((String continent) {
              return DropdownMenuItem<String>(
                value: continent,
                child: Text(continent),
              );
            }).toList(),
          ),
        ],
      ),
      body: filteredCountries.length > 1
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (currentIndex < filteredCountries.length)
                      _buildCountryCard(filteredCountries[currentIndex]), 
                    if (currentIndex + 1 < filteredCountries.length)
                      _buildCountryCard(filteredCountries[currentIndex + 1]), 
                  ],
                ),
                const SizedBox(height: 20),
                _buildSliderSelection(), 
              ],
            )
          : const Center(
              child: Text(
                'Aucun pays trouvé',
                style: TextStyle(fontSize: 24),
              ),
            ),
    );
  }

  Widget _buildCountryCard(dynamic country) {
    return Card(
      elevation: 5,
      child: Container(
        width: 150, 
        height: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              country['flags']['png'],
              width: 100,
              height: 60,
            ),
            const SizedBox(height: 20),
            Text(
              country['name']['common'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Capitale: ${country['capital'] != null ? country['capital'][0] : 'N/A'}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Continent: ${country['continents'][0]}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSelection() {
    return Column(
      children: [
        const Text(
          'Glisser pour choisir',
          style: TextStyle(fontSize: 18),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: _CustomFlagThumb(), 
            trackHeight: 4.0,
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.grey[300],
            overlayColor: Colors.blue.withAlpha(32),
            valueIndicatorTextStyle: const TextStyle(color: Colors.black),
          ),
          child: Slider(
            value: sliderValue,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (value) {
              _onSliderChange(value);
            },
          ),
        ),
      ],
    );
  }
}


class _CustomFlagThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(35.0, 35.0); 
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
      required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    const flagIcon = Icons.flag; 
    const flagSize = 24.0;

    
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(flagIcon.codePoint),
        style: TextStyle(
          fontSize: flagSize,
          fontFamily: flagIcon.fontFamily,
          color: Colors.blue,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );
    painter.layout();
    painter.paint(canvas, Offset(center.dx - (flagSize / 2), center.dy - (flagSize / 2)));
  }
}
