import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/permission_service.dart';
import '../auth/auth_provider.dart';
import 'event_position_form_screen.dart';
import 'event_route_form_screen.dart';
import '../access/request_access_link.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;
  late Duty _hostDuty;
  EventPosition? _selectedPosition;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _event = MockEvents.findById(widget.eventId)!;
    _hostDuty = MockDuties.findById(_event.dutyId)!;
  }

  Color _positionColor(EventPositionType type) {
    switch (type) {
      case EventPositionType.command: return Colors.purple;
      case EventPositionType.point: return Colors.red;
      case EventPositionType.patrol: return Colors.orange;
      case EventPositionType.standby: return Colors.blueGrey;
      case EventPositionType.base: return Colors.green;
      case EventPositionType.liaison: return Colors.teal;
    }
  }

  IconData _positionIcon(EventPositionType type) {
    switch (type) {
      case EventPositionType.command: return Icons.flag;
      case EventPositionType.point: return Icons.medical_services;
      case EventPositionType.patrol: return Icons.directions_walk;
      case EventPositionType.standby: return Icons.pause_circle;
      case EventPositionType.base: return Icons.home_work;
      case EventPositionType.liaison: return Icons.connect_without_contact;
    }
  }

  /// Parses an EventRoute's optional colorHex (e.g. "#1D9E75") into a
  /// Color, falling back to the app's primary color if not set or
  /// unparsable.
  Color _routeColor(EventRoute route) {
    final hex = route.colorHex;
    if (hex == null) return AppColors.primary;
    try {
      final cleaned = hex.replaceFirst('#', '');
      final value = int.parse('FF$cleaned', radix: 16);
      return Color(value);
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _onPinTapped(EventPosition position) {
    setState(() => _selectedPosition = position);
    if (position.latitude != null && position.longitude != null) {
      _mapController.move(
        LatLng(position.latitude!, position.longitude!),
        _mapController.camera.zoom,
      );
    }
  }

  Future<void> _openAssignSheet(EventPosition position, AuthProvider auth) async {
    if (!auth.canAssignToPosition(_hostDuty)) return;

    final dutyMemberIds = _hostDuty.members.map((dm) => dm.memberId).toSet();
    final candidates = MockMembers.all.where((m) {
      if (!dutyMemberIds.contains(m.id)) return false; // must be on the duty roster
      if (position.requiredSkillIds.isEmpty) return true;
      return position.requiredSkillIds.any((skillId) => m.skillIds.contains(skillId));
    }).toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));

    final selected = Set<String>.from(position.assignedMemberIds);

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
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
                          Expanded(
                            child: Text(
                              'Assign — ${position.nameEn}',
                              style: AppTextStyles.headingSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext, selected),
                            child: Text('Done (${selected.length}/${position.requiredMembers})'),
                          ),
                        ],
                      ),
                    ),
                    if (position.requiredSkillIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Showing duty members with required skills',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: candidates.isEmpty
                          ? Center(
                              child: Text(
                                'No eligible members on this duty roster match the required skills.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: candidates.length,
                              itemBuilder: (context, index) {
                                final m = candidates[index];
                                final isSelected = selected.contains(m.id);
                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (v) => setSheetState(() {
                                    if (v == true) {
                                      selected.add(m.id);
                                    } else {
                                      selected.remove(m.id);
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
        final index = _event.positions.indexWhere((p) => p.id == position.id);
        if (index != -1) {
          _event.positions[index] = EventPosition(
            id: position.id,
            eventId: position.eventId,
            nameEn: position.nameEn,
            type: position.type,
            locationDescription: position.locationDescription,
            latitude: position.latitude,
            longitude: position.longitude,
            requiredMembers: position.requiredMembers,
            assignedMemberIds: result.toList(),
            requiredSkillIds: position.requiredSkillIds,
            equipmentIds: position.equipmentIds,
          );
          if (_selectedPosition?.id == position.id) {
            _selectedPosition = _event.positions[index];
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position assignment updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage = auth.canManageEvent;
    final canAssign = auth.canAssignToPosition(_hostDuty);
    final positionsWithCoords = _event.positions
        .where((p) => p.latitude != null && p.longitude != null)
        .toList();

    final center = _event.latitude != null && _event.longitude != null
        ? LatLng(_event.latitude!, _event.longitude!)
        : const LatLng(16.7733, 96.1689); // fallback: Botahtaung area

    return Scaffold(
      appBar: AppBar(
        title: Text(_event.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (canManage)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add_position') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventPositionFormScreen(eventId: _event.id),
                    ),
                  ).then((saved) {
                    if (saved == true) {
                      setState(() {
                        _event = MockEvents.findById(widget.eventId)!;
                      });
                    }
                  });
                }
                if (value == 'manage_routes') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventRouteFormScreen(event: _event),
                    ),
                  ).then((updated) {
                    if (updated == true) {
                      setState(() {
                        _event = MockEvents.findById(widget.eventId)!;
                      });
                    }
                  });
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'add_position', child: Text('Add Position')),
                PopupMenuItem(value: 'manage_routes', child: Text('Manage Routes')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          if (!canManage)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: RequestAccessLink(featureName: 'Events — Manage Positions & Routes'),
            ),
          Expanded(
            flex: 4,
            child: positionsWithCoords.isEmpty
                ? _buildNoMapState()
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 14.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'mm.redcross.botahtaung',
                      ),
                      if (_event.routes.isNotEmpty)
                        PolylineLayer(
                          polylines: _event.routes
                              .where((r) => r.hasEnoughPointsToDraw)
                              .map((r) => Polyline(
                                    points: r.waypoints
                                        .map((w) => LatLng(w.latitude, w.longitude))
                                        .toList(),
                                    color: _routeColor(r),
                                    strokeWidth: 4,
                                  ))
                              .toList(),
                        ),
                      // Patrol positions with their own defined path
                      // (a route segment or custom path) — rendered in
                      // orange to visually distinguish "this patrol's
                      // specific stretch" from the full event route(s)
                      // above. A patrol with no path defined just
                      // shows as a normal pin, covering its single
                      // point only.
                      if (_event.positions.any((p) => p.hasPatrolPath))
                        PolylineLayer(
                          polylines: _event.positions
                              .where((p) => p.hasPatrolPath)
                              .map((p) => Polyline(
                                    points: p.patrolPath
                                        .map((w) => LatLng(w.latitude, w.longitude))
                                        .toList(),
                                    color: Colors.orange,
                                    strokeWidth: 3,
                                  ))
                              .toList(),
                        ),
                      MarkerLayer(
                        markers: positionsWithCoords.map((p) {
                          final isSelected = _selectedPosition?.id == p.id;
                          return Marker(
                            point: LatLng(p.latitude!, p.longitude!),
                            width: isSelected ? 48 : 38,
                            height: isSelected ? 48 : 38,
                            child: GestureDetector(
                              onTap: () => _onPinTapped(p),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _positionColor(p.type),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4),
                                  ],
                                ),
                                child: Icon(
                                  _positionIcon(p.type),
                                  color: Colors.white,
                                  size: isSelected ? 24 : 18,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ),
          Expanded(
            flex: 5,
            child: _buildPositionList(canAssign),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMapState() {
    return Container(
      color: AppColors.grey50.withValues(alpha: 0.1),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, size: 40, color: AppColors.grey500),
              const SizedBox(height: 12),
              Text(
                'No positions added yet',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'The map will appear once you add at least one position with a location. Use the menu (⋮) above to add a position or draw a route.',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_event.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '${AppFormatters.date(_event.date)} · ${_event.startTimeDisplay} · ${_event.location}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_event.totalAssigned}/${_event.totalRequired}',
                style: AppTextStyles.headingSmall.copyWith(
                  color: _event.allPositionsFilled ? Colors.green : Colors.orange,
                ),
              ),
              Text('assigned', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionList(bool canAssign) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: _event.positions.length,
      itemBuilder: (context, index) {
        final p = _event.positions[index];
        final isSelected = _selectedPosition?.id == p.id;
        return Card(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : null,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () => setState(() => _selectedPosition = p),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: _positionColor(p.type),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_positionIcon(p.type), color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nameEn, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                            Text(p.locationDescription, style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: p.isFilled
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${p.assignedMemberIds.length}/${p.requiredMembers}',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold,
                            color: p.isFilled ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (p.assignedMemberIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: p.assignedMemberIds.map((id) {
                        final m = MockMembers.findById(id);
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: AvatarColorGen.fromString(id),
                            child: Text(m?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 9)),
                          ),
                          label: Text(m?.nameEn ?? id, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                  if (canAssign) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _openAssignSheet(p, context.read<AuthProvider>()),
                        icon: const Icon(Icons.person_add_outlined, size: 16),
                        label: const Text('Assign'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
