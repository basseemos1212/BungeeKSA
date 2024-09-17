import 'package:bungee_ksa/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

class ClassDetailsDialog extends StatefulWidget {
  final String className;
  final String classType;
  final int price;
  final String classDocId;

  const ClassDetailsDialog({
    super.key,
    required this.className,
    required this.classType,
    required this.price,
    required this.classDocId,
  });

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
        final now = DateTime.now();
        availableTimes = (dynamicData as Map<String, dynamic>).map((day, hours) {
          DateTime parsedDay = DateFormat('yyyy-MM-dd').parse(day);
          if (parsedDay.isAfter(now) || DateFormat('yyyy-MM-dd').format(parsedDay) == DateFormat('yyyy-MM-dd').format(now)) {
            return MapEntry(day, (hours as Map<String, dynamic>).map((hour, seats) {
              return MapEntry(hour, seats as int);
            }));
          }
          return const MapEntry("", {});
        });
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
            Text("${AppLocalizations.of(context)!.price}: ${widget.price} ${AppLocalizations.of(context)!.currency}"), // Localized "Price"
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
          child: Text(AppLocalizations.of(context)!.close, style: const TextStyle(color: Colors.red)), // Localized "Close"
        ),
        TextButton(
          onPressed: _selectedHour != null
              ? () {
            _bookClass();
          }
              : null,
          child: Text(AppLocalizations.of(context)!.book), // Localized "Book"
        ),
      ],
    );
  }

  Widget _buildAvailableDays() {
    final availableDays = availableTimes.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.availableDays, style: const TextStyle(fontWeight: FontWeight.bold)), // Localized "Available Days"
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
                  _selectedHour = null;
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

    final DateTime selectedDayDate = DateFormat('yyyy-MM-dd').parse(_selectedDay!);
    final filteredAvailableHours = availableHours.where((hour) {
      if (DateFormat('yyyy-MM-dd').format(selectedDayDate) == DateFormat('yyyy-MM-dd').format(now)) {
        DateTime parsedHour = DateFormat('h:mm a', 'en').parse(hour); // Force English format for the time
        DateTime todayHour = DateTime(now.year, now.month, now.day, parsedHour.hour, parsedHour.minute);
        return todayHour.isAfter(now);
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.availableHours, style: const TextStyle(fontWeight: FontWeight.bold)), // Localized "Available Hours"
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: filteredAvailableHours.map((hour) {
            int availableSeats = availableTimes[_selectedDay]![hour]!;
            return ChoiceChip(
              label: Text("$hour (${AppLocalizations.of(context)!.seatsLeft}:$availableSeats)"), // Localized seats left
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
            // Check if the user already has a booking for this class, date, and hour
            final existingBooking = await _firestore
                .collection('bookings')
                .where('userId', isEqualTo: userId)
                .where('classDocId', isEqualTo: widget.classDocId)
                .where('date', isEqualTo: selectedDayString)
                .where('hour', isEqualTo: _selectedHour)
                .get();

            if (existingBooking.docs.isEmpty) {
              final bookingData = {
                'userId': userId,
                'className': widget.className,
                'classType': widget.classType,
                'date': selectedDayString,
                'hour': _selectedHour,
                'price': widget.price,
                'classDocId': widget.classDocId,
                'attend': false, // Add attendance tracking, initially set to false
              };

              // Save the booking
              await _firestore.collection('bookings').add(bookingData);

              // Decrease available seats for the booked time
              availableTimes[selectedDayString]![_selectedHour!] = currentSeats - 1;

              // Update class document with reduced available seats
              await _firestore.collection('classes').doc(widget.classDocId).update({
                'available_times': availableTimes,
              });

              if (mounted) {
                setState(() {});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.bookingSuccessful)), // Localized success message
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.alreadyBooked)), // Localized already booked message
                );
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.userNotLoggedIn)), // Localized user not logged in message
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.noSeatsAvailable)), // Localized no seats available message
          );
        }
      }
    }
  }
}
