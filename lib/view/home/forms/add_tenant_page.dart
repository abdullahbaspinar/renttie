import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/model/tenant.dart';
import 'package:renttie/services/file_storage_service.dart';
import 'package:renttie/services/image_storage_service.dart';
import 'package:renttie/view/auth/widgets/auth_primary_button.dart';
import 'package:renttie/view/auth/widgets/auth_text_field.dart';
import 'package:renttie/view/home/widgets/photo_picker_field.dart';

class AddTenantPage extends StatefulWidget {
  const AddTenantPage({super.key, this.tenant});

  /// Doluysa düzenleme modunda açılır.
  final Tenant? tenant;

  @override
  State<AddTenantPage> createState() => _AddTenantPageState();
}

class _AddTenantPageState extends State<AddTenantPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _depositController;
  late final TextEditingController _rentController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  String? _selectedPropertyId;
  String? _photoPath;
  String? _contractPath;
  DateTime? _leaseStart;
  DateTime? _leaseEnd;
  int _paymentDay = 1;
  bool _prorateFirstMonth = false;
  PaymentTiming _paymentTiming = PaymentTiming.advance;
  bool _isLoading = false;

  bool get _isEdit => widget.tenant != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tenant;
    _nameController = TextEditingController(text: t?.name);
    _phoneController = TextEditingController(text: t?.phone);
    _emailController = TextEditingController(text: t?.email);
    _depositController = TextEditingController(
      text: t != null && t.depositAmount > 0 ? '${t.depositAmount}' : null,
    );
    _rentController = TextEditingController(
      text: t != null && t.monthlyRent > 0 ? '${t.monthlyRent}' : null,
    );
    _emergencyNameController =
        TextEditingController(text: t?.emergencyContactName);
    _emergencyPhoneController =
        TextEditingController(text: t?.emergencyContactPhone);
    _selectedPropertyId = t?.propertyId;
    _photoPath = t?.photoPath;
    _contractPath = t?.contractPath;
    _leaseStart = t?.leaseStart;
    _leaseEnd = t?.leaseEnd;
    _paymentDay = (t?.paymentDay ?? 1).clamp(1, 28);
    _prorateFirstMonth = t?.prorateFirstMonth ?? false;
    _paymentTiming = t?.paymentTiming ?? PaymentTiming.advance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _depositController.dispose();
    _rentController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null) {
      _showSnack('Lütfen bir mülk seçin');
      return;
    }
    if (_leaseStart == null || _leaseEnd == null) {
      _showSnack('Kira başlangıç ve bitiş tarihlerini seçin');
      return;
    }
    if (!_leaseEnd!.isAfter(_leaseStart!)) {
      _showSnack('Bitiş tarihi başlangıçtan sonra olmalı');
      return;
    }

    setState(() => _isLoading = true);
    final cubit = context.read<RentalCubit>();

    try {
      if (_isEdit) {
        await cubit.updateTenant(
        widget.tenant!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          propertyId: _selectedPropertyId,
          paymentDay: _paymentDay,
          depositAmount: int.tryParse(_depositController.text.trim()) ?? 0,
          monthlyRent: int.parse(_rentController.text.trim()),
          leaseStart: _leaseStart,
          leaseEnd: _leaseEnd,
          contractPath: _contractPath,
          photoPath: _photoPath,
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim(),
          prorateFirstMonth: _prorateFirstMonth,
          paymentTiming: _paymentTiming,
        ),
      );
    } else {
      await cubit.addTenant(
        Tenant(
          id: cubit.newId('tenant'),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          propertyId: _selectedPropertyId!,
          paymentDay: _paymentDay,
          depositAmount: int.tryParse(_depositController.text.trim()) ?? 0,
          monthlyRent: int.parse(_rentController.text.trim()),
          leaseStart: _leaseStart,
          leaseEnd: _leaseEnd,
          contractPath: _contractPath,
          photoPath: _photoPath,
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim(),
          prorateFirstMonth: _prorateFirstMonth,
          paymentTiming: _paymentTiming,
        ),
      );
      }
      if (!mounted) return;
      context.pop();
      _showSnack(_isEdit ? 'Kiracı güncellendi' : 'Kiracı eklendi');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Kiracı kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickPhoto() async {
    final path =
        await ImageStorageService.instance.pickAndStoreImage('tenant');
    if (path != null && mounted) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _pickContract() async {
    try {
      final path = await FileStorageService.instance.pickAndStoreContract();
      if (path != null && mounted) {
        setState(() => _contractPath = path);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('$e');
    }
  }

  Future<void> _pickLeaseDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_leaseStart ?? now)
        : (_leaseEnd ?? _leaseStart?.copyWith(year: _leaseStart!.year + 1) ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2015),
      lastDate: DateTime(2040),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _leaseStart = picked;
        // Başlangıç seçilince ödeme gününü otomatik öner.
        if (picked.day <= 28) _paymentDay = picked.day;
      } else {
        _leaseEnd = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final properties = context.read<RentalCubit>().state.properties;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        title: Text(
          _isEdit ? 'Kiracıyı Düzenle' : 'Kiracı Ekle',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: properties.isEmpty
          ? Center(
              child: Text(
                'Önce bir mülk eklemelisiniz',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            )
          : SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhotoPickerField(
                      photoPath: _photoPath,
                      onPick: _pickPhoto,
                      isCircular: true,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AuthTextField(
                      controller: _nameController,
                      label: 'Ad Soyad',
                      hint: 'Kiracı adı',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Ad soyad gerekli'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Telefon',
                      hint: '05XX XXX XX XX (isteğe bağlı)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: _emailController,
                      label: 'E-posta',
                      hint: 'ornek@email.com (isteğe bağlı)',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v != null &&
                            v.trim().isNotEmpty &&
                            !v.contains('@')) {
                          return 'Geçerli e-posta girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLabel(context, 'Mülk'),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      key: ValueKey('property_$_selectedPropertyId'),
                      initialValue: _selectedPropertyId,
                      decoration: _dropdownDecoration(context),
                      hint: const Text('Mülk seçin'),
                      items: properties
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPropertyId = v),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: _rentController,
                      label: 'Aylık Kira (TL)',
                      hint: '12000',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Aylık kira gerekli';
                        }
                        final amount = int.tryParse(v.trim());
                        if (amount == null || amount <= 0) {
                          return 'Geçerli bir tutar girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLabel(context, 'Kira Dönemi'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: 'Başlangıç',
                            date: _leaseStart,
                            onTap: () => _pickLeaseDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateField(
                            label: 'Bitiş',
                            date: _leaseEnd,
                            onTap: () => _pickLeaseDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLabel(context, 'Aylık Ödeme Günü'),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<int>(
                      key: ValueKey('payment_day_$_paymentDay'),
                      initialValue: _paymentDay,
                      decoration: _dropdownDecoration(context),
                      items: List.generate(
                        28,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Her ayın ${index + 1}. günü'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _paymentDay = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLabel(context, 'Ödeme Şekli'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTimingSelector(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildProrateToggle(context),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: _depositController,
                      label: 'Depozito Miktarı (TL)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final amount = int.tryParse(v.trim());
                        if (amount == null || amount < 0) {
                          return 'Geçerli bir tutar girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLabel(context, 'Acil Durum Kişisi (isteğe bağlı)'),
                    const SizedBox(height: AppSpacing.sm),
                    AuthTextField(
                      controller: _emergencyNameController,
                      label: 'Acil Durum Kişisi Adı',
                      hint: 'Örn. Yakın akraba',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: _emergencyPhoneController,
                      label: 'Acil Durum Telefonu',
                      hint: '05XX XXX XX XX',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLabel(context, 'Kira Sözleşmesi (isteğe bağlı)'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildContractPicker(context),
                    const SizedBox(height: 32),
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

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Giriş tarihi ile ödeme günü arasındaki gün sayısına göre kıst tutarı.
  ({int days, int amount})? _proratePreview() {
    if (_leaseStart == null) return null;
    final rent = int.tryParse(_rentController.text.trim());
    if (rent == null || rent <= 0) return null;
    if (_leaseStart!.day == _paymentDay) return null;

    final start = _leaseStart!;
    final firstRegular = start.day <= _paymentDay
        ? DateTime(start.year, start.month, _paymentDay)
        : DateTime(start.year, start.month + 1, _paymentDay);
    final days = firstRegular
        .difference(DateTime(start.year, start.month, start.day))
        .inDays;
    if (days <= 0) return null;
    return (days: days, amount: (rent * days / 30).round());
  }

  Widget _buildTimingSelector(BuildContext context) {
    Widget option(PaymentTiming timing, String title, String subtitle) {
      final selected = _paymentTiming == timing;
      return Material(
        color: selected
            ? AppColors.secondary.withValues(alpha: 0.12)
            : AppColors.surface(context),
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: () => setState(() => _paymentTiming = timing),
          borderRadius: AppRadius.lgAll,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: selected
                    ? AppColors.secondary
                    : AppColors.border(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 18,
                      color: selected
                          ? AppColors.secondary
                          : AppColors.textHint(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w700,
                          fontSize: AppTypography.sizeMd,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: AppTypography.sizeXs,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        option(
          PaymentTiming.advance,
          'Peşin',
          'Önce öder, sonra kalır (dönem başı)',
        ),
        const SizedBox(height: AppSpacing.md),
        option(
          PaymentTiming.arrears,
          'Dönem Sonu',
          'Kalır, sonra öder (dönem sonu)',
        ),
      ],
    );
  }

  Widget _buildProrateToggle(BuildContext context) {
    final preview = _proratePreview();
    return Material(
      color: AppColors.surface(context),
      borderRadius: AppRadius.lgAll,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          children: [
            SwitchListTile(
            value: _prorateFirstMonth,
            onChanged: (v) => setState(() => _prorateFirstMonth = v),
            activeThumbColor: AppColors.secondary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              'İlk ay kıst kira hesapla',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: AppTypography.sizeBase,
              ),
            ),
            subtitle: Text(
              'Giriş tarihi ile ödeme günü arasını gün bazlı hesaplar',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: AppTypography.sizeSm,
              ),
            ),
          ),
            if (_prorateFirstMonth && preview != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'İlk ödeme: ${preview.days} gün için '
                        '${formatCurrency(preview.amount)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: AppTypography.sizeSm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
    );
  }

  Widget _buildContractPicker(BuildContext context) {
    final hasContract = _contractPath != null;
    final fileName =
        hasContract ? _contractPath!.split('/').last.replaceFirst(RegExp(r'^\d+_'), '') : null;

    return Material(
      color: AppColors.surface(context),
      borderRadius: AppRadius.lgAll,
      child: ListTile(
        onTap: _pickContract,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: AppColors.border(context)),
        ),
        leading: Icon(
          hasContract ? Icons.description : Icons.upload_file_outlined,
          color: AppColors.secondary,
        ),
        title: Text(
          fileName ?? 'Sözleşme yükle (PDF, görsel...)',
          style: TextStyle(
            color: hasContract
                ? AppColors.textPrimary(context)
                : AppColors.textSecondary(context),
            fontSize: AppTypography.sizeBase,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: hasContract
            ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                onPressed: () => setState(() => _contractPath = null),
              )
            : null,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: AppTypography.sizeXs,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? '${date!.day}.${date!.month}.${date!.year}'
                      : 'Seçin',
                  style: TextStyle(
                    color: date != null
                        ? AppColors.textPrimary(context)
                        : AppColors.textHint(context),
                    fontWeight: FontWeight.w600,
                    fontSize: AppTypography.sizeMd,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
