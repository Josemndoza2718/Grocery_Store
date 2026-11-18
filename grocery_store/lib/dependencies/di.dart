import 'package:grocery_store/dependencies/providers.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:provider/single_child_widget.dart';

/// App-wide dependencies (available before and after login).
final List<SingleChildWidget> globalDi = [
  ...globalProviders,
];

/// Dependencies bound to the active [session] (user + store).
List<SingleChildWidget> sessionDi(AppSession session) => [
      ...sessionProviders(session),
    ];
