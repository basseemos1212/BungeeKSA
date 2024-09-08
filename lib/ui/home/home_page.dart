import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle("Private Classes"),
          _buildCarousel(context, ["Private 1", "Private 2", "Private 3"]),
          const SizedBox(height: 16),
          _buildSectionTitle("Adult Classes"),
          _buildCarousel(context, ["Adult 1", "Adult 2", "Adult 3"]),
          const SizedBox(height: 16),
          _buildSectionTitle("Kids Classes"),
          _buildCarousel(context, ["Kids 1", "Kids 2", "Kids 3"]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, List<String> items) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildClassCard(context, items[index]);
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, String className) {
    return GestureDetector(
      onTap: () => _showClassDetailsDialog(context, className),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: _boxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImage('assets/images/logo.png', 100),
            const SizedBox(height: 8),
            Text(
              className,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Description here',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildImage(String path, double size) {
    return Image.asset(
      path,
      height: size,
      width: size,
    );
  }

  void _showClassDetailsDialog(BuildContext context, String className) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassDetailsDialog(className: className);
      },
    );
  }
}

class ClassDetailsDialog extends StatefulWidget {
  final String className;

  const ClassDetailsDialog({Key? key, required this.className}) : super(key: key);

  @override
  _ClassDetailsDialogState createState() => _ClassDetailsDialogState();
}

class _ClassDetailsDialogState extends State<ClassDetailsDialog> {
  String? _selectedDay;
  String? _selectedHour;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.className),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrainerInfo(),
            const SizedBox(height: 20),
            _buildSectionTitle("Available Times:"),
            const Text("Sunday - Thursday, 8 AM - 10 AM"),
            const Text("Location: Bungee Fitness Center, Room 3"),
            const SizedBox(height: 20),
            _buildSectionTitle("Available Days:"),
            _buildAvailableDays(),
            if (_selectedDay != null) ...[
              const SizedBox(height: 20),
              _buildSectionTitle("Available Hours:"),
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
          onPressed: _selectedDay != null && _selectedHour != null
              ? () {
                  // Handle booking logic here
                  Navigator.of(context).pop();
                }
              : null, // Disable if no day or hour is selected
          child: const Text('Book'),
        ),
      ],
    );
  }

  Widget _buildTrainerInfo() {
    return Row(
      children: [
        _buildImage('assets/images/trainer.png', 50),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trainer: Hanan Mohamed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Expert in Bungee Workouts"),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableDays() {
    List<String> days = ["Sun", "Mon", "Tue"];

    return Wrap(
      spacing: 8.0,
      children: days.map((day) {
        return ChoiceChip(
          label: Text(day),
          selected: _selectedDay == day,
          onSelected: (bool selected) {
            setState(() {
              _selectedDay = selected ? day : null;
              _selectedHour = null; // Reset selected hour when day changes
            });
          },
          selectedColor: Colors.greenAccent,
        );
      }).toList(),
    );
  }

  Widget _buildAvailableHours() {
    List<String> hours = ["8:00 AM", "9:00 AM", "10:00 AM","11:00 AM", "12:00 AM", "1:00 PM","2:00PM"];

    return Wrap(
      spacing: 8.0,
      children: hours.map((hour) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: ChoiceChip(
            label: Text(hour),
            selected: _selectedHour == hour,
            onSelected: (bool selected) {
              setState(() {
                _selectedHour = selected ? hour : null;
              });
            },
            selectedColor: Colors.blueAccent,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImage(String path, double size) {
    return Image.asset(
      path,
      height: size,
      width: size,
    );
  }
}
