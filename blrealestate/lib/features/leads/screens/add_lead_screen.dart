import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/premium_widgets.dart';

class AddLeadScreen extends ConsumerStatefulWidget {
  const AddLeadScreen({super.key});

  @override
  ConsumerState<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends ConsumerState<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _messageController = TextEditingController();
  int? _selectedPropertyId;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    try {
      if (!mounted) return;
      if (_isSubmitting) return;
      if (_formKey.currentState?.validate() != true) return;
      setState(() => _isSubmitting = true);

      // Convert to yyyy-MM-dd (ISO 8601)
      String isoDate = _selectedDate?.toIso8601String().split('T').first ?? '';
      if (isoDate.isEmpty) {
        AppSnackBar.error(context, 'Please select a valid date');
        setState(() => _isSubmitting = false);
        return;
      }

      final Map<String, dynamic> payload = {
        'name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'message': _messageController.text.trim(),
        'appointment_date': isoDate,
      };
      if (_selectedPropertyId != null) {
        payload['property_id'] = _selectedPropertyId;
      }

      final success = await ref.read(leadProvider.notifier).addLead(payload);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        AppSnackBar.success(context, AppStrings.leadSuccess);
        Navigator.pop(context);
      } else {
        AppSnackBar.error(context, AppStrings.leadFailed);
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
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(16),
        ),
        validator:
            validator ??
            (v) => (v == null || v.isEmpty) ? AppStrings.required : null,
      ),
    );
  }

  Widget _buildPropertyDropdown() {
    final inventoryState = ref.watch(allPropertiesDropdownProvider);
    final properties = inventoryState.maybeWhen(
      data: (data) => data,
      orElse: () => <InventoryModel>[],
    );
    final validSelectedId = properties.any((p) => p.id == _selectedPropertyId)
        ? _selectedPropertyId
        : null;

    // Build items once — memoized by property list reference.
    // Avoids rebuilding 500 DropdownMenuItems on every keystroke setState.
    final items = properties
        .map((p) => DropdownMenuItem<int>(
              value: p.id,
              child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ))
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        // ignore: deprecated_member_use
        value: validSelectedId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Select Property',
          prefixIcon: const Icon(Icons.apartment, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(16),
        ),
        items: items,
        onChanged: (v) => setState(() => _selectedPropertyId = v),
        validator: (v) => v == null ? AppStrings.required : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);

    return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.registerClient)),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Client Info ──────────────────────────────────────────
                _field(
                  AppStrings.clientName,
                  _nameController,
                  Icons.person_outline,
                ),
                _field(
                  AppStrings.phoneNumber,
                  _phoneController,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.required;
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                      return AppStrings.validPhone10;
                    }
                    return null;
                  },
                ),
                _field(
                  AppStrings.address,
                  _addressController,
                  Icons.location_on_outlined,
                  maxLines: 2,
                ),

                // ── Property & Date ──────────────────────────────────────
                const Divider(height: 32),
                _buildPropertyDropdown(),
                _field(
                  AppStrings.meetingDate,
                  _dateController,
                  Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDate,
                ),
                _field(
                  'Message',
                  _messageController,
                  Icons.message_outlined,
                  maxLines: 3,
                  validator: (v) => null, // Optional field
                ),

                const SizedBox(height: 32),
                PremiumButton(
                  text: AppStrings.submitToAdmin,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
    );
  }
}
