import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_category_record_counts.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_section.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../helpers/category_display_name.dart';
import '../widgets/category_settings_row.dart';
import '../widgets/delete_category_dialog.dart';

enum _DeletePhase { idle, dispatched, running }

class CategoryListPage extends StatefulWidget {
  final GetCategoryRecordCounts? getCounts;

  const CategoryListPage({super.key, this.getCounts});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  static const _load = LoadCategories(sortByUsage: true);

  Map<String, int>? _counts;

  int _countsGeneration = 0;

  _DeletePhase _deletePhase = _DeletePhase.idle;

  List<Category>? _lastLoaded;

  bool _recovering = false;

  GetCategoryRecordCounts get _getCounts =>
      widget.getCounts ?? di.getIt<GetCategoryRecordCounts>();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CategoryBloc>();
    if (bloc.state case CategoryLoaded(:final categories, type: null)) {
      _lastLoaded = categories;
    }

    bloc.add(_load);
    unawaited(_loadCounts());
  }

  Future<void> _loadCounts() async {
    final generation = ++_countsGeneration;
    final result = await _getCounts(NoParams());
    if (!mounted || generation != _countsGeneration) return;
    result.fold((failure) {
      appLogger.warning('Category counts failed: ${failure.message}');
      setState(() => _counts = null);
    }, (counts) => setState(() => _counts = counts));
  }

  Future<void> _reload() async {
    if (_deletePhase != _DeletePhase.idle) return;
    _recovering = false;
    context.read<CategoryBloc>().add(_load);
    await _loadCounts();
  }

  void _onAddPressed() => unawaited(context.push('/categories/new'));

  void _onCategoryTap(Category category) {
    final id = category.id;
    if (id == null) return;
    unawaited(
      context.push('/categories/$id/edit', extra: {'category': category}),
    );
  }

  Future<int> _countFor(String id) async {
    if (_counts == null) await _loadCounts();

    return _counts?[id] ?? 0;
  }

  Future<void> _showDeleteDialog(Category category) async {
    if (category.isDefault) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(t.categories.defaultCannotDelete)),
        );

      return;
    }

    final id = category.id;
    if (id == null) return;

    final transactionCount = await _countFor(id);
    if (!mounted) return;

    final confirmed = await DeleteCategoryDialog.show(
      context: context,
      categoryName: category.displayName,
      transactionCount: transactionCount,
    );

    if (confirmed == true && mounted) {
      _deletePhase = _DeletePhase.dispatched;
      context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
    }
  }

  void _onCategoryState(BuildContext context, CategoryState state) {
    switch (state) {
      case CategoryLoading():
        if (_deletePhase == _DeletePhase.dispatched) {
          _deletePhase = _DeletePhase.running;
        }
      case CategoryLoaded(:final categories, type: null):
        _lastLoaded = categories;
        _recovering = false;
        if (_deletePhase == _DeletePhase.running) {
          _deletePhase = _DeletePhase.idle;
          unawaited(_loadCounts());
        }
      case CategoryLoaded() || CategorySearchResults():
        context.read<CategoryBloc>().add(_load);
      case CategoryError(:final message):
        _onCategoryError(context, message);
      case CategoryInitial():
        break;
    }
  }

  void _onCategoryError(BuildContext context, String message) {
    final wasDeleting = _deletePhase != _DeletePhase.idle;
    _deletePhase = _DeletePhase.idle;
    appLogger.error('Category list error: $message');

    if (_lastLoaded == null) return;

    if (_recovering) {
      setState(() {
        _lastLoaded = null;
        _recovering = false;
      });

      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasDeleting ? t.categories.settings.deleteFailed : message,
          ),
        ),
      );
    _recovering = true;
    context.read<CategoryBloc>().add(_load);
  }

  Widget _buildBody(CategoryState state) {
    final categories = switch (state) {
      CategoryLoaded(:final categories, type: null) => categories,
      _ => _lastLoaded,
    };

    if (categories != null) {
      return categories.isEmpty
          ? AppEmptyState(icon: PiconsRegular.tag, message: t.categories.empty)
          : _buildList(categories);
    }

    if (state case CategoryError(:final message)) {
      return AppEmptyState(
        icon: PiconsRegular.warningCircle,
        message: message,
        actionLabel: t.common.tryAgain,
        onAction: () => unawaited(_reload()),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildList(List<Category> categories) {
    final entries = [
      ..._sectionEntries(categories, RecordType.expense),
      ..._sectionEntries(categories, RecordType.income),
    ];
    final counts = _counts;

    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: entries.length,
      itemBuilder: (_, index) => switch (entries[index]) {
        _SectionTitle(:final title) => SettingsSectionHeader(title: title),
        _CategoryEntry(:final category, :final isFirst, :final isLast) =>
          SettingsSectionSlot(
            isFirst: isFirst,
            isLast: isLast,
            child: CategorySettingsRow(
              category: category,
              recordCount: counts == null ? null : (counts[category.id] ?? 0),
              onTap: () => _onCategoryTap(category),
              onLongPress: () => unawaited(_showDeleteDialog(category)),
            ),
          ),
      },
    );
  }

  String _sectionTitle(RecordType type) => switch (type) {
    RecordType.expense => t.categories.settings.sections.expense,
    RecordType.income => t.categories.settings.sections.income,
  };

  List<_ListEntry> _sectionEntries(List<Category> categories, RecordType type) {
    final ofType = [
      for (final category in categories)
        if (category.type == type) category,
    ];
    if (ofType.isEmpty) return const [];

    return [
      _SectionTitle(_sectionTitle(type)),
      for (final (index, category) in ofType.indexed)
        _CategoryEntry(
          category,
          isFirst: index == 0,
          isLast: index == ofType.length - 1,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: t.categories.settings.title,
        leading: const AppBackButton(),
        actions: [
          IconButton(
            icon: const Icon(PiconsRegular.plus),
            color: context.palette.brand,
            tooltip: t.categories.form.add,
            onPressed: _onAddPressed,
          ),
        ],
        onRefresh: _reload,
        child: BlocConsumer<CategoryBloc, CategoryState>(
          listener: _onCategoryState,
          builder: (_, state) => _buildBody(state),
        ),
      ),
    );
  }
}

sealed class _ListEntry {
  const _ListEntry();
}

class _SectionTitle extends _ListEntry {
  final String title;

  const _SectionTitle(this.title);
}

class _CategoryEntry extends _ListEntry {
  final Category category;
  final bool isFirst;
  final bool isLast;

  const _CategoryEntry(
    this.category, {
    required this.isFirst,
    required this.isLast,
  });
}
