import '../models/dashboard_snapshot.dart';

abstract interface class QuotaRepository {
  Future<DashboardSnapshot> fetchDashboard();
}
