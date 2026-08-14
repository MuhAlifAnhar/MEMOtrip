import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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
        .snapshots()
        .listen(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => TravelMemory.fromFirestore(doc))
            .toList();
        // Sort in memory to avoid requiring a composite index (userId + date) in Firestore
        list.sort((a, b) => b.date.compareTo(a.date));
        state = MemoryState(memories: list, isLoading: false);
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
  /// the photo to ImgBB first, then store the display URL.
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

      // 2. Upload image to ImgBB
      final imageUrl = await _uploadImageToImgBB(
        bytes: imageBytes,
        filename: '$docId.$imageExtension',
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal menambah memori: $e',
      );
    }
  }

  // ── UPDATE ──────────────────────────────────────────────

  /// Updates an existing memory. If new [imageBytes] are provided, the image
  /// is uploaded to ImgBB.
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
        imageUrl = await _uploadImageToImgBB(
          bytes: newImageBytes,
          filename: '$memoryId.$newImageExtension',
        );
      }

      await _col.doc(memoryId).update({
        'destinationName': destinationName,
        'category': category,
        'date': Timestamp.fromDate(date),
        'caption': caption,
        'imageUrl': imageUrl,
      });
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
      // Delete Firestore document (ImgBB uploaded files are kept as they are hosted externally)
      await _col.doc(memoryId).delete();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal menghapus memori: $e',
      );
    }
  }

  // ── Storage/API helpers ─────────────────────────────────

  Future<String> _uploadImageToImgBB({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=ef1364bc9c4093041fae1d09148cad68');
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final displayUrl = jsonResponse['data']?['display_url'];
      if (displayUrl != null) {
        return displayUrl as String;
      }
      throw Exception('Tautan gambar (display_url) tidak ditemukan dalam respon.');
    } else {
      throw Exception('Pengunggahan gambar ke ImgBB gagal dengan status: ${response.statusCode}');
    }
  }
}

// ─────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────

final memoryProvider =
    StateNotifierProvider<MemoryNotifier, MemoryState>((ref) {
  return MemoryNotifier();
});
