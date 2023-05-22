import 'package:flutter/material.dart';
import 'package:frontend/movie_tile.dart';
import 'package:frontend/movies_predefined.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const double borderRadiusProportion = 0.1;

Future<http.Response> fetchMovies() {
  final queryParameters = {
    'offset': 0,
    'limit': 3,
  };
  return http.get(Uri.https('10.0.2.2:8080', '/api/movies', queryParameters));
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController controller = ScrollController();
  List<Movie> movies = [];
  bool isSearchbarFilled = false;

  void searchFunction(String searchStr) {
    setState(() {
      final String lowerSearchStr = searchStr.toLowerCase();
      movies = moviesPredefined
          .where((movie) => movie.title.toLowerCase().contains(lowerSearchStr))
          .toList();
      isSearchbarFilled = lowerSearchStr.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listBorderRadius =
        MediaQuery.of(context).size.width * borderRadiusProportion;

    return ListView.builder(
      controller: controller,
      itemCount: 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(listBorderRadius)),
                  child: TextField(
                    onChanged: searchFunction,
                    decoration: const InputDecoration(
                      hintText: "search movies",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(listBorderRadius),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: movies.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      isSearchbarFilled ? "Matching movies" : "Recommended",
                      textScaleFactor: titleScaleFactor,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  final movie = movies[index - 1];
                  return MovieTile(movie: movie);
                }
              },
            ),
          );
        }
      },
    );
  }
}
