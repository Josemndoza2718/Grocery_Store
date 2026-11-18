import 'package:flutter/material.dart';
import 'package:grocery_store/ui/views/home/widgets/home_dashboard.dart';

/// Home tab. A single dashboard for owners and employees: it shows or hides
/// actions according to the role of the active session.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const HomeDashboard();
}
