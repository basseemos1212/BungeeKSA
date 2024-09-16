import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class BarcodeDetailPage extends StatelessWidget {
  final String className;
  final String date;
  final String hour;
  final int price;
  final String barcodeData;
  final Map<String, dynamic> userData; // Accept userData with userName and userEmail

  const BarcodeDetailPage({
    super.key,
    required this.className,
    required this.date,
    required this.hour,
    required this.price,
    required this.barcodeData,
    required this.userData, // Ensure userData is passed
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display user name and email
            Text(
              "User: ${userData['name']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Email: ${userData['email']}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Display class details
            Text(
              className,
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
                  "Date: $date",
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
                  "Time: $hour",
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
                  "Price: $price SAR",
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Display the barcode
            BarcodeWidget(
              barcode: Barcode.code128(), // Using Code 128 for barcodes
              data: barcodeData, // The barcode data (userId + classId)
              width: 220,
              height: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              "Scan this barcode at the entrance.",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
