import 'dart:convert';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/features/receipt_scan/data/receipt_extraction_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

const _parser = ReceiptExtractionParser();

void _expectValidOrFormatException(String reply) {
  try {
    final extraction = _parser.parse(reply);
    expect(extraction.amount.isFinite, isTrue);
    expect(extraction.amount, greaterThan(0));
    expect(extraction.amount, lessThanOrEqualTo(AppConstants.maxAmount));
    expect(extraction.description.trim(), isNotEmpty);
  } on FormatException {
    // A reply that isn't a usable receipt.
  }
}

void main() {
  property('any reply gives a valid receipt or a FormatException', () {
    forAll(anyText(maxLength: 200), maxExamples: propertyTrials, (reply) {
      _expectValidOrFormatException(reply);
    });
  });

  property(
    'any JSON-shaped reply gives a valid receipt or a FormatException',
    () {
      final values = oneOf([
        smsNoise(maxLength: 20),
        float(nan: true, infinity: true),
        integer(),
        null_(),
        boolean(),
      ]);

      forAll(
        combine4(values, values, values, smsNoise(maxLength: 30)),
        maxExamples: propertyTrials,
        (v) {
          final (amount, description, date, noise) = v;
          final json = jsonEncode({
            'amount': amount,
            'description': description,
            'date': date,
          }, toEncodable: (o) => '$o');
          _expectValidOrFormatException('$noise $json $noise');
        },
      );
    },
  );

  property('a well-formed receipt keeps its amount', () {
    forAll(positiveCents(), maxExamples: propertyTrials, (cents) {
      final reply = jsonEncode({
        'amount': centsText(cents),
        'description': 'Groceries',
        'date': '2026-10-05',
      });
      expect(_parser.parse(reply).amount, cents / 100);
    });
  });
}
