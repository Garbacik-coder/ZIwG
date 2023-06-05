import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/movies_predefined.dart';
import 'package:frontend/watchlist_screen.dart';
import 'package:frontend/rated_screen.dart';
import 'movie_tile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

const double titleTextScaleFactor = 4.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MovieRecommendationApp());
}

class MovieRecommendationApp extends StatelessWidget {
  const MovieRecommendationApp({super.key});

  static const String _title = 'Movie recommendation system';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.teal[800],
        // textTheme: Theme.of(context).textTheme.apply(
        //       bodyColor: Colors.white,
        //       displayColor: Colors.white,
        //     ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.currentUser?.getIdToken();
    // FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInScreen(
            providerConfigs: [
              EmailProviderConfiguration(),
            ],
          );
        }

        return const RootWidget();
      },
    );
  }
}

const List<Widget> pages = <Widget>[
  HomeScreen(),
  WatchlistScreen(),
  RatedScreen(),
];

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  final ScrollController _homeController = ScrollController();
  int _selectedIndex = 0;
  List<Movie> movies = moviesPredefined;

  void searchMovies(String searchStr) {
    setState(() {
      final String lowerSearchStr = searchStr.toLowerCase();
      movies = moviesPredefined
          .where((movie) => movie.title.toLowerCase().contains(lowerSearchStr))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey[400],
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.teal[800],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 40,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.replay_circle_filled_outlined,
              size: 40,
            ),
            label: 'To watch',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.recommend,
              size: 40,
            ),
            label: 'Rated',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.logout,
                size: 40,
              ),
              label: 'Log Out'),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          // only scroll to top when current index is selected.
          if (_selectedIndex == index) {
            _homeController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }

          switch (index) {
            case 0:
              break;
            case 1:
              break;
            case 2:
              break;
            case 3:
              break;
          }

          if (index < 3) {
            setState(
              () {
                _selectedIndex = index;
              },
            );
          }
        },
      ),
    );
  }
}
