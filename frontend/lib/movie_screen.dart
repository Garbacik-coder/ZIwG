import 'package:flutter/material.dart';
import 'package:frontend/movie_tile.dart';

class MovieScreen extends StatefulWidget {
  final Movie movie;
  const MovieScreen({required this.movie, super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  Function onWatchlistButtonPressed = () {
    // implement
  };

  Function onRateButtonPressed = () {
    // implement
  };

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
                                onPressed: () {
                                  onRateButtonPressed();
                                },
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
