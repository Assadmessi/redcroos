import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';

/// Lets a Company Commander/Deputy review pending access-grant
/// requests from their Company Sergeant Major (or Master Access
/// reviewing any company) — approve with a chosen expiry date, or
/// deny with a reason.
class AccessGrantApprovalScreen extends StatefulWidget {
  const AccessGrantApprovalScreen({super.key});

  @override
  State<AccessGrantApprovalScreen> createState() => _AccessGrantApprovalScreenState();
}

class _AccessGrantApprovalScreenState extends State<AccessGrantApprovalScreen> {
  Future<void> _approve(AccessGrantRequest request, AuthProvider auth) async {
    final expiry = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Access expires on',
    );
    if (expiry == null) return;

    setState(() {
      MockAccessGrants.update(AccessGrantRequest(
        id: request.id,
        requesterId: request.requesterId,
        targetMemberId: request.targetMemberId,
        requestedSections: request.requestedSections,
        reason: request.reason,
        status: AccessGrantStatus.approved,
        approverId: auth.currentMember?.id,
        requestedAt: request.requestedAt,
        decidedAt: DateTime.now(),
        expiresAt: expiry,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Access granted until ${AppFormatters.date(expiry)}')),
    );
  }

  Future<void> _deny(AccessGrantRequest request, AuthProvider auth) async {
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
      MockAccessGrants.update(AccessGrantRequest(
        id: request.id,
        requesterId: request.requesterId,
        targetMemberId: request.targetMemberId,
        requestedSections: request.requestedSections,
        reason: request.reason,
        status: AccessGrantStatus.denied,
        approverId: auth.currentMember?.id,
        requestedAt: request.requestedAt,
        decidedAt: DateTime.now(),
        denialReason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request denied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    if (me == null) return const SizedBox.shrink();

    final pending = MockAccessGrants.pendingFor(me.companyNo);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Access Requests', style: AppTextStyles.headingMedium),
          ),
        ),
        Expanded(
          child: pending.isEmpty
              ? Center(
                  child: Text(
                    'No pending access requests.',
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

  Widget _requestCard(AccessGrantRequest request, AuthProvider auth) {
    final requester = MockMembers.findById(request.requesterId);
    final target = MockMembers.findById(request.targetMemberId);

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
                  radius: 18,
                  backgroundColor: requester != null ? AvatarColorGen.fromString(requester.id) : AppColors.grey500,
                  child: Text(requester?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 12)),
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
            const SizedBox(height: 12),
            Text(
              'Requesting access to ${target?.nameEn ?? request.targetMemberId}\'s profile',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: request.requestedSections
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
            Text(
              'Requested ${AppFormatters.date(request.requestedAt)}',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
            ),
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
