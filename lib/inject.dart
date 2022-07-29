import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:useless_kit/router/router.dart';

Future<void> inject() async {
  final sl = GetIt.instance;

  GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
  );

  sl.registerSingleton(router);
}
