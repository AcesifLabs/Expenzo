import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

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
