import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImportExportPage extends StatelessWidget {
  const ImportExportPage({Key? key}) : super(key: key);

  /// 📥 Import JSON file and store data into Firestore
  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final data = json.decode(content);

        if (data is List) {
          for (var item in data) {
            await FirebaseFirestore.instance.collection('settings').add(item);
          }
        } else if (data is Map) {
          await FirebaseFirestore.instance
              .collection('settings')
              .add(data.cast<String, dynamic>());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Data imported successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Import failed: $e')),
      );
    }
  }

  /// 📤 Export Firestore data into a local JSON file
  Future<void> _exportData(BuildContext context) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('settings').get();
      final List<Map<String, dynamic>> dataList =
          snapshot.docs.map((doc) => doc.data()).toList();

      final jsonString = json.encode(dataList);

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/exported_data.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Exported to: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        title: const Text('Import / Export',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 24), // top padding from app bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // horizontal center
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 450),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28), // left margin
                    child: Container(
                      width: pageWidth * 0.85,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xff8654B0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Import / Export',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Use this page to import settings from your computer or export data from Firebase.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          _buildActionButton(
                            context,
                            icon: Icons.upload_file_outlined,
                            title: 'Import',
                            onTap: () => _importData(context),
                          ),
                          const SizedBox(height: 24),
                          _buildActionButton(
                            context,
                            icon: Icons.download_outlined,
                            title: 'Export',
                            onTap: () => _exportData(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff280446),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
