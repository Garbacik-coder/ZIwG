import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/movie_tile.dart';
import 'package:frontend/movies_predefined.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class RatedScreen extends StatefulWidget {
  const RatedScreen({super.key});

  @override
  State<RatedScreen> createState() => _RatedScreenState();
}

Future<List<Movie>> fetchRatedMovies(int offset, int limit, String str) async {
  final queryParameters = {
    'offset': offset.toString(),
    'limit': limit.toString(),
    'substring': str,
  };
  final response = await http.get(
    Uri.http('10.0.2.2:8080', '/api/movies/rated', queryParameters),
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

class _RatedScreenState extends State<RatedScreen> {
  List<Movie> ratedMovies = [];
  bool isSearchbarFilled = false;

  bool isLastPage = false;
  int offset = 0;
  bool loading = true;
  final int numberOfMoviesPerRequest = 3;
  final int nextPageTrigger = 2;
  ScrollController scrollController = ScrollController();
  String searchString = "";

  Timer? timer;

  Future<void> updateRatedMovies() async {
    // try {
    final additionalMovies =
        await fetchRatedMovies(offset, numberOfMoviesPerRequest, searchString);

    setState(() {
      loading = false;
      offset = offset + numberOfMoviesPerRequest;
      ratedMovies.addAll(additionalMovies);
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
            ratedMovies = [];
            offset = 0;
            updateRatedMovies();
          });
        },
      );
    });
  }

  @override
  void initState() {
    scrollController.addListener(() {
      var nextPageTrigger = 0.8 * scrollController.position.maxScrollExtent;

      if (!loading && scrollController.position.pixels > nextPageTrigger) {
        setState(() {
          loading = true;
          updateRatedMovies();
        });
      }
    });
    super.initState();
    updateRatedMovies();
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
              itemCount: ratedMovies.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      "Rated movies",
                      textScaleFactor: titleScaleFactor,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  final movie = ratedMovies[index - 1];
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
