import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import '../bloc/sample_analyzer_bloc.dart';
import '../../domain/entities/message_source.dart';
import 'template_editor_page.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';

// Design tokens from SampleAnalyzerScreen (.pen)
const Color _background = Color(0xFF141315);
const Color _surface = Color(0xFF1C1B1D);
const Color _primary = Color(0xFFD1C4E9);
const Color _primaryGlow = Color(0x1FD1C4E9);
const Color _textPrimary = Color(0xFFF5F7FA);
const Color _textSecondary = Color(0xFF8E8E93);

class SampleAnalyzerPage extends StatelessWidget {
  final MessageSource source;

  const SampleAnalyzerPage({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.getIt<SampleAnalyzerBloc>()
            ..add(LoadSamples(contactId: source.contactId)),
      child: SampleAnalyzerView(source: source),
    );
  }
}

class SampleAnalyzerView extends StatefulWidget {
  final MessageSource source;

  const SampleAnalyzerView({super.key, required this.source});

  @override
  State<SampleAnalyzerView> createState() => _SampleAnalyzerViewState();
}

class _SampleAnalyzerViewState extends State<SampleAnalyzerView> {
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
      context.read<SampleAnalyzerBloc>().add(
        LoadMoreSamples(contactId: widget.source.contactId),
      );
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
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              const SizedBox(height: 12),
              _buildInfoBanner(),
              const SizedBox(height: 12),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: _textPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Samples: ${widget.source.contactName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              fontFamily: 'Work Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Select a message below to create an expense template. '
        'The app will learn to extract amounts from similar messages.',
        style: TextStyle(
          fontSize: 14,
          color: _textSecondary,
          fontFamily: 'Work Sans',
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SampleAnalyzerBloc, SampleAnalyzerState>(
      builder: (context, state) {
        if (state is SampleAnalyzerLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primary),
            ),
          );
        }
        if (state is SampleAnalyzerError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                color: _textSecondary,
                fontFamily: 'Work Sans',
              ),
            ),
          );
        }
        if (state is SampleAnalyzerLoaded) {
          if (state.messages.isEmpty) {
            return const Center(
              child: Text(
                'No recent messages found.',
                style: TextStyle(
                  color: _textSecondary,
                  fontFamily: 'Work Sans',
                ),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 16),
            itemCount: state.hasReachedMax
                ? state.messages.length
                : state.messages.length + 1,
            itemBuilder: (context, index) {
              if (index >= state.messages.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  ),
                );
              }

              final msg = state.messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMessageCard(msg),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageCard(SmsMessage msg) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              SlidePageRoute(
                builder: (_) => TemplateEditorPage(
                  source: widget.source,
                  sampleMessage: msg,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(msg.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontFamily: 'Work Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  msg.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textPrimary,
                    fontFamily: 'Work Sans',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildTemplateButton(msg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateButton(SmsMessage msg) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(
            builder: (_) =>
                TemplateEditorPage(source: widget.source, sampleMessage: msg),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _primaryGlow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_fix_high, size: 16, color: _primary),
            SizedBox(width: 6),
            Text(
              'Use as Template',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _primary,
                fontFamily: 'Work Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
