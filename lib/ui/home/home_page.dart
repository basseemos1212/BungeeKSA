import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bungee_ksa/ui/widgets/classes_detail_dialog.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bungee Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-class'), // Navigate to AddClassScreen
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitleWithIcon(context, 'assets/images/limited_offer.png'),
          _buildCarouselWithType(context, 'Hot Deals'),
          const SizedBox(height: 16),
          _buildSectionTitle("Private Classes"),
          _buildCarouselWithType(context, 'Private'),
          const SizedBox(height: 16),
          _buildSectionTitle("Adult Classes"),
          _buildCarouselWithType(context, 'Adult'),
          const SizedBox(height: 16),
          _buildSectionTitle("Kids Classes"),
          _buildCarouselWithType(context, 'Kids'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitleWithIcon(BuildContext context, String iconPath) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          height: 130,
          width: 130,
          fit: BoxFit.fill,
        ),
      ],
    );
  }

  Widget _buildCarouselWithType(BuildContext context, String classType) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('classes').where('type', isEqualTo: classType).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No $classType classes available.'));
        }

        List<DocumentSnapshot> classes = snapshot.data!.docs;

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return _buildClassCard(context, classes[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildClassCard(BuildContext context, DocumentSnapshot classDoc) {
    String className = classDoc['name'];
    int price = classDoc['price'];

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
              className,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Price: $price SAR',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
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
    String className = classDoc['name'];
    int price = classDoc['price'];
    String classDocId = classDoc.id;

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
}
