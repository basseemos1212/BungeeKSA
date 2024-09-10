import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // Ensure the data structure is properly cast to the correct type
      availableTimes = (dynamicData as Map<String, dynamic>).map((day, hours) {
        return MapEntry(day, (hours as Map<String, dynamic>).map((hour, seats) {
          return MapEntry(hour, seats as int);
        }));
      });
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
              selectedColor: Colors.greenAccent,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailableHours() {
    final availableHours = availableTimes[_selectedDay]!.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Hours:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: availableHours.map((hour) {
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
              selectedColor: Colors.blueAccent,
              disabledColor: availableSeats == 0 ? Colors.grey.shade300 : null,
            );
          }).toList(),
        ),
      ],
    );
  }

 Future<void> _bookClass() async {
  if (_selectedDay != null && _selectedHour != null) {
    // Convert selected day to string format for Firestore
    String selectedDayString = _selectedDay!; // assuming _selectedDay is already a formatted string like '2024-09-10'

    // Ensure availableTimes for selected day and hour are not null before reducing seats
    if (availableTimes[selectedDayString] != null && availableTimes[selectedDayString]![_selectedHour!] != null) {
      int currentSeats = availableTimes[selectedDayString]![_selectedHour!] as int;

      if (currentSeats > 0) {
        // Retrieve the user ID for booking (assumes user is already authenticated)
        final userId = FirebaseAuth.instance.currentUser?.uid;

        if (userId != null) {
          // Create booking data
          final bookingData = {
            'userId': userId,
            'className': widget.className,
            'classType': widget.classType,
            'date': selectedDayString,
            'hour': _selectedHour,
            'price': widget.price,
          };

          // Add booking data to Firestore (bookings collection)
          await _firestore.collection('bookings').add(bookingData);

          // Reduce available seats for the specific hour on the selected day
          availableTimes[selectedDayString]![_selectedHour!] = currentSeats - 1;

          // Update Firestore document with reduced seats for the specific day and hour
          await _firestore.collection('classes').doc(widget.classDocId).update({
            'available_times': availableTimes,
          });

          // Check if widget is mounted before calling setState
          if (mounted) {
            setState(() {
              // Update the UI after booking
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking successful!')),
            );
          }
        } else {
          // Show error if user is not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in!')),
          );
        }
      } else {
        // Notify user that no seats are available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No available seats for the selected time.')),
        );
      }
    }
  }
}

}