import 'dart:ui';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/weather_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherServices _WeatherServices = WeatherServices();
  final TextEditingController _cityController = TextEditingController();

  String _city = "islamabad";
  Map<String, dynamic>? _currentweather;

  late bool _isConnected;

  @override
  void initState() {
    super.initState();
    _isConnected = true;

    _checkinternet();
    _fethcWeather();
  }

  Future<void> _checkinternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
        _fethcWeather();
      });
    }
  }

  Future<void> _fethcWeather() async {
    try {
      final weatherData = await _WeatherServices.fatchcurrentWehater(_city);

      setState(() {
        _currentweather = weatherData;
      });
    } catch (e) {
      print(e);
    }
  }

  void _ShowCitySelection() {
    _cityController.text = _city;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter the city Name"),
            content: TypeAheadField(
              suggestionsCallback: (pattern) {
                return _WeatherServices.fetchCitysuggestion(pattern);
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: _cityController,
                  focusNode: focusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("City"),
                  ),
                );
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(_cityController.text),
                );
              },
              onSelected: (city) {
                setState(() {
                  _city = city['name'];
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _city = _cityController.text;
                  });
                  Navigator.pop(context);
                  _fethcWeather();
                },
                child: Text('Submit'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isConnected
          ? _buildNoInternetWidget()
          : Container(
              child: _currentweather == null
                  ? Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          Color(0xFF1A2344),
                          Color.fromARGB(255, 125, 32, 142),
                          Colors.purple,
                          Color.fromARGB(255, 151, 44, 170),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          Color(0xFF1A2344),
                          Color.fromARGB(255, 125, 32, 142),
                          Colors.purple,
                          Color.fromARGB(255, 151, 44, 170),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                      child: ListView(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              InkWell(
                                // onTap: _ShowCitySelection,
                                child: Text(
                                  _city,
                                  style: GoogleFonts.lato(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                onTap: () {
                                  _ShowCitySelection();
                                  print("Search icon tapped");
                                },
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Image.network(
                                    'http:${_currentweather!['current']['condition']['icon']}',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover),
                                Text(
                                  '${_currentweather!['current']['temp_c'].round()}C',
                                  style: GoogleFonts.lato(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_currentweather!['current']['condition']['text']}',
                                  style: GoogleFonts.lato(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildwidgetdetail(
                                        'Humidity',
                                        Icons.opacity,
                                        _currentweather!['current']
                                            ['humidity']),
                                    _buildwidgetdetail(
                                        'sunrise',
                                        Icons.wb_sunny,
                                        _currentweather!['forecast']
                                                ['forecastday'][0]['astro']
                                            ['sunrise']),
                                    _buildwidgetdetail(
                                        'Sunset',
                                        Icons.brightness_3,
                                        _currentweather!['forecast']
                                                ['forecastday'][0]['astro']
                                            ['sunset']),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildwidgetdetail(String Label, IconData icon, dynamic value) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A2344).withOpacity(0.5),
                    Color(0xFF1A2344).withOpacity(0.2),
                  ],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(
                height: 8,
              ),
              Text(Label,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(
                height: 8,
              ),
              Text(value is String ? value : value.toString(),
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 80,
            color: Colors.grey[500],
          ),
          SizedBox(height: 20),
          Text(
            'No internet connection!',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkinternet(); // Check internet connection again
            },
            child: Text('Try Again',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
