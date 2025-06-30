import 'package:flutter/material.dart';
import 'package:flutter_application_3/bottomnavbar/homepagecontent.dart';
import 'package:flutter_application_3/bottomnavbar/my_feed.dart';
import 'package:flutter_application_3/bottomnavbar/my_profile.dart';
import 'package:flutter_application_3/components/bookmarks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    
    HomePageContent(), 
    NewsScreen(), 
    MyProfile(),
    BookmarksPage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
  icon: Icon(Icons.bookmark),
  label: 'Bookmarks',
),

        ],
      ),
    );
  }
}
