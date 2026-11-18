import 'package:grocery_store/dependencies/providers.dart';
import 'package:provider/single_child_widget.dart';

/// App-wide dependencies (available before and after login).
final List<SingleChildWidget> globalDi = [
  ...globalProviders,
];

/// Dependencies bound to the authenticated user [userId].
List<SingleChildWidget> sessionDi(String userId) => [
      ...sessionProviders(userId),
    ];
