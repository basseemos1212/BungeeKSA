import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For star ratings

class FeedbackFormPage extends StatefulWidget {
  final String classId;
  final String userId; // Now passing userId directly

  const FeedbackFormPage({
    super.key,
    required this.classId,
    required this.userId,
  });

  @override
  _FeedbackFormPageState createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  double workoutRating = 0.0;
  double trainerRating = 0.0;
  double atmosphereRating = 0.0;
  final TextEditingController feedbackController = TextEditingController();

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'classId': widget.classId,
        'userId': widget.userId, // Storing userId in Firestore
        'workoutRating': workoutRating,
        'trainerRating': trainerRating,
        'atmosphereRating': atmosphereRating,
        'writtenFeedback': feedbackController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
      Navigator.pop(context); // Close the feedback form
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate the Workout:'),
            RatingBar.builder(
              initialRating: workoutRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  workoutRating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Rate the Trainer:'),
            RatingBar.builder(
              initialRating: trainerRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  trainerRating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Rate the Atmosphere:'),
            RatingBar.builder(
              initialRating: atmosphereRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  atmosphereRating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'Additional Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
