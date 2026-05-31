import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../domain/entities/record.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';
import 'new_transaction/all_categories_picker.dart';
import 'new_transaction/category_picker_item.dart';
import 'new_transaction/numeric_keypad.dart';
import 'new_transaction/type_toggle.dart';

class NewTransactionSheet extends StatefulWidget {
  const NewTransactionSheet({super.key});

  @override
  State<NewTransactionSheet> createState() => _NewTransactionSheetState();
}

class _NewTransactionSheetState extends State<NewTransactionSheet>
    with TickerProviderStateMixin {
  late RecordType _type;
  final _amountText = ValueNotifier<String>('');
  final _noteCtrl = TextEditingController();
  String? _selectedCategoryId;
  List<Category> _categories = [];
  bool _hasManuallyDeselected = false;

  // ── Validation error flags ──
  bool _labelError = false;
  bool _categoryError = false;
  bool _isSubmitting = false;

  // ── Date picker + recurring ──
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  // ── Validation glow animation ──
  late final AnimationController _glowController;
  late final CurvedAnimation _glowCurve;

  // ── Typewriter placeholder state ──
  static const _expensePlaceholders = [
    'Groceries',
    'Uber to office',
    'Lunch with colleague',
    'Netflix subscription',
    'Electricity bill',
    'Gas station',
  ];

  static const _incomePlaceholders = [
    'Salary',
    'Freelance payment',
    'Side hustle',
    'Refund',
    'Bonus',
    'Investment dividend',
  ];

  Timer? _typewriterTimer;
  int _twPhraseIndex = 0;
  int _twCharIndex = 0;
  String _twDisplayText = '';
  bool _twIsErasing = false;
  bool _twIsPaused = false;

  @override
  void initState() {
    super.initState();
    _type = RecordType.expense;
    _loadCategories();

    // Unified note controller listener (label validation + typewriter)
    _noteCtrl.addListener(_onNoteChanged);

    // Validation glow animation setup
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _glowCurve = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
    _glowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _glowController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _labelError = false;
          _categoryError = false;
        });
      }
    });

    // Start typewriter after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startTypewriter();
    });
  }

  @override
  void dispose() {
    _stopTypewriter();
    _noteCtrl.removeListener(_onNoteChanged);
    _glowController.dispose();
    _amountText.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Note change handler (clear label error + pause/resume typewriter) ──
  void _onNoteChanged() {
    // Task 3: Clear label error when user types
    if (_labelError && _noteCtrl.text.trim().isNotEmpty) {
      setState(() => _labelError = false);
    }

    // Task 7: Typewriter pause/resume
    if (_noteCtrl.text.isNotEmpty && !_twIsPaused) {
      _twIsPaused = true;
      _stopTypewriter();
      setState(() => _twDisplayText = '');
    } else if (_noteCtrl.text.isEmpty && _twIsPaused) {
      _twIsPaused = false;
      _startTypewriter();
    }
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(
      LoadCategories(type: _type, sortByUsage: true),
    );
  }

  void _showAllCategories(BuildContext context, List<Category> allCategories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AllCategoriesPicker(
        categories: allCategories,
        selectedId: _selectedCategoryId,
        onSelect: (id) {
          setState(() {
            _selectedCategoryId = id;
            _categoryError = false;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  // ── Pre-select default "General" category ──
  void _selectDefaultCategory(List<Category> categories) {
    if (_selectedCategoryId != null) return;
    if (_hasManuallyDeselected) return;
    if (categories.isEmpty) return;

    Category? generalCat;
    for (final c in categories) {
      if (c.name == 'General' && c.isDefault) {
        generalCat = c;
        break;
      }
    }

    final targetId = generalCat?.id ?? categories.first.id;
    if (targetId != null) {
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedCategoryId == null) {
          setState(() => _selectedCategoryId = targetId);
        }
      });
    }
  }

  void _switchType(RecordType t) {
    _glowController.reset();
    _stopTypewriter();
    setState(() {
      _type = t;
      _selectedCategoryId = null;
      _categories = [];
      _hasManuallyDeselected = false;
      _labelError = false;
      _categoryError = false;
    });
    _loadCategories();
    if (!_twIsPaused) {
      _startTypewriter();
    }
  }

  // ── Swipe gesture handler (left→right = expense, right→left = income) ──
  // Safe with category-chip ListView: the chip scrollbar's
  // HorizontalDragGestureRecognizer wins the gesture arena within its
  // bounds; this handler only fires on unclaimed horizontal drags.
  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null) return;
    if (velocity.abs() < 100) return;

    final targetType = velocity > 0 ? RecordType.expense : RecordType.income;

    if (targetType != _type) {
      _switchType(targetType);
    }
  }

  void _appendDigit(String d) {
    final current = _amountText.value;
    if (d == '.' && current.contains('.')) return;
    if (current == '0' && d != '.') {
      _amountText.value = d;
      return;
    }
    // Limit to 2 decimal places
    if (current.contains('.') && current.split('.')[1].length >= 2) return;
    // Limit total digits
    if (current.replaceAll('.', '').length >= 10) return;
    _amountText.value = current + d;
  }

  void _backspace() {
    if (_amountText.value.isNotEmpty) {
      _amountText.value = _amountText.value.substring(
        0,
        _amountText.value.length - 1,
      );
    }
  }

  double get _parsedAmount => double.tryParse(_amountText.value) ?? 0;

  // Resolve animated glow border color for validation error fields
  Color _resolveGlowBorderColor(
    bool hasError,
    ColorScheme colors, {
    Color? fallback,
  }) {
    if (!hasError) return fallback ?? Colors.transparent;
    if (_glowController.isAnimating) {
      return Color.lerp(
        colors.error.withAlpha(80),
        colors.error,
        _glowCurve.value,
      )!;
    }
    return colors.error.withAlpha(150);
  }

  // ── Validation glow trigger ──
  void _triggerValidationGlow() {
    _glowController.forward(from: 0.0);
  }

  // ── Submit with validation (amount + label + category) ──
  Future<void> _submit() async {
    if (_isSubmitting) return;
    final amount = _parsedAmount;
    bool hasError = false;

    if (amount <= 0) {
      hasError = true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter an amount')));
    }

    if (_noteCtrl.text.trim().isEmpty) {
      hasError = true;
      _labelError = true;
    }

    if (_selectedCategoryId == null) {
      hasError = true;
      _categoryError = true;
    }

    if (hasError) {
      setState(() {});
      if (_labelError || _categoryError) {
        _triggerValidationGlow();
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final now = DateTime.now().toUtc();
    final finalAmount = _type == RecordType.expense ? -amount : amount;

    final record = Record(
      amount: finalAmount,
      description: _noteCtrl.text.trim(),
      date: _selectedDate,
      categoryId: _selectedCategoryId,
      source: ExpenseSource.manual,
      recordType: _type,
      createdAt: now,
      updatedAt: now,
    );

    context.read<RecordBloc>().add(AddRecordEvent(record));

    if (_isRecurring) {
      final created = await _createRecurringTransaction(finalAmount);
      if (!created) {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
        return;
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ── Fire-and-forget recurring creation (primary record already saved) ──
  Future<bool> _createRecurringTransaction(double finalAmount) async {
    try {
      await di.featureDependenciesReady;
      if (!di.getIt.isRegistered<RecurringRepository>()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recurring transactions are not ready yet.'),
            ),
          );
        }
        return false;
      }
      final repo = di.getIt<RecurringRepository>();

      // First occurrence was just saved manually; advance to next period
      // so the recurring processor doesn't immediately duplicate it.
      final nextOccurrence = _nextOccurrenceAfter(_selectedDate);

      await repo.createRecurring(
        RecurringTransaction(
          description: _noteCtrl.text.trim(),
          amount: finalAmount,
          categoryId: _selectedCategoryId,
          frequency: RecurringFrequency.monthly,
          startDate: _selectedDate,
          endDate: null,
          nextOccurrence: nextOccurrence,
          isActive: true,
          autoCreateExpense: true,
          dayOfMonth: _selectedDate.day,
        ),
      );
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Recurring transaction could not be saved. '
              'You can set it up later from the Recurring tab.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// Returns the next scheduled occurrence after [date] based on frequency.
  /// Currently only monthly frequency is exposed in the sheet UI.
  DateTime _nextOccurrenceAfter(DateTime date) {
    // monthly: advance by one month, preserving the day-of-month
    return DateTime(date.year, date.month + 1, date.day);
  }

  // ── Typewriter engine (type → pause → erase → next) ──
  List<String> get _twPhrases =>
      _type == RecordType.expense ? _expensePlaceholders : _incomePlaceholders;

  void _startTypewriter() {
    _stopTypewriter();
    _twPhraseIndex = 0;
    _twCharIndex = 0;
    _twDisplayText = '';
    _twIsErasing = false;
    _tickTypewriter();
  }

  void _stopTypewriter() {
    _typewriterTimer?.cancel();
    _typewriterTimer = null;
  }

  void _tickTypewriter() {
    if (_twIsPaused || !mounted) return;

    final phrases = _twPhrases;
    if (phrases.isEmpty) return;

    final currentPhrase = phrases[_twPhraseIndex % phrases.length];

    if (!_twIsErasing) {
      // Typing phase
      if (_twCharIndex < currentPhrase.length) {
        _twCharIndex++;
        _twDisplayText = currentPhrase.substring(0, _twCharIndex);
        setState(() {});
        _typewriterTimer = Timer(
          const Duration(milliseconds: 80),
          _tickTypewriter,
        );
      } else {
        // Phrase complete — pause 2 seconds, then erase
        _typewriterTimer = Timer(const Duration(seconds: 2), () {
          if (!_twIsPaused && mounted) {
            _twIsErasing = true;
            _tickTypewriter();
          }
        });
      }
    } else {
      // Erasing phase
      if (_twCharIndex > 0) {
        _twCharIndex--;
        _twDisplayText = currentPhrase.substring(0, _twCharIndex);
        setState(() {});
        _typewriterTimer = Timer(
          const Duration(milliseconds: 40),
          _tickTypewriter,
        );
      } else {
        // Fully erased — next phrase after brief gap
        _twIsErasing = false;
        _twPhraseIndex = (_twPhraseIndex + 1) % phrases.length;
        _twCharIndex = 0;
        _twDisplayText = '';
        setState(() {});
        _typewriterTimer = Timer(const Duration(milliseconds: 300), () {
          if (!_twIsPaused && mounted) {
            _tickTypewriter();
          }
        });
      }
    }
  }

  // ── Dynamic hint text (typewriter or static fallback) ──
  String _getHintText() {
    if (!_twIsPaused && _twDisplayText.isNotEmpty) {
      return _twDisplayText;
    }
    return _type == RecordType.expense ? 'Name of expense' : 'Name of income';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onHorizontalDragEnd: _onHorizontalSwipe,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withAlpha(50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: TypeToggle(type: _type, onSwitch: _switchType),
                ),
                // Amount display
                ValueListenableBuilder<String>(
                  valueListenable: _amountText,
                  builder: (_, val, child) {
                    final displayVal = val.isEmpty ? '0' : val;
                    final sign = _type == RecordType.expense ? '-' : '+';
                    final signColor = _type == RecordType.expense
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF34C759);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '$sign$displayVal',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: signColor,
                          letterSpacing: -1,
                        ),
                      ),
                    );
                  },
                ),
                // Numeric keypad with hold-to-delete
                NumericKeypad(
                  onDigit: _appendDigit,
                  onBackspace: _backspace,
                  color: colors,
                ),
                // Note field (required, animated error border, typewriter hint)
                _buildNoteField(colors),
                _buildCategoryChips(colors),
                _buildDateAndRecurringRow(colors),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : () => unawaited(_submit()),
                      style: FilledButton.styleFrom(
                        backgroundColor: _type == RecordType.expense
                            ? colors.error
                            : colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Add ${_type.displayName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Note field with animated validation border & typewriter hint ──
  Widget _buildNoteField(ColorScheme colors) {
    return AnimatedBuilder(
      animation: _glowCurve,
      builder: (context, _) {
        final borderColor = _resolveGlowBorderColor(
          _labelError,
          colors,
          fallback: colors.onSurface.withAlpha(25),
        );
        final borderWidth = _labelError ? 2.0 : 1.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: TextStyle(color: colors.onSurface.withAlpha(80)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _labelError ? borderColor : colors.primary,
                  width: 2.0,
                ),
              ),
              filled: true,
              fillColor: colors.onSurface.withAlpha(8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(fontSize: 15, color: colors.onSurface),
          ),
        );
      },
    );
  }

  // ── Date picker + recurring checkbox row ──
  Widget _buildDateAndRecurringRow(ColorScheme colors) {
    final dateFmt = DateFormat('MMM dd, yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Row(
        children: [
          // Date button
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: isDark
                          ? ColorScheme.dark(
                              primary: AppColors.secondary,
                              onPrimary: Colors.black,
                              surface: AppColors.surfaceDark,
                              onSurface: Colors.white,
                              onSurfaceVariant: Colors.white70,
                            )
                          : null,
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.onSurface.withAlpha(30)),
                  color: colors.onSurface.withAlpha(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.calendar(PhosphorIconsStyle.light),
                      size: 20,
                      color: colors.onSurface.withAlpha(180),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      dateFmt.format(_selectedDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      PhosphorIcons.caretDown(PhosphorIconsStyle.light),
                      size: 14,
                      color: colors.onSurface.withAlpha(100),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Recurring checkbox + info icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _isRecurring,
                  onChanged: (v) => setState(() => _isRecurring = v ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: colors.primary,
                  side: BorderSide(
                    color: colors.onSurface.withAlpha(120),
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Recurring?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface.withAlpha(200),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message:
                    'Check this if your expense or income repeats every month',
                preferBelow: false,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  PhosphorIcons.info(PhosphorIconsStyle.light),
                  size: 14,
                  color: colors.onSurface.withAlpha(120),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Category chips with default selection & animated error glow ──
  Widget _buildCategoryChips(ColorScheme colors) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (ctx, state) {
        if (state is CategoryLoaded) {
          // Ignore if loaded for a different record type (race with _switchType)
          if (state.type != null && state.type != _type) {
            return _buildCategoryLoadingSpinner(colors);
          }
          _categories = state.categories;
          _selectDefaultCategory(state.categories);
        }
        final allCats = _categories;
        if (state is CategoryLoading) {
          return _buildCategoryLoadingSpinner(colors);
        }
        if (allCats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No categories available',
              style: TextStyle(color: colors.onSurface.withAlpha(80)),
            ),
          );
        }

        final displayCats = allCats.take(5).toList();
        if (_selectedCategoryId != null &&
            !displayCats.any((c) => c.id == _selectedCategoryId)) {
          Category? selected;
          for (final c in allCats) {
            if (c.id == _selectedCategoryId) {
              selected = c;
              break;
            }
          }
          if (selected != null) {
            displayCats.removeLast();
            displayCats.insert(0, selected);
          }
        }

        // Task 4: Wrap with AnimatedBuilder for per-chip glow
        return AnimatedBuilder(
          animation: _glowCurve,
          builder: (context, _) {
            return Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...displayCats.map((cat) {
                    return CategoryPickerItem(
                      category: cat,
                      isSelected: cat.id == _selectedCategoryId,
                      errorBorderColor: _resolveGlowBorderColor(
                        _categoryError,
                        colors,
                        fallback: Colors.transparent,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                          _categoryError = false;
                        });
                      },
                    );
                  }),
                  if (_selectedCategoryId == null)
                    GestureDetector(
                      onTap: () => _showAllCategories(context, allCats),
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: colors.onSurface.withAlpha(10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIcons.dotsThree(PhosphorIconsStyle.bold),
                          size: 20,
                          color: colors.onSurface.withAlpha(150),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryLoadingSpinner(ColorScheme colors) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.onSurface.withAlpha(80),
        ),
      ),
    );
  }
}
