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
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.75),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movie.title,
                            textScaleFactor: 3,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            textAlign: TextAlign.justify,
                            widget.movie.description,
                            textScaleFactor: 1.35,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "rating: ${widget.movie.rating}",
                            textScaleFactor: 1.2,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "year: ${widget.movie.year}",
                            textScaleFactor: 1.2,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "length: ${widget.movie.length}",
                            textScaleFactor: 1.2,
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "genres: ${widget.movie.genres}",
                            textScaleFactor: 1.2,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: EdgeInsets.all(0),
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
                                padding: EdgeInsets.all(0),
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
                          height: MediaQuery.of(context).size.height * 0.2),
                    )
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
