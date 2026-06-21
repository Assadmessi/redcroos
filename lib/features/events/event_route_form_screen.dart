import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';

class EventRouteFormScreen extends StatefulWidget {
  final Event event;
  const EventRouteFormScreen({super.key, required this.event});

  @override
  State<EventRouteFormScreen> createState() => _EventRouteFormScreenState();
}

class _EventRouteFormScreenState extends State<EventRouteFormScreen> {
  late List<EventRoute> _routes;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _routes = List<EventRoute>.from(widget.event.routes);
  }

  void _addRoute() async {
    final result = await Navigator.push<EventRoute>(
      context,
      MaterialPageRoute(
        builder: (_) => _RouteEditorScreen(event: widget.event),
      ),
    );
    if (result != null) {
      setState(() {
        _routes.add(result);
        _changed = true;
      });
    }
  }

  void _editRoute(EventRoute route) async {
    final result = await Navigator.push<EventRoute>(
      context,
      MaterialPageRoute(
        builder: (_) => _RouteEditorScreen(event: widget.event, existing: route),
      ),
    );
    if (result != null) {
      setState(() {
        final index = _routes.indexWhere((r) => r.id == route.id);
        if (index != -1) _routes[index] = result;
        _changed = true;
      });
    }
  }

  void _deleteRoute(EventRoute route) {
    setState(() {
      _routes.removeWhere((r) => r.id == route.id);
      _changed = true;
    });
  }

  void _done() {
    if (_changed) {
      // Actually persist the updated route list back into MockEvents —
      // without this, the routes drawn in this screen only ever
      // existed in this screen's local _routes list and were
      // discarded on pop, which is why they never showed up on the
      // event detail map or the position-picker map.
      MockEvents.update(Event(
        id: widget.event.id,
        dutyId: widget.event.dutyId,
        title: widget.event.title,
        titleMm: widget.event.titleMm,
        date: widget.event.date,
        startHour: widget.event.startHour,
        startMinute: widget.event.startMinute,
        endHour: widget.event.endHour,
        endMinute: widget.event.endMinute,
        location: widget.event.location,
        latitude: widget.event.latitude,
        longitude: widget.event.longitude,
        description: widget.event.description,
        positions: widget.event.positions,
        routes: _routes,
        status: widget.event.status,
      ));
    }
    Navigator.pop(context, _changed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routes'),
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text('DONE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _routes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No routes yet. Add a route to draw a path on the event map (e.g. the marathon course).',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: _parseColor(route.colorHex),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(route.name),
                    subtitle: Text('${route.waypoints.length} waypoints'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _editRoute(route),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => _deleteRoute(route),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRoute,
        icon: const Icon(Icons.add),
        label: const Text('Add Route'),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ROUTE EDITOR — tap-to-draw map (primary) + manual entry (fallback)
// ═══════════════════════════════════════════════════════════════
class _RouteEditorScreen extends StatefulWidget {
  final Event event;
  final EventRoute? existing;
  const _RouteEditorScreen({required this.event, this.existing});

  @override
  State<_RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<_RouteEditorScreen> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late List<RouteWaypoint> _waypoints;
  bool _manualEntryMode = false;
  String _selectedColorHex = '#1D9E75';

  final _manualLatCtrl = TextEditingController();
  final _manualLngCtrl = TextEditingController();
  final _manualLabelCtrl = TextEditingController();

  static const _colorOptions = ['#1D9E75', '#378ADD', '#E24B4A', '#BA7517', '#7F77DD'];

  /// Other routes already saved for this event, excluding the one
  /// currently being created/edited — shown dimmed on the map as
  /// context so the new route isn't drawn on a disconnected blank map.
  List<EventRoute> get _otherRoutes {
    return widget.event.routes
        .where((r) =>
            r.id != widget.existing?.id && r.hasEnoughPointsToDraw)
        .toList();
  }

  Color _parseColorHex(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  void initState() {
    super.initState();
    _waypoints = List<RouteWaypoint>.from(widget.existing?.waypoints ?? []);
    if (widget.existing?.colorHex != null) {
      _selectedColorHex = widget.existing!.colorHex!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _manualLatCtrl.dispose();
    _manualLngCtrl.dispose();
    _manualLabelCtrl.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _waypoints.add(RouteWaypoint(latitude: point.latitude, longitude: point.longitude));
    });
  }

  void _addManualWaypoint() {
    final lat = double.tryParse(_manualLatCtrl.text.trim());
    final lng = double.tryParse(_manualLngCtrl.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid latitude and longitude numbers')),
      );
      return;
    }
    setState(() {
      _waypoints.add(RouteWaypoint(
        latitude: lat,
        longitude: lng,
        label: _manualLabelCtrl.text.trim().isEmpty ? null : _manualLabelCtrl.text.trim(),
      ));
      _manualLatCtrl.clear();
      _manualLngCtrl.clear();
      _manualLabelCtrl.clear();
    });
  }

  void _removeWaypoint(int index) {
    setState(() => _waypoints.removeAt(index));
  }

  void _undoLastWaypoint() {
    if (_waypoints.isNotEmpty) {
      setState(() => _waypoints.removeLast());
    }
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a route name')),
      );
      return;
    }
    if (_waypoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 2 waypoints to draw a route')),
      );
      return;
    }

    final route = EventRoute(
      id: widget.existing?.id ?? 'route_${DateTime.now().microsecondsSinceEpoch}',
      eventId: widget.event.id,
      name: _nameCtrl.text.trim(),
      colorHex: _selectedColorHex,
      waypoints: _waypoints,
    );
    Navigator.pop(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final fallbackCenter = widget.event.latitude != null && widget.event.longitude != null
        ? LatLng(widget.event.latitude!, widget.event.longitude!)
        : const LatLng(16.7733, 96.1689);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Route' : 'Edit Route'),
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
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Route Name (e.g. Main Route, Detour B)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Color:', style: AppTextStyles.bodySmall),
                    const SizedBox(width: 8),
                    ..._colorOptions.map((hex) {
                      final isSelected = _selectedColorHex == hex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedColorHex = hex),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16)),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Tap Map'), icon: Icon(Icons.touch_app_outlined)),
                      ButtonSegment(value: true, label: Text('Manual Entry'), icon: Icon(Icons.edit_note_outlined)),
                    ],
                    selected: {_manualEntryMode},
                    onSelectionChanged: (s) => setState(() => _manualEntryMode = s.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (!_manualEntryMode) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tap the map to add waypoints in order. ${_waypoints.length} added.',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _waypoints.isNotEmpty
                          ? LatLng(_waypoints.first.latitude, _waypoints.first.longitude)
                          : fallbackCenter,
                      initialZoom: 14.5,
                      onTap: (tapPosition, point) => _onMapTap(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'mm.redcross.botahtaung',
                      ),
                      // Other already-saved routes for this event, shown
                      // dimmed as context so the new/edited route isn't
                      // drawn on a disconnected blank map.
                      if (_otherRoutes.isNotEmpty)
                        PolylineLayer(
                          polylines: _otherRoutes
                              .map((r) => Polyline(
                                    points: r.waypoints
                                        .map((w) => LatLng(w.latitude, w.longitude))
                                        .toList(),
                                    color: _parseColorHex(r.colorHex).withValues(alpha: 0.4),
                                    strokeWidth: 3,
                                  ))
                              .toList(),
                        ),
                      // Existing positions for this event (aid stations,
                      // command post, etc.), shown as small grey dots.
                      if (widget.event.positions.isNotEmpty)
                        MarkerLayer(
                          markers: widget.event.positions
                              .where((p) => p.latitude != null && p.longitude != null)
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
                      if (_waypoints.length >= 2)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _waypoints.map((w) => LatLng(w.latitude, w.longitude)).toList(),
                              color: Color(int.parse('FF${_selectedColorHex.replaceFirst('#', '')}', radix: 16)),
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
                            width: 28, height: 28,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isFirst ? Colors.green : (isLast ? Colors.red : Colors.white),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black54, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold,
                                    color: (isFirst || isLast) ? Colors.white : Colors.black,
                                  ),
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
                onPressed: _waypoints.isEmpty ? null : _undoLastWaypoint,
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('Undo Last Waypoint'),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualLatCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _manualLngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _manualLabelCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Label (optional, e.g. "Turn onto Pansodan St")',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _addManualWaypoint,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Waypoint'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _waypoints.isEmpty
                  ? Center(
                      child: Text(
                        'No waypoints added yet.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _waypoints.length,
                      itemBuilder: (context, index) {
                        final w = _waypoints[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary,
                            child: Text('${index + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                          title: Text(
                            '${w.latitude.toStringAsFixed(5)}, ${w.longitude.toStringAsFixed(5)}',
                          ),
                          subtitle: w.label != null ? Text(w.label!) : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _removeWaypoint(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}