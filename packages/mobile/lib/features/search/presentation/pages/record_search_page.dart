import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import '../../domain/entities/search_filters.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_bar.dart';

class RecordSearchPage extends StatefulWidget {
  const RecordSearchPage({super.key});

  @override
  State<RecordSearchPage> createState() => _RecordSearchPageState();
}

class _RecordSearchPageState extends State<RecordSearchPage> {
  final _searchController = TextEditingController();
  SearchFilters _currentFilters = const SearchFilters();

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
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
              onClear: () {
                context.read<SearchBloc>().add(const ClearSearch());
              },
              onFilterTap: () => _showFilterSheet(context),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return _buildInitialState();
                } else if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchLoaded) {
                  return _buildResultsList(state);
                } else if (state is SearchError) {
                  return _buildErrorState(state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for records',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a query or apply filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(SearchLoaded state) {
    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: state.results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final result = state.results[index];
        final record = result.record;
        final dateFormat = DateFormat('MMM dd, yyyy');
        final isNegative = record.amount < 0;

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
              record.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              dateFormat.format(record.date),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
            ),
            trailing: Text(
              '${isNegative ? '-' : ''}৳${record.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isNegative ? AppColors.errorDark : AppColors.successDark,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
}
