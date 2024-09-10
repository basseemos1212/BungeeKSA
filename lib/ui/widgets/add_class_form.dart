import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddClassScreen extends StatefulWidget {
  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String selectedClassType = 'Private'; // Default class type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: classNameController,
              decoration: const InputDecoration(labelText: 'Class Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: selectedClassType,
              onChanged: (newValue) {
                setState(() {
                  selectedClassType = newValue!;
                });
              },
              items: <String>['Private', 'Adult', 'Kids', 'Hot Deals']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addClass,
              child: const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addClass() async {
    if (classNameController.text.isNotEmpty && priceController.text.isNotEmpty) {
      // Create a map of data for Firestore
      final classData = {
        'name': classNameController.text,
        'price': int.parse(priceController.text),
        'type': selectedClassType,
        'available_times': _generateAvailableTimes(),
      };

      try {
        await FirebaseFirestore.instance.collection('classes').add(classData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class added successfully')),
        );

        // Clear the fields after saving
        classNameController.clear();
        priceController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add class: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  // Generate available seats for each hour of the day (9 AM - 6 PM)
  Map<String, Map<String, int>> _generateAvailableTimes() {
    final Map<String, Map<String, int>> availableTimes = {};
    final DateTime today = DateTime.now();

    // Create availability for the next 7 days
    for (int i = 0; i < 7; i++) {
      String dateKey = DateFormat('yyyy-MM-dd').format(today.add(Duration(days: i)));
      availableTimes[dateKey] = {
        "9:00 AM": 10,
        "10:00 AM": 10,
        "11:00 AM": 10,
        "12:00 PM": 10,
        "1:00 PM": 10,
        "2:00 PM": 10,
        "3:00 PM": 10,
        "4:00 PM": 10,
        "5:00 PM": 10,
        "6:00 PM": 10,
      };
    }

    return availableTimes;
  }
}
