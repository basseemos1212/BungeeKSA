import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddClassScreen extends StatefulWidget {
  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? selectedClassType; // Selected class type (initially null)
  List<String> selectedDates = []; // To store selected dates
  Map<String, Map<String, dynamic>> availableTimes = {}; // To store hours and seat counts per date

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('classTypes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                List<DropdownMenuItem<String>> classTypeItems = snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc['name'],
                    child: Text(doc['name']),
                  );
                }).toList();

                return DropdownButton<String>(
                  value: selectedClassType,
                  onChanged: (newValue) {
                    setState(() {
                      selectedClassType = newValue!;
                    });
                  },
                  hint: const Text("Select Class Type"),
                  items: classTypeItems,
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                _pickDate();
              },
              child: const Text("Select Active Dates"),
            ),
            const SizedBox(height: 16),
            selectedDates.isNotEmpty
                ? Column(
                    children: selectedDates.map((date) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: $date"),
                          ElevatedButton(
                            onPressed: () {
                              _pickTimeForDate(date);
                            },
                            child: const Text("Add Available Hours and Seats"),
                          ),
                          if (availableTimes[date] != null) ...[
                            const Text(
                              "Available Hours and Seats:",
                              style: TextStyle(fontSize: 14, color: Colors.green),
                            ),
                            ...availableTimes[date]!.entries.map((entry) {
                              return Text("Hour: ${entry.key}, Seats: ${entry.value}");
                            }).toList(),
                          ],
                        ],
                      );
                    }).toList(),
                  )
                : const Text("No dates selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _addClassToFirestore();
              },
              child: const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        if (!selectedDates.contains(formattedDate)) {
          selectedDates.add(formattedDate); // Add the selected date if not already added
        }
      });
    }
  }

  Future<void> _pickTimeForDate(String date) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime != null) {
      final seatsController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Set available seats for ${pickedTime.format(context)}"),
            content: TextField(
              controller: seatsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of seats'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final formattedTime = pickedTime.format(context);
                  final seats = int.tryParse(seatsController.text);

                  if (seats != null) {
                    setState(() {
                      if (availableTimes[date] == null) {
                        availableTimes[date] = {};
                      }
                      availableTimes[date]![formattedTime] = seats;
                    });
                  }

                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _addClassToFirestore() async {
    if (classNameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        selectedClassType != null &&
        selectedDates.isNotEmpty &&
        availableTimes.isNotEmpty) {
      final classData = {
        'name': classNameController.text,
        'price': int.parse(priceController.text),
        'type': selectedClassType,
        'available_times': availableTimes, // Store selected dates, hours, and seat counts
      };

      try {
        await FirebaseFirestore.instance.collection('classes').add(classData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class added successfully')),
        );

        // Clear inputs after saving
        classNameController.clear();
        priceController.clear();
        setState(() {
          selectedDates.clear();
          availableTimes.clear();
        });
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
}
