import 'package:bungee_ksa/ui/widgets/barcode_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:math';

class BarcodePage extends StatefulWidget {
  final dynamic userData;  // Add user data as a parameter

  const BarcodePage({super.key, required this.userData});

  @override
  _BarcodePageState createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final List<String> backgroundImages = [
    'assets/images/1.jpeg',  // Background Image 1
    'assets/images/2.jpg',   // Background Image 2
    'assets/images/3.jpeg',  // Background Image 3
    'assets/images/4.jpg',   // Background Image 4
  ];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userEmail;
  bool isScanning = false;
  bool scanSuccess = false;
  Map<String, bool> expandedState = {}; // To track expanded user bookings

  @override
  void initState() {
    super.initState();
    userEmail = _auth.currentUser?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Classes'),
      ),
      body: userEmail != null && userEmail!.contains('@manager')
          ? _buildManagerScanner()  // Manager scans barcodes
          : userEmail != null && userEmail!.contains('@admin')
              ? _buildAdminUserList()  // Admin views all users and their bookings
              : _buildUserBookings(),  // Normal users view their bookings
    );
  }

  // Build camera scanner for manager
  Widget _buildManagerScanner() {
    return Center(
      child: ElevatedButton(
        onPressed: isScanning ? null : _startBarcodeScan,  // Disable button during scanning
        child: Text(isScanning ? 'Scanning...' : 'Start Scanning'),
      ),
    );
  }

  // Start barcode scanning
  Future<void> _startBarcodeScan() async {
    try {
      setState(() {
        isScanning = true;
      });

      // Start barcode scanning
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        await _processScannedBarcode(result.rawContent);
      }
    } catch (e) {
      print('Error during scan: $e');
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  // Process the scanned barcode and mark the user as attended
  Future<void> _processScannedBarcode(String barcodeData) async {
    try {
      final parts = barcodeData.split('-');
      if (parts.length != 2) {
        _showScanResult(false);  // Invalid barcode format
        return;
      }

      final userId = parts[0];
      final classId = parts[1];

      // Find the booking and mark as attended
      final bookingSnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('classDocId', isEqualTo: classId)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        final bookingDoc = bookingSnapshot.docs.first;
        await _firestore.collection('bookings').doc(bookingDoc.id).update({
          'attend': true,
        });

        // Show success feedback
        _showScanResult(true);
      } else {
        _showScanResult(false);
      }
    } catch (e) {
      print('Error processing barcode: $e');
      _showScanResult(false);
    }
  }

  // Show result of scan with animation (checkmark for success, cross for failure)
  void _showScanResult(bool success) {
    setState(() {
      scanSuccess = success;
    });

    // Show a dialog or an animation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Scan Successful' : 'Scan Failed'),
          content: success
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 100),
                    SizedBox(height: 20),
                    Text('User has been marked as attended.'),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 100),
                    SizedBox(height: 20),
                    Text('Invalid barcode or booking not found.'),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Build user list for admin
  Widget _buildAdminUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userId = userDoc.id;
            final userName = userDoc['email'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(userName),
                  trailing: IconButton(
                    icon: Icon(
                      expandedState[userId] == true
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        expandedState[userId] = !(expandedState[userId] ?? false);
                      });
                    },
                  ),
                ),
                if (expandedState[userId] == true)
                  _buildUserBookingsForAdmin(userId), // Fetch user bookings when expanded
              ],
            );
          },
        );
      },
    );
  }

  // Build bookings for a particular user (for admin)
  Widget _buildUserBookingsForAdmin(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('attend', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No bookings available.'),
          );
        }

        final bookings = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,  // To allow nesting in ListView
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final classDetail = bookings[index].data() as Map<String, dynamic>;
            final classId = bookings[index].id;
            return _buildClassCard(context, classDetail, classId);
          },
        );
      },
    );
  }

  // Build bookings for the current user (non-manager view)
  Widget _buildUserBookings() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .where('attend', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No available classes for attendance.'));
        }

        final bookings = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final classDetail = bookings[index].data() as Map<String, dynamic>;
            final classId = bookings[index].id;
            return _buildClassCard(context, classDetail, classId);
          },
        );
      },
    );
  }

  // Build booking card with the random background for users
  Widget _buildClassCard(BuildContext context, Map<String, dynamic> classDetail, String classId) {
    final userId = _auth.currentUser?.uid;
    final String randomBackgroundImage = backgroundImages[Random().nextInt(backgroundImages.length)];

    return GestureDetector(
      onTap: () {
       Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BarcodeDetailPage(
      className: classDetail['className'],
      date: classDetail['date'],
      price: classDetail['price'],
      hour: classDetail['hour'],
      barcodeData: "$userId-$classId",
      userData: {
        'name': widget.userData['name'],  // Pass user name
        'email': widget.userData['email'], // Pass user email
      },
    ),
  ),
);

      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          image: DecorationImage(
            image: AssetImage(randomBackgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classDetail['className'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Date: ${classDetail['date']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Time: ${classDetail['hour']}",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Price: ${classDetail['price']} SAR",
                    style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Tap to view barcode",
                style: TextStyle(fontSize: 14, color: Colors.amberAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
