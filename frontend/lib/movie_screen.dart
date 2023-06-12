import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/movie_tile.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class MovieScreen extends StatefulWidget {
  Movie movie;
  MovieScreen({required this.movie, super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  late Movie movie = widget.movie;
  late double rating = movie.userRating?.toDouble() ?? 0.0;
  bool isHidden = false;

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    double deviceWidth = deviceSize.width;
    double deviceHeight = deviceSize.height;

    double imageHeight = deviceHeight * 0.5;
    double endPaddingHeight = deviceHeight * 0.2;
    double cardPadding = deviceWidth * 0.06;
    double borderRadius = deviceWidth * 0.1;
    double titleScaleFactor = 3.0;
    double descriptionScaleFactor = 1.35;
    double otherScaleFactor = 1.2;
    double afterTitleGap = deviceHeight * 0.015;
    double afterOtherGap = deviceHeight * 0.01;

    double starSize = deviceWidth * 0.062;

    Widget ratePopup = AlertDialog(
      backgroundColor: Colors.teal[800],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius)),
      title: const Text(
        'Rate this movie',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return RatingBar.builder(
            glow: false,
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            unratedColor: Colors.amber.withAlpha(75),
            itemCount: 10,
            itemSize: starSize,
            itemPadding: EdgeInsets.symmetric(horizontal: starSize / 20),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (newRating) {
              setState(() {
                rating = newRating;
              });
            },
            updateOnDrag: true,
          );
        },
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Remove rating',
            style: TextStyle(
              color: Colors.red[300],
            ),
          ),
          onPressed: () async {
            final response = await http.post(
              Uri.http('10.0.2.2:8080', '/api/movies/${movie.movieId}/unrate'),
              headers: {
                HttpHeaders.authorizationHeader:
                    'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}'
              },
            );
            if (response.statusCode == 200) {
              setState(() {
                movie.userRating = null;
                movie.isRated = false;
              });
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () async {
            final queryParameters = {
              'rating': rating.toString(),
            };
            print("given rating ${rating.toString()}");
            final response = await http.post(
              Uri.http('10.0.2.2:8080', '/api/movies/${movie.movieId}/rate',
                  queryParameters),
              headers: {
                HttpHeaders.authorizationHeader:
                    'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}'
              },
            );
            if (response.statusCode == 200) {
              setState(() {
                movie.userRating = rating.toInt();
                movie.isRated = true;
              });
            }
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );

    Future<void> onRateButtonPressed() async {
      rating = movie.userRating?.toDouble() ?? 0.0;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ratePopup;
        },
      );
    }

    Future<void> onHideButtonPressed() async {
      if (!isHidden) {
        final response = await http.post(
          Uri.http(
            '10.0.2.2:8080',
            '/api/movies/${movie.movieId}/reject',
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            isHidden = true;
          });
        }
      } else {
        final response = await http.post(
          Uri.http(
            '10.0.2.2:8080',
            '/api/movies/${movie.movieId}/unreject',
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            isHidden = false;
          });
        }
      }
    }

    onWatchlistButtonPressed() async {
      if (!movie.isOnWatchlist) {
        final response = await http.post(
          Uri.http(
              '10.0.2.2:8080', '/api/movies/${movie.movieId}/add_to_watchlist'),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            movie.isOnWatchlist = !movie.isOnWatchlist;
          });
        }
      } else {
        final response = await http.post(
          Uri.http('10.0.2.2:8080',
              '/api/movies/${movie.movieId}/remove_from_watchlist'),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            movie.isOnWatchlist = !movie.isOnWatchlist;
          });
        }
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Image.network(
            movie.imageUrl,
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: imageHeight,
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.75),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(borderRadius),
                          topRight: Radius.circular(borderRadius),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            textScaleFactor: titleScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: afterTitleGap,
                          ),
                          Text(
                            textAlign: TextAlign.justify,
                            movie.description,
                            textScaleFactor: descriptionScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: afterOtherGap,
                          ),
                          Text(
                            "rating: ${movie.rating}",
                            textScaleFactor: otherScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "year: ${movie.year}",
                            textScaleFactor: otherScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "length: ${movie.length}",
                            textScaleFactor: otherScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "genres: ${movie.genres}",
                            textScaleFactor: otherScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: afterTitleGap,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: onHideButtonPressed,
                                icon: Icon(
                                  Icons.visibility_off,
                                  color: isHidden ? Colors.white : Colors.grey,
                                  size: 64,
                                ),
                              ),
                              IconButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: () {
                                  onWatchlistButtonPressed();
                                },
                                icon: Icon(
                                  Icons.watch_later,
                                  color: movie.isOnWatchlist
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 64,
                                ),
                              ),
                              IconButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: onRateButtonPressed,
                                icon: Icon(
                                  Icons.star,
                                  color: movie.isRated
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 64,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.75),
                      ),
                      constraints: BoxConstraints.expand(
                        height: endPaddingHeight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
