import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

class InterviewPdfsScreen extends StatelessWidget {
  const InterviewPdfsScreen({super.key});

  // Add your PDF files here
  List<String> get pdfAssets => const [
        'assets/interview_pdfs/sample.pdf',
        // Add more here
      ];

  Future<bool> assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview PDFs')),
      body: FutureBuilder(
        future: Future.wait(pdfAssets.map(assetExists)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter out missing assets
          final validAssets = <String>[];
          for (int i = 0; i < pdfAssets.length; i++) {
            if (snapshot.data![i] == true) {
              validAssets.add(pdfAssets[i]);
            }
          }

          if (validAssets.isEmpty) {
            return const Center(
              child: Text(
                'No PDFs found.\nPlease add files to assets/interview_pdfs/',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: validAssets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final path = validAssets[index];
              final name = path.split('/').last;

              return ListTile(
                title: Text(name),
                trailing: const Icon(Icons.picture_as_pdf),
                onTap: () async {
                  if (kIsWeb) {
                    final uri = Uri.parse(path);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _PdfViewerPage(assetPath: path),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PdfViewerPage extends StatelessWidget {
  final String assetPath;
  const _PdfViewerPage({required this.assetPath});
  @override
  Widget build(BuildContext context) {
    return _PdfViewerStateful(assetPath: assetPath);
  }
}

class _PdfViewerStateful extends StatefulWidget {
  final String assetPath;
  const _PdfViewerStateful({required this.assetPath});
  @override
  State<_PdfViewerStateful> createState() => _PdfViewerStatefulState();
}

class _PdfViewerStatefulState extends State<_PdfViewerStateful> {
  late PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(document: PdfDocument.openAsset(widget.assetPath));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.assetPath.split('/').last)),
      body: PdfViewPinch(controller: _controller),
    );
  }
}
