// invoice_scanner_screen.dart

import 'package:flutter/material.dart';

class InvoiceScannerScreen extends StatelessWidget {
  const InvoiceScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Scanner')),
      body: const Center(child: Text('Invoice Scanner Screen')),
    );
  }
}
