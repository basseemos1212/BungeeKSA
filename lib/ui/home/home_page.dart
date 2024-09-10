import 'package:bungee_ksa/blocs/states/classes_state.dart';
import 'package:bungee_ksa/ui/widgets/classes_detail_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bungee_ksa/blocs/bloc/classes_bloc.dart';

import '../../blocs/events/classes_event.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Trigger the FetchClasses event to start the real-time stream
    context.read<ClassesBloc>().add(FetchClasses());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bungee Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-class'),
          ),
        ],
      ),
      body: BlocBuilder<ClassesBloc, ClassesState>(
        builder: (context, state) {
          if (state is ClassesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClassesLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionTitleWithIcon(context, 'assets/images/limited_offer.png'),
                _buildCarouselWithType(context, 'Hot Deals', state.classes),
                const SizedBox(height: 16),
                _buildSectionTitle("Private Classes"),
                _buildCarouselWithType(context, 'Private', state.classes),
                const SizedBox(height: 16),
                _buildSectionTitle("Adult Classes"),
                _buildCarouselWithType(context, 'Adult', state.classes),
                const SizedBox(height: 16),
                _buildSectionTitle("Kids Classes"),
                _buildCarouselWithType(context, 'Kids', state.classes),
              ],
            );
          } else if (state is ClassesError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
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

  Widget _buildCarouselWithType(BuildContext context, String classType, List<DocumentSnapshot> classes) {
    // Filter classes by the type (i.e., Private, Adult, Kids, etc.)
    final filteredClasses = classes.where((doc) => doc['type'] == classType).toList();

    if (filteredClasses.isEmpty) {
      return Center(child: Text('No $classType classes available.'));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredClasses.length,
        itemBuilder: (context, index) {
          return _buildClassCard(context, filteredClasses[index]);
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, DocumentSnapshot classDoc) {
    // Ensure fields exist and have valid values
    final String className = classDoc['name'] ?? 'Unknown Class';
    final int? price = classDoc['price'];

    // Handle cases where price or className might be missing
    if (price == null) {
      return const Center(child: Text('Invalid class data'));
    }

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
    final String className = classDoc['name'] ?? 'Unknown Class';
    final int? price = classDoc['price'];
    final String classDocId = classDoc.id;

    // Check if price is valid before showing the dialog
    if (price != null) {
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
    } else {
      // Show error message if class data is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid class data.')),
      );
    }
  }
}
