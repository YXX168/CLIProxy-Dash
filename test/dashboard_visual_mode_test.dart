import 'package:cliproxy_dash/app.dart';
import 'package:cliproxy_dash/models/codex_account.dart';
import 'package:cliproxy_dash/models/quota_window.dart';
import 'package:cliproxy_dash/services/config_store.dart';
import 'package:cliproxy_dash/services/management_service.dart';
import 'package:cliproxy_dash/widgets/energy_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConfigStore extends ConfigStore {
  _FakeConfigStore();

  @override
  Future<AppConfig> load() async => const AppConfig(
    baseUrl: 'http://127.0.0.1:8317',
    apiKey: 'test-key',
  );
}

class _FakeManagementService extends ManagementService {
  _FakeManagementService() : super(client: null);

  @override
  Future<List<CodexAccount>> fetchAccounts({
    required String baseUrl,
    required String apiKey,
  }) async {
    return const [
      CodexAccount(
        id: 'account-0',
        email: 'test@example.com',
        label: 'test@example.com',
        primary: QuotaWindow(
          usedPercent: 20,
          resetAt: '2026-08-27T00:00:00Z',
          limitWindowSeconds: 604800,
        ),
        secondary: null,
      ),
    ];
  }
}

Future<void> _pumpDashboard(WidgetTester tester, VisualMode mode) async {
  await tester.pumpWidget(
    CLIProxyDashApp(
      configStore: _FakeConfigStore(),
      managementService: _FakeManagementService(),
      initialVisualMode: mode,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('console mode renders account cards and keeps summary stats', (
    tester,
  ) async {
    await _pumpDashboard(tester, VisualMode.console);

    expect(find.byKey(const Key('summary-stats-grid')), findsOneWidget);
    expect(find.byKey(const Key('account-card-0')), findsOneWidget);
    expect(find.byKey(const Key('energy-account-0')), findsNothing);
  });

  testWidgets('energy mode renders one energy core per account', (
    tester,
  ) async {
    await _pumpDashboard(tester, VisualMode.energy);

    expect(find.byKey(const Key('summary-stats-grid')), findsOneWidget);
    expect(find.byKey(const Key('account-card-0')), findsNothing);
    expect(find.byKey(const Key('energy-account-0')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('energy-account-0')),
        matching: find.text('80%'),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('labels a single current quota window as weekly', (tester) async {
    await _pumpDashboard(tester, VisualMode.console);

    await tester.tap(find.byKey(const Key('account-card-0')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('周额度'), findsWidgets);
    expect(find.text('5 小时限额'), findsNothing);
  });

  testWidgets('settings opens the redesigned control center', (tester) async {
    await _pumpDashboard(tester, VisualMode.console);

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    expect(find.text('控制中心'), findsOneWidget);
  });
}
