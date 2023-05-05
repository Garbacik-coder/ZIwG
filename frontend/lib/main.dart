import 'package:flutter/material.dart';
import 'movie_tile.dart';

List<Movie> movies = [
  Movie(
    "The Shawshank Redemption",
    "Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.",
    "Drama",
    "9.3",
    "1994",
    "2h 22min",
    "https://upload.wikimedia.org/wikipedia/en/8/81/ShawshankRedemptionMoviePoster.jpg",
    false,
    true,
    9,
  ),
  Movie(
    "The Dark Knight",
    "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.",
    "Action, Crime, Drama",
    "9.0",
    "2008",
    "2h 32min",
    "https://upload.wikimedia.org/wikipedia/en/1/1c/The_Dark_Knight_%282008_film%29.jpg",
    true,
    true,
    10,
  ),
  Movie(
    "Inception",
    "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
    "Action, Adventure, Sci-Fi",
    "8.8",
    "2010",
    "2h 28min",
    "https://upload.wikimedia.org/wikipedia/en/2/2e/Inception_%282010%29_theatrical_poster.jpg",
    true,
    true,
    8,
  ),
  Movie(
    "Forrest Gump",
    "The presidencies of Kennedy and Johnson, the events of Vietnam, Watergate, and other historical events unfold through the perspective of an Alabama man with an IQ of 75, whose only desire is to be reunited with his childhood sweetheart.",
    "Drama, Romance",
    "8.8",
    "1994",
    "2h 22min",
    "https://upload.wikimedia.org/wikipedia/en/6/67/Forrest_Gump_poster.jpg",
    false,
    true,
    8,
  ),
  Movie(
    "The Godfather",
    "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.",
    "Crime, Drama",
    "9.2",
    "1972",
    "2h 55min",
    "https://upload.wikimedia.org/wikipedia/en/1/1c/Godfather_ver1.jpg",
    false,
    true,
    9,
  ),
];

void main() => runApp(const MovieRecommendationApp());

class MovieRecommendationApp extends StatelessWidget {
  const MovieRecommendationApp({super.key});

  static const String _title = 'Movie recommendation system';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: RootWidget(),
    );
  }
}

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();

  Widget _listViewBody() {
    return ListView.separated(
        controller: _homeController,
        itemBuilder: (BuildContext context, int index) {
          return Center(child: Image.asset('assets/images/65.jpg'));
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
              thickness: 1,
            ),
        itemCount: 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SearchBarWidget(),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieTile(movie: movie);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.replay_circle_filled_outlined,
              color: Colors.black,
            ),
            label: 'Recently Watched',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.recommend,
              color: Colors.black,
            ),
            label: 'Recommendation',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              label: 'Log Out'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 8, 77, 23),
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

          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }
}

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
