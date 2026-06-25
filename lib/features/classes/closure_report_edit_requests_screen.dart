import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';

/// Master Access reviews pending requests to edit a locked (post-
/// deadline) Closure Report — approves specific section(s) (may be
/// fewer than what was requested) or denies with a reason.
class ClosureReportEditRequestsScreen extends StatefulWidget {
  const ClosureReportEditRequestsScreen({super.key});

  @override
  State<ClosureReportEditRequestsScreen> createState() => _ClosureReportEditRequestsScreenState();
}

class _ClosureReportEditRequestsScreenState extends State<ClosureReportEditRequestsScreen> {
  Future<void> _approve(ClosureReportEditRequest request, AuthProvider auth) async {
    final selectedSections = Set<ClosureReportSection>.from(request.sectionsRequested);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Approve Edit Request', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Select which section(s) to actually grant — you can approve fewer than what was requested.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 12),
                  ...request.sectionsRequested.map((section) {
                    final isSelected = selectedSections.contains(section);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: isSelected,
                      onChanged: (v) => setSheetState(() {
                        if (v == true) {
                          selectedSections.add(section);
                        } else {
                          selectedSections.remove(section);
                        }
                      }),
                      title: Text(section.label, style: AppTextStyles.bodyMedium),
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedSections.isEmpty ? null : () => Navigator.pop(sheetContext, true),
                    child: const Text('Approve Selected'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      MockClosureReportEditRequests.update(ClosureReportEditRequest(
        id: request.id, classId: request.classId, closureReportId: request.closureReportId,
        requesterId: request.requesterId, sectionsRequested: request.sectionsRequested,
        reason: request.reason, status: ClosureReportEditRequestStatus.approved,
        approverId: auth.currentMember?.id, sectionsGranted: selectedSections.toList(),
        requestedAt: request.requestedAt, decidedAt: DateTime.now(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit access granted')),
    );
  }

  Future<void> _deny(ClosureReportEditRequest request, AuthProvider auth) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deny Request'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason (optional)', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deny'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      MockClosureReportEditRequests.update(ClosureReportEditRequest(
        id: request.id, classId: request.classId, closureReportId: request.closureReportId,
        requesterId: request.requesterId, sectionsRequested: request.sectionsRequested,
        reason: request.reason, status: ClosureReportEditRequestStatus.denied,
        approverId: auth.currentMember?.id,
        requestedAt: request.requestedAt, decidedAt: DateTime.now(),
        denialReason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request denied')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pending = MockClosureReportEditRequests.pending();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Closure Report Edit Requests', style: AppTextStyles.headingMedium),
          ),
        ),
        Expanded(
          child: pending.isEmpty
              ? Center(
                  child: Text(
                    'No pending edit requests.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pending.length,
                  itemBuilder: (context, index) => _requestCard(pending[index], auth),
                ),
        ),
      ],
    );
  }

  Widget _requestCard(ClosureReportEditRequest request, AuthProvider auth) {
    final requester = MockMembers.findById(request.requesterId);
    final trainingClass = MockClasses.findById(request.classId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: requester != null ? AvatarColorGen.fromString(requester.id) : AppColors.grey500,
                  child: Text(requester?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(requester?.nameEn ?? request.requesterId, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(requester?.rankNameEn ?? '', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Class: ${trainingClass?.title ?? request.classId}', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: request.sectionsRequested
                  .map((s) => Chip(
                        label: Text(s.label, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.grey50.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('"${request.reason}"', style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 4),
            Text('Requested ${AppFormatters.date(request.requestedAt)}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deny(request, auth),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Deny'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approve(request, auth),
                    child: const Text('Approve'),
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
