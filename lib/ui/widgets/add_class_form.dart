import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController arabicClassNameController = TextEditingController(); // Arabic name controller
  final TextEditingController priceController = TextEditingController();
  final TextEditingController hashtagSearchController = TextEditingController(); // Hashtag search controller

  String? selectedClassType; // Selected class type (initially null)
  List<String> selectedDates = []; // To store selected dates
  Map<String, Map<String, dynamic>> availableTimes = {}; // To store hours and seat counts per date

  List<String> predefinedHashtags = ['Adult Classes', 'Kids Classes', 'Private Classes']; // Predefined hashtags

  void _fillWithHashtag(String hashtag) {
    // Fill both English and Arabic names based on hashtag
    if (hashtag == 'Adult Classes') {
      classNameController.text = 'Adult Classes';
      arabicClassNameController.text = 'حصص الكبار';
    } else if (hashtag == 'Kids Classes') {
      classNameController.text = 'Kids Classes';
      arabicClassNameController.text = 'حصص الأطفال';
    } else if (hashtag == 'Private Classes') {
      classNameController.text = 'Private Classes';
      arabicClassNameController.text = 'حصص خاصة';
    } else {
      // For any custom hashtags, ensure both fields are handled
      classNameController.text = hashtag;
      arabicClassNameController.text = 'حصص'; // Provide a generic default Arabic name
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHashtags = predefinedHashtags
        .where((hashtag) =>
            hashtag.toLowerCase().contains(hashtagSearchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addNewClass), // Localized title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: hashtagSearchController,
              decoration: InputDecoration(
                labelText: 'Search Hashtags',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (text) {
                setState(() {}); // Rebuild the widget to filter hashtags
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: [
                for (var hashtag in filteredHashtags)
                  ActionChip(
                    label: Text('#$hashtag'),
                    onPressed: () => _fillWithHashtag(hashtag),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: classNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.className, // Localized label for English class name
              ),
            ),
            TextField(
              controller: arabicClassNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.classNameArabic, // Localized label for Arabic class name
              ),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.price, // Localized label
              ),
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
                  hint: Text(AppLocalizations.of(context)!.selectClassType), // Localized hint
                  items: classTypeItems,
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                _pickDate();
              },
              child: Text(AppLocalizations.of(context)!.selectActiveDates), // Localized button text
            ),
            const SizedBox(height: 16),
            selectedDates.isNotEmpty
                ? Column(
                    children: selectedDates.map((date) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${AppLocalizations.of(context)!.availableHoursAndSeats}: $date"),
                          ElevatedButton(
                            onPressed: () {
                              _pickTimeForDate(date);
                            },
                            child: Text(AppLocalizations.of(context)!.addAvailableHoursAndSeats), // Localized text
                          ),
                          if (availableTimes[date] != null) ...[
                            Text(
                              AppLocalizations.of(context)!.availableHoursAndSeats,
                              style: const TextStyle(fontSize: 14, color: Colors.green),
                            ),
                            ...availableTimes[date]!.entries.map((entry) {
                              return Text("${AppLocalizations.of(context)!.setAvailableSeats} ${entry.key}, ${AppLocalizations.of(context)!.numberOfSeats}: ${entry.value}");
                            }),
                          ],
                        ],
                      );
                    }).toList(),
                  )
                : Text(AppLocalizations.of(context)!.noDatesSelected), // Localized text
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _addClassToFirestore();
              },
              child: Text(AppLocalizations.of(context)!.addClass), // Localized button text
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
            title: Text("${AppLocalizations.of(context)!.setAvailableSeats} ${pickedTime.format(context)}"),
            content: TextField(
              controller: seatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.numberOfSeats), // Localized label
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Force the time format to always use AM/PM in English
                  final formattedTime = DateFormat('h:mm a', 'en').format(
                    DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute),
                  );

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
                child: Text(AppLocalizations.of(context)!.ok), // Localized text
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _addClassToFirestore() async {
    if (classNameController.text.isNotEmpty &&
        arabicClassNameController.text.isNotEmpty && // Check Arabic name
        priceController.text.isNotEmpty &&
        selectedClassType != null &&
        selectedDates.isNotEmpty &&
        availableTimes.isNotEmpty) {
      final classData = {
        'name': classNameController.text,
        'arabic_name': arabicClassNameController.text, // Store Arabic name
        'price': int.parse(priceController.text),
        'type': selectedClassType,
        'available_times': availableTimes, // Store selected dates, hours, and seat counts
      };

      try {
        await FirebaseFirestore.instance.collection('classes').add(classData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.classAddedSuccessfully)), // Localized success message
        );

        // Clear inputs after saving
        classNameController.clear();
        arabicClassNameController.clear(); // Clear Arabic name input
        priceController.clear();
        setState(() {
          selectedDates.clear();
          availableTimes.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.failedToAddClass}: $e')), // Localized error message
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)), // Localized message
      );
    }
  }
}
