import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/safe_cache_manager.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../providers/app_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  bool _isSubmitting = false;

  // Either a real file path (local storage) OR in-memory bytes (cloud/Google Photos).
  // Only one will be non-null at a time.
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController    = TextEditingController(text: p['name'] ?? '');
    _emailController   = TextEditingController(text: p['email'] ?? '');
    _addressController = TextEditingController(text: p['address'] ?? '');
    _cityController    = TextEditingController(text: p['city'] ?? '');
    _stateController   = TextEditingController(text: p['state'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      if (!mounted) return;
      if (_isSubmitting) return;
      if (_formKey.currentState?.validate() != true) return;
      setState(() => _isSubmitting = true);

      final success = await ref.read(profileProvider.notifier).updateProfile(
        {
          'name':    _nameController.text.trim(),
          'email':   _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'city':    _cityController.text.trim(),
          'state':   _stateController.text.trim(),
        },
        imagePath: _selectedImagePath,
        imageBytes: _selectedImageBytes,
        imageName: _selectedImageName,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        AppSnackBar.success(context, 'Profile updated successfully');
        Navigator.pop(context);
      } else {
        AppSnackBar.error(context, 'Failed to update profile. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackBar.error(context, 'An unexpected error occurred');
      }
    }
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: enabled ? AppColors.primary : AppColors.textSecondary(context)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(16),
          filled: !enabled,
          fillColor: AppColors.textSecondary(context).withValues(alpha: 0.1),
          suffixIcon: !enabled
              ? Icon(Icons.lock_outline, color: AppColors.textSecondary(context), size: 18)
              : null,
        ),
        validator: enabled
            ? (validator ?? (v) => (v == null || v.isEmpty) ? AppStrings.required : null)
            : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      // withData: false — never load file bytes into memory on the platform thread.
      // withData: true caused ANR (SIGQUIT/signal 3) because file_picker read
      // the entire image synchronously on the Android main thread before returning.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final path = file.path;
      final name = file.name;

      if (path != null && path.isNotEmpty) {
        // Verify the file exists on disk before accepting it.
        final localFile = File(path);
        if (localFile.existsSync()) {
          setState(() {
            _selectedImagePath = path;
            _selectedImageBytes = null;
            _selectedImageName = name;
          });
          return;
        }
      }

      // Path is null or file doesn't exist — read bytes async on Dart isolate.
      // This is safe because it runs on the Dart thread, not the Android main thread.
      if (path != null && path.isNotEmpty) {
        try {
          final bytes = await File(path).readAsBytes();
          if (!mounted) return;
          setState(() {
            _selectedImagePath = null;
            _selectedImageBytes = bytes;
            _selectedImageName = name.isNotEmpty ? name : 'profile_image.jpg';
          });
          return;
        } catch (_) {
          // Fall through to error
        }
      }

      if (mounted) AppSnackBar.error(context, 'Could not load the selected image. Please try another.');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed to pick image');
    }
  }

  /// Returns the widget to show inside the avatar circle.
  Widget _avatarChild() {
    // 1. Newly picked image — bytes (cloud/content URI fallback)
    if (_selectedImageBytes != null) {
      return Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    }
    // 2. Newly picked image — local file path
    if (_selectedImagePath != null) {
      return Image.file(File(_selectedImagePath!), fit: BoxFit.cover);
    }
    // 3. Existing network image from profile
    final imageUrl = widget.profile['image_url']?.toString().isNotEmpty == true
        ? widget.profile['image_url'].toString()
        : widget.profile['image']?.toString() ?? '';
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        cacheManager: SafeCacheManager(),
        fit: BoxFit.cover,
        memCacheWidth: 200,
        memCacheHeight: 200,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => Icon(Icons.person, size: 50, color: AppColors.textSecondary(context)),
      );
    }
    // 4. No image at all
    return Icon(Icons.person, size: 50, color: AppColors.textSecondary(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textSecondary(context).withValues(alpha: 0.2),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: ClipOval(child: _avatarChild()),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isSubmitting ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Icon(Icons.camera_alt, color: AppColors.surfaceLight, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _field('Full Name', _nameController, Icons.person_outline),
              _field(
                'Email',
                _emailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
                validator: null,
              ),
              _field('Address', _addressController, Icons.location_on_outlined),
              _field('City', _cityController, Icons.location_city_outlined),
              _field('State', _stateController, Icons.map_outlined),
              const SizedBox(height: 32),
              PremiumButton(
                text: 'SAVE CHANGES',
                isLoading: _isSubmitting,
                onPressed: _save,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
