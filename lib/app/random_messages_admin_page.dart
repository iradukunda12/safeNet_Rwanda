import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RandomMessagesAdminPage extends StatefulWidget {
  const RandomMessagesAdminPage({super.key});

  @override
  State<RandomMessagesAdminPage> createState() => _RandomMessagesAdminPageState();
}

class _RandomMessagesAdminPageState extends State<RandomMessagesAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedType = 'motivation';
  
  final List<String> _messageTypes = [
    'motivation',
    'mindfulness',
    'encouragement',
    'self_care',
    'progress',
    'rest',
    'strength',
    'gratitude',
    'growth',
    'worth',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _addRandomMessage() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.red);
      return;
    }

    try {
      await _firestore.collection('random_messages').add({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'type': _selectedType,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _bodyController.clear();
      _selectedType = 'motivation';
      
      _showSnackBar('Message added successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error adding message: $e', Colors.red);
    }
  }

  Future<void> _triggerRandomMessage() async {
    try {
      _showSnackBar('Sending random message...', Colors.blue);
      
      final callable = _functions.httpsCallable('triggerRandomMessage');
      final result = await callable.call();
      
      if (result.data['success'] == true) {
        final sentMessage = result.data['sentMessage'];
        _showSnackBar(
          'Message sent: ${sentMessage['title']}', 
          Colors.green,
        );
      } else {
        _showSnackBar('Failed to send message', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error triggering message: $e', Colors.red);
    }
  }

  Future<void> _getMessageStats() async {
    try {
      final callable = _functions.httpsCallable('getMessageStats');
      final result = await callable.call();
      
      final stats = result.data;
      _showStatsDialog(stats);
    } catch (e) {
      _showSnackBar('Error getting stats: $e', Colors.red);
    }
  }

  void _showStatsDialog(Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Message Statistics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Total Active Messages', stats['totalActiveMessages'].toString()),
              _buildStatRow('Total Sent Messages', stats['totalSentMessages'].toString()),
              _buildStatRow('Sent Last 30 Days', stats['sentLast30Days'].toString()),
              const SizedBox(height: 16),
              const Text('Messages by Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(stats['messagesByType'] as Map<String, dynamic>).entries.map(
                (entry) => _buildStatRow(entry.key, entry.value.toString()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Messages Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _getMessageStats,
            tooltip: 'View Stats',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Create New Random Message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Message Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _messageTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Message Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addRandomMessage,
              icon: const Icon(Icons.add),
              label: const Text('Add Message'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Trigger a Random Message Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _triggerRandomMessage,
              icon: const Icon(Icons.send),
              label: const Text('Send Random Message'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
