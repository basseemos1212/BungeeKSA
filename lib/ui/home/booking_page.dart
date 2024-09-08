import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    List<DateTime> nextSevenDays = List.generate(7, (index) => today.add(Duration(days: index)));

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFilter(nextSevenDays),
          const SizedBox(height: 16),
          _buildSectionTitle("Upcoming 7 Days"),
          const SizedBox(height: 16),
          _selectedDay == null
              ? _buildUpcomingSevenDays(context, nextSevenDays)
              : _buildCalendarWithWorkouts(context, _selectedDay!),
        ],
      ),
    );
  }

  // Build the filter dropdown to select a specific day
  Widget _buildFilter(List<DateTime> nextSevenDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filter by Day:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<DateTime>(
          value: _selectedDay,
          hint: const Text('Select a Day'),
          onChanged: (DateTime? newDay) {
            setState(() {
              _selectedDay = newDay;
            });
          },
          items: nextSevenDays.map((DateTime day) {
            return DropdownMenuItem<DateTime>(
              value: day,
              child: Text(DateFormat('EEEE, MMM d').format(day)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Build the 7-day calendar with available workouts if no filter is selected
  Widget _buildUpcomingSevenDays(BuildContext context, List<DateTime> nextSevenDays) {
    return Column(
      children: nextSevenDays.map((day) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(day),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildWorkoutCard(
              context,
              day: day,
              classType: "Adult Class",
              availableSeats: 5,
              totalSeats: 10,
              trainerImage: 'assets/images/trainer.png',
              trainerName: "Hanan Mohamed",
            ),
            const SizedBox(height: 16),
            _buildWorkoutCard(
              context,
              day: day,
              classType: "Kids Class",
              availableSeats: 0, // Fully booked example
              totalSeats: 10,
              trainerImage: 'assets/images/trainer.png',
              trainerName: "Esraa Ali",
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  // Build the 7-day calendar with available workouts
  Widget _buildCalendarWithWorkouts(BuildContext context, DateTime selectedDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMM d').format(selectedDay),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildWorkoutCard(
          context,
          day: selectedDay,
          classType: "Adult Class",
          availableSeats: 5,
          totalSeats: 10,
          trainerImage: 'assets/images/trainer.png',
          trainerName: "Hanan Mohamed",
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard(
          context,
          day: selectedDay,
          classType: "Kids Class",
          availableSeats: 4,
          totalSeats: 11,
          trainerImage: 'assets/images/trainer.png',
          trainerName: "Esraa Ali",
        ),
        const Divider(),
      ],
    );
  }

  // Build individual workout card for a specific day
  Widget _buildWorkoutCard(
    BuildContext context, {
    required DateTime day,
    required String classType,
    required int availableSeats,
    required int totalSeats,
    required String trainerImage,
    required String trainerName,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Trainer's Image
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(trainerImage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classType,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Trainer: $trainerName",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "$availableSeats/$totalSeats seats available",
                  style: TextStyle(
                    fontSize: 14,
                    color: availableSeats == 0 ? Colors.red : Colors.blue, // Red color for full classes
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
