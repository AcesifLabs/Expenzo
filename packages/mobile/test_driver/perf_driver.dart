import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Writes `build/<scenario>.timeline_summary.json` for each scenario in
/// perf_test/app_perf_test.dart; scripts/perf_compare.dart reads them.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    for (final MapEntry(key: scenario, value: timeline) in data.entries) {
      final summary = driver.TimelineSummary.summarize(
        driver.Timeline.fromJson(timeline as Map<String, dynamic>),
      );
      await summary.writeTimelineToFile(
        scenario,
        pretty: true,
        includeSummary: true,
      );
    }
  },
);
