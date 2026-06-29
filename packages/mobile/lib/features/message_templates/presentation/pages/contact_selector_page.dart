import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
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
import '../../../parsing_rules/presentation/widgets/transaction_list_skeleton.dart';

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

class _ContactSelectorViewState extends State<ContactSelectorView> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ContactSelectorBloc>().add(LoadMoreContacts());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
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

    await Navigator.of(
      context,
    ).push(SlidePageRoute(builder: (_) => SampleAnalyzerPage(source: source)));
    if (!mounted) return;
    context.read<MessageSourcesBloc>().add(LoadMessageSources());
  }

  Widget _buildHeader(ThemeData theme) {
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildHeaderTitle(colors), _buildSearchField(colors)],
    );
  }

  Widget _buildHeaderTitle(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan SMS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monitor SMS for expenses',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: colors.onSurface.withAlpha(140),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme colors) {
    final surfaceDimAlpha = colors.onSurface.withAlpha(100);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          hintStyle: TextStyle(color: surfaceDimAlpha),
          prefixIcon: Icon(
            PiconsRegular.magnifyingGlass,
            color: surfaceDimAlpha,
            size: 20,
          ),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(fontSize: 15, color: colors.onSurface),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onContactTap(contact, existingSource),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconTile(contact, colors),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameRow(contact, isMonitored, colors),
                      const SizedBox(height: 4),
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
        color: const Color(0xFF2B292C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        contact.sourceType == ExpenseSource.sms
            ? PiconsRegular.chatCircle
            : PiconsRegular.envelope,
        color: colors.secondary,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
        ),
        if (isMonitored) _buildActiveBadge(colors),
      ],
    );
  }

  Widget _buildActiveBadge(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Active',
          style: TextStyle(
            color: colors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewText(DeviceContact contact, ColorScheme colors) {
    return Text(
      contact.lastMessage,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: colors.onSurface.withAlpha(120),
      ),
    );
  }

  Widget _buildContactList(
    List<DeviceContact> contacts,
    List<MessageSource> monitoredSources,
    ThemeData theme,
  ) {
    final filteredContacts = contacts
        .where(
          (c) =>
              c.displayName.toLowerCase().contains(_searchQuery) ||
              c.address.toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (filteredContacts.isEmpty) {
      return const Center(child: Text('No contacts found'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: contacts.length >= 100
          ? filteredContacts.length
          : filteredContacts.length + 1,
      itemBuilder: (context, index) {
        if (index >= filteredContacts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
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
  void dispose() {
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
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<MessageSourcesBloc, MessageSourcesState>(
              builder: (context, sourcesState) {
                final monitoredSources = sourcesState is MessageSourcesLoaded
                    ? sourcesState.sources.where((s) => s.isMonitored).toList()
                    : <MessageSource>[];

                return BlocBuilder<ContactSelectorBloc, ContactSelectorState>(
                  builder: (context, state) {
                    if (state is ContactSelectorLoading) {
                      return const TransactionListSkeleton(itemCount: 8);
                    }
                    if (state is ContactSelectorError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ContactSelectorLoaded) {
                      return _buildContactList(
                        state.contacts,
                        monitoredSources,
                        theme,
                      );
                    }

                    return const SizedBox.shrink();
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
