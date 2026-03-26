import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/center.dart';
import '../widgets/center_image.dart';
import '../widgets/language_toggle_button.dart';

class OwnerCenterEditorScreen extends StatefulWidget {
  const OwnerCenterEditorScreen({
    super.key,
    this.center,
    required this.ownerEmail,
  });

  final EsportCenter? center;
  final String ownerEmail;

  @override
  State<OwnerCenterEditorScreen> createState() => _OwnerCenterEditorScreenState();
}

class _OwnerCenterEditorScreenState extends State<OwnerCenterEditorScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _pcCountController;
  late final TextEditingController _pcSpecController;
  late final TextEditingController _priceController;
  late final TextEditingController _phoneController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  String? _profileImageBase64;
  List<String> _imagesBase64 = <String>[];
  final Set<int> _selectedImageIndexes = <int>{};

  bool get _selectionMode => _selectedImageIndexes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final center = widget.center;
    _nameController = TextEditingController(text: center?.name ?? '');
    _addressController = TextEditingController(text: center?.address ?? '');
    _pcCountController = TextEditingController(text: center?.pcCount.toString() ?? '');
    _pcSpecController = TextEditingController(text: center?.pcSpec ?? '');
    _priceController = TextEditingController(text: center?.price.toString() ?? '');
    _phoneController = TextEditingController(text: center?.phone ?? '');
    _latitudeController = TextEditingController(text: center?.latitude.toString() ?? '');
    _longitudeController = TextEditingController(text: center?.longitude.toString() ?? '');
    _profileImageBase64 = center?.profileImageBase64;
    _imagesBase64 = List<String>.from(center?.imagesBase64 ?? const <String>[]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _pcCountController.dispose();
    _pcSpecController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _profileImageBase64 = base64Encode(bytes);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerCenterImageFailed)),
      );
    }
  }

  void _removeProfileImage() {
    setState(() {
      _profileImageBase64 = null;
    });
  }

  Future<void> _pickImages() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picked = await _imagePicker.pickMultiImage(
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (picked.isEmpty) return;
      final nextImages = <String>[];
      for (final file in picked) {
        final bytes = await file.readAsBytes();
        nextImages.add(base64Encode(bytes));
      }
      if (!mounted) return;
      setState(() {
        _imagesBase64 = <String>[
          ..._imagesBase64,
          ...nextImages,
        ];
        _selectedImageIndexes.clear();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerCenterImageFailed)),
      );
    }
  }

  void _toggleImageSelection(int index) {
    setState(() {
      if (_selectedImageIndexes.contains(index)) {
        _selectedImageIndexes.remove(index);
      } else {
        _selectedImageIndexes.add(index);
      }
    });
  }

  void _enterSelectionMode(int index) {
    setState(() {
      _selectedImageIndexes.add(index);
    });
  }

  void _openImageViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CenterImageViewer(
          imagesBase64: _imagesBase64,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _removeSelectedImages() {
    if (_selectedImageIndexes.isEmpty) return;
    final nextImages = <String>[];
    for (var i = 0; i < _imagesBase64.length; i++) {
      if (!_selectedImageIndexes.contains(i)) {
        nextImages.add(_imagesBase64[i]);
      }
    }
    setState(() {
      _imagesBase64 = nextImages;
      _selectedImageIndexes.clear();
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final pcCount = int.tryParse(_pcCountController.text.trim());
    final price = int.tryParse(_priceController.text.trim());
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());

    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _pcSpecController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        pcCount == null ||
        price == null ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerInvalidCenterData)),
      );
      return;
    }

    final center = EsportCenter(
      id: widget.center?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      pcCount: pcCount,
      pcSpec: _pcSpecController.text.trim(),
      price: price,
      phone: _phoneController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      ownerEmail: widget.ownerEmail,
      profileImageBase64: _profileImageBase64,
      imagesBase64: _imagesBase64,
    );

    Navigator.of(context).pop(center);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    InputDecoration decoration(String label) => InputDecoration(labelText: label);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.center == null ? l10n.ownerAddCenter : l10n.ownerEditCenter,
        ),
        actions: [
          const LanguageToggleButton(),
          if (_selectionMode)
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedImageIndexes.clear();
                });
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.ownerCenterProfileImageLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _profileImageBase64 == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => _CenterImageViewer(
                                imagesBase64: <String>[_profileImageBase64!],
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                  child: Center(
                    child: CenterImage(
                      imageBase64: _profileImageBase64,
                      width: 170,
                      height: 170,
                      borderRadius: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickProfileImage,
                      icon: const Icon(Icons.person_rounded),
                      label: Text(
                        _profileImageBase64 == null
                            ? l10n.ownerCenterAddProfileImage
                            : l10n.ownerCenterChangeProfileImage,
                      ),
                    ),
                    if (_profileImageBase64 != null)
                      OutlinedButton.icon(
                        onPressed: _removeProfileImage,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.ownerCenterRemoveProfileImage),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.ownerCenterGalleryLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                if (_imagesBase64.isEmpty)
                  const CenterImage(
                    imageBase64: null,
                    width: double.infinity,
                    height: 180,
                    borderRadius: 20,
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagesBase64.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedImageIndexes.contains(index);
                        return GestureDetector(
                          onTap: () {
                            if (_selectionMode) {
                              _toggleImageSelection(index);
                            } else {
                              _openImageViewer(index);
                            }
                          },
                          onLongPress: () => _enterSelectionMode(index),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFEF4444)
                                        : Colors.white.withValues(alpha: 0.14),
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: CenterImage(
                                  imageBase64: _imagesBase64[index],
                                  width: 220,
                                  height: 180,
                                  borderRadius: 20,
                                ),
                              ),
                              if (_selectionMode)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: isSelected
                                        ? const Color(0xFFEF4444)
                                        : Colors.black.withValues(alpha: 0.42),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                if (_imagesBase64.isNotEmpty)
                  Text(
                    l10n.ownerCenterImageSelectionHint,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                if (_imagesBase64.isNotEmpty) const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.ownerCenterAddImages),
                    ),
                    if (_imagesBase64.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed:
                            _selectedImageIndexes.isEmpty ? null : _removeSelectedImages,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.ownerCenterRemoveSelectedImages),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(controller: _nameController, decoration: decoration(l10n.name)),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: decoration(l10n.ownerCenterAddress),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pcCountController,
            keyboardType: TextInputType.number,
            decoration: decoration(l10n.ownerCenterPcCount),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pcSpecController,
            decoration: decoration(l10n.ownerCenterPcSpec),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: decoration(l10n.ownerCenterPrice),
          ),
          const SizedBox(height: 12),
          TextField(controller: _phoneController, decoration: decoration(l10n.phone)),
          const SizedBox(height: 12),
          TextField(
            controller: _latitudeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoration(l10n.ownerCenterLatitude),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _longitudeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoration(l10n.ownerCenterLongitude),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: Text(l10n.ownerSaveCenter),
          ),
        ],
      ),
    );
  }
}

class _CenterImageViewer extends StatefulWidget {
  const _CenterImageViewer({
    required this.imagesBase64,
    required this.initialIndex,
  });

  final List<String> imagesBase64;
  final int initialIndex;

  @override
  State<_CenterImageViewer> createState() => _CenterImageViewerState();
}

class _CenterImageViewerState extends State<_CenterImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1}/${widget.imagesBase64.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagesBase64.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: CenterImage(
                imageBase64: widget.imagesBase64[index],
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
