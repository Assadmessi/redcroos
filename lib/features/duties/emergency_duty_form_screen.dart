import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';
import 'duty_detail_screen.dart';

/// Emergency Duty creation — deliberately minimal, open to ANY
/// active member (no rank gate), since the whole point is letting
/// whoever arrives first at an unexpected accident log it
/// immediately without delay. The creator is auto-checked-in as the
/// first responder.
class EmergencyDutyFormScreen extends StatefulWidget {
  const EmergencyDutyFormScreen({super.key});

  @override
  State<EmergencyDutyFormScreen> createState() => _EmergencyDutyFormScreenState();
}

class _EmergencyDutyFormScreenState extends State<EmergencyDutyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController();
  late final _locationCtrl = TextEditingController();
  late final _descriptionCtrl = TextEditingController();
  bool _isDisasterLevel = false;
  bool _isMutualAidOutsideBotahtaung = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _create(AuthProvider auth) {
    if (!_formKey.currentState!.validate()) return;
    final me = auth.currentMember;
    if (me == null) return;

    final now = DateTime.now();
    final dutyId = 'duty_emergency_${now.microsecondsSinceEpoch}';

    final duty = Duty(
      id: dutyId,
      title: _titleCtrl.text.trim(),
      titleMm: '',
      type: DutyType.emergency,
      scale: DutyScale.regular,
      date: now,
      startHour: now.hour,
      startMinute: now.minute,
      location: _locationCtrl.text.trim(),
      members: [
        // Creator is auto-checked-in as the first responder.
        DutyMember(
          memberId: me.id,
          roleInDuty: DutyRoleInDuty.commander,
          status: DutyAssignmentStatus.accepted,
          checkedInAt: now,
          assignedAt: now,
          respondedAt: now,
        ),
      ],
      status: DutyStatus.ongoing,
      description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
      createdByMemberId: me.id,
      isDisasterLevel: _isDisasterLevel,
      isMutualAidOutsideBotahtaung: _isMutualAidOutsideBotahtaung,
    );

    MockDuties.add(duty);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency duty logged — you are checked in as first responder')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DutyDetailScreen(dutyId: dutyId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Emergency'),
        backgroundColor: Colors.red.shade50,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency_outlined, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For unexpected accidents requiring an immediate response. '
                      'You\'ll be checked in as the first responder once submitted.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'What happened?',
                hintText: 'e.g. Traffic accident, building fire',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Street, landmark, or area',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Disaster-level event'),
              subtitle: const Text('Mass casualty, major fire, flood, building collapse, etc.'),
              value: _isDisasterLevel,
              onChanged: (v) => setState(() => _isDisasterLevel = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Outside Botahtaung (mutual aid)'),
              subtitle: const Text('Responding to another township/district\'s request'),
              value: _isMutualAidOutsideBotahtaung,
              onChanged: (v) => setState(() => _isMutualAidOutsideBotahtaung = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _create(auth),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.red,
              ),
              icon: const Icon(Icons.report_outlined),
              label: const Text('Report Emergency & Check In'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
