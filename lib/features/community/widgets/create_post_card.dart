import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../providers/community_provider.dart';

class CreatePostCard extends StatefulWidget {
  const CreatePostCard({super.key});

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  final TextEditingController _textController = TextEditingController();
  PlatformFile? _selectedImage;
  final picker.ImagePicker _picker = picker.ImagePicker();

  void _showMediaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.petalCream,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ajouter une photo',
              style: AppTextStyles.title(18, AppColors.textPrimary),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Appareil photo',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galerie',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.body(14, AppColors.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedImage = result.files.first;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker.XFile? photo = await _picker.pickImage(source: picker.ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = PlatformFile(
          name: photo.name,
          path: photo.path,
          size: 0, // Not needed for our implementation
        );
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _publishPost() {
    if (_textController.text.trim().isNotEmpty || _selectedImage != null) {
      context.read<CommunityProvider>().addPost(
        _textController.text.trim(),
        imageFile: _selectedImage,
      );
      
      _textController.clear();
      _removeImage();
      FocusScope.of(context).unfocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Publication ajoutée avec succès !', style: AppTextStyles.body(14, Colors.white)),
          backgroundColor: AppColors.roseDeep,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.roseDeep.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.petalCream.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Quoi de neuf dans votre jardin ? 🌸',
                      hintStyle: AppTextStyles.body(14, AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.body(14, AppColors.textPrimary),
                    maxLines: null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildAction(Icons.image_outlined, 'Photo', color: Colors.blue, onTap: () => _showMediaPicker(context)),
                      const SizedBox(width: 12),
                      _buildAction(Icons.videocam_outlined, 'Vidéo', color: Colors.orange),
                      const SizedBox(width: 12),
                      _buildAction(Icons.star_outline, 'Expérience', color: Colors.amber),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D1D2D), // Dark red as in image
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Publier', style: AppTextStyles.body(14, Colors.white, weight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.body(13, AppColors.textPrimary, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
