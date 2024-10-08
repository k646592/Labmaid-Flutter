import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewScreen extends StatefulWidget {
  final String pdfData;
  final String pdfName;

  const PdfViewScreen({Key? key, required this.pdfData, required this.pdfName}) : super(key:key);

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const Center(child: CircularProgressIndicator());
    if (widget.pdfData != '') {
      child = SfPdfViewer.memory(
        base64Decode(widget.pdfData),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.pdfName)),
      body: child,
    );
  }
}