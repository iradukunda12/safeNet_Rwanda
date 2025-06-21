import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:school_project/features/auth/controllers/auth_controller.dart';
import '../../features/auth/repositories/auth_repository.dart';

// Fetch user profile from Firestore
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  final user = authRepo.getCurrentUser();
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return doc.data();
});

class TopSection extends ConsumerWidget implements PreferredSizeWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(authStateProvider).value;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: userProfileAsync.when(
        loading: () => const Text(
          'Loading...',
          style: TextStyle(color: Colors.black54),
        ),
        error: (error, stack) {
          debugPrint('Error loading user profile: $error');
          return const Text(
            'Error loading user',
            style: TextStyle(color: Colors.red),
          );
        },
        data: (data) {
          final firstName = data?['firstName'] ?? 'User';
          final lastName = data?['lastName'] ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello,',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '$firstName $lastName',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout, color: Colors.black54),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/sign-in');
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 20,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null ? const Icon(Icons.person) : null,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
