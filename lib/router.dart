import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/session/session_list_screen.dart';
import 'screens/session/session_detail_screen.dart';
import 'screens/session/session_add_screen.dart';
import 'screens/session/session_detail_input_screen.dart';
import 'screens/agenda/agenda_list_screen.dart';
import 'screens/agenda/agenda_add_screen.dart';
import 'screens/agenda/agenda_detail_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/budget/budget_add_screen.dart';
import 'screens/member/member_list_screen.dart';
import 'screens/member/member_add_screen.dart';
import 'screens/department/department_list_screen.dart';
import 'screens/department/department_add_screen.dart';
import 'screens/stats/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SessionListScreen(),
        ),
        GoRoute(
          path: '/session/add',
          builder: (context, state) => const SessionAddScreen(),
        ),
        GoRoute(
          path: '/session/:id',
          builder: (context, state) =>
              SessionDetailScreen(sessionId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/session/:id/detail-input',
          builder: (context, state) =>
              SessionDetailInputScreen(sessionId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/session/:id/agenda',
          builder: (context, state) =>
              AgendaListScreen(sessionId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/session/:id/agenda/add',
          builder: (context, state) =>
              AgendaAddScreen(sessionId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/session/:sessionId/agenda/:agendaId',
          builder: (context, state) => AgendaDetailScreen(
            sessionId: state.pathParameters['sessionId']!,
            agendaId: state.pathParameters['agendaId']!,
          ),
        ),
        GoRoute(
          path: '/session/:id/budget',
          builder: (context, state) =>
              BudgetScreen(sessionId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/session/:id/budget/add',
          builder: (context, state) =>
              BudgetAddScreen(sessionId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/members',
          builder: (context, state) => const MemberListScreen(),
        ),
        GoRoute(
          path: '/members/add',
          builder: (context, state) => const MemberAddScreen(),
        ),
        GoRoute(
          path: '/departments',
          builder: (context, state) => const DepartmentListScreen(),
        ),
        GoRoute(
          path: '/departments/add',
          builder: (context, state) => const DepartmentAddScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
      ],
    ),
  ],
);
