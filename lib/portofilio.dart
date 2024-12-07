import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PortfolioPDFGenerator extends StatefulWidget {
  const PortfolioPDFGenerator({super.key});

  @override
  _PortfolioPDFGeneratorState createState() => _PortfolioPDFGeneratorState();
}

class _PortfolioPDFGeneratorState extends State<PortfolioPDFGenerator> {
  final pdf = pw.Document();
  File? generatedPDF;
  bool isGenerating = false;

  Future<pw.Font> _loadArabicFont() async {
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    return pw.Font.ttf(fontData);
  }

  Future<void> _generatePDF() async {
    setState(() => isGenerating = true);

    final arabicFont = await _loadArabicFont();
    // pdf.addPage(
    //   pw.MultiPage(build: 
    //   (context) => [
       
        
    //   ]
    //   )
    // );

    // First Page: Arabic
    pdf.addPage(
     // pw.MultiPage(build: build)
      pw.Page(
        pageTheme: _buildPageTheme(textDirection: pw.TextDirection.rtl),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'معلومات شخصية',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                font: arabicFont,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('الاسم: محمد أحمد', style: pw.TextStyle(font: arabicFont)),
            pw.Text('الاتصال: mohamed@example.com',
                style: pw.TextStyle(font: arabicFont)),
            pw.Text('الهاتف: +1234567890',
                style: pw.TextStyle(font: arabicFont)),
          ],
        ),
      ),
    );

    // Second Page: English
    pdf.addPage(
      pw.Page(
        pageTheme: _buildPageTheme(textDirection: pw.TextDirection.ltr),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Personal Information',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Name: John Doe'),
            pw.Text('Contact: johndoe@example.com'),
            pw.Text('Phone: +1234567890'),
            _buildPersonalInfoSection(),
            _buildSkillsSection(),
            _buildWorkExperienceSection()
          ],
        ),
      ),
    );

    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/portfolio.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    setState(() {
      generatedPDF = file;
      isGenerating = false;
    });
     // Show a snackbar with the file path
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: 
      Text("PDF Generated and saved at: ${file.path}")),
    );
  
  }

  pw.PageTheme _buildPageTheme({required pw.TextDirection textDirection}) {
    return pw.PageTheme(
      margin: const pw.EdgeInsets.all(20),
      textDirection: textDirection,
    );
  }

  pw.Widget _buildPersonalInfoSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Personal Information',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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
        pw.Text('Work Experience',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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
        pw.Text('Skills',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text(' Flutter Development'),
        pw.Text(' Dart Programming'),
        pw.Text(' UI/UX Design'),
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
      Share.shareXFiles([XFile(generatedPDF!.path)],
          text: 'Check out my portfolio!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: isGenerating ? null : _generatePDF,
              icon: isGenerating
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(isGenerating ? 'Generating...' : 'Generate PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isGenerating ? Colors.grey : Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: generatedPDF == null ? null : _openPDF,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    generatedPDF == null ? Colors.grey : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: generatedPDF == null ? null : _sharePDF,
              icon: const Icon(Icons.share),
              label: const Text('Share PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    generatedPDF == null ? Colors.grey : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final File file;

  const PDFViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View PDF')),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}
