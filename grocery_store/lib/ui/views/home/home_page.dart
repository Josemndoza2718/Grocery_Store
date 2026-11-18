import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:grocery_store/ui/views/home/widgets/admin_dashboard.dart';
import 'package:grocery_store/ui/views/home/widgets/user_dashboard.dart';
import 'package:provider/provider.dart';

/// Shows the dashboard for the role the user has in the active store.
///
/// The role comes from the session (owner of the store or employee), no
/// longer from the self-assigned `isAdmin` field of the profile.
/// Phase 2 of the multi-store plan unifies both dashboards into one.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return session.isOwner ? const AdminDashboard() : const UserDashboard();
  }
}
