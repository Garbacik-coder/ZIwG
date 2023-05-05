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

class MovieTile extends StatelessWidget {
  const MovieTile({required this.movie, super.key});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          movie.imageUrl,
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 20,
          bottom: 20,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title),
                Text("${movie.rating} | ${movie.year} | ${movie.length}")
              ]),
        )
      ],
    );
  }
}
