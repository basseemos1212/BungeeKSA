import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For star ratings
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization

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
        SnackBar(content: Text(AppLocalizations.of(context)!.feedbackSubmittedSuccessfully)),
      );
      Navigator.pop(context); // Close the feedback form
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorSubmittingFeedback}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.giveFeedback),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.rateWorkout),
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
            Text(AppLocalizations.of(context)!.rateTrainer),
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
            Text(AppLocalizations.of(context)!.rateAtmosphere),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.additionalFeedback,
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text(AppLocalizations.of(context)!.submitFeedback),
            ),
          ],
        ),
      ),
    );
  }
}
