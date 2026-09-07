import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../providers/app_providers.dart';

class HoldPropertyScreen extends ConsumerStatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const HoldPropertyScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  ConsumerState<HoldPropertyScreen> createState() => _HoldPropertyScreenState();
}

class _HoldPropertyScreenState extends ConsumerState<HoldPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  // Store only file paths — no PlatformFile bytes in memory
  List<String> _documentPaths = [];
  List<String> _documentNames = [];

  bool _isSubmitting = false;
  bool _isPickingFiles = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    if (_isPickingFiles || _isSubmitting) return;
    setState(() => _isPickingFiles = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false, // never load file bytes into memory
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;

      // Max 5 files
      if (result.files.length > 5) {
        AppSnackBar.error(context, 'Max 5 files allowed.');
        return;
      }

      // Max 3 MB per file
      const maxBytes = 3 * 1024 * 1024;
      final valid = result.files.where((f) => f.size <= maxBytes && f.path != null).toList();
      final skipped = result.files.length - valid.length;
      if (skipped > 0) {
        AppSnackBar.error(context, '$skipped file(s) skipped — max 3 MB each.');
      }

      if (valid.isNotEmpty) {
        setState(() {
          _documentPaths = valid.map((f) => f.path!).toList();
          _documentNames = valid.map((f) => f.name).toList();
        });
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Could not open file picker. Please try again.');
    } finally {
      if (mounted) setState(() => _isPickingFiles = false);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(inventoryProvider.notifier).holdUnit(
            propertyId: widget.propertyId,
            customerName: _nameCtrl.text.trim(),
            customerMobile: _mobileCtrl.text.trim(),
            amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
            documentPaths: _documentPaths,
          );
      if (!mounted) return;
      AppSnackBar.success(context, 'Hold request submitted successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      String msg = 'Failed to submit. Please try again.';
      if (e is DioException && e.response?.data is Map) {
        msg = (e.response!.data as Map)['message']?.toString() ?? msg;
      }
      AppSnackBar.error(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch live status so button disables immediately after successful hold
    final liveStatus = ref.watch(inventoryProvider).maybeWhen(
      data: (data) {
        final (items, _) = data;
        try {
          return items.firstWhere((i) => i.id == widget.propertyId).displayStatus;
        } catch (_) {
          return 'ACTIVE';
        }
      },
      orElse: () => 'ACTIVE',
    );
    final isAlreadyHeld = liveStatus == 'HOLD';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hold Property'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.apartment, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.propertyTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _field('Customer Name', _nameCtrl, Icons.person_outline),
              _field(
                'Customer Mobile',
                _mobileCtrl,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Enter valid 10-digit mobile number';
                  return null;
                },
              ),
              _field(
                'Amount (₹)',
                _amountCtrl,
                Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) return 'Enter valid amount';
                  return null;
                },
              ),

              Text(
                'Documents (Aadhar, PAN, etc.) — max 5 files, 3 MB each',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: (_isSubmitting || _isPickingFiles) ? null : _pickDocuments,
                icon: _isPickingFiles
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _documentPaths.isEmpty
                      ? 'Select Documents (Optional)'
                      : '${_documentPaths.length} file(s) selected',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
              ),
              if (_documentNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...List.generate(_documentNames.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file_outlined, size: 14, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _documentNames[i],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isSubmitting)
                        GestureDetector(
                          onTap: () => setState(() {
                            _documentPaths.removeAt(i);
                            _documentNames.removeAt(i);
                          }),
                          child: Icon(Icons.close, size: 14, color: AppColors.textSecondary(context)),
                        ),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 24),
              PremiumButton(
                text: isAlreadyHeld ? 'Already on Hold' : 'Submit Hold Request',
                icon: isAlreadyHeld ? Icons.lock : null,
                isLoading: _isSubmitting,
                onPressed: (isAlreadyHeld || _isPickingFiles) ? null : _submit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }
}
