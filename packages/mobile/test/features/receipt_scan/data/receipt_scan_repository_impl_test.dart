import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_datasource.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_vision_request.dart';
import 'package:expense_tracker/features/receipt_scan/domain/usecases/extract_receipt.dart';
import 'package:expense_tracker/features/receipt_scan/data/repositories/receipt_scan_repository_impl.dart';

class _MockGroq extends Mock implements GroqDataSource {}

class _FakeRequest extends Fake implements GroqVisionRequest {}

void main() {
  late _MockGroq groq;
  late ReceiptScanRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_FakeRequest()));

  setUp(() {
    dotenv.loadFromString(
      envString: 'GROQ_API_KEY=k\nGROQ_VISION_MODEL=test/vision',
    );
    groq = _MockGroq();
    repository = ReceiptScanRepositoryImpl(dataSource: groq);
  });

  tearDown(dotenv.clean);

  Future<Object?> extract() async {
    final result = await repository.extractFromImage(
      imageBytes: Uint8List.fromList([1, 2, 3]),
      mimeType: 'image/png',
    );

    return result.fold((failure) => failure, (extraction) => extraction);
  }

  test('a readable receipt is extracted with the configured model', () async {
    when(() => groq.completeWithImage(any())).thenAnswer(
      (_) async => '{"amount":13.23,"description":"Groceries","date":null}',
    );

    final result = await extract();

    expect(result, isNot(isA<Failure>()));
    final sent =
        verify(() => groq.completeWithImage(captureAny())).captured.single
            as GroqVisionRequest;
    expect(sent.model, 'test/vision');
    expect(sent.systemPrompt, contains('null if you cannot read it'));
  });

  test('a null total is a total-unreadable failure', () async {
    when(
      () => groq.completeWithImage(any()),
    ).thenAnswer((_) async => '{"amount":null,"description":"Groceries"}');

    expect(await extract(), isA<ReceiptTotalUnreadableFailure>());
  });

  test('an API error is a service-unavailable failure', () async {
    when(() => groq.completeWithImage(any())).thenThrow(
      const ServerException(message: 'model_not_found', statusCode: 404),
    );

    expect(await extract(), isA<ReceiptServiceUnavailableFailure>());
  });

  test('a 400 for this photo keeps the generic read failure', () async {
    when(() => groq.completeWithImage(any())).thenThrow(
      const ServerException(message: 'json_validate_failed', statusCode: 400),
    );

    expect(
      await extract(),
      isA<ServerFailure>().having((f) => f.statusCode, 'status', 400),
    );
  });

  test('no connection stays a network failure', () async {
    when(
      () => groq.completeWithImage(any()),
    ).thenThrow(const SocketException('Failed host lookup'));

    expect(await extract(), isA<NetworkFailure>());
  });

  test('a reply that is not JSON keeps the generic read failure', () async {
    when(
      () => groq.completeWithImage(any()),
    ).thenAnswer((_) async => 'sorry, I cannot help');

    expect(await extract(), isA<ServerFailure>());
  });
}
