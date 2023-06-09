import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
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

Future<void> signIn() async {
  final queryParameters = {
    'userId': FirebaseAuth.instance.currentUser?.uid,
    'idToken': await FirebaseAuth.instance.currentUser?.getIdToken(),
  };
  await http
      .post(Uri.http('10.0.2.2:8080', '/api/users/sign_in', queryParameters));
}

Future<List<Movie>> fetchMovies(int offset, int limit, String str) async {
  final queryParameters = {
    'offset': offset.toString(),
    'limit': limit.toString(),
    'substring': str,
  };
  final response = await http.get(
    Uri.http('10.0.2.2:8080', '/api/movies', queryParameters),
    headers: {
      HttpHeaders.authorizationHeader:
          'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}'
    },
  );
  final json = jsonDecode(response.body);
  final movieCount = (json["count"] as int);
  final movieList =
      (json["movies"] as List).map((m) => Movie.fromDICT(m)).toList();
  return movieList;
}

Future<List<Movie>> fetchRecommendedMovies(int offset, int limit) async {
  final queryParameters = {
    'offset': offset.toString(),
    'limit': limit.toString(),
  };

  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

  final response = await http.get(
    Uri.http(
      '10.0.2.2:8080',
      '/api/movies/recommended',
      queryParameters,
    ),
    headers: {"Authorization": 'Bearer $token'},
  );
  final json = jsonDecode(response.body);
  final movieCount = (json["count"] as int);
  final movieList =
      (json["movies"] as List).map((m) => Movie.fromDICT(m)).toList();
  return movieList;
}

class _HomeScreenState extends State<HomeScreen> {
  bool signedIn = false;
  List<Movie> movies = [];
  List<Movie> recommendedMovies = [];
  List<Movie> displayedMovies = [];
  bool isSearchbarFilled = false;
  String searchString = "";

  bool isLastPage = false;
  int allOffset = 0;
  int recommendedOffset = 0;
  bool loading = true;
  final int numberOfMoviesPerRequest = 3;
  List<String> movieTitles = [];
  final int nextPageTrigger = 2;
  ScrollController scrollController = ScrollController();

  Timer? timer;

  Future<void> updateRecommendedMovies() async {
    if (!signedIn) {
      await signIn();
      setState(() {
        signedIn = true;
      });
    }
    // try {
    final additionalMovies = await fetchRecommendedMovies(
        recommendedOffset, numberOfMoviesPerRequest);

    setState(() {
      loading = false;
      recommendedOffset = recommendedOffset + numberOfMoviesPerRequest;
      recommendedMovies.addAll(additionalMovies);
      displayedMovies = recommendedMovies;
    });
    // } catch (e) {
    //   print("error --> $e");
    // }
  }

  Future<void> updateMovies() async {
    // try {
    final additionalMovies =
        await fetchMovies(allOffset, numberOfMoviesPerRequest, searchString);

    setState(() {
      loading = false;
      allOffset = allOffset + numberOfMoviesPerRequest;
      movies.addAll(additionalMovies);
      displayedMovies = movies;
    });
    // } catch (e) {
    //   print("error --> $e");
    // }
  }

  void searchFunction(String searchStr) {
    setState(() {
      final String lowerSearchStr = searchStr.toLowerCase();
      searchString = lowerSearchStr;
      isSearchbarFilled = lowerSearchStr.isNotEmpty;
      timer?.cancel();
      timer = Timer(
        const Duration(seconds: 1),
        () {
          setState(() {
            if (isSearchbarFilled) {
              movies = [];
              allOffset = 0;
              updateMovies();
            } else {
              recommendedMovies = [];
              recommendedOffset = 0;
              updateRecommendedMovies();
            }
          });
        },
      );
    });
    // setState(() {
    //   final String lowerSearchStr = searchStr.toLowerCase();
    //   isSearchbarFilled = lowerSearchStr.isNotEmpty;
    //   if (isSearchbarFilled) {
    //     displayedMovies = movies
    //         .where(
    //             (movie) => movie.title.toLowerCase().contains(lowerSearchStr))
    //         .toList();
    //   } else {
    //     displayedMovies = recommendedMovies;
    //   }
    // });
  }

  @override
  void initState() {
    scrollController.addListener(() {
      var nextPageTrigger = 0.8 * scrollController.position.maxScrollExtent;

      if (!loading && scrollController.position.pixels > nextPageTrigger) {
        setState(() {
          loading = true;
          if (isSearchbarFilled) {
            updateMovies();
          } else {
            updateRecommendedMovies();
          }
        });
      }
    });
    super.initState();
    updateRecommendedMovies();
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
              itemCount: displayedMovies.length + 1,
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
                  final movie = displayedMovies[index - 1];
                  return MovieTile(movie: movie);

                  // final movieTitle = movies[index - 1].title;
                  // return MovieTileStub(title: movieTitle);

                  // final movieTitle = movieTitles[index - 1];
                  // return MovieTileStub(title: movieTitle);
                }
              },
            ),
          );
        }
      },
    );
  }
}
