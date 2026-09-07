import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../providers/documents_provider.dart';

// Document type options
const _docTypes = [
  'Aadhar Card',
  'PAN Card',
  'Passport',
  'Driving License',
  'Voter ID',
  'Other',
];

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isUploading = false;

  Future<void> _uploadDocument() async {
    if (_isUploading) return;

    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    // Check size — max 3 MB
    const maxBytes = 3 * 1024 * 1024;
    if (file.size > maxBytes) {
      AppSnackBar.error(context, 'File too large — max 3 MB.');
      return;
    }

    // Pick document type
    final docType = await _pickDocType();
    if (!mounted || docType == null) return;

    setState(() => _isUploading = true);
    try {
      final ok = await ref.read(documentsProvider.notifier).uploadDocument(
            filePath: file.path!,
            documentType: docType,
          );
      if (!mounted) return;
      if (ok) {
        AppSnackBar.success(context, 'Document uploaded successfully');
      } else {
        AppSnackBar.error(context, 'Upload failed. Please try again.');
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<String?> _pickDocType() async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textSecondary(context), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Text('Select Document Type',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ..._docTypes.map((t) => ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: Text(t),
                  onTap: () => Navigator.pop(context, t),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceLight,
        elevation: 0,
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: AppColors.surfaceLight, strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.upload_file_rounded),
              tooltip: 'Upload Document',
              onPressed: _uploadDocument,
            ),
        ],
      ),
      body: docsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(itemHeight: 72),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary(context)),
              const SizedBox(height: 12),
              Text('Could not load documents', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(documentsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (docs) => docs.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_outlined, size: 72, color: AppColors.textSecondary(context)),
                    const SizedBox(height: 16),
                    Text('No documents uploaded yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary(context))),
                    const SizedBox(height: 8),
                    Text('Tap the upload icon to add a document',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _DocTile(doc: docs[i]),
              ),
      ),
      floatingActionButton: _isUploading
          ? null
          : FloatingActionButton.extended(
              onPressed: _uploadDocument,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.upload_file_rounded, color: AppColors.surfaceLight),
              label: Text('Upload', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.surfaceLight, fontWeight: FontWeight.bold)),
            ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _DocTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final name = doc['document_type']?.toString() ?? doc['name']?.toString() ?? 'Document';
    final date = doc['created_at']?.toString() ?? '';
    final url  = doc['document_url']?.toString() ?? doc['url']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textSecondary(context).withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(color: AppColors.textPrimary(context).withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              url.toLowerCase().endsWith('.pdf')
                  ? Icons.picture_as_pdf_outlined
                  : Icons.image_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (date.isNotEmpty)
                  Text(date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}
