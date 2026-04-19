import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/contact_selector_bloc.dart';
import '../bloc/contact_selector_event.dart';
import '../bloc/contact_selector_state.dart';
import '../bloc/message_sources_bloc.dart';
import '../bloc/message_sources_event.dart';
import '../bloc/message_sources_state.dart';
import '../../domain/entities/message_source.dart';
import 'sample_analyzer_page.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Sources')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<MessageSourcesBloc, MessageSourcesState>(
              builder: (context, sourcesState) {
                final monitoredSources = sourcesState is MessageSourcesLoaded
                    ? sourcesState.sources.where((s) => s.isMonitored).toList()
                    : <MessageSource>[];

                return BlocBuilder<ContactSelectorBloc, ContactSelectorState>(
                  builder: (context, state) {
                    if (state is ContactSelectorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ContactSelectorError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ContactSelectorLoaded) {
                      final filteredContacts = state.contacts
                          .where(
                            (c) =>
                                c.displayName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                c.address.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                      if (filteredContacts.isEmpty) {
                        return const Center(child: Text('No contacts found'));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: state.hasReachedMax
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

                          final contact = filteredContacts[index];
                          final existingSource = monitoredSources
                              .cast<MessageSource?>()
                              .firstWhere(
                                (s) => s?.contactId == contact.address,
                                orElse: () => null,
                              );
                          final isMonitored = existingSource != null;

                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                contact.sourceType == 'sms'
                                    ? Icons.sms
                                    : Icons.email,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    contact.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isMonitored)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              contact.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              final source =
                                  existingSource ??
                                  MessageSource(
                                    id: 'src_${DateTime.now().millisecondsSinceEpoch}',
                                    contactId: contact.address,
                                    contactName: contact.displayName,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );

                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SampleAnalyzerPage(source: source),
                                    ),
                                  )
                                  .then((_) {
                                    if (context.mounted) {
                                      context.read<MessageSourcesBloc>().add(
                                        LoadMessageSources(),
                                      );
                                    }
                                  });
                            },
                          );
                        },
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
