import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For checkmark animation
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization

import 'feedback_form.dart'; // For Timer to close the page automatically

class BarcodeDetailPage extends StatefulWidget {
  final String className;
  final String date;
  final String hour;
  final int price;
  final String barcodeData; // barcodeData contains userId-classId

  const BarcodeDetailPage({
    super.key,
    required this.className,
    required this.date,
    required this.hour,
    required this.price,
    required this.barcodeData,
  });

  @override
  _BarcodeDetailPageState createState() => _BarcodeDetailPageState();
}

class _BarcodeDetailPageState extends State<BarcodeDetailPage> {
  bool _isAttendanceMarked = false; // To prevent multiple animations

  @override
  void initState() {
    super.initState();
    _listenToAttendance(); // Start listening to attendance status changes
  }

  // Stream to listen for attendance updates in Firestore
  void _listenToAttendance() {
    final parts = widget.barcodeData.split('-'); // Assuming userId and classId format
    if (parts.length == 2) {
      final classId = parts[1]; // The classId is actually the document ID

      // Listen for real-time updates to the "attend" field in the specific document
      FirebaseFirestore.instance
          .collection('bookings')
          .doc(classId) // Access the document directly by its ID
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final bool attend = snapshot['attend'] ?? false;
          if (attend && !_isAttendanceMarked) {
            setState(() {
              _isAttendanceMarked = true; // Prevent multiple animations
            });
            _showCheckmarkAnimation(); // Show checkmark animation
          }
        }
      });
    }
  }

  // Show checkmark animation and close the page before navigating to feedback
  void _showCheckmarkAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/animations/checkmark.json', // Use a checkmark animation from Lottie
          width: 300,
          height: 300,
          repeat: false,
          onLoaded: (composition) {
            Timer(const Duration(seconds: 2), () {
              Navigator.of(context).pop(); // Close the dialog

              // Pop the BarcodeDetailPage from the stack first
              Navigator.of(context).pop();

              // Then navigate to the feedback form page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FeedbackFormPage(
                    classId: widget.barcodeData.split('-')[1], // Pass classId
                    userId: widget.barcodeData.split('-')[0], // Pass userId
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.barcodeData.split('-')[0]; // Extract userId
    final classId = widget.barcodeData.split('-')[1]; // Extract classId

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display userId
            Text(
              "${AppLocalizations.of(context)!.userID}: $userId",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Display class details
            Text(
              widget.className,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.date_range, color: Colors.grey, size: 22),
                const SizedBox(width: 10),
                Text(
                  "${AppLocalizations.of(context)!.date}: ${widget.date}",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 22),
                const SizedBox(width: 10),
                Text(
                  "${AppLocalizations.of(context)!.time}: ${widget.hour}",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.attach_money, color: Colors.blue, size: 22),
                const SizedBox(width: 10),
                Text(
                  "${AppLocalizations.of(context)!.price}: ${widget.price} ${AppLocalizations.of(context)!.currency}",
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Display the barcode
            BarcodeWidget(
              barcode: Barcode.code128(), // Using Code 128 for barcodes
              data: widget.barcodeData, // The barcode data (userId + classId)
              width: 220,
              height: 90,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.scanBarcodeAtEntrance,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
