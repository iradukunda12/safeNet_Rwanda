import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HealthBlogPage extends StatefulWidget {
  const HealthBlogPage({super.key});

  @override
  State<HealthBlogPage> createState() => _HealthBlogPageState();
}

class _HealthBlogPageState extends State<HealthBlogPage> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  List<DocumentSnapshot> _blogs = [];
  List<DocumentSnapshot> _filteredBlogs = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadBlogsFromFirebase();
  }

  Future<void> _loadBlogsFromFirebase() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('blogs')
          .limit(20)
          .get();

      setState(() {
        _blogs = snapshot.docs;
        _filteredBlogs = _blogs;
      });
    } catch (e) {
      print("Error loading blogs: $e");
    }
  }

  void _filterBlogs(String query) {
    final filtered = _blogs.where((doc) {
      final title = doc['title'].toString().toLowerCase();
      final content = doc['content'].toString().toLowerCase();
      return title.contains(query.toLowerCase()) || content.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredBlogs = filtered;
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') setState(() => _isListening = false);
        },
        onError: (val) => print('Speech error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            _searchController.text = val.recognizedWords;
            _filterBlogs(val.recognizedWords);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Voice Blog'),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _listen,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterBlogs,
              decoration: const InputDecoration(
                hintText: 'Search blogs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredBlogs.isEmpty
                ? const Center(child: Text('No blogs found'))
                : ListView.builder(
                    itemCount: _filteredBlogs.length,
                    itemBuilder: (context, index) {
                      final blog = _filteredBlogs[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(blog['title']),
                          subtitle: Text(
                            '${blog['content'].toString().substring(0, 60)}...',
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'read', child: Text('Read')),
                              const PopupMenuItem(value: 'listen', child: Text('Listen')),
                            ],
                            onSelected: (value) {
                              if (value == 'read') {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(blog['title']),
                                    content: SingleChildScrollView(child: Text(blog['content'])),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      )
                                    ],
                                  ),
                                );
                              } else if (value == 'listen') {
                                _speak(blog['content']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
