import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';
import 'feature_access_request_screen.dart';

/// Small, reusable "Need access? Request it" link — drop this into
/// any module's restricted/limited view to let an eligible office-
/// tier member jump straight into the generic Feature Access Request
/// flow, pre-filled with that module's name. Renders nothing if the
/// current member isn't eligible to request (e.g. Master Access,
/// who doesn't need this).
class RequestAccessLink extends StatelessWidget {
  final String featureName;
  const RequestAccessLink({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.canRequestFeatureAccess) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FeatureAccessRequestScreen(prefilledFeature: featureName),
          ),
        ),
        icon: const Icon(Icons.lock_open_outlined, size: 18),
        label: Text('Request access to $featureName'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
      ),
    );
  }
}
