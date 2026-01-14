import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/data/models/estate_model.dart';

class SearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  var searchQuery = "".obs;

  final List<EstateModel> dummyEstates = [
    EstateModel("Urban Heights Apartment", "4.7", "Sector 15, Hisar", "230", "Apartment"),
    EstateModel("Palm Residency Villa", "4.9", "Hisar Cantt", "520", "Villa"),
    EstateModel("Green Valley Modern House", "4.8", "Rajguru Nagar, Hisar", "310", "House"),
    EstateModel("City Center Luxury Flat", "4.6", "Camp Chowk, Hisar", "275", "Apartment"),
    EstateModel("Rosewood Premium Villa", "5.0", "Model Town, Hisar", "590", "Villa"),
    EstateModel("Silver Leaf Apartments", "4.7", "Urban Estate II, Hisar", "240", "Apartment"),
    EstateModel("Golden Meadows House", "4.8", "Hisar University Rd", "330", "House"),
  ];


  List<EstateModel> get filteredEstates {
    if (searchQuery.value.isEmpty) return dummyEstates;
    return dummyEstates
        .where((e) => e.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }
}
