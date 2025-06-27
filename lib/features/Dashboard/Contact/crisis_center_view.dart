import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);
  static const white = Colors.white;
  static const whiteOpacity = Color(0xFFE8E8E8);
}

class CrisisCenterView extends StatefulWidget {
  const CrisisCenterView({super.key});

  @override
  State<CrisisCenterView> createState() => _CrisisCenterViewState();
}

class _CrisisCenterViewState extends State<CrisisCenterView> {
  String? userId; // will hold persistent user id
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (savedUserId != null) {
      setState(() {
        userId = savedUserId;
      });
    } else {
      final newUserId = const Uuid().v4();
      await prefs.setString('userId', newUserId);
      setState(() {
        userId = newUserId;
      });
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _addPost() async {
    final message = _postController.text.trim();
    if (message.isEmpty || userId == null) return;

    try {
      await _firestore.collection('support_posts').add({
        'userId': userId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _postController.clear();
      Navigator.of(context, rootNavigator: true).pop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your post has been shared successfully!'),
              backgroundColor: AppColors.containerD,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting message: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.containerD,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.forum_outlined, color: AppColors.white),
            SizedBox(width: 8),
            Text(
              'Share Your Experience',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: _postController,
            maxLines: 5,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Share your thoughts, feelings, or experiences...',
              hintStyle: const TextStyle(color: AppColors.whiteOpacity),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dropdownMenuD),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dropdownMenuD),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.white, width: 2),
              ),
              filled: true,
              fillColor: AppColors.primaryD.withOpacity(0.3),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _postController.clear();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.whiteOpacity),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dropdownMenuD,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Share Post'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      // Still loading userId from storage
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: AppColors.headerD,
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.support_agent, color: AppColors.white),
              SizedBox(width: 8),
              Text(
                'Anonymous Support',
                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.whiteOpacity,
            indicatorColor: AppColors.dropdownMenuD,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Your Posts'),
              Tab(icon: Icon(Icons.group), text: 'Community'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.headerD, AppColors.primaryD, AppColors.containerD],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.containerD.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dropdownMenuD.withOpacity(0.3), width: 1),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: AppColors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Safe Space for Support',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Share your experiences and connect with others anonymously. You\'re not alone in this journey.',
                          style: TextStyle(fontSize: 15, color: AppColors.whiteOpacity, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _showPostDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dropdownMenuD,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.add_comment, size: 20),
                      label: const Text('Share Your Story', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      children: [
                        PostListTab(isOwnPosts: true, userId: userId!, firestore: _firestore),
                        PostListTab(isOwnPosts: false, userId: userId!, firestore: _firestore),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostListTab extends StatelessWidget {
  final bool isOwnPosts;
  final String userId;
  final FirebaseFirestore firestore;

  const PostListTab({
    super.key,
    required this.isOwnPosts,
    required this.userId,
    required this.firestore,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('support_posts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.whiteOpacity),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong\n${snapshot.error}',
                  style: const TextStyle(color: AppColors.whiteOpacity),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.dropdownMenuD),
            ),
          );
        }

        final allPosts = snapshot.data!.docs;
        final filteredPosts = allPosts.where((doc) {
          final data = doc.data()! as Map<String, dynamic>;
          final postUserId = data['userId'] as String?;
          if (isOwnPosts) {
            return postUserId == userId;
          } else {
            return postUserId != null && postUserId != userId;
          }
        }).toList();

        if (filteredPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isOwnPosts ? Icons.post_add : Icons.forum, size: 64, color: AppColors.whiteOpacity),
                const SizedBox(height: 16),
                Text(
                  isOwnPosts
                      ? 'You haven\'t shared any posts yet.\nTap the button above to share your first post!'
                      : 'No posts from the community yet.\nBe the first to share something!',
                  style: const TextStyle(color: AppColors.whiteOpacity, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            final data = filteredPosts[index].data()! as Map<String, dynamic>;
            final message = data['message'] ?? '';
            final Timestamp? timestamp = data['timestamp'] as Timestamp?;
            final time = timestamp != null ? timestamp.toDate() : DateTime.now();

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.containerD.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dropdownMenuD.withOpacity(0.3), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isOwnPosts ? AppColors.dropdownMenuD : AppColors.primaryD,
                          radius: 20,
                          child: Icon(isOwnPosts ? Icons.person : Icons.person_outline, color: AppColors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isOwnPosts ? 'You' : 'Anonymous',
                                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(_formatTime(time),
                                  style: const TextStyle(color: AppColors.whiteOpacity, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(message, style: const TextStyle(color: AppColors.white, fontSize: 15, height: 1.4)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
