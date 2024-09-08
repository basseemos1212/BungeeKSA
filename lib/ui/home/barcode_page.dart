import 'package:flutter/material.dart';

class BarcodePage extends StatelessWidget {
  final List<Map<String, dynamic>> classDetails = [
    {
      "className": "Adult Bungee Workout",
      "date": "September 6, 2024",
      "price": 150,
      "barcodeImage": 'assets/images/barcode.png',
      "attended": true, // User has not attended
    },
    {
      "className": "Kids Bungee Basics",
      "date": "September 12, 2024",
      "price": 100,
      "barcodeImage": 'assets/images/barcode.png',
      "attended": false, // User has attended this class
    },
    {
      "className": "Advanced Bungee",
      "date": "September 15, 2024",
      "price": 200,
      "barcodeImage": 'assets/images/barcode.png',
      "attended": false, // User has not attended
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: classDetails.length,
        itemBuilder: (context, index) {
          return _buildClassCard(context, classDetails[index]);
        },
      ),
    );
  }

  // Build each class card
  Widget _buildClassCard(BuildContext context, Map<String, dynamic> classDetail) {
    return GestureDetector(
      onTap: () {
        // When tapped, open the barcode detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarcodeDetailPage(
              className: classDetail['className'],
              date: classDetail['date'],
              price: classDetail['price'],
              barcodeImage: classDetail['barcodeImage'],
              attended: classDetail['attended'],
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classDetail['className'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Date: ${classDetail['date']}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Price: ${classDetail['price']} SAR",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              if (classDetail['attended'])
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Class attended",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarcodeDetailPage extends StatelessWidget {
  final String className;
  final String date;
  final int price;
  final String barcodeImage;
  final bool attended;

  const BarcodeDetailPage({
    Key? key,
    required this.className,
    required this.date,
    required this.price,
    required this.barcodeImage,
    required this.attended,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                className,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Date: $date",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                "Price: $price SAR",
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
              const SizedBox(height: 40),
              // Display the barcode if not attended, otherwise show a message
              if (!attended)
                Image.asset(
                  barcodeImage,
                  height: 150,
                )
              else
                const Text(
                  "You have already attended this class.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.red),
                ),
              const SizedBox(height: 20),
              if (!attended)
                const Text(
                  "Scan this barcode at the entrance.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
