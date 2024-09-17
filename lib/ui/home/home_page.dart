import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // For random selection

import 'package:bungee_ksa/ui/widgets/classes_detail_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization


class HomePage extends StatefulWidget {
  final dynamic userData; // Pass user data to HomePage

  const HomePage({super.key, required this.userData});

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
        title:  Text(AppLocalizations.of(context)!.bungeeClasses),
        actions: [
          // Show "Add Class" button for admins and managers
          if (_isAdminOrManager(userEmail))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/add-class'),
            ),
          // Show "Add Class Type" button for admins only
          if (_isAdmin(userEmail))
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

          // Ensure "Limited Offer" class type is first
          classTypes.sort((a, b) => _sortLimitedOfferFirst(a, b));

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

  // Helper function to sort "Limited Offer" to appear first
  int _sortLimitedOfferFirst(DocumentSnapshot a, DocumentSnapshot b) {
    if (a['name'].toLowerCase() == "limited offer") return -1;
    if (b['name'].toLowerCase() == "limited offer") return 1;
    return 0;
  }

  // Helper function to check if the user is an admin
  bool _isAdmin(String? email) {
    return email != null && email.contains('@admin');
  }

  // Helper function to check if the user is either an admin or a manager
  bool _isAdminOrManager(String? email) {
    return email != null && (email.contains('@admin') || email.contains('@manager'));
  }

  // Build section title for each class type
  Widget _buildSectionTitle(BuildContext context, String classType, String classTypeId, String? userEmail) {
    return Row(
      children: [
        // Show "Limited Offer" image if class type is "Limited Offer"
        if (classType.toLowerCase() == "limited offer")
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
        if (_isAdmin(userEmail)) // Add delete button for admins
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteClassTypeWithClasses(context, classTypeId),
          ),
      ],
    );
  }

  // Build carousel for classes under each class type
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

  // Build a single class card for the carousel
  Widget _buildClassCard(BuildContext context, DocumentSnapshot classDoc, String? userEmail) {
    final String className = classDoc['name'];
    final int price = classDoc['price'];

    // Select a random background image
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
                    '${AppLocalizations.of(context)!.price}: $price ${AppLocalizations.of(context)!.currency}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (_isAdmin(userEmail))
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

  // Show class details dialog
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

  // Delete a class and its associated bookings
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

  // Delete a class type, related classes, and bookings
  Future<void> _deleteClassTypeWithClasses(BuildContext context, String classTypeId) async {
    try {
      DocumentSnapshot classTypeDoc = await _firestore.collection('classTypes').doc(classTypeId).get();
      if (!classTypeDoc.exists) {
        _scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Class type not found')),
        );
        return;
      }

      String classTypeName = classTypeDoc['name'];

      // Delete all classes of this type
      final classesQuerySnapshot = await _firestore
          .collection('classes')
          .where('type', isEqualTo: classTypeName)
          .get();

      for (var classDoc in classesQuerySnapshot.docs) {
        await _firestore.collection('classes').doc(classDoc.id).delete();
      }

      // Delete associated bookings
      final bookingsQuerySnapshot = await _firestore
          .collection('bookings')
          .where('classType', isEqualTo: classTypeName)
          .get();

      for (var bookingDoc in bookingsQuerySnapshot.docs) {
        await _firestore.collection('bookings').doc(bookingDoc.id).delete();
      }

      // Finally, delete the class type
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
