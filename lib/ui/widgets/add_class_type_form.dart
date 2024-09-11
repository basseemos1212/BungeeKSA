import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddClassTypeScreen extends StatelessWidget {
  final TextEditingController typeNameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Class Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: typeNameController,
              decoration: const InputDecoration(labelText: 'Class Type Name'),
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
                    const SnackBar(content: Text('Class type added successfully')),
                  );
                  Navigator.pop(context);
                } else {
                  // Show error if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in the class type name')),
                  );
                }
              },
              child: const Text('Add Class Type'),
            ),
          ],
        ),
      ),
    );
  }
}
