import 'dart:convert';
import 'dart:io';

const _scenarios = ['records_scroll', 'dashboard_range', 'open_reports'];
const _metrics = [
  'average_frame_build_time_millis',
  'worst_frame_build_time_millis',
  'missed_frame_build_budget_count',
];

const _missedShareLimit = 0.02;
const _worstFrameLimitMs = 32;

const _regressionLimit = 1.2;

Map<String, dynamic> _summary(String scenario) =>
    jsonDecode(File('build/$scenario.timeline_summary.json').readAsStringSync())
        as Map<String, dynamic>;

void main(List<String> args) {
  final current = {
    for (final scenario in _scenarios)
      scenario: {
        for (final metric in [..._metrics, 'frame_count'])
          metric: _summary(scenario)[metric],
      },
  };
  final baselineFile = File('perf_baseline.json');
  if (args.contains('--update')) {
    baselineFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(current),
    );
    stdout.writeln('Baseline written.');

    return;
  }

  final baseline = jsonDecode(baselineFile.readAsStringSync()) as Map;
  for (final scenario in _scenarios) {
    final now = current[scenario]!;
    final frames = (now['frame_count'] as num?) ?? 0;
    final missed = (now['missed_frame_build_budget_count'] as num?) ?? 0;
    final worst = (now['worst_frame_build_time_millis'] as num?) ?? 0;
    stdout.writeln('$scenario: $now');
    if (frames > 0 && missed / frames > _missedShareLimit) {
      stdout.writeln(
        '::warning::$scenario missed $missed of $frames frame budgets.',
      );
    }
    if (worst > _worstFrameLimitMs) {
      stdout.writeln('::warning::$scenario worst frame build took $worst ms.');
    }
    final before = baseline[scenario] as Map? ?? const {};
    for (final metric in _metrics) {
      final was = before[metric] as num?;
      final value = now[metric] as num?;
      if (was != null &&
          value != null &&
          was > 0 &&
          value > was * _regressionLimit) {
        stdout.writeln(
          '::warning::$scenario $metric went from $was to $value.',
        );
      }
    }
  }
}
