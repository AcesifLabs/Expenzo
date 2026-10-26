import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/lifecycle/local_data_epoch.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';

void refreshAfterLocalWipe(BuildContext context) {
  di.getIt<LocalDataEpoch>().bump();
  di.getIt<SettingsBloc>().add(const LoadSettings());
  context.read<CategoryBloc>().add(const LoadCategories());
  context.read<RecordBloc>().add(const LoadRecords());
  context.go(AppRootTab.home.location);
}
