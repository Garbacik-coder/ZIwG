import 'package:flutter/material.dart';
import 'package:frontend/movie_tile.dart';
import 'package:frontend/movies_predefined.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

const double borderRadiusProportion = 0.1;

class _WatchlistScreenState extends State<WatchlistScreen> {
  final ScrollController controller = ScrollController();
  List<Movie> movies = moviesPredefined;

  void searchFunction(String searchStr) {
    setState(() {
      final String lowerSearchStr = searchStr.toLowerCase();
      movies = moviesPredefined
          .where((movie) => movie.title.toLowerCase().contains(lowerSearchStr))
          .toList();
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
                    child: const Text(
                      "Watchlist",
                      textScaleFactor: titleScaleFactor,
                      style: TextStyle(
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
