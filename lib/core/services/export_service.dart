import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  ExportService._();
  static final instance = ExportService._();

  /// Share the note as plain text
  Future<void> shareAsText({required String title, required String content}) async {
    final String shareText = "$title\n\n$content";
    await Share.share(shareText, subject: title);
  }

  /// Generate a PDF from the note and share it
  Future<void> shareAsPdf({required String title, required String content}) async {
    final pdf = pw.Document();

    // Load fonts that support unicode (including Tamil and Emojis)
    final font = await PdfGoogleFonts.notoSansRegular();
    final tamilFont = await PdfGoogleFonts.notoSansTamilRegular();
    final fallback = await PdfGoogleFonts.notoColorEmoji();

    // Split content by lines to avoid large widget spanning issues
    final lines = content.split('\n');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(
              title.isEmpty ? 'Untitled Note' : title,
              style: pw.TextStyle(
                font: font,
                fontFallback: [tamilFont, fallback],
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            ...lines.map((line) => pw.Paragraph(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  text: line,
                  style: pw.TextStyle(
                    font: font,
                    fontFallback: [tamilFont, fallback],
                    fontSize: 14,
                    lineSpacing: 1.5,
                  ),
                )),
          ];
        },
      ),
    );

    // Save the PDF to a temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/note_export.pdf');
    await file.writeAsBytes(await pdf.save());

    // Share the file
    final xFile = XFile(file.path, mimeType: 'application/pdf');
    await Share.shareXFiles([xFile]);
  }

  /// Share a captured screenshot image of the note
  Future<void> shareAsImage({required Uint8List imageBytes, required String title}) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/note_export.png');
    await file.writeAsBytes(imageBytes);

    // Share the file
    final xFile = XFile(file.path, mimeType: 'image/png');
    await Share.shareXFiles([xFile]);
  }
}
