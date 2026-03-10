
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageProcessingService {
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  /// Picks an image and opens a professional cropper UI with fixed compatibility errors
  Future<String?> pickAndCropImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100, 
      );
      
      if (pickedFile == null) return null;

      final Color primaryColor = const Color(0xFF00796B);
      final Color accentColor = const Color(0xFF00BFA5);

      // Professional Cropping without compatibility errors
      final croppedFile = await _cropper.cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop & Rotate',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: accentColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            backgroundColor: Colors.black,
            statusBarColor: primaryColor,
          ),
          IOSUiSettings(
            title: 'Crop & Rotate',
            aspectRatioLockEnabled: false,
            resetButtonHidden: false,
          ),
        ],
      );

      return croppedFile?.path;
    } catch (e) {
      debugPrint("IMAGE_PROCESS_ERROR: $e");
      return null;
    }
  }
}
