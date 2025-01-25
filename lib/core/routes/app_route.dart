import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:subject/app/domain/common/modal_screen.dart';
import 'package:subject/app/domain/todo/views/to_do_screen.dart';
import 'package:subject/app/domain/user/views/sign_in_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      _toDoRoutes(),
      _authRoutes(),
      _otherRoutes(),
    ],
  );

  static GoRoute _toDoRoutes() {
    return GoRoute(
        path: '/', builder: (context, state) => const ToDoScreen());
  }

  static GoRoute _authRoutes() {
    return GoRoute(path: '/sign_in', builder: (context, state) => const SignInScreen());
  }

  static GoRoute _otherRoutes() {
    return GoRoute(
      path: '/modal:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'];

        return CustomTransitionPage(
          child: ModalScreen(id: id!),
          key: state.pageKey,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }
}
