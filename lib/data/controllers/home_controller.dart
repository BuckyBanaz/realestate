import 'package:get/get.dart';
import '../../screens/home/modules/recommended_properties.dart'; // For types if needed, or just define maps
import '../../screens/home/modules/featured_properties_list.dart'; // For types

class HomeController extends GetxController {
  // Observables
  var isRefreshing = false.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(seconds: 4)); // Show shimmer for 4 seconds
    isLoading.value = false;
  }


  // -- Featured Properties Data --
  var featuredProperties = <Map<String, String>>[
    {
      "title": "Grand Larts",
      "location": "7866, Near star",
      "bedrooms": "3",
      "bathrooms": "2",
      "price": "\$5400",
      "image": "https://www.housingman.com/news/wp-content/uploads/2019/06/image-1-copy-2.jpg",
    },
    {
      "title": "Shree Shyam Kunj",
      "location": "Sector 15, Hisar",
      "bedrooms": "4",
      "bathrooms": "3",
      "price": "\$6200",
      "image": "https://www.deccanproperties.com/assets/images/property_images/property2856.jpg",
    },
    {
      "title": "Fairview Apartment",
      "location": "Hisar Cantt",
      "bedrooms": "2",
      "bathrooms": "2",
      "price": "\$4800",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_pWH24HG5pnZvjYuP5Z85ZYgT3cYMFdUXMw&s",
    },
    {
      "title": "Rajguru Farmhouse",
      "location": "Rajguru Nagar",
      "bedrooms": "5",
      "bathrooms": "4",
      "price": "\$7500",
      "image": "https://assets-news.housing.com/news/wp-content/uploads/2022/04/04144614/Types-of-plots-and-various-types-of-housing-plots-in-India-feature-compressed.jpg",
    },
    {
      "title": "Green Valley",
      "location": "Model Town",
      "bedrooms": "3",
      "bathrooms": "2",
      "price": "\$5100",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuDC_Szol-NA_sCgrIcS33Mkzklznk2UGY0Q&s",
    },
  ].obs;

  // -- Recommended Properties Data --
   var recommendedProperties = <Map<String, dynamic>>[
      {
        "title": "Skyline Haven",
        "location": "Sector 45, Gurgaon",
        "price": "\$8,500",
        "rating": 4.8,
        "image": "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 3,
        "baths": 2,
        "area": "1200 sqft"
      },
      {
        "title": "Urban Loft",
        "location": "Whitefield, Bangalore",
        "price": "\$6,200",
        "rating": 4.5,
        "image": "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 2,
        "baths": 1,
        "area": "950 sqft"
      },
      {
        "title": "Serenity Villa",
        "location": "Lonavala, Pune",
        "price": "\$12,000",
        "rating": 4.9,
        "image": "https://images.unsplash.com/photo-1613490493576-7fde63acd811?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 4,
        "baths": 4,
        "area": "3500 sqft"
      },
       {
        "title": "Palm Heights",
        "location": "Bandra West, Mumbai",
        "price": "\$9,000",
        "rating": 4.7,
        "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "beds": 3,
        "baths": 2,
        "area": "1500 sqft"
      },
  ].obs;

  // -- News Data --
  var newsList = <Map<String, String>>[
      {
        "title": "BMC announces first housing lottery; to give 426 Mumbai flats",
        "date": "24 Jan",
        "readTime": "7 min read",
        "image": "https://img.freepik.com/free-photo/toy-bricks-table-with-word-news_144627-47476.jpg", 
        "description": "The BMC Housing Lottery is offering houses in Kandivali, Bhandup, and more..."
      },
      {
        "title": "Real Estate market sees a boom in Q1 2025",
        "date": "22 Jan",
        "readTime": "5 min read",
        "image": "https://img.freepik.com/free-photo/graph-chart-growth-analysis-concept_53876-120302.jpg",
        "description": "Experts predict a sharp rise in property prices across tier-1 cities."
      },
      {
        "title": "New Metro line boosts property rates in Pune",
        "date": "20 Jan",
        "readTime": "4 min read",
        "image": "https://img.freepik.com/free-photo/city-skyline-landmarks-urban-scene_1112-887.jpg",
        "description": "Connectivity improvements lead to a surge in demand for residential units."
      },
  ].obs;


  // Refresh Method
  Future<void> onRefresh() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate data update by shuffling
    featuredProperties.shuffle();
    recommendedProperties.shuffle();
    newsList.shuffle();
    
    isRefreshing.value = false;
  }
}
