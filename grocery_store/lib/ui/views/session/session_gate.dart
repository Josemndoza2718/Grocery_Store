import 'package:flutter/material.dart';
import 'package:grocery_store/dependencies/di.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:grocery_store/ui/views/origin/main_page.dart';
import 'package:grocery_store/ui/views/session/no_store_page.dart';
import 'package:grocery_store/ui/views/session/session_status_pages.dart';
import 'package:grocery_store/ui/views/session/store_picker_page.dart';
import 'package:provider/provider.dart';

/// Builds a [MaterialApp] with the app's shared configuration.
typedef AppBuilder = Widget Function({Key? key, required Widget home});

/// Shows the right screen for the current [SessionController.status] and,
/// once a store is active, mounts the session providers for that store.
///
/// The session providers are keyed by `uid-storeId`: switching store (or
/// user) disposes the previous view models and their Firestore subscriptions.
class SessionGate extends StatelessWidget {
  const SessionGate({super.key, required this.buildApp});

  final AppBuilder buildApp;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SessionController>();

    switch (controller.status) {
      case SessionStatus.loading:
        return buildApp(
          key: const ValueKey('session-loading'),
          home: const SessionLoadingPage(),
        );
      case SessionStatus.error:
        return buildApp(
          key: const ValueKey('session-error'),
          home: const SessionErrorPage(),
        );
      case SessionStatus.noStore:
        return buildApp(
          key: const ValueKey('session-no-store'),
          home: const NoStorePage(),
        );
      case SessionStatus.pickStore:
        return buildApp(
          key: const ValueKey('session-pick-store'),
          home: const StorePickerPage(),
        );
      case SessionStatus.ready:
        final AppSession session = controller.session!;
        return MultiProvider(
          key: ValueKey('session-${session.key}'),
          providers: [
            Provider<AppSession>.value(value: session),
            // Live store document (name, IVA, exchange rate...).
            Provider<Store>.value(value: controller.currentStore!),
            ...sessionDi(session),
          ],
          child: buildApp(home: const MainPage(selectedIndex: 0)),
        );
    }
  }
}
