import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/info_row_widget.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/data_refresh_header.dart';
import '../../dashboard/widgets/shared_status_chip.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myLeadsTitle),
          automaticallyImplyLeading: false,
        ),
        body: const SizedBox.shrink(),
      );
    }
    final leadState = ref.watch(leadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myLeadsTitle),
        automaticallyImplyLeading: false,
      ),
      body: leadState.when(
        skipLoadingOnReload: true,
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(itemHeight: 100),
        ),

        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.textSecondary(context)),
              const SizedBox(height: 12),
              Text(AppStrings.couldNotLoadLeads,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(leadProvider.notifier).refresh(),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
        data: (data) {
          final (leads, metadata) = data;
          return RefreshIndicator(
            onRefresh: () async => ref.read(leadProvider.notifier).refresh(),
            child: leads.isEmpty
                ? const _EmptyLeads()
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: leads.length + 1,
                    itemBuilder: (context, i) {
                      // Index 0 — refresh header
                      if (i == 0) {
                        return DataRefreshHeader(
                          lastUpdated: metadata.formattedTime,
                          onRefresh: () async =>
                              ref.read(leadProvider.notifier).refresh(),
                        );
                      }
                      // Lead cards — offset by 1 for the header
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          i == 1 ? 16 : 0, // top padding only on first card
                          16,
                          i == leads.length ? 100 : 0, // bottom padding on last card
                        ),
                        child: _LeadCard(lead: leads[i - 1]),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(lead.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: RepaintBoundary(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: color),
          ),
          title: Text(
            lead.clientName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lead.phone,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary(context))),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lead.status.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            HapticFeedback.selectionClick();
            _showDetails(context, lead);
          },
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, LeadModel lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: _LeadDetailSheet(
            lead: lead,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }
}

class _LeadDetailSheet extends ConsumerStatefulWidget {
  final LeadModel lead;
  final ScrollController scrollController;

  const _LeadDetailSheet({
    required this.lead,
    required this.scrollController,
  });

  @override
  ConsumerState<_LeadDetailSheet> createState() => _LeadDetailSheetState();
}

class _LeadDetailSheetState extends ConsumerState<_LeadDetailSheet> {
  bool _isUpdating = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.lead.status;
  }

  // ── Format date — uses centralized DateFormatter ─────────────────────────
  String _formatDate(String raw) => DateFormatter.format(raw);

  // ── Open phone dialer ─────────────────────────────────────────────────────
  Future<void> _callPhone(String phone) async {
    if (phone.trim().isEmpty) return;
    try {
      final uri = Uri(scheme: 'tel', path: phone.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      // silently ignore — dialer unavailable on some devices
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(_currentStatus);

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header banner ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      widget.lead.clientName.isNotEmpty
                          ? widget.lead.clientName[0].toUpperCase()
                          : '?',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lead.clientName,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.lead.phone,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _currentStatus.isNotEmpty
                        ? _currentStatus[0].toUpperCase() + _currentStatus.substring(1)
                        : 'New',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // ── Call button ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _callPhone(widget.lead.phone);
                },
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text(
                  'Call ${widget.lead.clientName.split(' ').first}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.surfaceLight,
                  elevation: 3,
                  shadowColor: AppColors.success.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          // ── Details card ─────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.inputFill(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                InfoRowWidget(icon: Icons.phone_outlined, label: AppStrings.phoneNumber, value: widget.lead.phone),
                const Divider(height: 1, color: AppColors.backgroundLight),
                if (widget.lead.email != null && widget.lead.email!.isNotEmpty) ...[
                  InfoRowWidget(icon: Icons.email_outlined, label: 'Email', value: widget.lead.email!),
                  const Divider(height: 1, color: AppColors.backgroundLight),
                ],
                InfoRowWidget(icon: Icons.location_on_outlined, label: AppStrings.address, value: widget.lead.address ?? 'N/A'),
                const Divider(height: 1, color: AppColors.backgroundLight),
                InfoRowWidget(icon: Icons.event_rounded, label: AppStrings.meetingDate, value: _formatDate(widget.lead.meetingDate)),
                if (widget.lead.message != null && widget.lead.message!.isNotEmpty) ...[
                  const Divider(height: 1, color: AppColors.backgroundLight),
                  InfoRowWidget(icon: Icons.message_outlined, label: 'Message', value: widget.lead.message!),
                ],
                if (widget.lead.propertyTitle != null && widget.lead.propertyTitle!.isNotEmpty) ...[
                  const Divider(height: 1, color: AppColors.backgroundLight),
                  InfoRowWidget(icon: Icons.apartment_rounded, label: 'Property', value: widget.lead.propertyTitle!),
                ],
              ],
            ),
          ),

          // ── Update status ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              AppStrings.updateStatus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: _isUpdating
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSharedStatusChip(context, 'new',         AppColors.pending),
                      _buildSharedStatusChip(context, 'seen',        AppColors.statusSeen),
                      _buildSharedStatusChip(context, 'contacted',   AppColors.statusContacted),
                      _buildSharedStatusChip(context, 'proposal',    AppColors.statusProposal),
                      _buildSharedStatusChip(context, 'negotiation', AppColors.statusNegotiation),
                      _buildSharedStatusChip(context, 'closed',      AppColors.success),
                    ],
                  ),
          ),
        ],
      ),
    );
  }


  Widget _buildSharedStatusChip(BuildContext context, String status, Color color) {
    return SharedStatusChip(
      status: status,
      currentStatus: _currentStatus,
      isUpdating: _isUpdating,
      color: color,
      onUpdate: (newStatus) async {
        setState(() => _isUpdating = true);
        try {
          final ok = await ref.read(leadProvider.notifier).updateLeadStatus(widget.lead.id, newStatus);
          if (!context.mounted) return;
          setState(() {
            _isUpdating = false;
            if (ok) _currentStatus = newStatus;
          });
          if (ok) {
            AppSnackBar.success(context, '${AppStrings.statusUpdatedTo} $newStatus');
            Navigator.of(context).pop();
          } else {
            AppSnackBar.error(context, 'Failed to update status');
          }
        } catch (_) {
          if (!context.mounted) return;
          setState(() => _isUpdating = false);
          AppSnackBar.error(context, 'Error updating status');
        }
      },
    );
  }
}

class _EmptyLeads extends StatelessWidget {
  const _EmptyLeads();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_search, size: 80, color: AppColors.textSecondary(context)),
              const SizedBox(height: 16),
              Text(AppStrings.noLeads,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary(context))),
              const SizedBox(height: 8),
              Text(AppStrings.noLeadsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
            ],
          ),
        ),
      ],
    );
  }
}
