import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PortfolioPDFGenerator extends StatefulWidget {
  @override
  _PortfolioPDFGeneratorState createState() => _PortfolioPDFGeneratorState();
}

class _PortfolioPDFGeneratorState extends State<PortfolioPDFGenerator> {
  final pdf = pw.Document();
  File? generatedPDF;

  @override
  void initState() {
    super.initState();
    _generatePDF();
  }

  Future<void> _generatePDF() async {
    pdf.addPage(
      pw.MultiPage(
        pageTheme: _buildPageTheme(),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Text('Portfolio', style: pw.TextStyle(fontSize: 20, color: PdfColors.blue)),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(color: PdfColors.grey, fontSize: 12),
          ),
        ),
        build: (context) => [
          _buildPersonalInfoSection(),
          _buildWorkExperienceSection(),
          _buildSkillsSection(),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/portfolio.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    setState(() {
      generatedPDF = file;
    });
  }

  pw.PageTheme _buildPageTheme() {
    return pw.PageTheme(
      margin: const pw.EdgeInsets.all(20),
      textDirection: pw.TextDirection.ltr,
    );
  }

  pw.Widget _buildPersonalInfoSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Personal Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Name: John Doe'),
        pw.Text('Contact: johndoe@example.com'),
        pw.Text('Phone: +1234567890'),
      ],
    );
  }

  pw.Widget _buildWorkExperienceSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Text('Work Experience', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Bullet(text: 'Software Developer at XYZ Inc.'),
        pw.Bullet(text: 'Intern at ABC Ltd.'),
      ],
    );
  }

  pw.Widget _buildSkillsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Text('Skills', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('• Flutter Development'),
        pw.Text('• Dart Programming'),
        pw.Text('• UI/UX Design'),
      ],
    );
  }

  void _openPDF() {
    if (generatedPDF != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(file: generatedPDF!),
        ),
      );
    }
  }

  void _sharePDF() {
    if (generatedPDF != null) {
      Share.shareFiles([generatedPDF!.path], text: 'Check out my portfolio!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Portfolio PDF')),
      body: Center(
        child: generatedPDF == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _openPDF,
                    child: Text('Open PDF'),
                  ),
                  ElevatedButton(
                    onPressed: _sharePDF,
                    child: Text('Share PDF'),
                  ),
                ],
              ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final File file;

  PDFViewerScreen({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View PDF')),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}
