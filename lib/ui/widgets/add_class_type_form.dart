import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

class AddClassTypeScreen extends StatelessWidget {
  final TextEditingController typeNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AddClassTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addNewClassType), // Localized title
      ),
      body: Padding(
        padding: const 
        EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: typeNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.classTypeName, // Localized label
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (typeNameController.text.isNotEmpty) {
                  await _firestore.collection('classTypes').add({
                    'name': typeNameController.text,
                  });

                  // Show success and navigate back
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.classTypeAddedSuccess)), // Localized message
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
