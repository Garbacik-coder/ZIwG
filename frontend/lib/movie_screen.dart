import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/movie_tile.dart';

class MovieScreen extends StatefulWidget {
  Movie movie;
  MovieScreen({required this.movie, super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  Function onWatchlistButtonPressed = () {
    // implement
  };

  Future<void> onRateButtonPressed() async {
    double rating = widget.movie.userRating?.toDouble() ?? 0.0;

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
                minRating: 0.5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                unratedColor: Colors.amber.withAlpha(75),
                itemCount: 5,
                itemSize: 45,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
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
              onPressed: () {
                setState(() {
                  widget.movie.userRating = null;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.movie.userRating = rating.toInt();
                });
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Image.network(
            widget.movie.imageUrl,
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
                            widget.movie.title,
                            textScaleFactor: titleScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: afterTitleGap,
                          ),
                          Text(
                            textAlign: TextAlign.justify,
                            widget.movie.description,
                            textScaleFactor: descriptionScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: afterOtherGap,
                          ),
                          Text(
                            "rating: ${widget.movie.rating}",
                            textScaleFactor: otherScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "year: ${widget.movie.year}",
                            textScaleFactor: otherScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "length: ${widget.movie.length}",
                            textScaleFactor: otherScaleFactor,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "genres: ${widget.movie.genres}",
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
                                  color: widget.movie.isOnWatchlist
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
                                  color: widget.movie.isRated
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
