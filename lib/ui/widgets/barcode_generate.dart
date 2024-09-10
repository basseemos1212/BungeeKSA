import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class BarcodeScreen extends StatelessWidget {
  final String customerName;
  final int price;
  final String className;

  BarcodeScreen({
    required this.customerName,
    required this.price,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    String barcodeData = '$customerName | $className | $price SAR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Barcode'),
      ),
      body: Center(
        child: BarcodeWidget(
          barcode: Barcode.code128(),
          data: barcodeData,
          width: 200,
          height: 100,
          drawText: true,
        ),
      ),
    );
  }
}
