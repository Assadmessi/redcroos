import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import 'feature_access_request_screen.dart';

/// One consolidated screen for the generic Feature Access Request
/// system: Master Access sees ALL pending requests (across every
/// requester/module) plus the full history; everyone else sees their
/// own submitted requests and can submit a new one.
class AccessRequestsOverviewScreen extends StatefulWidget {
  const AccessRequestsOverviewScreen({super.key});

  @override
  State<AccessRequestsOverviewScreen> createState() => _AccessRequestsOverviewScreenState();
}

class _AccessRequestsOverviewScreenState extends State<AccessRequestsOverviewScreen> {
  bool _showHistory = false;

  Future<void> _approve(FeatureAccessRequest request, AuthProvider auth) async {
    final expiry = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Access expires on',
    );
    if (expiry == null) return;

    setState(() {
      MockFeatureAccessRequests.update(FeatureAccessRequest(
        id: request.id,
        requesterId: request.requesterId,
        moduleOrFeature: request.moduleOrFeature,
        reason: request.reason,
        status: FeatureAccessStatus.approved,
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

  Future<void> _deny(FeatureAccessRequest request, AuthProvider auth) async {
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
      MockFeatureAccessRequests.update(FeatureAccessRequest(
        id: request.id,
        requesterId: request.requesterId,
        moduleOrFeature: request.moduleOrFeature,
        reason: request.reason,
        status: FeatureAccessStatus.denied,
        approverId: auth.currentMember?.id,
        requestedAt: request.requestedAt,
        decidedAt: DateTime.now(),
        denialReason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request denied')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    if (me == null) return const SizedBox.shrink();

    final canApprove = auth.canApproveFeatureAccess;
    final canRequest = auth.canRequestFeatureAccess;

    final requests = canApprove
        ? (_showHistory ? MockFeatureAccessRequests.history() : MockFeatureAccessRequests.pending())
        : MockFeatureAccessRequests.submittedBy(me.id);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Access Requests', style: AppTextStyles.headingMedium),
                  ),
                  if (canApprove)
                    IconButton(
                      icon: Icon(_showHistory ? Icons.pending_actions : Icons.history),
                      tooltip: _showHistory ? 'Show pending' : 'Show history',
                      onPressed: () => setState(() => _showHistory = !_showHistory),
                    ),
                ],
              ),
            ),
            Expanded(
              child: requests.isEmpty
                  ? Center(
                      child: Text(
                        canApprove
                            ? (_showHistory ? 'No requests yet.' : 'No pending requests.')
                            : 'You haven\'t submitted any access requests.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: requests.length,
                      itemBuilder: (context, index) =>
                          _requestCard(requests[index], auth, canApprove && !_showHistory),
                    ),
            ),
          ],
        ),
        if (canRequest)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeatureAccessRequestScreen()),
              ).then((submitted) {
                if (submitted == true) setState(() {});
              }),
              icon: const Icon(Icons.add),
              label: const Text('Request Access'),
            ),
          ),
      ],
    );
  }

  Widget _requestCard(FeatureAccessRequest request, AuthProvider auth, bool showActions) {
    final requester = MockMembers.findById(request.requesterId);
    final (color, label) = switch (request.status) {
      FeatureAccessStatus.pending => (Colors.orange, 'Pending'),
      FeatureAccessStatus.approved => (Colors.green, 'Approved'),
      FeatureAccessStatus.denied => (Colors.red, 'Denied'),
      FeatureAccessStatus.expired => (Colors.grey, 'Expired'),
      FeatureAccessStatus.revoked => (Colors.grey, 'Revoked'),
    };

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Requesting: ${request.moduleOrFeature}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
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
            if (request.status == FeatureAccessStatus.approved && request.expiresAt != null)
              Text('Expires ${AppFormatters.date(request.expiresAt!)}', style: AppTextStyles.labelSmall.copyWith(color: Colors.green)),
            if (request.status == FeatureAccessStatus.denied && request.denialReason != null)
              Text('Denial reason: ${request.denialReason}', style: AppTextStyles.labelSmall.copyWith(color: Colors.red)),
            if (showActions) ...[
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
          ],
        ),
      ),
    );
  }
}
