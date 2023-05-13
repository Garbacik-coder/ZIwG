import 'package:flutter/material.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/movies_predefined.dart';
import 'package:frontend/watchlist_screen.dart';
import 'package:frontend/rated_screen.dart';
import 'movie_tile.dart';

const double titleTextScaleFactor = 4.0;

void main() => runApp(const MovieRecommendationApp());

class MovieRecommendationApp extends StatelessWidget {
  const MovieRecommendationApp({super.key});

  static const String _title = 'Movie recommendation system';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(scaffoldBackgroundColor: Colors.teal[800]),
      home: const RootWidget(),
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

// legacy code, may be useful when implementing searchbar logic
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<StatefulWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    void searchMovies(String searchText) {
      print("do something");
    }

    return TextField(
      controller: searchController,
      onChanged: searchMovies,
      decoration: InputDecoration(
        hintText: "Search Movies",
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.black),
          onPressed: () {
            searchController.clear();
            searchMovies("");
          },
        ),
      ),
    );
  }
}

  // bool _isStarred = false;

  // Widget _listViewBody() {
  //   return ListView.separated(
  //     controller: _homeController,
  //     itemBuilder: (BuildContext context, int index) {
  //       return Center(
  //         child: GestureDetector(
  //           child: Image.asset('assets/images/65.jpg'),
  //           onTap: () {
  //             _showRatingDialog();
  //           },
  //         ),
  //       );
  //     },
  //     separatorBuilder: (BuildContext context, int index) => const Divider(
  //       thickness: 1,
  //     ),
  //     itemCount: 5,
  //   );
  // }

  // Future<void> _showRatingDialog() async {
  //   int rating = 0;
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Rate this image'),
  //         content: StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: List.generate(
  //                 5,
  //                 (index) {
  //                   return IconButton(
  //                     icon: Icon(
  //                       index < rating ? Icons.star : Icons.star_border,
  //                       color: index < rating ? Colors.yellow : null,
  //                     ),
  //                     onPressed: () {
  //                       setState(() {
  //                         rating = index + 1;
  //                       });
  //                     },
  //                   );
  //                 },
  //               ),
  //             );
  //           },
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('CANCEL'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               setState(() {
  //                 _isStarred = true;
  //                 print(rating);
  //               });
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
