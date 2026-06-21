import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';

class EventPositionFormScreen extends StatefulWidget {
  final String eventId;
  final EventPosition? position; // null = create new, non-null = edit
  const EventPositionFormScreen({super.key, required this.eventId, this.position});

  @override
  State<EventPositionFormScreen> createState() => _EventPositionFormScreenState();
}

class _EventPositionFormScreenState extends State<EventPositionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.position != null;

  late final _nameCtrl = TextEditingController(text: widget.position?.nameEn ?? '');
  late final _locationCtrl =
      TextEditingController(text: widget.position?.locationDescription ?? '');
  late final _requiredMembersCtrl =
      TextEditingController(text: widget.position?.requiredMembers.toString() ?? '2');

  EventPositionType _type = EventPositionType.point;
  LatLng? _pickedLocation;
  final Set<String> _selectedSkillIds = {};
  final Set<String> _selectedMemberIds = {};
  List<RouteWaypoint> _patrolPath = [];
  final Set<String> _selectedEquipmentIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.position != null) {
      _type = widget.position!.type;
      if (widget.position!.latitude != null && widget.position!.longitude != null) {
        _pickedLocation = LatLng(widget.position!.latitude!, widget.position!.longitude!);
      }
      _selectedSkillIds.addAll(widget.position!.requiredSkillIds);
      _selectedEquipmentIds.addAll(widget.position!.equipmentIds);
      _selectedMemberIds.addAll(widget.position!.assignedMemberIds);
      _patrolPath = List<RouteWaypoint>.from(widget.position!.patrolPath);
    } else {
      final event = MockEvents.findById(widget.eventId);
      if (event?.latitude != null && event?.longitude != null) {
        _pickedLocation = LatLng(event!.latitude!, event.longitude!);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _requiredMembersCtrl.dispose();
    super.dispose();
  }

  /// Lets the user pick an existing event route, then mark a start
  /// and end waypoint along it — the patrol path becomes that
  /// sub-range of the route's waypoints, NOT the full route.
  Future<void> _pickRouteSegment() async {
    final event = MockEvents.findById(widget.eventId);
    final routes = event?.routes.where((r) => r.hasEnoughPointsToDraw).toList() ?? [];

    if (routes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No routes have been drawn for this event yet. Use "Manage Routes" on the event screen first, or draw a custom path instead.')),
      );
      return;
    }

    final result = await showModalBottomSheet<List<RouteWaypoint>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        EventRoute selectedRoute = routes.first;
        int startIndex = 0;
        int endIndex = selectedRoute.waypoints.length - 1;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Route Segment', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<EventRoute>(
                        initialValue: selectedRoute,
                        decoration: const InputDecoration(labelText: 'Route', border: OutlineInputBorder()),
                        items: routes
                            .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                            .toList(),
                        onChanged: (r) => setSheetState(() {
                          selectedRoute = r!;
                          startIndex = 0;
                          endIndex = selectedRoute.waypoints.length - 1;
                        }),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start waypoint: ${startIndex + 1} of ${selectedRoute.waypoints.length}',
                        style: AppTextStyles.bodySmall,
                      ),
                      Slider(
                        value: startIndex.toDouble(),
                        min: 0,
                        max: (selectedRoute.waypoints.length - 1).toDouble(),
                        divisions: selectedRoute.waypoints.length > 1
                            ? selectedRoute.waypoints.length - 1
                            : null,
                        onChanged: (v) => setSheetState(() {
                          startIndex = v.round();
                          if (startIndex >= endIndex) endIndex = startIndex + 1;
                          if (endIndex > selectedRoute.waypoints.length - 1) {
                            endIndex = selectedRoute.waypoints.length - 1;
                          }
                        }),
                      ),
                      Text(
                        'End waypoint: ${endIndex + 1} of ${selectedRoute.waypoints.length}',
                        style: AppTextStyles.bodySmall,
                      ),
                      Slider(
                        value: endIndex.toDouble(),
                        min: 0,
                        max: (selectedRoute.waypoints.length - 1).toDouble(),
                        divisions: selectedRoute.waypoints.length > 1
                            ? selectedRoute.waypoints.length - 1
                            : null,
                        onChanged: (v) => setSheetState(() {
                          endIndex = v.round();
                          if (endIndex <= startIndex) startIndex = endIndex - 1;
                          if (startIndex < 0) startIndex = 0;
                        }),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: startIndex < endIndex
                            ? () => Navigator.pop(
                                  sheetContext,
                                  selectedRoute.waypoints.sublist(startIndex, endIndex + 1),
                                )
                            : null,
                        child: const Text('Use This Segment'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _patrolPath = result);
    }
  }

  /// Lets the user draw a completely independent path just for this
  /// patrol position, separate from any event route — same
  /// tap-to-draw map used for event routes.
  Future<void> _drawCustomPatrolPath() async {
    final result = await Navigator.push<List<RouteWaypoint>>(
      context,
      MaterialPageRoute(
        builder: (_) => _PatrolPathDrawScreen(
          eventId: widget.eventId,
          initialPath: _patrolPath,
        ),
      ),
    );
    if (result != null) {
      setState(() => _patrolPath = result);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap the map to set this position\'s location')),
      );
      return;
    }

    final event = MockEvents.findById(widget.eventId);
    if (event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find this event — please go back and try again')),
      );
      return;
    }

    final requiredMembers = int.tryParse(_requiredMembersCtrl.text.trim()) ?? 2;
    final positionId = widget.position?.id ?? 'pos_${DateTime.now().microsecondsSinceEpoch}';

    final position = EventPosition(
      id: positionId,
      eventId: widget.eventId,
      nameEn: _nameCtrl.text.trim(),
      type: _type,
      locationDescription: _locationCtrl.text.trim(),
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
      requiredMembers: requiredMembers,
      assignedMemberIds: _selectedMemberIds.toList(),
      requiredSkillIds: _selectedSkillIds.toList(),
      equipmentIds: _selectedEquipmentIds.toList(),
      patrolPath: _type == EventPositionType.patrol ? _patrolPath : const [],
    );

    // Actually persist the position into the event's position list —
    // this was the root cause of positions not appearing after save:
    // the form built nothing and never called MockEvents.update().
    final updatedPositions = List<EventPosition>.from(event.positions);
    final existingIndex = updatedPositions.indexWhere((p) => p.id == positionId);
    if (existingIndex != -1) {
      updatedPositions[existingIndex] = position;
    } else {
      updatedPositions.add(position);
    }

    MockEvents.update(Event(
      id: event.id,
      dutyId: event.dutyId,
      title: event.title,
      titleMm: event.titleMm,
      date: event.date,
      startHour: event.startHour,
      startMinute: event.startMinute,
      endHour: event.endHour,
      endMinute: event.endMinute,
      location: event.location,
      latitude: event.latitude,
      longitude: event.longitude,
      description: event.description,
      positions: updatedPositions,
      routes: event.routes,
      status: event.status,
    ));

    // Show the snackbar BEFORE popping — Navigator.pop() unmounts
    // this widget, and using its `context` afterward can throw
    // "widget has been unmounted".
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Position updated' : 'Position created')),
    );
    Navigator.pop(context, true);
  }

  String _typeLabel(EventPositionType t) => switch (t) {
        EventPositionType.base => 'Base',
        EventPositionType.point => 'Point',
        EventPositionType.patrol => 'Patrol',
        EventPositionType.standby => 'Standby',
        EventPositionType.command => 'Command',
        EventPositionType.liaison => 'Liaison',
      };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Position' : 'Add Position'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard('Position Details', [
              _textField(_nameCtrl, 'Position Name (e.g. Aid Station 1)', required: true),
              _typeDropdown(),
              _textField(_locationCtrl, 'Location Description', required: true),
              _textField(_requiredMembersCtrl, 'Required Members', required: true, isNumber: true),
            ]),
            _sectionCard('Map Location — tap to set', [
              _buildLocationPicker(),
              if (_pickedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Lat: ${_pickedLocation!.latitude.toStringAsFixed(5)}, '
                    'Lng: ${_pickedLocation!.longitude.toStringAsFixed(5)}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                ),
            ]),
            if (_type == EventPositionType.patrol)
              _sectionCard('Patrol Path (optional)', [
                Text(
                  'If this patrol covers a specific stretch rather than the full '
                  'event route, define it here — either as a segment of an '
                  'existing route, or as its own separate path.',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickRouteSegment,
                        icon: const Icon(Icons.linear_scale, size: 18),
                        label: const Text('Select Route Segment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _drawCustomPatrolPath,
                        icon: const Icon(Icons.edit_road, size: 18),
                        label: const Text('Draw Custom Path'),
                      ),
                    ),
                  ],
                ),
                if (_patrolPath.length >= 2) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.route, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Patrol path set — ${_patrolPath.length} waypoints',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _patrolPath = []),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'No path set — this patrol will cover only the single '
                      'point above, not a route.',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                    ),
                  ),
              ]),
            _sectionCard('Required Skills', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MockSkills.all.map((skill) {
                  final isSelected = _selectedSkillIds.contains(skill.id);
                  return FilterChip(
                    label: Text(skill.nameEn),
                    selected: isSelected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedSkillIds.add(skill.id);
                      } else {
                        _selectedSkillIds.remove(skill.id);
                      }
                    }),
                  );
                }).toList(),
              ),
            ]),
            _sectionCard('Equipment Needed', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MockEquipment.all.map((eq) {
                  final isSelected = _selectedEquipmentIds.contains(eq.id);
                  return FilterChip(
                    label: Text(eq.name),
                    selected: isSelected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedEquipmentIds.add(eq.id);
                      } else {
                        _selectedEquipmentIds.remove(eq.id);
                      }
                    }),
                  );
                }).toList(),
              ),
            ]),
            if (_hostDuty != null && auth.canAssignToPosition(_hostDuty!))
              _sectionCard('Assign Members', [
                if (_eligibleCandidates.isEmpty)
                  Text(
                    'No duty roster members match the required skills yet. '
                    'Add members to the duty first, or adjust required skills above.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  )
                else ...[
                  Text(
                    'Selected ${_selectedMemberIds.length}/${_requiredMembersCtrl.text} '
                    '— showing duty roster members matching required skills',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 8),
                  ..._eligibleCandidates.map((m) {
                    final isSelected = _selectedMemberIds.contains(m.id);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: isSelected,
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selectedMemberIds.add(m.id);
                        } else {
                          _selectedMemberIds.remove(m.id);
                        }
                      }),
                      secondary: CircleAvatar(
                        radius: 16,
                        backgroundColor: AvatarColorGen.fromString(m.id),
                        child: Text(m.initials,
                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      title: Text(m.nameEn),
                      subtitle: Text(m.rankNameEn),
                    );
                  }),
                ],
              ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_isEdit ? 'Save Changes' : 'Add Position'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    final event = MockEvents.findById(widget.eventId);
    final fallback = event?.latitude != null && event?.longitude != null
        ? LatLng(event!.latitude!, event.longitude!)
        : const LatLng(16.7733, 96.1689);

    // Show the event's existing routes and other already-placed
    // positions as context, so this isn't a disconnected blank map —
    // the new/edited position can be placed sensibly relative to the
    // route and other positions already drawn for this event.
    final existingRoutes = event?.routes.where((r) => r.hasEnoughPointsToDraw).toList() ?? [];
    final otherPositions = event?.positions
            .where((p) =>
                p.id != widget.position?.id &&
                p.latitude != null &&
                p.longitude != null)
            .toList() ??
        [];

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _pickedLocation ?? fallback,
            initialZoom: 15,
            onTap: (tapPosition, point) => setState(() => _pickedLocation = point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'mm.redcross.botahtaung',
            ),
            if (existingRoutes.isNotEmpty)
              PolylineLayer(
                polylines: existingRoutes
                    .map((r) => Polyline(
                          points: r.waypoints
                              .map((w) => LatLng(w.latitude, w.longitude))
                              .toList(),
                          color: _parseRouteColor(r.colorHex),
                          strokeWidth: 3,
                        ))
                    .toList(),
              ),
            if (otherPositions.isNotEmpty)
              MarkerLayer(
                markers: otherPositions
                    .map((p) => Marker(
                          point: LatLng(p.latitude!, p.longitude!),
                          width: 18,
                          height: 18,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            if (_pickedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation!,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// The Duty that hosts this event — needed to check
  /// canAssignToPosition (Master Access OR the duty's commander/
  /// officer) and to filter eligible candidates to the duty roster.
  Duty? get _hostDuty {
    final event = MockEvents.findById(widget.eventId);
    if (event == null) return null;
    return MockDuties.findById(event.dutyId);
  }

  /// Eligible candidates for assignment to this position: members on
  /// the host duty's roster, filtered to those matching at least one
  /// of the position's required skills (or everyone on the roster if
  /// no skills are required). Mirrors the filtering logic in
  /// EventDetailScreen's assign sheet, so behavior is consistent
  /// whether you assign inline here or later from the event map.
  List<Member> get _eligibleCandidates {
    final hostDuty = _hostDuty;
    if (hostDuty == null) return [];

    final dutyMemberIds = hostDuty.members.map((dm) => dm.memberId).toSet();
    final candidates = MockMembers.all.where((m) {
      if (!dutyMemberIds.contains(m.id)) return false;
      if (_selectedSkillIds.isEmpty) return true;
      return _selectedSkillIds.any((skillId) => m.skillIds.contains(skillId));
    }).toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));
    return candidates;
  }

  Color _parseRouteColor(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
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
              ...children.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: c,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label,
      {bool required = false, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<EventPositionType>(
      initialValue: _type,
      decoration: const InputDecoration(labelText: 'Position Type', border: OutlineInputBorder()),
      items: EventPositionType.values
          .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t))))
          .toList(),
      onChanged: (v) => setState(() => _type = v!),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PATROL PATH DRAW SCREEN
//
// A simplified tap-to-draw map, scoped to defining a single patrol
// position's independent path — separate from any event-wide route.
// Shows the event's existing routes and positions dimmed as context,
// same as the position picker and route editor.
// ═══════════════════════════════════════════════════════════════
class _PatrolPathDrawScreen extends StatefulWidget {
  final String eventId;
  final List<RouteWaypoint> initialPath;
  const _PatrolPathDrawScreen({required this.eventId, required this.initialPath});

  @override
  State<_PatrolPathDrawScreen> createState() => _PatrolPathDrawScreenState();
}

class _PatrolPathDrawScreenState extends State<_PatrolPathDrawScreen> {
  late List<RouteWaypoint> _waypoints;

  @override
  void initState() {
    super.initState();
    _waypoints = List<RouteWaypoint>.from(widget.initialPath);
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _waypoints.add(RouteWaypoint(latitude: point.latitude, longitude: point.longitude));
    });
  }

  void _undoLast() {
    if (_waypoints.isNotEmpty) setState(() => _waypoints.removeLast());
  }

  void _save() {
    if (_waypoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 2 waypoints to define a path')),
      );
      return;
    }
    Navigator.pop(context, _waypoints);
  }

  @override
  Widget build(BuildContext context) {
    final event = MockEvents.findById(widget.eventId);
    final fallback = event?.latitude != null && event?.longitude != null
        ? LatLng(event!.latitude!, event.longitude!)
        : const LatLng(16.7733, 96.1689);
    final existingRoutes = event?.routes.where((r) => r.hasEnoughPointsToDraw).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Patrol Path'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tap the map to add waypoints in order. ${_waypoints.length} added.',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _waypoints.isNotEmpty
                        ? LatLng(_waypoints.first.latitude, _waypoints.first.longitude)
                        : fallback,
                    initialZoom: 14.5,
                    onTap: (tapPosition, point) => _onMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'mm.redcross.botahtaung',
                    ),
                    if (existingRoutes.isNotEmpty)
                      PolylineLayer(
                        polylines: existingRoutes
                            .map((r) => Polyline(
                                  points: r.waypoints
                                      .map((w) => LatLng(w.latitude, w.longitude))
                                      .toList(),
                                  color: AppColors.grey500.withValues(alpha: 0.5),
                                  strokeWidth: 3,
                                ))
                            .toList(),
                      ),
                    if (_waypoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _waypoints.map((w) => LatLng(w.latitude, w.longitude)).toList(),
                            color: Colors.orange,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _waypoints.asMap().entries.map((entry) {
                        final i = entry.key;
                        final w = entry.value;
                        final isFirst = i == 0;
                        final isLast = i == _waypoints.length - 1;
                        return Marker(
                          point: LatLng(w.latitude, w.longitude),
                          width: 26,
                          height: 26,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFirst ? Colors.green : (isLast ? Colors.red : Colors.orange),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _waypoints.isEmpty ? null : _undoLast,
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Undo Last Waypoint'),
            ),
          ),
        ],
      ),
    );
  }
}