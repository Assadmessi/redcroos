import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';

/// Generic "I need access to X for my office's work" request form.
/// Available to any office-tier member (Platoon Office, Company
/// Office, Brigade Office) — always routed to Master Access for
/// review. Can be opened with a pre-filled feature name (e.g. from
/// a specific module's restricted-view banner) or blank (e.g. from
/// the drawer/overview screen).
class FeatureAccessRequestScreen extends StatefulWidget {
  final String? prefilledFeature;
  const FeatureAccessRequestScreen({super.key, this.prefilledFeature});

  @override
  State<FeatureAccessRequestScreen> createState() => _FeatureAccessRequestScreenState();
}

class _FeatureAccessRequestScreenState extends State<FeatureAccessRequestScreen> {
  String? _selectedFeature;
  late final _customFeatureCtrl = TextEditingController();
  late final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefilledFeature != null) {
      if (KnownFeatureAreas.all.contains(widget.prefilledFeature)) {
        _selectedFeature = widget.prefilledFeature;
      } else {
        _selectedFeature = 'Other (describe in reason)';
        _customFeatureCtrl.text = widget.prefilledFeature!;
      }
    }
  }

  @override
  void dispose() {
    _customFeatureCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _submit(AuthProvider auth) {
    if (_selectedFeature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select what you need access to')),
      );
      return;
    }
    final isOther = _selectedFeature == 'Other (describe in reason)';
    if (isOther && _customFeatureCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what you need access to')),
      );
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason')),
      );
      return;
    }

    final featureName = isOther ? _customFeatureCtrl.text.trim() : _selectedFeature!;

    MockFeatureAccessRequests.add(FeatureAccessRequest(
      id: 'feat_${DateTime.now().microsecondsSinceEpoch}',
      requesterId: auth.currentMember!.id,
      moduleOrFeature: featureName,
      reason: _reasonCtrl.text.trim(),
      status: FeatureAccessStatus.pending,
      requestedAt: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent to Brigade Office for review')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isOther = _selectedFeature == 'Other (describe in reason)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Access'),
        actions: [
          TextButton(
            onPressed: () => _submit(auth),
            child: const Text('SUBMIT', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'If you need access to a module or feature for your office\'s work, '
            'request it here. This goes to Brigade Office for review.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedFeature,
            decoration: const InputDecoration(
              labelText: 'What do you need access to?',
              border: OutlineInputBorder(),
            ),
            items: KnownFeatureAreas.all
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => _selectedFeature = v),
          ),
          if (isOther) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customFeatureCtrl,
              decoration: const InputDecoration(
                labelText: 'Describe what you need',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _submit(auth),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
