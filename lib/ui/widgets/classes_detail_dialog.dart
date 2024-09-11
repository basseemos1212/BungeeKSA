import 'package:bungee_ksa/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClassDetailsDialog extends StatefulWidget {
  final String className;
  final String classType;
  final int price;
  final String classDocId;

  const ClassDetailsDialog({
    Key? key,
    required this.className,
    required this.classType,
    required this.price,
    required this.classDocId,
  }) : super(key: key);

  @override
  _ClassDetailsDialogState createState() => _ClassDetailsDialogState();
}

class _ClassDetailsDialogState extends State<ClassDetailsDialog> {
  String? _selectedDay;
  String? _selectedHour;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, int>> availableTimes = {};

  @override
  void initState() {
    super.initState();
    _fetchClassData();
  }

  Future<void> _fetchClassData() async {
    final doc = await _firestore.collection('classes').doc(widget.classDocId).get();
    if (doc.exists) {
      setState(() {
        final dynamicData = doc['available_times'];
        // Get the current date
        final now = DateTime.now();
        availableTimes = (dynamicData as Map<String, dynamic>).map((day, hours) {
          DateTime parsedDay = DateFormat('yyyy-MM-dd').parse(day);
          // Include today and future dates only
          if (parsedDay.isAfter(now) || DateFormat('yyyy-MM-dd').format(parsedDay) == DateFormat('yyyy-MM-dd').format(now)) {
            return MapEntry(day, (hours as Map<String, dynamic>).map((hour, seats) {
              return MapEntry(hour, seats as int);
            }));
          }
          return MapEntry("", {}); // Empty entry for past dates
        });
        // Remove invalid entries (past dates)
        availableTimes.removeWhere((key, value) => key.isEmpty);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.className),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price: ${widget.price} SAR"),
            const SizedBox(height: 8),
            _buildAvailableDays(),
            if (_selectedDay != null) ...[
              const SizedBox(height: 20),
              _buildAvailableHours(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: _selectedHour != null
              ? () {
                  _bookClass();
                  Navigator.of(context).pop();
                }
              : null, // Disable if no day or hour is selected
          child: const Text('Book'),
        ),
      ],
    );
  }

  Widget _buildAvailableDays() {
    final availableDays = availableTimes.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Days:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: availableDays.map((day) {
            return ChoiceChip(
              label: Text(day),
              selected: _selectedDay == day,
              onSelected: (selected) {
                setState(() {
                  _selectedDay = selected ? day : null;
                  _selectedHour = null; // Reset hour selection
                });
              },
              selectedColor: AppColors.secondary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailableHours() {
    final availableHours = availableTimes[_selectedDay]!.keys.toList();
    final now = DateTime.now();

    // Parse the selected day to compare with the current date
    final DateTime selectedDayDate = DateFormat('yyyy-MM-dd').parse(_selectedDay!);
    
    // Only filter hours for today; future days show all hours
    final filteredAvailableHours = availableHours.where((hour) {
      if (DateFormat('yyyy-MM-dd').format(selectedDayDate) == DateFormat('yyyy-MM-dd').format(now)) {
        // Parse the hour to DateTime and compare with the current time
        DateTime parsedHour = DateFormat('h:mm a').parse(hour);
        DateTime todayHour = DateTime(now.year, now.month, now.day, parsedHour.hour, parsedHour.minute);
        return todayHour.isAfter(now);
      }
      return true; // Keep all hours for future days
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Hours:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: filteredAvailableHours.map((hour) {
            int availableSeats = availableTimes[_selectedDay]![hour]!;
            return ChoiceChip(
              label: Text("$hour (${availableSeats} seats left)"),
              selected: _selectedHour == hour,
              onSelected: (selected) {
                if (availableSeats > 0) {
                  setState(() {
                    _selectedHour = selected ? hour : null;
                  });
                }
              },
              selectedColor: AppColors.accent,
              disabledColor: availableSeats == 0 ? Colors.grey.shade300 : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _bookClass() async {
    if (_selectedDay != null && _selectedHour != null) {
      String selectedDayString = _selectedDay!;

      if (availableTimes[selectedDayString] != null && availableTimes[selectedDayString]![_selectedHour!] != null) {
        int currentSeats = availableTimes[selectedDayString]![_selectedHour!] as int;

        if (currentSeats > 0) {
          final userId = FirebaseAuth.instance.currentUser?.uid;

          if (userId != null) {
            final bookingData = {
              'userId': userId,
              'className': widget.className,
              'classType': widget.classType,
              'date': selectedDayString,
              'hour': _selectedHour,
              'price': widget.price,
            };

            await _firestore.collection('bookings').add(bookingData);

            availableTimes[selectedDayString]![_selectedHour!] = currentSeats - 1;

            await _firestore.collection('classes').doc(widget.classDocId).update({
              'available_times': availableTimes,
            });

            if (mounted) {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking successful!')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User not logged in!')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No available seats for the selected time.')),
          );
        }
      }
    }
  }
}
