import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';


class PdfViewScreen extends StatefulWidget {
  final String pdfURL;
  final String fileName;

  const PdfViewScreen({Key? key, required this.pdfURL, required this.fileName}) : super(key:key);

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  Uint8List? pdfBytes;

  @override
  void initState() {
    super.initState();
    _fetchPDF();
  }

  Future<void> _fetchPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfURL));
      if (response.statusCode == 200) {
        setState(() {
          pdfBytes = response.bodyBytes;
        });
      } else {
        print('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const Center(child: CircularProgressIndicator());
    if (pdfBytes != null) {
      child = PdfPreview(
          build: (format) => pdfBytes!,
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.fileName,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: child,
    );
  }
}