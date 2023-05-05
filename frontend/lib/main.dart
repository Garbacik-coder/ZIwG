import 'package:flutter/material.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Movie recomendation system';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  final ScrollController _homeController = ScrollController();
  bool _isStarred = false;
  

  Widget _listViewBody() {
    return ListView.separated(
      controller: _homeController,
      itemBuilder: (BuildContext context, int index) {
        return Center(
          child: GestureDetector(
            child: Image.asset('assets/images/65.jpg'),
            onTap: () {
              _showRatingDialog();
            },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        thickness: 1,
      ),
      itemCount: 5,
    );
  }
  Future<void> _showRatingDialog() async {
    int rating = 0;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate this image'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: index < rating ? Colors.yellow : null,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  _isStarred = true;
                  print(rating);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _searchMovies(String searchText) {
    print("do something");
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _searchMovies,
          decoration: InputDecoration(
            hintText: "Search Movies",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _searchController.clear();
                _searchMovies("");
              },
            ),
          ),
        ),
      ),
      body: _listViewBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,color: Colors.black),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay_circle_filled_outlined,color: Colors.black),
            label: 'Recently Watched'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend,color: Colors.black),
            label: 'Recommendation'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout,color: Colors.black),
            label: 'Log Out'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 8, 77, 23),
        onTap: (int index) {
          switch (index) {
            case 0:
              // only scroll to top when current index is selected.
              if (_selectedIndex == index) {
                _homeController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
              break;
            case 1:
              // only scroll to top when current index is selected.
              if (_selectedIndex == index) {
                _homeController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
              break;
            case 2:
              // only scroll to top when current index is selected.
              if (_selectedIndex == index) {
                _homeController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
              break;
            case 3:
              // only scroll to top when current index is selected.
              if (_selectedIndex == index) {
                _homeController.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
              break;
          }
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }

  
}
