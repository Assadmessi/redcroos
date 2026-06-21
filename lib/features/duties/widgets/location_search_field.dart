import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_theme.dart';

/// A single geocoding suggestion from Nominatim.
class LocationSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;

  const LocationSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// A text field that searches real-world locations via Nominatim
/// (OpenStreetMap's free geocoding API, no key required) as the user
/// types, and lets them pick a suggestion to auto-fill the location
/// text plus its coordinates.
///
/// If nothing matches what they're looking for, they can simply keep
/// typing their own free-text location — manual entry always remains
/// available; suggestions are a convenience, not a requirement.
class LocationSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final void Function(LocationSuggestion suggestion)? onSuggestionSelected;

  const LocationSearchField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.onSuggestionSelected,
  });

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final _dio = Dio();
  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _suppressNextSearch = false; // avoid re-searching right after picking a suggestion

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    if (_suppressNextSearch) {
      _suppressNextSearch = false;
      return;
    }
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    try {
      // Nominatim usage policy requires a descriptive User-Agent and
      // at most ~1 request/sec — the 500ms debounce above keeps us
      // well within that for a single user typing.
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          // Bias results toward Myanmar, where the brigade operates.
          'countrycodes': 'mm',
        },
        options: Options(
          headers: {'User-Agent': 'BotahtaungRedCrossBrigadeApp/1.0'},
        ),
      );

      if (!mounted) return;
      final results = (response.data as List).map((item) {
        return LocationSuggestion(
          displayName: item['display_name'] as String,
          latitude: double.parse(item['lat'] as String),
          longitude: double.parse(item['lon'] as String),
        );
      }).toList();

      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    } catch (_) {
      // Network failure, rate limit, or no results — fail silently
      // into manual entry. The text field keeps whatever the user
      // typed; they're never blocked from entering their own text.
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    _suppressNextSearch = true;
    widget.controller.text = suggestion.displayName;
    setState(() => _suggestions = []);
    widget.onSuggestionSelected?.call(suggestion);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search, size: 20),
            helperText: 'Suggestions appear as you type — or keep typing your own.',
            helperMaxLines: 2,
          ),
          validator: widget.required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
          onChanged: _onChanged,
          // Fallback: if for any reason the debounced auto-search
          // hasn't fired yet (e.g. typed fast and immediately hit
          // Enter), pressing Enter/search on the keyboard forces an
          // immediate search too — but this is a fallback, not the
          // primary trigger. The primary trigger is onChanged above,
          // which fires on every keystroke.
          onFieldSubmitted: (value) {
            _debounce?.cancel();
            if (value.trim().length >= 3) _search(value);
          },
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey50.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _suggestions.map((s) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 18),
                  title: Text(s.displayName, style: AppTextStyles.bodySmall, maxLines: 2),
                  onTap: () => _selectSuggestion(s),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}