import 'dart:convert';

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

Future<List<String>> fetchMovies(int offset, int limit) async {
  final queryParameters = {
    'offset': offset.toString(),
    'limit': limit.toString(),
  };
  final response =
      await http.get(Uri.http('10.0.2.2:8080', '/api/movies', queryParameters));
  final json = jsonDecode(response.body);
  final parsed = (json as List).map((m) => m["title"] as String).toList();
  return parsed;
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = moviesPredefined;
  bool isSearchbarFilled = false;

  bool isLastPage = false;
  int offset = 0;
  bool loading = true;
  final int numberOfMoviesPerRequest = 3;
  List<String> movieTitles = [];
  final int nextPageTrigger = 2;
  ScrollController scrollController = ScrollController();

  Future<void> fetchData() async {
    try {
      final additionalMovieTitles =
          await fetchMovies(offset, numberOfMoviesPerRequest);

      setState(() {
        loading = false;
        offset = offset + numberOfMoviesPerRequest;
        movieTitles.addAll(additionalMovieTitles);
      });
    } catch (e) {
      print("error --> $e");
    }
  }

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
  void initState() {
    scrollController.addListener(() {
      var nextPageTrigger = 0.8 * scrollController.position.maxScrollExtent;

      if (!loading && scrollController.position.pixels > nextPageTrigger) {
        setState(() {
          loading = true;
          fetchData();
          print('henloo');
        });
      }
    });
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final listBorderRadius =
        MediaQuery.of(context).size.width * borderRadiusProportion;

    return ListView.builder(
      controller: scrollController,
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
              itemCount: movieTitles.length + 1,
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
                  // final movie = movies[index - 1];
                  // return MovieTile(movie: movie);

                  // final movieTitle = movies[index - 1].title;
                  // return MovieTileStub(title: movieTitle);

                  final movieTitle = movieTitles[index - 1];
                  return MovieTileStub(title: movieTitle);
                }
              },
            ),
          );
        }
      },
    );
  }
}
