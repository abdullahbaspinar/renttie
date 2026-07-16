import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/view/auth/widgets/auth_primary_button.dart';
import 'package:renttie/view/auth/widgets/auth_text_field.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedTenantId;
  DateTime _dueDate = DateTime.now();
  PaymentStatus _status = PaymentStatus.waiting;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save(RentalState state) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTenantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kiracı seçin')),
      );
      return;
    }

    final tenant = state.tenantById(_selectedTenantId!);
    if (tenant == null) return;

    setState(() => _isLoading = true);
    final cubit = context.read<RentalCubit>();
    try {
      await cubit.addPayment(
        Payment(
          id: cubit.newId('pay'),
          propertyId: tenant.propertyId,
          tenantId: tenant.id,
          amount: int.parse(_amountController.text.trim()),
          dueDate: _dueDate,
          status: _status,
        ),
      );
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödeme eklendi')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ödeme kaydedilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        final tenants = state.tenants;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.background(context),
            title: Text(
              'Ödeme Ekle',
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
          ),
          body: tenants.isEmpty
              ? Center(
                  child: Text(
                    'Önce bir kiracı eklemelisiniz',
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
                        _buildTenantDropdown(context, state),
                        const SizedBox(height: AppSpacing.xl),
                        AuthTextField(
                          controller: _amountController,
                          label: 'Tutar (TL)',
                          hint: '12000',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Tutar gerekli';
                            }
                            if (int.tryParse(v.trim()) == null) {
                              return 'Geçerli tutar girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildDatePicker(context),
                        const SizedBox(height: AppSpacing.xl),
                        _buildStatusChips(context),
                        const SizedBox(height: AppSpacing.xxxl),
                        AuthPrimaryButton(
                          label: 'Kaydet',
                          isLoading: _isLoading,
                          onPressed: () => _save(state),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTenantDropdown(BuildContext context, RentalState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kiracı',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedTenantId,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface(context),
            border: OutlineInputBorder(
              borderRadius: AppRadius.lgAll,
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
          ),
          hint: const Text('Kiracı seçin'),
          items: state.tenants.map((t) {
            final property = state.propertyById(t.propertyId);
            return DropdownMenuItem(
              value: t.id,
              child: Text('${property?.name ?? ''} - ${t.name}'),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedTenantId = v),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vade Tarihi',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: AppColors.surface(context),
          borderRadius: AppRadius.lgAll,
          child: ListTile(
            onTap: _pickDate,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgAll,
              side: BorderSide(color: AppColors.border(context)),
            ),
            title: Text(
              '${_dueDate.day}.${_dueDate.month}.${_dueDate.year}',
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durum',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: PaymentStatus.values.map((status) {
            final label = switch (status) {
              PaymentStatus.waiting => 'Bekliyor',
              PaymentStatus.overdue => 'Gecikti',
              PaymentStatus.paid => 'Ödendi',
            };
            return ChoiceChip(
              label: Text(label),
              selected: _status == status,
              selectedColor: AppColors.secondary.withValues(alpha: 0.2),
              onSelected: (_) => setState(() => _status = status),
            );
          }).toList(),
        ),
      ],
    );
  }
}
