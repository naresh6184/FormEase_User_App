import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formease/themed_scaffold.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'homepage.dart';

class PDFGeneratorPGPage extends StatefulWidget {
  final String name, rollNo, department, hostelBlock, days, leaveStartDate,
      leaveEndDate, natureOfLeave, reason, address, mobile , email;

  const PDFGeneratorPGPage({
    super.key,
    required this.name,
    required this.rollNo,
    required this.department,
    required this.hostelBlock,
    required this.days,
    required this.leaveStartDate,
    required this.leaveEndDate,
    required this.natureOfLeave,
    required this.reason,
    required this.address,
    required this.mobile,
    required this.email,
  });

  @override
  _PDFGeneratorPGPageState createState() => _PDFGeneratorPGPageState();
}

class _PDFGeneratorPGPageState extends State<PDFGeneratorPGPage> {
  Uint8List? pdfData;
  late pw.Font ttfRegular;
  late pw.Font ttfBold;
  late pw.Font ttfHindi;
  String? _applicationId;
  bool _isLoading = false;

  @override
  void initState() {
    _loadFonts();
    super.initState();
  }

  Future<void> _loadFonts() async {
    try {
      final robotoRegular = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final robotoBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
      final hindiFont = await rootBundle.load("assets/fonts/TiroDevanagariHindi-Regular.ttf");

      ttfRegular = pw.Font.ttf(robotoRegular);
      ttfBold = pw.Font.ttf(robotoBold);
      ttfHindi = pw.Font.ttf(hindiFont);
    } catch (e) {
      throw Exception('Failed to load fonts: $e');
    }
  }

  Future<Uint8List> _generatePdf(String applicationId) async {
    final pdf = pw.Document();

    // Load the header image before adding pages
    final ByteData data = await rootBundle.load('assets/collegeheader.png');
    final Uint8List imageBytes = data.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        build: (pw.Context context) {
          final pageWidth = PdfPageFormat.a4.width - 60; // Adjusted width after margins

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(applicationId, imageBytes), // Pass the image
              _buildFormTitle(),
              _buildStudentInfo(pageWidth), // Pass page width
              _buildSignatureSection(),
              _buildOfficeUseSection(pageWidth),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }


  pw.Widget _buildHeader(String applicationId, Uint8List imageBytes) {
    return pw.Container(
      height: 75, // Force a fixed height to prevent extra space
      child: pw.Stack(
        children: [
          pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.Image(
              pw.MemoryImage(imageBytes),
              width: 483, // Adjust width as needed
              fit: pw.BoxFit.contain, // Ensures no extra space
            ),
          ),
          pw.Positioned(
            top: 0, // Moves ID to the absolute top
            right: 0,
            child: pw.Text(
              'ID: $applicationId',
              style: pw.TextStyle(fontSize: 15, font: ttfBold),
            ),
          ),
        ],
      ),
    );
  }





  pw.Widget _buildFormTitle() {
    return pw.Column(
      children: [
        pw.Divider(height: 10, thickness: 1),
        pw.Center(
          child: pw.Text(
            'Student Leave Application Form (for PG)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              font: ttfBold,
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            '(The leave application form should be submitted at least 36 hours before leaving the campus)',
            style: pw.TextStyle(fontSize: 9, font: ttfRegular),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildStudentInfo(double pageWidth) {
    return pw.Container(
      width: pageWidth, // Ensure bounded width
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildField('1. Name : ', widget.name, pageWidth),
          pw.SizedBox(height: 2),
          pw.Row(
            children: [
              pw.Expanded(child: _buildField('2. Roll No : ', widget.rollNo, pageWidth / 2 - 10)),
              pw.SizedBox(width: 10),
              pw.Expanded(child: _buildField('Department : ', widget.department, pageWidth / 2 - 10)),
            ],
          ),
          _buildField('3. Hostel Block & Room No. : ', widget.hostelBlock, pageWidth),
          _buildField('4. No. of Days applied for Leave : ', widget.days, pageWidth),
          pw.SizedBox(height: 2),
          pw.Row(
            children: [
              pw.Expanded(child: _buildField('5. Duration of leave     From : ', widget.leaveStartDate, pageWidth / 2 - 10)),
              pw.SizedBox(width: 10),
              pw.Expanded(child: _buildField('To : ', widget.leaveEndDate, pageWidth / 2 - 10)),
            ],
          ),
          _buildField('6. Nature of Leave : ', widget.natureOfLeave, pageWidth),
          _buildField('7. Reason of Leave : ', widget.reason, pageWidth),
          _buildField('8. Address during Leave : ', widget.address, pageWidth),
          pw.Row(
            children:[
              pw.Expanded(child: _buildField('9. Mobile No. : ', widget.mobile, pageWidth / 2-10 ),),
              pw.Expanded(child: _buildField('10. Institute E-mail ID:', widget.email, pageWidth / 2-10 , fontsize: 11 ),),
            ]
          ),
        ],
      ),
    );
  }



  pw.Widget _buildSignatureSection() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 28),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end, // Aligns text to the right
          children: [
            pw.Text(
              'Student Signature with Date',
              style: pw.TextStyle(font: ttfBold, fontSize: 12),
            ),
            pw.SizedBox(width: 20), // Leaves some space from the right
          ],
        ),
        // pw.SizedBox(height: 5),
      ],
    );
  }

  pw.Widget _buildSignatureSupervisor_and_Assistant() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, // Distributes elements to left and right
      children: [
        // Thesis Supervisor on the left
        pw.Text(
          'Thesis Supervisor',
          style: pw.TextStyle(font: ttfBold, fontSize: 12),
        ),

        // Dealing Department Assistant on the right
        pw.Text(
          'Dealing Department Assistant',
          style: pw.TextStyle(font: ttfBold, fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _buildOfficeUseSection(double pageWidth) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [

        pw.Center(
          child: pw.Text('For Department Office Use',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttfBold, fontSize: 15)),
        ),
        pw.Divider(height: 8, thickness: 1),
        pw.SizedBox(height: 12),
        pw.Row(
            children: [
              pw.Expanded(child: _buildUnderlineField('1. Class will be missed (Yes/No):', pageWidth / 2 - 10)),
              pw.Expanded(child: _buildUnderlineField('No. of days classes missed:', pageWidth / 2 - 10)),
            ]
        ),
        _buildUnderlineField('2. Leave taken earlier during the session (mention period): ', pageWidth),
        pw.SizedBox(height: -8), // Reduce the gap between point 2 and point 3

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start, // Ensures all text starts at the same height
              children: [
                pw.Text('3. Balance after taking this leave', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(width: 5),
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start, // Aligns CL and Medical properly
                    children: [
                      pw.Expanded(
                        child: _buildUnderlineField('1) CL', (pageWidth - 30) / 2), // Adjusted width
                      ),
                      pw.SizedBox(width: 10), // Spacing between CL and Medical
                      pw.Expanded(
                        child: _buildUnderlineField('2) Medical', (pageWidth - 30) / 2), // Adjusted width
                      ),
                    ],
                  ),
                ),
              ],
            ),
    pw.Padding(
    padding: const pw.EdgeInsets.only(left: 15), // Matches indentation of previous row
    child: _buildUnderlineField('3) Other (Specify)', pageWidth - 20),
    ),],
        ),

        pw.SizedBox(height: 28),
        _buildSignatureSupervisor_and_Assistant(),
        pw.Divider(height: 8, thickness: 1),
        _buildSignatureLine('Recommended/Not Recommended', 220),
        pw.SizedBox(height: 28),
        pw.Center(
          child: pw.Text('Head of Department',
              style: pw.TextStyle(fontSize: 12, font: ttfBold)),
        ),
        pw.Divider(height: 8, thickness: 1),
        _buildSignatureLine('Approved/Not Approved', 220),
        pw.SizedBox(height: 28),
        pw.Center(
          child: pw.Text('Dean (Academic Affairs)',
              style: pw.TextStyle(fontSize: 12, font: ttfBold)),
        ),
        pw.Divider(height: 8, thickness: 1),
        pw.Center(
          child: pw.Text('Approved leave forwarded to Chairman of Council Wardens for issuance of Gate Pass.',
              style: pw.TextStyle(fontSize: 10, font: ttfRegular)),
        ),
        pw.SizedBox(height: 28),
        pw.Center(
          child: pw.Text('Chairman of Council Wardens',
              style: pw.TextStyle(fontSize: 12, font: ttfBold)),
        ),
      ],
    );
  }

  pw.Widget _buildField(String label, String value, double maxWidth , {double fontsize = 14}) {
    return pw.Container(
      width: maxWidth,
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(font: ttfRegular, fontSize: 12)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Stack(
              alignment: pw.Alignment.center, // Center aligns the text & dotted line
              children: [
                // Dotted line
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: pw.Text(
                    '....................................................................................................',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 18, color: PdfColors.grey),
                    maxLines: 1,
                    textAlign: pw.TextAlign.center, // Ensures proper centering
                  ),
                ),
                // Actual text (now centered)
                pw.Align(
                  alignment: pw.Alignment.center, // Ensures text is centered
                  child: pw.Text(value, style: pw.TextStyle(font: ttfRegular, fontSize: fontsize)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  pw.Widget _buildUnderlineField(String text, double maxWidth) {
    return pw.Container(
      width: maxWidth,
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(text, style: pw.TextStyle(font: ttfRegular, fontSize: 12)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              '....................................................................................................',
              style: pw.TextStyle(font: ttfRegular, fontSize: 18, color: PdfColors.grey),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }


  pw.Widget _buildSignatureLine(String label, double width) {
    return pw.Center(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(label, style: pw.TextStyle(font: ttfRegular, fontSize: 12)),
          pw.SizedBox(height: 8),
        ],
      ),
    );
  }


  Future<void> _submitAndDownload() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _loadFonts();

      final response = await http.post(
        Uri.parse('http://192.168.25.109:5000/submit-application'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': widget.name,
          'roll_no': widget.rollNo,
          'department': widget.department,
          'hostel_block': widget.hostelBlock,
          'days': widget.days,
          'leave_start_date': widget.leaveStartDate,
          'leave_end_date': widget.leaveEndDate,
          'nature_of_leave': widget.natureOfLeave,
          'reason': widget.reason,
          'address': widget.address,
          'mobile': widget.mobile,
          'institute_email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['application_id'] == null) {
          throw Exception('Server did not return application ID');
        }
        _applicationId = jsonResponse['application_id'];

        final pdfBytes = await _generatePdf(_applicationId!);

        final directory = Directory('/storage/emulated/0/Download');
        final file = File('${directory.path}/Leave_Application_$_applicationId.pdf');
        await file.writeAsBytes(pdfBytes);

        if (mounted) {
          setState(() => pdfData = pdfBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF downloaded successfully!')),
          );

          // Wait for the SnackBar to be visible for a short time before navigating
          await Future.delayed(const Duration(seconds: 1));

          // Navigate to HomePage and clear the back stack
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false, // This removes all previous routes from the stack
            );
          }
        }
      } else {
        throw Exception('Server error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(title: const Text('PDF Preview')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PdfPreview(
              build: (format) => _generatePdf(_applicationId ?? 'TEMP_ID'),
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: _submitAndDownload,
                  child: const Text('Download PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}