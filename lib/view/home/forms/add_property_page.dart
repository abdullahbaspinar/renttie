import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/model/property.dart';
import 'package:renttie/services/image_storage_service.dart';
import 'package:renttie/view/auth/widgets/auth_primary_button.dart';
import 'package:renttie/view/auth/widgets/auth_text_field.dart';
import 'package:renttie/view/home/widgets/photo_picker_field.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key, this.property});

  /// Doluysa düzenleme modunda açılır.
  final Property? property;

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late PropertyType _type;
  String? _photoPath;
  bool _isLoading = false;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.property?.name);
    _addressController = TextEditingController(text: widget.property?.address);
    _type = widget.property?.type ?? PropertyType.apartment;
    _photoPath = widget.property?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final cubit = context.read<RentalCubit>();

    try {
      if (_isEdit) {
        await cubit.updateProperty(
          widget.property!.copyWith(
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            type: _type,
            photoPath: _photoPath,
          ),
        );
      } else {
        await cubit.addProperty(
          Property(
            id: cubit.newId('prop'),
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            type: _type,
            photoPath: _photoPath,
          ),
        );
      }
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Mülk güncellendi' : 'Mülk eklendi')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mülk kaydedilemedi: $e')),
      );
    }
  }

  Future<void> _pickPhoto() async {
    final path =
        await ImageStorageService.instance.pickAndStoreImage('property');
    if (path != null && mounted) {
      setState(() => _photoPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        title: Text(
          _isEdit ? 'Mülkü Düzenle' : 'Mülk Ekle',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screen,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoPickerField(
                photoPath: _photoPath,
                onPick: _pickPhoto,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AuthTextField(
                controller: _nameController,
                label: 'Mülk Adı',
                hint: 'Daire 3A',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Mülk adı gerekli' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthTextField(
                controller: _addressController,
                label: 'Adres',
                hint: 'İlçe, Şehir',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Adres gerekli' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Mülk Tipi',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildTypeChips(context),
              const SizedBox(height: AppSpacing.xxxl),
              AuthPrimaryButton(
                label: _isEdit ? 'Güncelle' : 'Kaydet',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: PropertyType.values.map((type) {
        final label = switch (type) {
          PropertyType.apartment => 'Daire',
          PropertyType.office => 'Ofis',
          PropertyType.shop => 'Dükkan',
          PropertyType.other => 'Diğer',
        };
        return ChoiceChip(
          label: Text(label),
          selected: _type == type,
          selectedColor: AppColors.secondary.withValues(alpha: 0.2),
          onSelected: (_) => setState(() => _type = type),
        );
      }).toList(),
    );
  }
}
