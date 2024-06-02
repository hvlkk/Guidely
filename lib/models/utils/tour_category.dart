import 'package:flutter/material.dart';

enum TourCategory {
  history,
  art,
  architecture,
  food,
  culture,
  adventure,
  nature,
  religion,
  family,
  sports,
}

const tourCategories = TourCategory.values;

Map<TourCategory, IconData> tourCategoryToIcon = {
  TourCategory.history: Icons.account_balance,
  TourCategory.art: Icons.palette,
  TourCategory.architecture: Icons.architecture,
  TourCategory.food: Icons.restaurant,
  TourCategory.culture: Icons.festival,
  TourCategory.adventure: Icons.emoji_events,
  TourCategory.nature: Icons.terrain,
  TourCategory.religion: Icons.church,
  TourCategory.family: Icons.family_restroom,
  TourCategory.sports: Icons.sports_soccer,
};

Map<TourCategory, String> tourCategoryToString = {
  TourCategory.history: 'History',
  TourCategory.art: 'Art',
  TourCategory.architecture: 'Architecture',
  TourCategory.food: 'Food',
  TourCategory.culture: 'Culture',
  TourCategory.adventure: 'Adventure',
  TourCategory.nature: 'Nature',
  TourCategory.religion: 'Religion',
  TourCategory.family: 'Family',
  TourCategory.sports: 'Sports',
};

Map<String, TourCategory> tourCategoryFromString = {
  'History': TourCategory.history,
  'Art': TourCategory.art,
  'Architecture': TourCategory.architecture,
  'Food': TourCategory.food,
  'Culture': TourCategory.culture,
  'Adventure': TourCategory.adventure,
  'Nature': TourCategory.nature,
  'Religion': TourCategory.religion,
  'Family': TourCategory.family,
  'Sports': TourCategory.sports,
};
