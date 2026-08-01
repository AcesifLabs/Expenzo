import 'package:get_it/get_it.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_datasource.dart';
import 'package:expense_tracker/features/receipt_scan/data/repositories/receipt_scan_repository_impl.dart';
import 'package:expense_tracker/features/receipt_scan/domain/repositories/receipt_scan_repository.dart';
import 'package:expense_tracker/features/receipt_scan/domain/usecases/extract_receipt.dart';

void initReceiptScanModule(GetIt getIt) {
  getIt.registerLazySingleton<ReceiptScanRepository>(
    () => ReceiptScanRepositoryImpl(dataSource: getIt<GroqDataSource>()),
  );
  getIt.registerLazySingleton(
    () => ExtractReceipt(getIt<ReceiptScanRepository>()),
  );
}
