import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // For random selection

import 'package:bungee_ksa/ui/widgets/classes_detail_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ScaffoldMessengerState _scaffoldMessenger;

  // List of background images
  final List<String> backgroundImages = [
    'assets/images/1.jpeg',
    'assets/images/2.jpg',
    'assets/images/3.jpeg',
    'assets/images/4.jpg',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String? userEmail = user?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bungee Classes'),
        actions: [
          if (userEmail != null &&
              (userEmail.contains('@admin') || userEmail.contains('@manager')))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/add-class'),
            ),
          if (userEmail != null && userEmail.contains('@admin'))
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => Navigator.pushNamed(context, '/add-class-type'),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('classTypes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No class types available.'));
          }

          List<DocumentSnapshot> classTypes = snapshot.data!.docs;

          // Reorder classTypes to ensure "Limited Offer" appears first
          classTypes.sort((a, b) {
            if (a['name'].toLowerCase() == "limited offer") return -1;
            if (b['name'].toLowerCase() == "limited offer") return 1;
            return 0;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: classTypes.length,
            itemBuilder: (context, index) {
              final classTypeDoc = classTypes[index];
              final classType = classTypeDoc['name'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, classType, classTypeDoc.id, userEmail),
                  const SizedBox(height: 16),
                  _buildCarouselWithType(context, classType, userEmail),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String classType, String classTypeId, String? userEmail) {
    return Row(
      children: [
        if (classType.toLowerCase() == "limited offer") // If class type is "Limited Offer", show the image
          Image.asset(
            'assets/images/limited_offer.png', // Path to the Limited Offer image
            height: 130,
          )
        else // Otherwise, show the class type name
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              classType,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
        if (userEmail != null && userEmail.contains('@admin')) // Add delete button for admins
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteClassTypeWithClasses(context, classTypeId),
          ),
      ],
    );
  }

  Widget _buildCarouselWithType(BuildContext context, String classType, String? userEmail) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('classes').where('type', isEqualTo: classType).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No $classType classes available.'));
        }

        final classes = snapshot.data!.docs;

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return _buildClassCard(context, classes[index], userEmail);
            },
          ),
        );
      },
    );
  }

  Widget _buildClassCard(BuildContext context, DocumentSnapshot classDoc, String? userEmail) {
    final String className = classDoc['name'];
    final int price = classDoc['price'];

    // Select a random background image from the list
    final String randomBackgroundImage = backgroundImages[Random().nextInt(backgroundImages.length)];

    return GestureDetector(
      onTap: () => _showClassDetailsDialog(context, classDoc),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image
            Container(
              width: 160,
              height: 220,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(randomBackgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              width: 160,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Class Details
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: $price SAR',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (userEmail != null && userEmail.contains('@admin'))
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteClass(classDoc.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClassDetailsDialog(BuildContext context, DocumentSnapshot classDoc) {
    final String className = classDoc['name'];
    final int price = classDoc['price'];
    final String classDocId = classDoc.id;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassDetailsDialog(
          className: className,
          classType: classDoc['type'],
          price: price,
          classDocId: classDocId,
        );
      },
    );
  }
  Future<void> _deleteClass(String classDocId) async {
    try {
      // First, delete all bookings associated with this class
      final bookingsQuerySnapshot = await _firestore
          .collection('bookings')
          .where('classDocId', isEqualTo: classDocId)
          .get();

      for (var bookingDoc in bookingsQuerySnapshot.docs) {
        await _firestore.collection('bookings').doc(bookingDoc.id).delete();
      }

      // Then delete the class itself
      await _firestore.collection('classes').doc(classDocId).delete();

      _scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Class and related bookings deleted successfully')),
      );
    } catch (e) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to delete class and bookings: $e')),
      );
    }
  }

  Future<void> _deleteClassTypeWithClasses(BuildContext context, String classTypeId) async {
    try {
      // Step 1: Fetch the classTypeName based on the classTypeId
      DocumentSnapshot classTypeDoc = await _firestore.collection('classTypes').doc(classTypeId).get();
      if (!classTypeDoc.exists) {
        _scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Class type not found')),
        );
        return;
      }

      String classTypeName = classTypeDoc['name']; // Get the classTypeName

      // Step 2: Delete all classes associated with the classTypeName
      final classesQuerySnapshot = await _firestore
          .collection('classes')
          .where('type', isEqualTo: classTypeName) // Query using the classTypeName
          .get();

      for (var classDoc in classesQuerySnapshot.docs) {
        // Delete the class itself
        await _firestore.collection('classes').doc(classDoc.id).delete();
      }

      // Step 3: Delete all bookings associated with the classTypeName
      final bookingsQuerySnapshot = await _firestore
          .collection('bookings')
          .where('classType', isEqualTo: classTypeName) // Query using the classTypeName
          .get();

      for (var bookingDoc in bookingsQuerySnapshot.docs) {
        // Delete the booking itself
        await _firestore.collection('bookings').doc(bookingDoc.id).delete();
      }

      // Step 4: Finally, delete the class type document itself
      await _firestore.collection('classTypes').doc(classTypeId).delete();

      _scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Class type, related classes, and bookings deleted successfully')),
      );
    } catch (e) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to delete class type, classes, and bookings: $e')),
      );
    }
  }



}
