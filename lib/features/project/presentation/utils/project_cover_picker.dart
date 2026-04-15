import 'package:image_picker/image_picker.dart';

typedef PickProjectCoverImage = Future<String?> Function();

Future<String?> pickProjectCoverImageFromGallery() async {
  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  return image?.path;
}
