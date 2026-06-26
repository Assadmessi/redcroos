import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';

class ClassFormScreen extends StatefulWidget {
  final TrainingClass? trainingClass; // null = create new, non-null = edit
  const ClassFormScreen({super.key, this.trainingClass});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.trainingClass != null;

  late final _titleCtrl = TextEditingController(text: widget.trainingClass?.title ?? '');
  late final _titleMmCtrl = TextEditingController(text: widget.trainingClass?.titleMm ?? '');
  late final _categoryCtrl = TextEditingController(text: widget.trainingClass?.category ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.trainingClass?.description ?? '');
  late final _locationCtrl = TextEditingController(text: widget.trainingClass?.location ?? '');
  late final _maxParticipantsCtrl =
      TextEditingController(text: widget.trainingClass?.maxParticipants.toString() ?? '20');
  late final _videoUrlCtrl = TextEditingController(text: widget.trainingClass?.videoUrl ?? '');
  late final _totalBudgetCtrl =
      TextEditingController(text: widget.trainingClass?.budget?.totalAmount.toStringAsFixed(0) ?? '');

  ClassType _type = ClassType.classRoom;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _instructorId;
  bool _isExternalInstructor = false;
  bool _hasCommittee = false;
  bool _hasBudget = false;
  bool _issuesCertificate = false;
  FundingSource _fundingSource = FundingSource.organizationFund;

  final Set<String> _requiredSkillIds = {};
  final Set<String> _awardedSkillIds = {};
  final List<ClassCommitteeMember> _committee = [];
  final List<ClassSession> _sessions = [];
  final List<FeedbackQuestion> _feedbackQuestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.trainingClass != null) {
      final c = widget.trainingClass!;
      _type = c.type;
      _startDate = c.startDate;
      _endDate = c.endDate;
      _instructorId = c.instructorId;
      _isExternalInstructor = c.isExternalInstructor;
      _hasCommittee = c.hasCommittee;
      _hasBudget = c.budget != null;
      _issuesCertificate = c.issuesCertificate;
      if (c.budget != null) _fundingSource = c.budget!.fundingSource;
      _requiredSkillIds.addAll(c.requiredSkillIds);
      _awardedSkillIds.addAll(c.awardedSkillIds);
      _committee.addAll(c.committee);
      _sessions.addAll(c.timetable);
      _feedbackQuestions.addAll(c.feedbackQuestions);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleMmCtrl.dispose();
    _categoryCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _videoUrlCtrl.dispose();
    _totalBudgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addSession() {
    setState(() {
      _sessions.add(ClassSession(
        id: 'session_${DateTime.now().microsecondsSinceEpoch}',
        classId: widget.trainingClass?.id ?? '',
        sessionNumber: _sessions.length + 1,
        topic: '',
        date: _startDate ?? DateTime.now(),
        startHour: 9, startMinute: 0, endHour: 12, endMinute: 0,
        location: _locationCtrl.text.trim(),
        status: 'scheduled',
      ));
    });
  }

  void _removeSession(int index) {
    setState(() => _sessions.removeAt(index));
  }

  Future<void> _editSessionTopic(int index) async {
    final ctrl = TextEditingController(text: _sessions[index].topic);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Session ${index + 1} Topic'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        final s = _sessions[index];
        _sessions[index] = ClassSession(
          id: s.id, classId: s.classId, sessionNumber: s.sessionNumber, topic: result,
          date: s.date, startHour: s.startHour, startMinute: s.startMinute,
          endHour: s.endHour, endMinute: s.endMinute, location: s.location,
          facilitator: s.facilitator, status: s.status,
        );
      });
    }
  }

  Future<void> _openCommitteeSheet() async {
    final candidates = MockMembers.all.where((m) => m.nameEn.isNotEmpty).toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final tempSelected = <String, String>{
          for (final c in _committee) c.memberId: c.role,
        };
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: Text('Class Committee', style: AppTextStyles.headingSmall)),
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext, tempSelected),
                            child: Text('Done (${tempSelected.length})'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: candidates.length,
                        itemBuilder: (context, index) {
                          final m = candidates[index];
                          final isSelected = tempSelected.containsKey(m.id);
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: AvatarColorGen.fromString(m.id),
                              child: Text(m.initials, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            title: Text(m.nameEn),
                            subtitle: Text(m.rankNameEn),
                            trailing: isSelected
                                ? SizedBox(
                                    width: 110,
                                    child: TextFormField(
                                      initialValue: tempSelected[m.id],
                                      decoration: const InputDecoration(hintText: 'Role', isDense: true),
                                      onChanged: (v) => tempSelected[m.id] = v,
                                    ),
                                  )
                                : null,
                            onTap: () => setSheetState(() {
                              if (isSelected) {
                                tempSelected.remove(m.id);
                              } else {
                                tempSelected[m.id] = 'Member';
                              }
                            }),
                            selected: isSelected,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _committee.clear();
        _committee.addAll(result.entries.map((e) => ClassCommitteeMember(memberId: e.key, role: e.value)));
      });
    }
  }

  void _addFeedbackQuestion(FeedbackQuestionType type) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(type == FeedbackQuestionType.rating ? 'Add Rating Question' : 'Add Text Question'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _feedbackQuestions.add(FeedbackQuestion(
          id: 'fq_${DateTime.now().microsecondsSinceEpoch}',
          text: result,
          type: type,
        ));
      });
    }
  }

  void _removeFeedbackQuestion(int index) {
    setState(() => _feedbackQuestions.removeAt(index));
  }

  void _save(AuthProvider auth, {bool publish = false}) {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set the start and end dates')),
      );
      return;
    }
    if (_instructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an instructor')),
      );
      return;
    }

    final instructor = MockMembers.findById(_instructorId!);
    if (!auth.canCreateClassForUnit(instructor?.companyNo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to create a class for this unit')),
      );
      return;
    }

    final classId = widget.trainingClass?.id ?? 'class_${DateTime.now().microsecondsSinceEpoch}';
    final maxParticipants = int.tryParse(_maxParticipantsCtrl.text.trim()) ?? 20;
    final classTitle = _titleCtrl.text.trim();

    // Resolve any pending, on-time nomination lists matching this
    // class's exact title — only for brand-new classes, not edits
    // (a nomination list is fulfilled once, at creation time, not
    // re-checked every time the class is edited afterward).
    var enrolledMemberIds = List<String>.from(widget.trainingClass?.enrolledMemberIds ?? const []);
    if (!_isEdit) {
      final nominatedIds = MockNominationLists.resolveNominationsForNewClass(classId, classTitle);
      final newlyEligible = nominatedIds.where((memberId) {
        if (enrolledMemberIds.contains(memberId)) return false; // already added manually
        if (enrolledMemberIds.length >= maxParticipants) return false; // class full
        final m = MockMembers.findById(memberId);
        if (m == null) return false;
        // Required skills: nominee must already hold every skill
        // this class requires, same as any other enrollment.
        if (_requiredSkillIds.isNotEmpty && !_requiredSkillIds.every((s) => m.skillIds.contains(s))) {
          return false;
        }
        // Already-has-certificate exclusion, same rule as the
        // member-facing "Request to Join" check.
        if (MockCertificates.hasCertificateMatching(memberId, classTitle)) return false;
        return true;
      }).toList();

      // Respect the remaining max-participants headroom even across
      // multiple nominees being added in this same pass.
      for (final memberId in newlyEligible) {
        if (enrolledMemberIds.length >= maxParticipants) break;
        enrolledMemberIds.add(memberId);
      }

      final skippedCount = nominatedIds.length - newlyEligible.length;
      if (nominatedIds.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            '${newlyEligible.length} nominated member(s) auto-enrolled'
            '${skippedCount > 0 ? ' ($skippedCount skipped — not eligible)' : ''}',
          )),
        );
      }
    }

    ClassBudget? budget;
    if (_hasBudget) {
      final totalAmount = double.tryParse(_totalBudgetCtrl.text.trim()) ?? 0;
      budget = ClassBudget(
        id: widget.trainingClass?.budget?.id ?? 'budget_${DateTime.now().microsecondsSinceEpoch}',
        classId: classId,
        totalAmount: totalAmount,
        fundingSource: _fundingSource,
        categoryAllocations: widget.trainingClass?.budget?.categoryAllocations ?? const {},
        memberLunchAllowed: widget.trainingClass?.budget?.memberLunchAllowed ?? false,
        memberTravelAllowed: widget.trainingClass?.budget?.memberTravelAllowed ?? false,
        approvalStatus: widget.trainingClass?.budget?.approvalStatus ?? 'pending',
        expenses: widget.trainingClass?.budget?.expenses ?? const [],
      );
    }

    final trainingClass = TrainingClass(
      id: classId,
      title: classTitle,
      titleMm: _titleMmCtrl.text.trim(),
      type: _type,
      category: _categoryCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      instructorId: _instructorId!,
      instructorName: instructor?.nameEn ?? _instructorId!,
      isExternalInstructor: _isExternalInstructor,
      startDate: _startDate!,
      endDate: _endDate!,
      location: _locationCtrl.text.trim(),
      maxParticipants: maxParticipants,
      enrolledMemberIds: enrolledMemberIds,
      status: widget.trainingClass?.status ?? (publish ? ClassStatus.open : ClassStatus.draft),
      requiredSkillIds: _requiredSkillIds.toList(),
      awardedSkillIds: _awardedSkillIds.toList(),
      issuesCertificate: _issuesCertificate,
      certificateTemplateId: widget.trainingClass?.certificateTemplateId,
      hasCommittee: _hasCommittee,
      committee: _hasCommittee ? _committee : const [],
      budget: budget,
      timetable: _sessions,
      minRankRequired: widget.trainingClass?.minRankRequired,
      videoUrl: _videoUrlCtrl.text.trim().isEmpty ? null : _videoUrlCtrl.text.trim(),
      feedbackQuestions: _feedbackQuestions,
    );

    if (_isEdit) {
      MockClasses.update(trainingClass);
    } else {
      MockClasses.add(trainingClass);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit
          ? 'Class updated'
          : (publish ? 'Class created and published' : 'Class saved as draft'))),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Class' : 'Create Class'),
        actions: [
          TextButton(
            onPressed: () => _save(auth),
            child: Text(
              _isEdit ? 'SAVE' : 'SAVE DRAFT',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard('Class Details', [
              _textField(_titleCtrl, 'Title (English)', required: true),
              _textField(_titleMmCtrl, 'Title (Myanmar)'),
              _typeDropdown(),
              _textField(_categoryCtrl, 'Category (e.g. Medical, Disaster)', required: true),
              _textField(_descriptionCtrl, 'Description', maxLines: 3, required: true),
            ]),
            _sectionCard('Instructor', [
              _instructorDropdown(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('External Instructor'),
                value: _isExternalInstructor,
                onChanged: (v) => setState(() => _isExternalInstructor = v),
              ),
            ]),
            _sectionCard('Schedule', [
              _dateField('Start Date', _startDate, () => _pickDate(isStart: true)),
              _dateField('End Date', _endDate, () => _pickDate(isStart: false)),
              _textField(_locationCtrl, 'Location', required: true),
              _textField(_maxParticipantsCtrl, 'Max Participants', isNumber: true, required: true),
            ]),
            _sectionCard('Timetable', [
              ..._sessions.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 10))),
                  title: Text(s.topic.isEmpty ? 'Tap to set topic' : s.topic, style: AppTextStyles.bodySmall),
                  subtitle: Text(AppFormatters.date(s.date), style: AppTextStyles.labelSmall),
                  onTap: () => _editSessionTopic(i),
                  trailing: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _removeSession(i)),
                );
              }),
              OutlinedButton.icon(
                onPressed: _addSession,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Session'),
              ),
            ]),
            _sectionCard('Skills', [
              Text('Required to enroll', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
              const SizedBox(height: 6),
              _skillChips(_requiredSkillIds),
              const SizedBox(height: 12),
              Text('Awarded on completion', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
              const SizedBox(height: 6),
              _skillChips(_awardedSkillIds),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Issues Certificate on Completion'),
                value: _issuesCertificate,
                onChanged: (v) => setState(() => _issuesCertificate = v),
              ),
            ]),
            _sectionCard('Committee', [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('This class has a committee'),
                value: _hasCommittee,
                onChanged: (v) => setState(() => _hasCommittee = v),
              ),
              if (_hasCommittee) ...[
                OutlinedButton.icon(
                  onPressed: _openCommitteeSheet,
                  icon: const Icon(Icons.groups_outlined, size: 18),
                  label: Text('Manage Committee (${_committee.length})'),
                ),
                ..._committee.map((cm) {
                  final m = MockMembers.findById(cm.memberId);
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(m?.nameEn ?? cm.memberId, style: AppTextStyles.bodySmall),
                    trailing: Text(cm.role, style: AppTextStyles.labelSmall),
                  );
                }),
              ],
            ]),
            _sectionCard('Budget', [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('This class has a budget'),
                value: _hasBudget,
                onChanged: (v) => setState(() => _hasBudget = v),
              ),
              if (_hasBudget) ...[
                _textField(_totalBudgetCtrl, 'Total Amount (BHD)', isNumber: true),
                _fundingSourceDropdown(),
              ],
            ]),
            _sectionCard('Feedback Questions (optional)', [
              Text(
                'Define what to ask students after this class. If left empty, no feedback form will be offered.',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 8),
              ..._feedbackQuestions.asMap().entries.map((entry) {
                final i = entry.key;
                final q = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    q.type == FeedbackQuestionType.rating ? Icons.star_outline : Icons.short_text,
                    size: 18,
                  ),
                  title: Text(q.text, style: AppTextStyles.bodySmall),
                  trailing: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _removeFeedbackQuestion(i)),
                );
              }),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addFeedbackQuestion(FeedbackQuestionType.rating),
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text('Rating Question'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addFeedbackQuestion(FeedbackQuestionType.text),
                      icon: const Icon(Icons.short_text, size: 18),
                      label: const Text('Text Question'),
                    ),
                  ),
                ],
              ),
            ]),
            _sectionCard('Online Video Lesson (optional)', [
              _textField(_videoUrlCtrl, 'YouTube Private Link'),
              Text(
                'Use a YouTube "Private" video link — only viewable by people with this exact link.',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
              ),
            ]),
            const SizedBox(height: 24),
            if (_isEdit)
              ElevatedButton(
                onPressed: () => _save(auth),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Save Changes'),
              )
            else ...[
              ElevatedButton(
                onPressed: () => _save(auth, publish: true),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Create & Publish'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _save(auth),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Save as Draft'),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              ...children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label,
      {bool required = false, int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(value == null ? 'Select date' : '${value.day}/${value.month}/${value.year}'),
      ),
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<ClassType>(
      initialValue: _type,
      decoration: const InputDecoration(labelText: 'Class Type', border: OutlineInputBorder()),
      items: ClassType.values.map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t)))).toList(),
      onChanged: (v) => setState(() => _type = v!),
    );
  }

  String _typeLabel(ClassType t) => switch (t) {
        ClassType.classRoom => 'Classroom',
        ClassType.workshop => 'Workshop',
        ClassType.seminar => 'Seminar',
        ClassType.drill => 'Drill',
        ClassType.other => 'Other',
      };

  Widget _instructorDropdown() {
    final candidates = MockMembers.all.where((m) => m.nameEn.isNotEmpty).toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));
    return DropdownButtonFormField<String>(
      initialValue: _instructorId,
      decoration: const InputDecoration(labelText: 'Instructor', border: OutlineInputBorder()),
      items: candidates.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nameEn))).toList(),
      onChanged: (v) => setState(() => _instructorId = v),
    );
  }

  Widget _fundingSourceDropdown() {
    return DropdownButtonFormField<FundingSource>(
      initialValue: _fundingSource,
      decoration: const InputDecoration(labelText: 'Funding Source', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: FundingSource.organizationFund, child: Text('Organization Fund')),
        DropdownMenuItem(value: FundingSource.externalGrant, child: Text('External Grant')),
        DropdownMenuItem(value: FundingSource.jointFunding, child: Text('Joint Funding')),
        DropdownMenuItem(value: FundingSource.custom, child: Text('Custom')),
      ],
      onChanged: (v) => setState(() => _fundingSource = v!),
    );
  }

  Widget _skillChips(Set<String> selectedIds) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MockSkills.all.map((skill) {
        final isSelected = selectedIds.contains(skill.id);
        return FilterChip(
          label: Text(skill.nameEn),
          selected: isSelected,
          onSelected: (v) => setState(() {
            if (v) {
              selectedIds.add(skill.id);
            } else {
              selectedIds.remove(skill.id);
            }
          }),
        );
      }).toList(),
    );
  }
}