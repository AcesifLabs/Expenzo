import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import '../bloc/contact_selector_bloc.dart';
import '../bloc/contact_selector_event.dart';
import '../bloc/contact_selector_state.dart';
import '../bloc/message_sources_bloc.dart';
import '../bloc/message_sources_event.dart';
import '../bloc/message_sources_state.dart';
import '../../domain/entities/message_source.dart';
import 'sample_analyzer_page.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../../parsing_rules/presentation/widgets/transaction_list_skeleton.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Returns true only when the keyboard transitioned from open to closed,
/// i.e. the previous bottom view inset was positive and the current one is
/// zero. Used to unfocus the search field once the keyboard collapses.
bool keyboardJustCollapsed({
  required double previousBottomInset,
  required double currentBottomInset,
}) => previousBottomInset > 0 && currentBottomInset == 0;

class ContactSelectorPage extends StatelessWidget {
  const ContactSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.getIt<ContactSelectorBloc>()..add(LoadContacts()),
        ),
        BlocProvider(
          create: (_) =>
              di.getIt<MessageSourcesBloc>()..add(LoadMessageSources()),
        ),
      ],
      child: const ContactSelectorView(),
    );
  }
}

class ContactSelectorView extends StatefulWidget {
  const ContactSelectorView({super.key});

  @override
  State<ContactSelectorView> createState() => _ContactSelectorViewState();
}

class _ContactSelectorViewState extends State<ContactSelectorView>
    with WidgetsBindingObserver {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  double _lastBottomInset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ContactSelectorBloc>().add(LoadMoreContacts());
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  Future<void> _onContactTap(
    DeviceContact contact,
    MessageSource? existingSource,
  ) async {
    final source =
        existingSource ??
        MessageSource(
          id: 'src_${DateTime.now().millisecondsSinceEpoch}',
          contactId: contact.address,
          contactName: contact.displayName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    await Navigator.of(context).push(
      SlidePageRoute<void>(builder: (_) => SampleAnalyzerPage(source: source)),
    );
    if (!mounted) return;
    context.read<MessageSourcesBloc>().add(LoadMessageSources());
  }

  Widget _buildHeader(ThemeData theme) {
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildHeaderTitle(), _buildSearchField(colors)],
    );
  }

  Widget _buildHeaderTitle() {
    return AppPageHeader(
      leading: AppBackButton(),
      title: t.common.autoImport,
      subtitle: t.messageTemplates.contacts.subtitle,
    );
  }

  Widget _buildSearchField(ColorScheme colors) {
    final surfaceDimAlpha = colors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
      child: TextField(
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: t.messageTemplates.contacts.search,
          hintStyle: TextStyle(color: surfaceDimAlpha),
          prefixIcon: Icon(
            PiconsRegular.magnifyingGlass,
            color: surfaceDimAlpha,
            size: 20,
          ),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smd,
          ),
        ),
        style: AppTypography.bodyLarge.copyWith(color: colors.onSurface),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildContactItem(
    DeviceContact contact,
    List<MessageSource> monitoredSources,
    ThemeData theme,
  ) {
    final colors = theme.colorScheme;
    final existingSource = monitoredSources.cast<MessageSource?>().firstWhere(
      (s) => s?.contactId == contact.address,
      orElse: () => null,
    );
    final isMonitored = existingSource != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          onTap: () => _onContactTap(contact, existingSource),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.smd,
              AppSpacing.md,
              AppSpacing.smd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconTile(contact, colors),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameRow(contact, isMonitored, colors),
                      const SizedBox(height: AppSpacing.xs),
                      _buildPreviewText(contact, colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconTile(DeviceContact contact, ColorScheme colors) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Icon(
        contact.sourceType == ExpenseSource.sms
            ? PiconsRegular.chatCircle
            : PiconsRegular.envelope,
        color: colors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildNameRow(
    DeviceContact contact,
    bool isMonitored,
    ColorScheme colors,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            contact.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyLarge.copyWith(color: colors.onSurface),
          ),
        ),
        if (isMonitored) _buildActiveBadge(colors),
      ],
    );
  }

  Widget _buildActiveBadge(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: Text(
          t.messageTemplates.contacts.active,
          style: AppTypography.labelMedium.copyWith(color: colors.primary),
        ),
      ),
    );
  }

  Widget _buildPreviewText(DeviceContact contact, ColorScheme colors) {
    return Text(
      contact.lastMessage,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
    );
  }

  Widget _buildContactList(
    List<DeviceContact> contacts,
    List<MessageSource> monitoredSources,
    ThemeData theme, {
    required bool isLoadingMore,
  }) {
    final filteredContacts = contacts
        .where(
          (c) =>
              c.displayName.toLowerCase().contains(_searchQuery) ||
              c.address.toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (filteredContacts.isEmpty) {
      final contactsT = t.messageTemplates.contacts;

      return AppEmptyState(
        icon: PiconsRegular.chatText,
        message: _searchQuery.isEmpty
            ? contactsT.empty
            : contactsT.noMatch(query: _searchQuery),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      // Without an explicit padding the list re-applies the status-bar inset,
      // which the header above already accounts for. Keep the bottom inset so
      // the last contact scrolls clear of the floating nav bar.
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      // The trailing spinner row only exists while a next page is loading.
      itemCount: filteredContacts.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= filteredContacts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildContactItem(
          filteredContacts[index],
          monitoredSources,
          theme,
        );
      },
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final currentBottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;

    if (keyboardJustCollapsed(
      previousBottomInset: _lastBottomInset,
      currentBottomInset: currentBottomInset,
    )) {
      _searchFocusNode.unfocus();
    }

    _lastBottomInset = currentBottomInset;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: BlocBuilder<MessageSourcesBloc, MessageSourcesState>(
              builder: (context, sourcesState) {
                final monitoredSources = sourcesState is MessageSourcesLoaded
                    ? sourcesState.sources.where((s) => s.isMonitored).toList()
                    : <MessageSource>[];

                return BlocBuilder<ContactSelectorBloc, ContactSelectorState>(
                  builder: (context, state) {
                    return switch (state) {
                      ContactSelectorLoading() => const TransactionListSkeleton(
                        itemCount: 8,
                      ),
                      ContactSelectorError(:final message) => Center(
                        child: Text(message),
                      ),
                      ContactSelectorLoaded(
                        :final contacts,
                        :final isLoadingMore,
                      ) =>
                        _buildContactList(
                          contacts,
                          monitoredSources,
                          theme,
                          isLoadingMore: isLoadingMore,
                        ),
                      _ => const SizedBox.shrink(),
                    };
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
