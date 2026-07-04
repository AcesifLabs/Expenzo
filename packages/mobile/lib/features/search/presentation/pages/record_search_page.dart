import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_result.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_bar_widget.dart';

class RecordSearchPage extends StatefulWidget {
  const RecordSearchPage({super.key});

  @override
  State<RecordSearchPage> createState() => _RecordSearchPageState();
}

class _RecordSearchPageState extends State<RecordSearchPage> {
  final _searchController = TextEditingController();
  SearchFilters _currentFilters = const SearchFilters();

  void _onSearchChanged(String query) {
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  void _onSearchClear() {
    context.read<SearchBloc>().add(const ClearSearch());
  }

  Widget _buildInitialState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PiconsRegular.magnifyingGlass,
            size: 64,
            color: colorScheme.onSurface.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for records',
            style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a query or apply filters',
            style: TextStyle(fontSize: 14, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PiconsRegular.magnifyingGlass,
            size: 64,
            color: colors.onSurface.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(fontSize: 18, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or filters',
            style: TextStyle(fontSize: 14, color: colors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(SearchResult result) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isNegative = result.amount < 0;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('📦', style: TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          result.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dateFormat.format(result.date),
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withAlpha(140),
          ),
        ),
        trailing: Text(
          '${isNegative ? '-' : ''}৳${result.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isNegative ? AppColors.errorDark : AppColors.successDark,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(SearchLoaded state) {
    if (state.results.isEmpty) return _buildEmptyResults();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: state.results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildResultItem(state.results[index]),
    );
  }

  Widget _buildErrorState(String message) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PiconsRegular.warningCircle, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(fontSize: 18, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: colors.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    FilterBottomSheet.show(
      context: context,
      currentFilters: _currentFilters,
      onFiltersChanged: (filters) {
        setState(() => _currentFilters = filters);
        context.read<SearchBloc>().add(SearchFiltersChanged(filters));
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Search Records',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _onSearchClear,
              onFilterTap: () => _showFilterSheet(context),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return switch (state) {
                  SearchInitial() => _buildInitialState(),
                  SearchLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  SearchLoaded() => _buildResultsList(state),
                  SearchError(:final message) => _buildErrorState(message),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
