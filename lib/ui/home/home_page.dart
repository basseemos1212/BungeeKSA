import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bungee_ksa/ui/widgets/classes_detail_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ScaffoldMessengerState _scaffoldMessenger;

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
          if (userEmail != null && (userEmail.contains('@admin') || userEmail.contains('@manager')))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/add-class'), // Navigate to AddClassScreen
            ),
          if (userEmail != null && userEmail.contains('@admin'))
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => Navigator.pushNamed(context, '/add-class-type'), // Navigate to AddClassTypeScreen
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
                  const SizedBox(height: 0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: _buildCarouselWithType(context, classType, userEmail),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Widget to build the section title with the option to delete the class type (for admins)
  Widget _buildSectionTitle(BuildContext context, String classType, String classTypeId, String? userEmail) {
    return Row(
      children: [
        if (classType.toLowerCase() == "limited offer") // If class type is "Limited Offer", show the image
          Image.asset(
            'assets/images/limited_offer.png', // Path to the Limited Offer image
            height: 130,
          )
        else // Otherwise, show the class type name
          Text(
            classType,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        if (userEmail != null && userEmail.contains('@admin')) // Add delete button for admins
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteClassTypeWithClasses(context, classTypeId),
          ),
      ],
    );
  }

  // Function to build the list of classes based on the class type
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
          height: 200,
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

    return GestureDetector(
      onTap: () => _showClassDetailsDialog(context, classDoc),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: _boxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              className,  // Always show the class name
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Price: $price SAR',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (userEmail != null && userEmail.contains('@admin')) ...[
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteClass(classDoc.id),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
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

  // Function to delete a class and show a confirmation message
  Future<void> _deleteClass(String classDocId) async {
    try {
      await _firestore.collection('classes').doc(classDocId).delete();
      _scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Class deleted successfully')),
      );
    } catch (e) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to delete class: $e')),
      );
    }
  }

  // Function to delete a class type and all associated classes
  Future<void> _deleteClassTypeWithClasses(BuildContext context, String classTypeId) async {
    try {
      // First, delete all classes associated with this class type
      final classesQuerySnapshot = await _firestore.collection('classes').where('typeId', isEqualTo: classTypeId).get();
      for (var classDoc in classesQuerySnapshot.docs) {
        await _firestore.collection('classes').doc(classDoc.id).delete();
      }

      // Then delete the class type itself
      await _firestore.collection('classTypes').doc(classTypeId).delete();
      
      _scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Class type and associated classes deleted successfully')),
      );
    } catch (e) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to delete class type: $e')),
      );
    }
  }
}
