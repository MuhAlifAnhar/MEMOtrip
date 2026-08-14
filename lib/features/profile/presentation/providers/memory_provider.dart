import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/travel_memory.dart';

// Re-export entity so consumers only import the provider file
export '../../domain/entities/travel_memory.dart';

// ─────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────

class MemoryState {
  final List<TravelMemory> memories;
  final bool isLoading;
  final String? error;

  const MemoryState({
    this.memories = const [],
    this.isLoading = false,
    this.error,
  });

  MemoryState copyWith({
    List<TravelMemory>? memories,
    bool? isLoading,
    String? error,
  }) {
    return MemoryState(
      memories: memories ?? this.memories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─────────────────────────────────────────────────────────
// Notifier (CRUD + real-time sync)
// ─────────────────────────────────────────────────────────

class MemoryNotifier extends StateNotifier<MemoryState> {
  MemoryNotifier() : super(const MemoryState(isLoading: true)) {
    _listenToMemories();
  }

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Collection reference for the current user's memories.
  CollectionReference get _col => _db.collection('memories');

  // ── Real-time listener ──────────────────────────────────

  void _listenToMemories() {
    final uid = _uid;
    if (uid == null) {
      state = const MemoryState();
      return;
    }

    _col
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => TravelMemory.fromFirestore(doc))
            .toList();
        state = MemoryState(memories: list);
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          error: 'Gagal memuat memori: $e',
        );
      },
    );
  }

  // ── CREATE ──────────────────────────────────────────────

  /// Adds a new memory. [imageBytes] and [imageExtension] are used to upload
  /// the photo to Firebase Storage first, then store the download URL.
  Future<void> addMemory({
    required String destinationName,
    required String category,
    required DateTime date,
    required String caption,
    required Uint8List imageBytes,
    required String imageExtension,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true);

    try {
      // 1. Generate a new Firestore doc ID for consistent naming
      final docRef = _col.doc();
      final docId = docRef.id;

      // 2. Upload image to Firebase Storage
      final imageUrl = await _uploadImage(
        userId: uid,
        memoryId: docId,
        bytes: imageBytes,
        extension: imageExtension,
      );

      // 3. Create Firestore document
      final memory = TravelMemory(
        id: docId,
        userId: uid,
        destinationName: destinationName,
        category: category,
        date: date,
        caption: caption,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await docRef.set(memory.toFirestore());
      // State will update automatically via the snapshot listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal menambah memori: $e',
      );
    }
  }

  // ── UPDATE ──────────────────────────────────────────────

  /// Updates an existing memory. If new [imageBytes] are provided, the old
  /// image is replaced in Storage.
  Future<void> updateMemory({
    required String memoryId,
    required String destinationName,
    required String category,
    required DateTime date,
    required String caption,
    String? existingImageUrl,
    Uint8List? newImageBytes,
    String? newImageExtension,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true);

    try {
      String imageUrl = existingImageUrl ?? '';

      // Upload new image if provided
      if (newImageBytes != null && newImageExtension != null) {
        imageUrl = await _uploadImage(
          userId: uid,
          memoryId: memoryId,
          bytes: newImageBytes,
          extension: newImageExtension,
        );
      }

      await _col.doc(memoryId).update({
        'destinationName': destinationName,
        'category': category,
        'date': Timestamp.fromDate(date),
        'caption': caption,
        'imageUrl': imageUrl,
      });
      // State will update automatically via the snapshot listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memperbarui memori: $e',
      );
    }
  }

  // ── DELETE ──────────────────────────────────────────────

  Future<void> deleteMemory(String memoryId) async {
    state = state.copyWith(isLoading: true);

    try {
      // Delete from Storage (best-effort, ignore if file missing)
      try {
        final uid = _uid ?? '';
        final ref = _storage.ref().child('memories/$uid/$memoryId');
        final result = await ref.listAll();
        for (final item in result.items) {
          await item.delete();
        }
      } catch (_) {
        // Image may not exist — that's fine
      }

      // Delete Firestore document
      await _col.doc(memoryId).delete();
      // State will update automatically via the snapshot listener
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal menghapus memori: $e',
      );
    }
  }

  // ── Storage helpers ─────────────────────────────────────

  Future<String> _uploadImage({
    required String userId,
    required String memoryId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final ref = _storage
        .ref()
        .child('memories')
        .child(userId)
        .child('$memoryId.$extension');

    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/$extension'),
    );
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

// ─────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────

final memoryProvider =
    StateNotifierProvider<MemoryNotifier, MemoryState>((ref) {
  return MemoryNotifier();
});
