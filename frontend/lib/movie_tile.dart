import 'dart:ffi';

import 'package:flutter/material.dart';

class Movie {
  String title;
  String description;
  String genres;
  String rating;
  String year;
  String length;
  String imageUrl;
  bool isOnWatchlist;
  bool isRated;
  int? userRating;

  Movie(
    this.title,
    this.description,
    this.genres,
    this.rating,
    this.year,
    this.length,
    this.imageUrl,
    this.isOnWatchlist,
    this.isRated,
    this.userRating,
  );
}

const double imageAspectRatio = 12 / 16;
const double borderRadiusProportion = 0.1;
const double marginProportion = 0.03;
const double textBoxMarginProportion = 0.05;
const double titleScaleFactor = 2.0;
const double infoScaleFactor = 1.2;

class MovieTile extends StatelessWidget {
  const MovieTile({required this.movie, super.key});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final String movieInfo =
        "${movie.rating} | ${movie.year} | ${movie.length}";
    final tileMargin = MediaQuery.of(context).size.width * marginProportion;
    final tileBorderRadius =
        MediaQuery.of(context).size.width * borderRadiusProportion;
    final textBoxMargin =
        MediaQuery.of(context).size.width * textBoxMarginProportion;

    return Container(
      margin: EdgeInsets.all(tileMargin),
      child: AspectRatio(
        aspectRatio: imageAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tileBorderRadius),
          child: Stack(
            children: [
              Image.network(
                movie.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(textBoxMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      movie.title,
                      textScaleFactor: titleScaleFactor,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      movieInfo,
                      textScaleFactor: infoScaleFactor,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
