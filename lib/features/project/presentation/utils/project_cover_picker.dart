import 'package:image_picker/image_picker.dart';

typedef PickProjectCoverImage = Future<String?> Function();
typedef PickGalleryImages = Future<List<String>> Function();

Future<String?> pickProjectCoverImageFromGallery() async {
  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  return image?.path;
}

Future<List<String>> pickGalleryImagesFromGallery() async {
  final images = await ImagePicker().pickMultiImage();
  return images.map((image) => image.path).toList();
}
