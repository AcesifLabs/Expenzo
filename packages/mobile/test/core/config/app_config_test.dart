import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/config/app_config.dart';

void main() {
  test('the page sits at the site root, outside the api prefix', () {
    expect(
      AppConfig.publicPageUri('https://api.example.com/api', 'privacy'),
      Uri.parse('https://api.example.com/privacy'),
    );
  });

  test('a trailing slash on the base gives the same page', () {
    expect(
      AppConfig.publicPageUri('https://h/api/', 'privacy'),
      Uri.parse('https://h/privacy'),
    );
  });

  test('a local backend keeps its port', () {
    expect(
      AppConfig.publicPageUri('http://localhost:3000/api', 'terms'),
      Uri.parse('http://localhost:3000/terms'),
    );
  });

  test('a query on the base is dropped', () {
    expect(
      AppConfig.publicPageUri('https://h/api?v=1', 'terms'),
      Uri.parse('https://h/terms'),
    );
  });
}
