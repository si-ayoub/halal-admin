import 'dart:io';

class StorageService {
  Future<String?> uploadImage({
    required File file,
    required String restaurantId,
    required String folder,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    print('Mode démo: Image uploadée');
    return 'https://via.placeholder.com/300';
  }

  Future<void> deleteImage(String imageUrl) async {
    print('Mode démo: Image supprimée');
  }

  Future<List<String>> uploadMultipleImages({
    required List<File> files,
    required String restaurantId,
    required String folder,
  }) async {
    await Future.delayed(Duration(seconds: 2));
    return files.map((f) => 'https://via.placeholder.com/300').toList();
  }
}
