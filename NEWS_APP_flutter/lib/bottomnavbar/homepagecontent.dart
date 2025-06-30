
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/admin/admin_list.dart';
import 'package:flutter_application_3/models/category_data.dart';
import 'package:flutter_application_3/models/category_model.dart';
import 'package:flutter_application_3/models/slider_data.dart';
import 'package:flutter_application_3/models/slider_model.dart';
import 'package:flutter_application_3/pages/article_web_view.dart';
import 'package:flutter_application_3/pages/category_news.dart';
import 'package:flutter_application_3/pages/search_page.dart';
import 'package:flutter_application_3/pages/settings_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<CategoryModel> categories = [];
  List<SliderModel> sliders = [];
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    categories = getCategories();
    getSlider();
  }

  getSlider() async {
    Sliders slider = Sliders();
    await slider.getSlider();
    setState(() {
      sliders = slider.sliders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "News",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.black),
            ),
            Text(
              "Hub",
              style: TextStyle(
                  color: const Color.fromARGB(230, 136, 30, 155),
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            )
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 10.0),
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryTile(
                      image: categories[index].image,
                      categoryName: categories[index].categoryName,
                    );
                  },
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Breaking News!",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 166, 19, 19),
                          fontSize: 19,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 13),
              sliders.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : CarouselSlider.builder(
                      itemCount: sliders.length,
                      itemBuilder: (context, index, realIndex) {
                        String? res = sliders[index].urlToImage;
                        String? res1 = sliders[index].title;
                        return buildImage(
                            res!, index, res1!, sliders[index].url!);
                      },
                      options: CarouselOptions(
                        height: 220,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                        onPageChanged: (index, reason) {
                          setState(() {
                            activeIndex = index;
                          });
                        },
                      ),
                    ),
              SizedBox(height: 25),
              Center(child: buildIndicator()),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "News by Our Admins",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 200, 
                child: const AdminList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(String image, int index, String name, String url) {
    return GestureDetector(
      onTap: () {
        if (url.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleWebView(blogUrl: url),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No URL available for this article")),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                height: 250,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                imageUrl: image,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/customnews_4.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 250,
              padding: EdgeInsets.only(left: 10),
              margin: EdgeInsets.only(top: 140.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                name,
                maxLines: 3,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return sliders.isEmpty
        ? SizedBox()
        : AnimatedSmoothIndicator(
            activeIndex: activeIndex,
            count: sliders.length,
            effect: ScaleEffect(
                dotHeight: 9, dotWidth: 9, activeDotColor: Colors.blue),
          );
  }
}

class CategoryTile extends StatelessWidget {
  final image, categoryName;
  const CategoryTile({super.key, this.categoryName, this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryNews(name: categoryName)));
      },
      child: Container(
        margin: EdgeInsets.only(right: 12),
        child: Center(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  image,
                  width: 140,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(128, 22, 21, 21),
                  ),
                  child: Center(
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
