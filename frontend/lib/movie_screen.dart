import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/movie_tile.dart';
import 'package:http/http.dart' as http;

class MovieScreen extends StatefulWidget {
  Movie movie;
  MovieScreen({required this.movie, super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  late Movie movie = widget.movie;

  Future<void> onRateButtonPressed() async {
    double rating = movie.userRating?.toDouble() ?? 0.0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[800],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                allowHalfRating: true,
                unratedColor: Colors.amber.withAlpha(75),
                itemCount: 10,
                itemSize: 25,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
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
                final response = await http.post(Uri.http(
                    '10.0.2.2:8080', '/api/movies/${movie.movieId}/unrate'));
                if (response.statusCode == 200) {
                  setState(() {
                    movie.userRating = null;
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
                final response = await http.post(Uri.http('10.0.2.2:8080',
                    '/api/movies/${movie.movieId}/rate', queryParameters));
                if (response.statusCode == 200) {
                  setState(() {
                    movie.userRating = rating.toInt();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

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

    onWatchlistButtonPressed() async {
      if (!movie.isOnWatchlist) {
        final response = await http.post(Uri.http(
            '10.0.2.2:8080', '/api/movies/${movie.movieId}/add_to_watchlist'));
        if (response.statusCode == 200) {
          setState(() {
            movie.isOnWatchlist = !movie.isOnWatchlist;
          });
        }
      } else {
        final response = await http.post(Uri.http('10.0.2.2:8080',
            '/api/movies/${movie.movieId}/remove_from_watchlist'));
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
