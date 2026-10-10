
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../repositories/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _teal = Color(0xFF2F817C);
  static const Color _textColor = Color(0xFF292929);
  static const Color _mutedColor = Color(0xFF9B9B9B);

  final ProfileRepository _repository = ProfileRepository();
  final ImagePicker _imagePicker = ImagePicker();

  String _userName = 'Sahal Muhammed';
  Uint8List? _photoBytes;

  bool _isLoading = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.getProfile();

      if (!mounted) return;

      final photo = profile['photo_blob'];

      setState(() {
        _userName = profile['name'] as String? ?? 'Sahal Muhammed';
        _photoBytes = photo == null
            ? null
            : Uint8List.fromList(List<int>.from(photo as List));
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load profile: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to load profile.');
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);

    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _teal),
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (updatedName == null || !mounted) return;

    if (updatedName.isEmpty) {
      _showMessage('Name cannot be empty.');
      return;
    }

    setState(() => _isBusy = true);

    try {
      await _repository.updateName(updatedName);

      if (!mounted) return;

      setState(() {
        _userName = updatedName;
        _isBusy = false;
      });

      _showMessage('Profile name saved.');
    } catch (error) {
      debugPrint('Could not update profile name: $error');

      if (!mounted) return;

      setState(() => _isBusy = false);
      _showMessage('Unable to save your name.');
    }
  }

  Future<void> _changePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image == null || !mounted) return;

      setState(() => _isBusy = true);

      final bytes = await image.readAsBytes();

      await _repository.updatePhoto(bytes);

      if (!mounted) return;

      setState(() {
        _photoBytes = bytes;
        _isBusy = false;
      });

      _showMessage('Profile photo saved.');
    } catch (error, stackTrace) {
      debugPrint('Could not update profile photo: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() => _isBusy = false);
      _showMessage('Unable to save the selected photo.');
    }
  }

  Future<void> _clearStorage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear storage?'),
        content: const Text(
          'This permanently deletes all saved transactions and credit '
          'entries, and resets your profile name and photo. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);

    try {
      await _repository.clearAllUserData();

      // Refresh the UI that reads transactions from the database.
      await context.read<TransactionProvider>().loadTransactions();

      if (!mounted) return;

      setState(() {
        _userName = 'Sahal Muhammed';
        _photoBytes = null;
        _isBusy = false;
      });

      _showMessage('Saved data cleared successfully.');
    } catch (error, stackTrace) {
      debugPrint('Could not clear storage: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() => _isBusy = false);
      _showMessage('Unable to clear saved data.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: const Color(0xFFB5B5B5),
      backgroundImage:
          _photoBytes == null ? null : MemoryImage(_photoBytes!),
      child: _photoBytes == null
          ? const Icon(
              Icons.person,
              size: 104,
              color: Color(0xFFEAEAEA),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        surfaceTintColor: _teal,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back to Dashboard',
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SizedBox.expand(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: _teal),
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        const Spacer(flex: 5),
                        SizedBox(
                          width: 132,
                          height: 132,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(child: _buildAvatar()),
                              Positioned(
                                right: 0,
                                bottom: 8,
                                child: Container(
                                  width: 43,
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: _teal,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Change profile photo',
                                    onPressed:
                                        _isBusy ? null : _changePhoto,
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 17),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: _textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _isBusy ? null : _editName,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: _mutedColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 19),
                        OutlinedButton(
                          onPressed: _isBusy ? null : _clearStorage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF777777),
                            side: const BorderSide(
                              color: Color(0xFFDADADA),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 10,
                            ),
                            minimumSize: const Size(134, 39),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Clear Storage',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Spacer(flex: 12),
                      ],
                    ),
                    if (_isBusy)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.white54,
                          child: const Center(
                            child: CircularProgressIndicator(color: _teal),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
