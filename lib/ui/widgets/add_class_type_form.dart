import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddClassTypeScreen extends StatefulWidget {
  const AddClassTypeScreen({super.key});

  @override
  _AddClassTypeScreenState createState() => _AddClassTypeScreenState();
}

class _AddClassTypeScreenState extends State<AddClassTypeScreen> {
  final TextEditingController typeNameController = TextEditingController(); // English name
  final TextEditingController arabicTypeNameController = TextEditingController(); // Arabic name
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined hashtags with their corresponding English and Arabic names
  final Map<String, Map<String, String>> hashtags = {
    '#LimitedOffers': {
      'english': 'Limited Offer',
      'arabic': 'عرض محدود',
    },
    '#AdvancedBungeeClass': {
      'english': 'Advanced Bungee Class',
      'arabic': 'حصص البنجي المتقدمة',
    },
    '#Beginner': {
      'english': 'Beginner Class',
      'arabic': 'حصص المبتدئين',
    },
    '#Intermediate': {
      'english': 'Intermediate Class',
      'arabic': 'حصص المستوى المتوسط',
    },
    '#HIITWorkout': {
      'english': 'HIIT Workout',
      'arabic': 'حصص التمارين المكثفة',
    },
  };

  // Fill the fields with the selected hashtag values
  void _fillWithHashtag(String hashtag) {
    final selectedHashtag = hashtags[hashtag];
    if (selectedHashtag != null) {
      typeNameController.text = selectedHashtag['english']!;
      arabicTypeNameController.text = selectedHashtag['arabic']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addNewClassType), // Localized title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display predefined hashtags
            Wrap(
              spacing: 8.0,
              children: [
                for (var hashtag in hashtags.keys)
                  ActionChip(
                    label: Text(hashtag),
                    onPressed: () => _fillWithHashtag(hashtag),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: typeNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.classTypeName, // Localized label for English name
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: arabicTypeNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.classTypeArabicName, // Localized label for Arabic name
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (typeNameController.text.isNotEmpty && arabicTypeNameController.text.isNotEmpty) {
                  await _firestore.collection('classTypes').add({
                    'name': typeNameController.text, // English name
                    'arabic_name': arabicTypeNameController.text, // Arabic name
                  });

                  // Show success and navigate back
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.classTypeAddedSuccess)), // Localized success message
                  );
                  Navigator.pop(context);
                } else {
                  // Show error if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.fillClassTypeName)), // Localized error message
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.addClassType), // Localized button text
            ),
          ],
        ),
      ),
    );
  }
}
