///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$aiAssistant$en aiAssistant = Translations$aiAssistant$en.internal(_root);
	late final Translations$auth$en auth = Translations$auth$en.internal(_root);
	late final Translations$budgets$en budgets = Translations$budgets$en.internal(_root);
	late final Translations$categories$en categories = Translations$categories$en.internal(_root);
	late final Translations$common$en common = Translations$common$en.internal(_root);
	late final Translations$currencies$en currencies = Translations$currencies$en.internal(_root);
	late final Translations$dashboard$en dashboard = Translations$dashboard$en.internal(_root);
	late final Translations$enums$en enums = Translations$enums$en.internal(_root);
	late final Translations$messageTemplates$en messageTemplates = Translations$messageTemplates$en.internal(_root);
	late final Translations$notifications$en notifications = Translations$notifications$en.internal(_root);
	late final Translations$parsingRules$en parsingRules = Translations$parsingRules$en.internal(_root);
	late final Translations$receiptScan$en receiptScan = Translations$receiptScan$en.internal(_root);
	late final Translations$records$en records = Translations$records$en.internal(_root);
	late final Translations$recurring$en recurring = Translations$recurring$en.internal(_root);
	late final Translations$reports$en reports = Translations$reports$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$shell$en shell = Translations$shell$en.internal(_root);
	late final Translations$smsParser$en smsParser = Translations$smsParser$en.internal(_root);
}

// Path: aiAssistant
class Translations$aiAssistant$en {
	Translations$aiAssistant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'AI assistant'
	String get title => 'AI assistant';

	/// en: 'Ask about your spending'
	String get inputHint => 'Ask about your spending';

	/// en: 'Send message'
	String get send => 'Send message';

	/// en: 'Expenzo AI provides suggestions based on your data. It is not a licensed financial advisor.'
	String get disclaimer => 'Expenzo AI provides suggestions based on your data. It is not a licensed financial advisor.';

	late final Translations$aiAssistant$suggestions$en suggestions = Translations$aiAssistant$suggestions$en.internal(_root);
	late final Translations$aiAssistant$refusals$en refusals = Translations$aiAssistant$refusals$en.internal(_root);
	late final Translations$aiAssistant$errors$en errors = Translations$aiAssistant$errors$en.internal(_root);
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$auth$errors$en errors = Translations$auth$errors$en.internal(_root);
	late final Translations$auth$syncConflict$en syncConflict = Translations$auth$syncConflict$en.internal(_root);
	late final Translations$auth$login$en login = Translations$auth$login$en.internal(_root);
}

// Path: budgets
class Translations$budgets$en {
	Translations$budgets$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budgets'
	String get title => 'Budgets';

	/// en: 'Track your monthly limits'
	String get subtitle => 'Track your monthly limits';

	/// en: 'Unnamed budget'
	String get unnamed => 'Unnamed budget';

	late final Translations$budgets$empty$en empty = Translations$budgets$empty$en.internal(_root);

	/// en: 'Budget saved'
	String get saved => 'Budget saved';

	/// en: 'Load budgets to see data'
	String get loadPrompt => 'Load budgets to see data';

	/// en: 'Edit'
	String get edit => 'Edit';

	late final Translations$budgets$delete$en delete = Translations$budgets$delete$en.internal(_root);
	late final Translations$budgets$card$en card = Translations$budgets$card$en.internal(_root);
	late final Translations$budgets$days$en days = Translations$budgets$days$en.internal(_root);
	late final Translations$budgets$form$en form = Translations$budgets$form$en.internal(_root);
	late final Translations$budgets$details$en details = Translations$budgets$details$en.internal(_root);
	late final Translations$budgets$picker$en picker = Translations$budgets$picker$en.internal(_root);
}

// Path: categories
class Translations$categories$en {
	Translations$categories$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Uncategorized'
	String get uncategorized => 'Uncategorized';

	Map<String, String> get defaults => {
		'default_in_salary': 'Salary',
		'default_in_freelance': 'Freelance',
		'default_in_investment': 'Investment',
		'default_in_refund': 'Refund',
		'default_in_gift': 'Gift',
		'default_in_general': 'General',
		'default_out_food': 'Food & Dining',
		'default_out_shopping': 'Shopping',
		'default_out_transport': 'Transport',
		'default_out_home': 'Home',
		'default_out_health': 'Health',
		'default_out_entertainment': 'Entertainment',
		'default_out_bills': 'Bills & Utilities',
		'default_out_travel': 'Travel',
		'default_out_education': 'Education',
		'default_out_investment': 'Investment',
		'default_out_gifts': 'Gifts',
		'default_out_general': 'General',
	};

	/// en: 'No categories created'
	String get empty => 'No categories created';

	late final Translations$categories$settings$en settings = Translations$categories$settings$en.internal(_root);

	/// en: 'Default categories cannot be deleted'
	String get defaultCannotDelete => 'Default categories cannot be deleted';

	late final Translations$categories$form$en form = Translations$categories$form$en.internal(_root);
	late final Translations$categories$delete$en delete = Translations$categories$delete$en.internal(_root);

	/// en: '{name} icon'
	String iconLabel({required Object name}) => '${name} icon';

	Map<String, String> get icons => {
		'shoppingCart': 'Shopping cart',
		'forkKnife': 'Fork and knife',
		'car': 'Car',
		'bag': 'Bag',
		'heart': 'Heart',
		'bookOpen': 'Book',
		'filmStrip': 'Film',
		'lightning': 'Lightning',
		'coffee': 'Coffee',
		'gift': 'Gift',
		'dog': 'Dog',
		'airplane': 'Airplane',
	};
	Map<String, String> get colors => {
		'Lavender': 'Lavender',
		'Rose': 'Rose',
		'Mint': 'Mint',
		'Sky': 'Sky',
		'Amber': 'Amber',
		'Teal': 'Teal',
		'Peach': 'Peach',
		'Slate': 'Slate',
	};
}

// Path: common
class Translations$common$en {
	Translations$common$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expenzo'
	String get appName => 'Expenzo';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Undo'
	String get undo => 'Undo';

	/// en: 'Try again'
	String get tryAgain => 'Try again';

	/// en: 'Not now'
	String get notNow => 'Not now';

	/// en: 'Open settings'
	String get openSettings => 'Open settings';

	/// en: 'Add expense'
	String get addExpense => 'Add expense';

	/// en: 'New budget'
	String get newBudget => 'New budget';

	/// en: 'Send feedback'
	String get sendFeedback => 'Send feedback';

	/// en: 'Auto-import from SMS'
	String get autoImport => 'Auto-import from SMS';

	/// en: 'Matching rules'
	String get matchingRules => 'Matching rules';

	late final Translations$common$errors$en errors = Translations$common$errors$en.internal(_root);
	late final Translations$common$dates$en dates = Translations$common$dates$en.internal(_root);
	late final Translations$common$a11y$en a11y = Translations$common$a11y$en.internal(_root);
	late final Translations$common$feedback$en feedback = Translations$common$feedback$en.internal(_root);

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Clear search'
	String get clearSearch => 'Clear search';

	/// en: 'Add transaction'
	String get addTransaction => 'Add transaction';

	/// en: 'No transactions in this period'
	String get noTransactionsInPeriod => 'No transactions in this period';

	late final Translations$common$fallback$en fallback = Translations$common$fallback$en.internal(_root);
	late final Translations$common$smsGate$en smsGate = Translations$common$smsGate$en.internal(_root);
}

// Path: currencies
class Translations$currencies$en {
	Translations$currencies$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	Map<String, String> get names => {
		'BDT': 'Bangladeshi taka',
		'USD': 'US dollar',
		'EUR': 'Euro',
		'GBP': 'British pound',
		'INR': 'Indian rupee',
		'PKR': 'Pakistani rupee',
		'NPR': 'Nepalese rupee',
		'LKR': 'Sri Lankan rupee',
		'AED': 'UAE dirham',
		'SAR': 'Saudi riyal',
		'MYR': 'Malaysian ringgit',
		'SGD': 'Singapore dollar',
		'THB': 'Thai baht',
		'PHP': 'Philippine peso',
		'IDR': 'Indonesian rupiah',
		'VND': 'Vietnamese dong',
		'JPY': 'Japanese yen',
		'KRW': 'South Korean won',
		'CNY': 'Chinese yuan',
		'AUD': 'Australian dollar',
		'CAD': 'Canadian dollar',
		'CHF': 'Swiss franc',
		'SEK': 'Swedish krona',
		'PLN': 'Polish złoty',
		'TRY': 'Turkish lira',
		'RUB': 'Russian ruble',
		'BRL': 'Brazilian real',
		'ZAR': 'South African rand',
	};
}

// Path: dashboard
class Translations$dashboard$en {
	Translations$dashboard$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$dashboard$range$en range = Translations$dashboard$range$en.internal(_root);

	/// en: 'Hi, {name}'
	String greeting({required Object name}) => 'Hi, ${name}';

	/// en: 'User'
	String get userFallback => 'User';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expense'
	String get expense => 'Expense';

	late final Translations$dashboard$sections$en sections = Translations$dashboard$sections$en.internal(_root);

	/// en: 'No budgets yet'
	String get noBudgets => 'No budgets yet';

	/// en: 'No transactions yet'
	String get noTransactions => 'No transactions yet';

	late final Translations$dashboard$menu$en menu = Translations$dashboard$menu$en.internal(_root);

	/// en: '{spent} of {total}'
	String budgetSpentOf({required Object spent, required Object total}) => '${spent} of ${total}';

	late final Translations$dashboard$trend$en trend = Translations$dashboard$trend$en.internal(_root);
	late final Translations$dashboard$autoImport$en autoImport = Translations$dashboard$autoImport$en.internal(_root);

	/// en: 'Scan a receipt'
	String get scanReceipt => 'Scan a receipt';
}

// Path: enums
class Translations$enums$en {
	Translations$enums$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$enums$recordType$en recordType = Translations$enums$recordType$en.internal(_root);
	late final Translations$enums$period$en period = Translations$enums$period$en.internal(_root);
	late final Translations$enums$frequency$en frequency = Translations$enums$frequency$en.internal(_root);
	late final Translations$enums$source$en source = Translations$enums$source$en.internal(_root);
	late final Translations$enums$theme$en theme = Translations$enums$theme$en.internal(_root);
	late final Translations$enums$digitGrouping$en digitGrouping = Translations$enums$digitGrouping$en.internal(_root);
	late final Translations$enums$fontSize$en fontSize = Translations$enums$fontSize$en.internal(_root);
	late final Translations$enums$firstDayOfWeek$en firstDayOfWeek = Translations$enums$firstDayOfWeek$en.internal(_root);
}

// Path: messageTemplates
class Translations$messageTemplates$en {
	Translations$messageTemplates$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$messageTemplates$errors$en errors = Translations$messageTemplates$errors$en.internal(_root);

	/// en: 'SMS format already exists'
	String get alreadyExists => 'SMS format already exists';

	/// en: 'Edit SMS format'
	String get edit => 'Edit SMS format';

	/// en: 'Delete SMS format'
	String get delete => 'Delete SMS format';

	/// en: 'SMS format deleted'
	String get deleted => 'SMS format deleted';

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';

	late final Translations$messageTemplates$retro$en retro = Translations$messageTemplates$retro$en.internal(_root);
	late final Translations$messageTemplates$editor$en editor = Translations$messageTemplates$editor$en.internal(_root);
	late final Translations$messageTemplates$analyzer$en analyzer = Translations$messageTemplates$analyzer$en.internal(_root);
	late final Translations$messageTemplates$contacts$en contacts = Translations$messageTemplates$contacts$en.internal(_root);

	/// en: 'New SMS format'
	String get create => 'New SMS format';
}

// Path: notifications
class Translations$notifications$en {
	Translations$notifications$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$notifications$channel$en channel = Translations$notifications$channel$en.internal(_root);
	late final Translations$notifications$budget$en budget = Translations$notifications$budget$en.internal(_root);
	late final Translations$notifications$recurringDue$en recurringDue = Translations$notifications$recurringDue$en.internal(_root);
	late final Translations$notifications$weeklySummary$en weeklySummary = Translations$notifications$weeklySummary$en.internal(_root);
	late final Translations$notifications$scan$en scan = Translations$notifications$scan$en.internal(_root);
	late final Translations$notifications$syncError$en syncError = Translations$notifications$syncError$en.internal(_root);
}

// Path: parsingRules
class Translations$parsingRules$en {
	Translations$parsingRules$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add rules from SMS formats'
	String get addFromFormats => 'Add rules from SMS formats';

	/// en: 'New rule'
	String get newRule => 'New rule';

	/// en: 'Edit rule'
	String get editRule => 'Edit rule';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Added "{name}"'
	String added({required Object name}) => 'Added "${name}"';

	late final Translations$parsingRules$empty$en empty = Translations$parsingRules$empty$en.internal(_root);

	/// en: 'Rule created'
	String get created => 'Rule created';

	/// en: 'Rule updated'
	String get updated => 'Rule updated';

	late final Translations$parsingRules$delete$en delete = Translations$parsingRules$delete$en.internal(_root);
	late final Translations$parsingRules$validation$en validation = Translations$parsingRules$validation$en.internal(_root);
	late final Translations$parsingRules$form$en form = Translations$parsingRules$form$en.internal(_root);
	late final Translations$parsingRules$tester$en tester = Translations$parsingRules$tester$en.internal(_root);
	Map<String, String> get templates => {
		'hdfc_bank_sms': 'Parses debit notifications from HDFC Bank',
		'icici_bank_sms': 'Parses debit notifications from ICICI Bank',
		'sbi_sms': 'Parses debit notifications from State Bank of India',
		'upi_payment_sms': 'Parses UPI payment notifications (PhonePe, Google Pay, Paytm)',
		'amazon_order_sms': 'Parses Amazon order confirmation and delivery SMS',
		'amazon_order_email': 'Parses Amazon order emails',
		'swiggy_order_email': 'Parses Swiggy order confirmation emails',
		'zomato_order_email': 'Parses Zomato order confirmation emails',
		'flipkart_order_email': 'Parses Flipkart order emails',
		'generic_payment_email': 'Parses generic payment confirmation emails',
	};
}

// Path: receiptScan
class Translations$receiptScan$en {
	Translations$receiptScan$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Camera permission is required to scan receipts.'
	String get permissionRequired => 'Camera permission is required to scan receipts.';

	/// en: 'No camera available on this device.'
	String get noCamera => 'No camera available on this device.';

	/// en: 'Couldn't open the camera.'
	String get cameraFailed => 'Couldn\'t open the camera.';

	/// en: 'Couldn't take the photo. Try again.'
	String get captureFailed => 'Couldn\'t take the photo. Try again.';

	/// en: 'Couldn't read the receipt. Try again or add it by hand.'
	String get readFailed => 'Couldn\'t read the receipt. Try again or add it by hand.';

	/// en: 'Choose from gallery'
	String get chooseFromGallery => 'Choose from gallery';

	/// en: 'Turn flash off'
	String get flashOff => 'Turn flash off';

	/// en: 'Turn flash on'
	String get flashOn => 'Turn flash on';

	/// en: 'Align receipt with the frame'
	String get align => 'Align receipt with the frame';

	/// en: 'Reading your receipt'
	String get reading => 'Reading your receipt';

	/// en: 'Take photo'
	String get takePhoto => 'Take photo';
}

// Path: records
class Translations$records$en {
	Translations$records$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$records$filter$en filter = Translations$records$filter$en.internal(_root);
	late final Translations$records$list$en list = Translations$records$list$en.internal(_root);
	late final Translations$records$picker$en picker = Translations$records$picker$en.internal(_root);
	late final Translations$records$sheet$en sheet = Translations$records$sheet$en.internal(_root);
}

// Path: recurring
class Translations$recurring$en {
	Translations$recurring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recurring transactions'
	String get title => 'Recurring transactions';

	/// en: 'Recurring transaction saved'
	String get saved => 'Recurring transaction saved';

	/// en: '(one) {{n} transaction added} (other) {{n} transactions added}'
	String posted({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} transaction added',
		other: '${n} transactions added',
	);

	/// en: 'No transactions due'
	String get nothingDue => 'No transactions due';

	late final Translations$recurring$sections$en sections = Translations$recurring$sections$en.internal(_root);
	late final Translations$recurring$defaults$en defaults = Translations$recurring$defaults$en.internal(_root);
	late final Translations$recurring$empty$en empty = Translations$recurring$empty$en.internal(_root);

	/// en: '{amount} · {frequency}'
	String amountEvery({required Object amount, required Object frequency}) => '${amount} · ${frequency}';

	/// en: 'Next: {date}'
	String next({required Object date}) => 'Next: ${date}';

	/// en: 'Process pending'
	String get processPending => 'Process pending';

	/// en: 'New recurring transaction'
	String get newTooltip => 'New recurring transaction';

	late final Translations$recurring$delete$en delete = Translations$recurring$delete$en.internal(_root);
	late final Translations$recurring$form$en form = Translations$recurring$form$en.internal(_root);
}

// Path: reports
class Translations$reports$en {
	Translations$reports$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$reports$insights$en insights = Translations$reports$insights$en.internal(_root);

	/// en: 'Reports'
	String get title => 'Reports';

	/// en: 'Ask AI'
	String get askAi => 'Ask AI';

	/// en: 'Last 7 days'
	String get last7Days => 'Last 7 days';

	/// en: 'Last 30 days'
	String get last30Days => 'Last 30 days';

	/// en: 'No category data'
	String get noCategoryData => 'No category data';

	/// en: 'No trend data yet'
	String get noTrendData => 'No trend data yet';

	/// en: 'No spending data yet'
	String get noSpending => 'No spending data yet';

	/// en: 'Total spent: {amount} in this period'
	String totalSpentInPeriod({required Object amount}) => 'Total spent: ${amount} in this period';

	late final Translations$reports$metrics$en metrics = Translations$reports$metrics$en.internal(_root);

	/// en: 'Spending by category'
	String get spendingByCategory => 'Spending by category';

	/// en: 'Key observations from your spending this month'
	String get observations => 'Key observations from your spending this month';

	/// en: 'No data'
	String get noData => 'No data';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$language$en language = Translations$settings$language$en.internal(_root);

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Default currency'
	String get currency => 'Default currency';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Allow notifications for Expenzo in system settings to get budget alerts.'
	String get notificationsBlocked => 'Allow notifications for Expenzo in system settings to get budget alerts.';

	late final Translations$settings$sections$en sections = Translations$settings$sections$en.internal(_root);
	late final Translations$settings$notifications$en notifications = Translations$settings$notifications$en.internal(_root);

	/// en: 'Turn bank and payment messages into transactions'
	String get autoImportSubtitle => 'Turn bank and payment messages into transactions';

	/// en: 'Patterns for messages auto-import can't read yet'
	String get matchingRulesSubtitle => 'Patterns for messages auto-import can\'t read yet';

	late final Translations$settings$recurring$en recurring = Translations$settings$recurring$en.internal(_root);

	/// en: 'Report a problem or suggest an idea'
	String get feedbackSubtitle => 'Report a problem or suggest an idea';

	/// en: 'Sign out'
	String get signOut => 'Sign out';

	/// en: 'Delete account'
	String get deleteAccount => 'Delete account';

	late final Translations$settings$signIn$en signIn = Translations$settings$signIn$en.internal(_root);
	late final Translations$settings$deleteDialog$en deleteDialog = Translations$settings$deleteDialog$en.internal(_root);

	/// en: 'Couldn't load your settings.'
	String get loadFailed => 'Couldn\'t load your settings.';

	late final Translations$settings$appearanceScreen$en appearanceScreen = Translations$settings$appearanceScreen$en.internal(_root);
	late final Translations$settings$currencyScreen$en currencyScreen = Translations$settings$currencyScreen$en.internal(_root);
	late final Translations$settings$numberFormat$en numberFormat = Translations$settings$numberFormat$en.internal(_root);
	late final Translations$settings$fontSize$en fontSize = Translations$settings$fontSize$en.internal(_root);
	late final Translations$settings$calendar$en calendar = Translations$settings$calendar$en.internal(_root);
	late final Translations$settings$homePage$en homePage = Translations$settings$homePage$en.internal(_root);
	late final Translations$settings$sync$en sync = Translations$settings$sync$en.internal(_root);
	late final Translations$settings$export$en export = Translations$settings$export$en.internal(_root);
	late final Translations$settings$deleteData$en deleteData = Translations$settings$deleteData$en.internal(_root);
	late final Translations$settings$categories$en categories = Translations$settings$categories$en.internal(_root);
}

// Path: shell
class Translations$shell$en {
	Translations$shell$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$shell$tabs$en tabs = Translations$shell$tabs$en.internal(_root);
	late final Translations$shell$reportsTabs$en reportsTabs = Translations$shell$reportsTabs$en.internal(_root);
}

// Path: smsParser
class Translations$smsParser$en {
	Translations$smsParser$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$smsParser$range$en range = Translations$smsParser$range$en.internal(_root);
	late final Translations$smsParser$summary$en summary = Translations$smsParser$summary$en.internal(_root);
	late final Translations$smsParser$card$en card = Translations$smsParser$card$en.internal(_root);
	late final Translations$smsParser$options$en options = Translations$smsParser$options$en.internal(_root);
	late final Translations$smsParser$toolbar$en toolbar = Translations$smsParser$toolbar$en.internal(_root);
	late final Translations$smsParser$section$en section = Translations$smsParser$section$en.internal(_root);
	late final Translations$smsParser$customRange$en customRange = Translations$smsParser$customRange$en.internal(_root);
	late final Translations$smsParser$results$en results = Translations$smsParser$results$en.internal(_root);
	late final Translations$smsParser$autoImport$en autoImport = Translations$smsParser$autoImport$en.internal(_root);
}

// Path: aiAssistant.suggestions
class Translations$aiAssistant$suggestions$en {
	Translations$aiAssistant$suggestions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Top expenses'
	String get topExpenses => 'Top expenses';

	/// en: 'How's my budget?'
	String get budget => 'How\'s my budget?';
}

// Path: aiAssistant.refusals
class Translations$aiAssistant$refusals$en {
	Translations$aiAssistant$refusals$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'I can only help with your Expenzo finances: spending, budgets, categories, income, balance, savings, transactions, reports and recurring bills. Ask a question about your own data.'
	String get outOfScope => 'I can only help with your Expenzo finances: spending, budgets, categories, income, balance, savings, transactions, reports and recurring bills. Ask a question about your own data.';

	/// en: 'I can't help with hidden instructions, internal context, secrets or requests to override my rules. Ask about your finances in Expenzo.'
	String get promptInjection => 'I can\'t help with hidden instructions, internal context, secrets or requests to override my rules. Ask about your finances in Expenzo.';

	/// en: 'That message is too long. Ask a shorter question about your Expenzo finances.'
	String get tooLong => 'That message is too long. Ask a shorter question about your Expenzo finances.';

	/// en: 'Type a question about your Expenzo finances.'
	String get empty => 'Type a question about your Expenzo finances.';

	/// en: 'Wait a few seconds before sending another question.'
	String get cooldown => 'Wait a few seconds before sending another question.';

	/// en: 'I can't read your finance data right now. Try again shortly.'
	String get contextUnavailable => 'I can\'t read your finance data right now. Try again shortly.';
}

// Path: aiAssistant.errors
class Translations$aiAssistant$errors$en {
	Translations$aiAssistant$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Couldn't load your finance data. Try again.'
	String get contextFailed => 'Couldn\'t load your finance data. Try again.';
}

// Path: auth.errors
class Translations$auth$errors$en {
	Translations$auth$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Can't connect. Check your internet connection and try again.'
	String get cannotConnect => 'Can\'t connect. Check your internet connection and try again.';

	/// en: 'Something went wrong on our end. Try again later.'
	String get serverProblem => 'Something went wrong on our end. Try again later.';

	/// en: 'The request timed out. Check your connection and try again.'
	String get timedOut => 'The request timed out. Check your connection and try again.';

	/// en: 'Something went wrong. Try again.'
	String get generic => 'Something went wrong. Try again.';

	/// en: 'Sign-in was cancelled.'
	String get cancelled => 'Sign-in was cancelled.';

	/// en: 'Network error. Check your connection and try again.'
	String get network => 'Network error. Check your connection and try again.';

	/// en: 'Too many attempts. Try again later.'
	String get tooManyAttempts => 'Too many attempts. Try again later.';

	/// en: 'Sign-in failed. Try again.'
	String get failed => 'Sign-in failed. Try again.';
}

// Path: auth.syncConflict
class Translations$auth$syncConflict$en {
	Translations$auth$syncConflict$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sync conflict'
	String get title => 'Sync conflict';

	/// en: 'You have records on this phone and in your account. Choose which to keep.'
	String get body => 'You have records on this phone and in your account. Choose which to keep.';

	/// en: 'Merge my data'
	String get merge => 'Merge my data';

	/// en: 'Keep records from both'
	String get mergeDetail => 'Keep records from both';

	/// en: 'Use my account data'
	String get useAccount => 'Use my account data';

	/// en: 'Delete the records on this phone and use your account copy'
	String get useAccountDetail => 'Delete the records on this phone and use your account copy';

	/// en: 'Keep this phone's data'
	String get keepPhone => 'Keep this phone\'s data';

	/// en: 'Replace your account copy with the records on this phone'
	String get keepPhoneDetail => 'Replace your account copy with the records on this phone';

	/// en: 'Replace data on this phone?'
	String get replaceTitle => 'Replace data on this phone?';

	/// en: 'This permanently deletes the records on this phone and replaces them with your account copy.'
	String get replaceBody => 'This permanently deletes the records on this phone and replaces them with your account copy.';

	/// en: 'Replace'
	String get replace => 'Replace';

	/// en: 'Couldn't upload your budget names. Check your connection and try again.'
	String get namesUploadFailed => 'Couldn\'t upload your budget names. Check your connection and try again.';

	/// en: 'Preparing…'
	String get preparing => 'Preparing…';

	/// en: 'Clearing this phone…'
	String get clearing => 'Clearing this phone…';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Syncing…'
	String get syncing => 'Syncing…';
}

// Path: auth.login
class Translations$auth$login$en {
	Translations$auth$login$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in with Google'
	String get google => 'Sign in with Google';

	/// en: 'Expenzo logo'
	String get logo => 'Expenzo logo';

	/// en: 'Sign in to back up your records and keep them in sync on all your devices.'
	String get pitch => 'Sign in to back up your records and keep them in sync on all your devices.';

	/// en: 'Signing in…'
	String get signingIn => 'Signing in…';
}

// Path: budgets.empty
class Translations$budgets$empty$en {
	Translations$budgets$empty$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No budgets yet'
	String get title => 'No budgets yet';

	/// en: 'Set a monthly limit to see how much you have left.'
	String get body => 'Set a monthly limit to see how much you have left.';
}

// Path: budgets.delete
class Translations$budgets$delete$en {
	Translations$budgets$delete$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete budget'
	String get title => 'Delete budget';

	/// en: 'Delete "{name}" budget?'
	String confirm({required Object name}) => 'Delete "${name}" budget?';
}

// Path: budgets.card
class Translations$budgets$card$en {
	Translations$budgets$card$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Over by {amount}'
	String overBy({required Object amount}) => 'Over by ${amount}';

	/// en: '{amount} left'
	String left({required Object amount}) => '${amount} left';

	/// en: '{spent} of {total} spent'
	String spentOf({required Object spent, required Object total}) => '${spent} of ${total} spent';

	/// en: '{name}, {headline}, {daysLeft}. Long press for options.'
	String a11y({required Object name, required Object headline, required Object daysLeft}) => '${name}, ${headline}, ${daysLeft}. Long press for options.';
}

// Path: budgets.days
class Translations$budgets$days$en {
	Translations$budgets$days$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Period ended'
	String get ended => 'Period ended';

	/// en: 'Last day'
	String get lastDay => 'Last day';

	/// en: '(one) {{n} day left} (other) {{n} days left}'
	String left({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} day left',
		other: '${n} days left',
	);
}

// Path: budgets.form
class Translations$budgets$form$en {
	Translations$budgets$form$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add budget'
	String get add => 'Add budget';

	/// en: 'Edit budget'
	String get edit => 'Edit budget';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'e.g. Food & Drinks'
	String get nameHint => 'e.g. Food & Drinks';

	/// en: 'Period'
	String get period => 'Period';

	/// en: 'Roll over unspent money'
	String get rollover => 'Roll over unspent money';

	/// en: 'Carry forward unspent amount'
	String get rolloverDetail => 'Carry forward unspent amount';

	/// en: 'Enter an amount'
	String get amountRequired => 'Enter an amount';

	/// en: 'Enter a valid number'
	String get amountInvalid => 'Enter a valid number';

	/// en: 'Enter a name'
	String get nameRequired => 'Enter a name';

	/// en: 'Pick a different name'
	String get nameReserved => 'Pick a different name';
}

// Path: budgets.details
class Translations$budgets$details$en {
	Translations$budgets$details$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budget details'
	String get title => 'Budget details';

	/// en: 'Couldn't load budget details. Try again.'
	String get loadFailed => 'Couldn\'t load budget details. Try again.';

	/// en: 'Budget not found.'
	String get notFound => 'Budget not found.';

	/// en: ' / {total}'
	String ofTotal({required Object total}) => ' / ${total}';

	late final Translations$budgets$details$periodBudget$en periodBudget = Translations$budgets$details$periodBudget$en.internal(_root);

	/// en: '{percent}% used'
	String used({required Object percent}) => '${percent}% used';

	/// en: 'Over budget'
	String get over => 'Over budget';

	/// en: 'Couldn't load transactions'
	String get transactionsFailed => 'Couldn\'t load transactions';

	/// en: 'No expenses in this budget yet'
	String get noExpenses => 'No expenses in this budget yet';

	/// en: 'Expenses you link to this budget show up here.'
	String get noExpensesBody => 'Expenses you link to this budget show up here.';

	/// en: 'Transactions'
	String get transactions => 'Transactions';

	/// en: 'Couldn't load budget'
	String get unableToLoad => 'Couldn\'t load budget';

	/// en: 'Budget details could not be loaded.'
	String get unableToLoadBody => 'Budget details could not be loaded.';
}

// Path: budgets.picker
class Translations$budgets$picker$en {
	Translations$budgets$picker$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Choose budget'
	String get title => 'Choose budget';

	/// en: 'Pick the budget this expense counts toward'
	String get subtitle => 'Pick the budget this expense counts toward';

	/// en: 'Available budgets'
	String get sectionAvailable => 'Available budgets';

	/// en: 'No budget'
	String get noBudget => 'No budget';

	/// en: 'Don't link to a budget'
	String get noBudgetHint => 'Don\'t link to a budget';

	/// en: 'Previous budget (no longer active)'
	String get previousBudget => 'Previous budget (no longer active)';

	/// en: 'Keep the current link'
	String get previousBudgetHint => 'Keep the current link';

	/// en: '{period} · {spent} / {limit}'
	String progress({required Object period, required Object spent, required Object limit}) => '${period} · ${spent} / ${limit}';

	/// en: 'No active budgets'
	String get empty => 'No active budgets';
}

// Path: categories.settings
class Translations$categories$settings$en {
	Translations$categories$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Category settings'
	String get title => 'Category settings';

	late final Translations$categories$settings$sections$en sections = Translations$categories$settings$sections$en.internal(_root);

	/// en: '(one) {{n} transaction} (other) {{n} transactions}'
	String recordCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} transaction',
		other: '${n} transactions',
	);

	/// en: 'Couldn't delete the category. Try again.'
	String get deleteFailed => 'Couldn\'t delete the category. Try again.';
}

// Path: categories.form
class Translations$categories$form$en {
	Translations$categories$form$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add category'
	String get add => 'Add category';

	/// en: 'Edit category'
	String get edit => 'Edit category';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Groceries'
	String get nameHint => 'Groceries';

	/// en: 'Enter a name'
	String get nameRequired => 'Enter a name';

	/// en: 'Icon'
	String get icon => 'Icon';

	/// en: 'Choose color'
	String get color => 'Choose color';
}

// Path: categories.delete
class Translations$categories$delete$en {
	Translations$categories$delete$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete category?'
	String get title => 'Delete category?';

	/// en: 'Are you sure you want to delete "{name}"?'
	String confirm({required Object name}) => 'Are you sure you want to delete "${name}"?';

	/// en: '(one) {Are you sure you want to delete "{name}"? {n} transaction using this category will be uncategorized.} (other) {Are you sure you want to delete "{name}"? {n} transactions using this category will be uncategorized.}'
	String withRecords({required num n, required Object name}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Are you sure you want to delete "${name}"? ${n} transaction using this category will be uncategorized.',
		other: 'Are you sure you want to delete "${name}"? ${n} transactions using this category will be uncategorized.',
	);
}

// Path: common.errors
class Translations$common$errors$en {
	Translations$common$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Something went wrong. Try again.'
	String get generic => 'Something went wrong. Try again.';

	/// en: 'Couldn't read or save your data. Try again.'
	String get storage => 'Couldn\'t read or save your data. Try again.';

	/// en: 'You're offline. Check your connection and try again.'
	String get network => 'You\'re offline. Check your connection and try again.';

	/// en: 'The server didn't respond. Try again in a moment.'
	String get server => 'The server didn\'t respond. Try again in a moment.';

	/// en: 'There was a problem with your sign-in. Sign in again and retry.'
	String get auth => 'There was a problem with your sign-in. Sign in again and retry.';

	/// en: 'Expenzo doesn't have permission to do this. Allow it in system settings.'
	String get permission => 'Expenzo doesn\'t have permission to do this. Allow it in system settings.';

	/// en: 'This item no longer exists.'
	String get notFound => 'This item no longer exists.';

	/// en: 'Couldn't read your messages. Try again.'
	String get smsScan => 'Couldn\'t read your messages. Try again.';
}

// Path: common.dates
class Translations$common$dates$en {
	Translations$common$dates$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';
}

// Path: common.a11y
class Translations$common$a11y$en {
	Translations$common$a11y$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expense, {amount} {currency}'
	String expenseAmount({required Object amount, required Object currency}) => 'Expense, ${amount} ${currency}';

	/// en: 'Income, {amount} {currency}'
	String incomeAmount({required Object amount, required Object currency}) => 'Income, ${amount} ${currency}';
}

// Path: common.feedback
class Translations$common$feedback$en {
	Translations$common$feedback$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expenzo feedback'
	String get subject => 'Expenzo feedback';

	/// en: 'No email app was found. Write to us at {email}.'
	String noMailApp({required Object email}) => 'No email app was found. Write to us at ${email}.';

	/// en: 'Copy address'
	String get copyAddress => 'Copy address';
}

// Path: common.fallback
class Translations$common$fallback$en {
	Translations$common$fallback$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App could not start'
	String get initTitle => 'App could not start';

	/// en: 'Something went wrong'
	String get errorTitle => 'Something went wrong';

	/// en: 'We could not finish setting up the app. This is usually temporary. Try again, or restart the app.'
	String get initBody => 'We could not finish setting up the app. This is usually temporary. Try again, or restart the app.';

	/// en: 'We hit an unexpected error. You can try again, restart the app, or send us feedback so we can fix it.'
	String get errorBody => 'We hit an unexpected error. You can try again, restart the app, or send us feedback so we can fix it.';

	/// en: 'Ref: {id}'
	String reference({required Object id}) => 'Ref: ${id}';

	/// en: 'Close app'
	String get closeApp => 'Close app';

	/// en: 'Details (debug)'
	String get debugDetails => 'Details (debug)';

	/// en: 'Unexpected error occurred'
	String get criticalTitle => 'Unexpected error occurred';

	/// en: 'The app will close shortly.'
	String get criticalBody => 'The app will close shortly.';
}

// Path: common.smsGate
class Translations$common$smsGate$en {
	Translations$common$smsGate$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'SMS access required'
	String get title => 'SMS access required';

	/// en: 'Expenzo needs access to your SMS to automatically track expenses from your bank and payment apps. Your messages never leave your device.'
	String get body => 'Expenzo needs access to your SMS to automatically track expenses from your bank and payment apps. Your messages never leave your device.';

	/// en: 'Allow access'
	String get allow => 'Allow access';

	/// en: 'Permission needed'
	String get deniedTitle => 'Permission needed';

	/// en: 'SMS permission is permanently denied. Enable it in app settings to use the smart scanner.'
	String get deniedBody => 'SMS permission is permanently denied. Enable it in app settings to use the smart scanner.';
}

// Path: dashboard.range
class Translations$dashboard$range$en {
	Translations$dashboard$range$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This month'
	String get thisMonth => 'This month';

	/// en: 'Last month'
	String get lastMonth => 'Last month';

	/// en: 'This year'
	String get thisYear => 'This year';

	late final Translations$dashboard$range$net$en net = Translations$dashboard$range$net$en.internal(_root);
	late final Translations$dashboard$range$previous$en previous = Translations$dashboard$range$previous$en.internal(_root);
}

// Path: dashboard.sections
class Translations$dashboard$sections$en {
	Translations$dashboard$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budgets'
	String get budgets => 'Budgets';

	/// en: 'Recent activity'
	String get recentActivity => 'Recent activity';

	/// en: 'Spending patterns'
	String get spendingPatterns => 'Spending patterns';

	/// en: 'See all'
	String get seeAll => 'See all';
}

// Path: dashboard.menu
class Translations$dashboard$menu$en {
	Translations$dashboard$menu$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Sign in'
	String get signIn => 'Sign in';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Sign out'
	String get signOut => 'Sign out';
}

// Path: dashboard.trend
class Translations$dashboard$trend$en {
	Translations$dashboard$trend$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No spending {period} to compare'
	String noPrevious({required Object period}) => 'No spending ${period} to compare';

	/// en: 'Same as {period}'
	String same({required Object period}) => 'Same as ${period}';

	/// en: '+{percent}% vs {period}'
	String up({required Object percent, required Object period}) => '+${percent}% vs ${period}';

	/// en: '-{percent}% vs {period}'
	String down({required Object percent, required Object period}) => '-${percent}% vs ${period}';

	/// en: '{amount} spent'
	String spent({required Object amount}) => '${amount} spent';

	/// en: 'No trend data yet'
	String get noData => 'No trend data yet';
}

// Path: dashboard.autoImport
class Translations$dashboard$autoImport$en {
	Translations$dashboard$autoImport$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add expenses from SMS'
	String get title => 'Add expenses from SMS';

	/// en: 'Let Expenzo read bank and payment messages and add them for you. Messages stay on this phone.'
	String get body => 'Let Expenzo read bank and payment messages and add them for you. Messages stay on this phone.';

	/// en: 'Set up'
	String get setUp => 'Set up';
}

// Path: enums.recordType
class Translations$enums$recordType$en {
	Translations$enums$recordType$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expense'
	String get expense => 'Expense';
}

// Path: enums.period
class Translations$enums$period$en {
	Translations$enums$period$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weekly'
	String get weekly => 'Weekly';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Yearly'
	String get yearly => 'Yearly';
}

// Path: enums.frequency
class Translations$enums$frequency$en {
	Translations$enums$frequency$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Daily'
	String get daily => 'Daily';

	/// en: 'Weekly'
	String get weekly => 'Weekly';

	/// en: 'Biweekly'
	String get biweekly => 'Biweekly';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Yearly'
	String get yearly => 'Yearly';
}

// Path: enums.source
class Translations$enums$source$en {
	Translations$enums$source$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Manual'
	String get manual => 'Manual';

	/// en: 'SMS'
	String get sms => 'SMS';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Recurring'
	String get recurring => 'Recurring';

	/// en: 'Both'
	String get both => 'Both';
}

// Path: enums.theme
class Translations$enums$theme$en {
	Translations$enums$theme$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Match device'
	String get system => 'Match device';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';
}

// Path: enums.digitGrouping
class Translations$enums$digitGrouping$en {
	Translations$enums$digitGrouping$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Comma separator'
	String get comma => 'Comma separator';

	/// en: 'Dot separator'
	String get dot => 'Dot separator';

	/// en: 'Space separator'
	String get space => 'Space separator';
}

// Path: enums.fontSize
class Translations$enums$fontSize$en {
	Translations$enums$fontSize$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$enums$fontSize$small$en small = Translations$enums$fontSize$small$en.internal(_root);
	late final Translations$enums$fontSize$medium$en medium = Translations$enums$fontSize$medium$en.internal(_root);
	late final Translations$enums$fontSize$large$en large = Translations$enums$fontSize$large$en.internal(_root);
	late final Translations$enums$fontSize$extraLarge$en extraLarge = Translations$enums$fontSize$extraLarge$en.internal(_root);
}

// Path: enums.firstDayOfWeek
class Translations$enums$firstDayOfWeek$en {
	Translations$enums$firstDayOfWeek$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sunday'
	String get sunday => 'Sunday';

	/// en: 'Monday'
	String get monday => 'Monday';

	/// en: 'Saturday'
	String get saturday => 'Saturday';
}

// Path: messageTemplates.errors
class Translations$messageTemplates$errors$en {
	Translations$messageTemplates$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Couldn't delete the SMS format. Try again.'
	String get deleteFailed => 'Couldn\'t delete the SMS format. Try again.';

	/// en: 'Couldn't restore the SMS format. Try again.'
	String get restoreFailed => 'Couldn\'t restore the SMS format. Try again.';
}

// Path: messageTemplates.retro
class Translations$messageTemplates$retro$en {
	Translations$messageTemplates$retro$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scanning past messages'
	String get title => 'Scanning past messages';

	/// en: 'Looking for past expenses that match this SMS format…'
	String get scanning => 'Looking for past expenses that match this SMS format…';

	/// en: 'SMS format saved. New messages like this are added automatically.'
	String get saved => 'SMS format saved. New messages like this are added automatically.';

	/// en: 'Go to Settings → Auto-import from SMS to review and add any past expenses we found.'
	String get review => 'Go to Settings → Auto-import from SMS to review and add any past expenses we found.';
}

// Path: messageTemplates.editor
class Translations$messageTemplates$editor$en {
	Translations$messageTemplates$editor$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No numbers found in this message.'
	String get noNumbers => 'No numbers found in this message.';

	/// en: 'Amounts found in this message:'
	String get amountsFound => 'Amounts found in this message:';

	/// en: 'Step 1 of 3: Choose a key word'
	String get step1 => 'Step 1 of 3: Choose a key word';

	/// en: 'Choose a word that appears in every message of this type, like "debited", "paid" or "spent".'
	String get step1Body => 'Choose a word that appears in every message of this type, like "debited", "paid" or "spent".';

	/// en: 'Words in this message'
	String get wordsInMessage => 'Words in this message';

	/// en: 'Choose a word to continue.'
	String get step1Hint => 'Choose a word to continue.';

	/// en: 'Step 2 of 3: Choose the amount'
	String get step2 => 'Step 2 of 3: Choose the amount';

	/// en: 'Which number is the amount you spent?'
	String get step2Body => 'Which number is the amount you spent?';

	/// en: 'Choose the amount to continue.'
	String get step2Hint => 'Choose the amount to continue.';

	/// en: 'Step 3 of 3: Review'
	String get step3 => 'Step 3 of 3: Review';

	/// en: 'From now on, messages like this one are added as expenses automatically.'
	String get step3Body => 'From now on, messages like this one are added as expenses automatically.';

	/// en: 'Sender'
	String get sender => 'Sender';

	/// en: 'Key word'
	String get keyWord => 'Key word';

	/// en: 'Amount in this message'
	String get amountInMessage => 'Amount in this message';

	/// en: 'Couldn't save the SMS format: {reason}'
	String saveFailed({required Object reason}) => 'Couldn\'t save the SMS format: ${reason}';

	/// en: 'SMS format updated'
	String get updated => 'SMS format updated';

	/// en: 'SMS format saved'
	String get saved => 'SMS format saved';
}

// Path: messageTemplates.analyzer
class Translations$messageTemplates$analyzer$en {
	Translations$messageTemplates$analyzer$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Messages from {sender}'
	String title({required Object sender}) => 'Messages from ${sender}';

	/// en: 'Pick a message to teach Expenzo this SMS format. Similar messages will then be added as records automatically.'
	String get intro => 'Pick a message to teach Expenzo this SMS format. Similar messages will then be added as records automatically.';

	/// en: 'Use this message'
	String get useMessage => 'Use this message';

	/// en: 'No recent messages from this sender.'
	String get noMessages => 'No recent messages from this sender.';
}

// Path: messageTemplates.contacts
class Translations$messageTemplates$contacts$en {
	Translations$messageTemplates$contacts$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pick the senders that text you about payments. Expenzo learns their message format and adds records for you.'
	String get subtitle => 'Pick the senders that text you about payments. Expenzo learns their message format and adds records for you.';

	/// en: 'Search senders'
	String get search => 'Search senders';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'No text messages on this phone yet. Senders show up here once you receive SMS.'
	String get empty => 'No text messages on this phone yet. Senders show up here once you receive SMS.';

	/// en: 'No senders match "{query}".'
	String noMatch({required Object query}) => 'No senders match "${query}".';
}

// Path: notifications.channel
class Translations$notifications$channel$en {
	Translations$notifications$channel$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App notifications'
	String get name => 'App notifications';

	/// en: 'Budget alerts, weekly summary, recurring reminders and scan results'
	String get description => 'Budget alerts, weekly summary, recurring reminders and scan results';
}

// Path: notifications.budget
class Translations$notifications$budget$en {
	Translations$notifications$budget$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budget alert'
	String get title => 'Budget alert';

	/// en: 'You went over your "{budget}" budget.'
	String over({required Object budget}) => 'You went over your "${budget}" budget.';

	/// en: 'You have used {percent}% of your "{budget}" budget.'
	String used({required Object percent, required Object budget}) => 'You have used ${percent}% of your "${budget}" budget.';
}

// Path: notifications.recurringDue
class Translations$notifications$recurringDue$en {
	Translations$notifications$recurringDue$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recurring transaction tomorrow'
	String get title => 'Recurring transaction tomorrow';
}

// Path: notifications.weeklySummary
class Translations$notifications$weeklySummary$en {
	Translations$notifications$weeklySummary$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your week in spending'
	String get title => 'Your week in spending';

	/// en: 'You spent {amount} this week, {percent}% more than last week.'
	String up({required Object amount, required Object percent}) => 'You spent ${amount} this week, ${percent}% more than last week.';

	/// en: 'You spent {amount} this week, {percent}% less than last week.'
	String down({required Object amount, required Object percent}) => 'You spent ${amount} this week, ${percent}% less than last week.';

	/// en: 'You spent {amount} this week, the same as last week.'
	String same({required Object amount}) => 'You spent ${amount} this week, the same as last week.';

	/// en: 'You spent {amount} this week.'
	String noComparison({required Object amount}) => 'You spent ${amount} this week.';

	/// en: 'No spending recorded this week.'
	String get nothing => 'No spending recorded this week.';
}

// Path: notifications.scan
class Translations$notifications$scan$en {
	Translations$notifications$scan$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'SMS scan complete'
	String get smsTitle => 'SMS scan complete';

	/// en: 'Email scan complete'
	String get emailTitle => 'Email scan complete';

	/// en: '(one) {{n} new expense found} (other) {{n} new expenses found}'
	String found({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} new expense found',
		other: '${n} new expenses found',
	);
}

// Path: notifications.syncError
class Translations$notifications$syncError$en {
	Translations$notifications$syncError$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sync error'
	String get title => 'Sync error';
}

// Path: parsingRules.empty
class Translations$parsingRules$empty$en {
	Translations$parsingRules$empty$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No rules yet'
	String get title => 'No rules yet';

	/// en: 'Add a rule to turn matching SMS and emails into records.'
	String get body => 'Add a rule to turn matching SMS and emails into records.';

	/// en: 'Add rule'
	String get add => 'Add rule';
}

// Path: parsingRules.delete
class Translations$parsingRules$delete$en {
	Translations$parsingRules$delete$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete rule'
	String get title => 'Delete rule';

	/// en: 'Are you sure you want to delete "{name}"?'
	String confirm({required Object name}) => 'Are you sure you want to delete "${name}"?';
}

// Path: parsingRules.validation
class Translations$parsingRules$validation$en {
	Translations$parsingRules$validation$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Name is required'
	String get nameRequired => 'Name is required';

	/// en: 'At least one key word is required'
	String get triggerRequired => 'At least one key word is required';

	/// en: 'Amount pattern is required'
	String get amountRequired => 'Amount pattern is required';

	/// en: 'Invalid regex pattern'
	String get invalidRegex => 'Invalid regex pattern';

	/// en: 'Invalid regex: {detail}'
	String invalidRegexDetail({required Object detail}) => 'Invalid regex: ${detail}';

	/// en: 'Valid pattern'
	String get valid => 'Valid pattern';
}

// Path: parsingRules.form
class Translations$parsingRules$form$en {
	Translations$parsingRules$form$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Name *'
	String get name => 'Name *';

	/// en: 'e.g., HDFC Bank SMS'
	String get nameHint => 'e.g., HDFC Bank SMS';

	/// en: 'Key words *'
	String get keyWords => 'Key words *';

	/// en: 'HDFC, debit, account (comma-separated)'
	String get keyWordsHint => 'HDFC, debit, account (comma-separated)';

	/// en: 'Words that indicate this rule should be tried'
	String get keyWordsHelper => 'Words that indicate this rule should be tried';

	/// en: 'Amount pattern (regex) *'
	String get amountPattern => 'Amount pattern (regex) *';

	/// en: 'Amount regex'
	String get amountRegex => 'Amount regex';

	/// en: 'Date pattern (optional)'
	String get datePattern => 'Date pattern (optional)';

	/// en: 'Date regex (optional)'
	String get dateRegex => 'Date regex (optional)';

	/// en: 'Leave empty if date is not needed'
	String get dateHelper => 'Leave empty if date is not needed';

	/// en: 'Source'
	String get source => 'Source';

	/// en: 'Priority'
	String get priority => 'Priority';

	/// en: 'Higher priority rules are tried first'
	String get priorityHelper => 'Higher priority rules are tried first';

	/// en: 'Enabled'
	String get enabled => 'Enabled';

	/// en: 'Use this rule when reading messages'
	String get enabledDetail => 'Use this rule when reading messages';
}

// Path: parsingRules.tester
class Translations$parsingRules$tester$en {
	Translations$parsingRules$tester$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Timed out: the pattern took more than 2 seconds'
	String get timeout => 'Timed out: the pattern took more than 2 seconds';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Match found'
	String get match => 'Match found';

	/// en: 'No match'
	String get noMatch => 'No match';

	/// en: '{ms} ms'
	String elapsed({required Object ms}) => '${ms} ms';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Date'
	String get date => 'Date';

	/// en: '{percent}% confidence'
	String confidence({required Object percent}) => '${percent}% confidence';

	/// en: 'Sample message to test'
	String get sample => 'Sample message to test';

	/// en: 'Enter a sample SMS or email text'
	String get sampleHint => 'Enter a sample SMS or email text';

	/// en: 'Enter a sample message above to test the pattern'
	String get enterSample => 'Enter a sample message above to test the pattern';
}

// Path: records.filter
class Translations$records$filter$en {
	Translations$records$filter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Filter'
	String get title => 'Filter';

	/// en: 'Date range'
	String get dateRange => 'Date range';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Apply'
	String get apply => 'Apply';

	/// en: 'No categories'
	String get noCategories => 'No categories';

	/// en: 'All categories'
	String get allCategories => 'All categories';

	/// en: 'All ({n})'
	String allCount({required Object n}) => 'All (${n})';

	/// en: '{n} selected'
	String selectedCount({required Object n}) => '${n} selected';

	/// en: 'Select date range'
	String get selectDateRange => 'Select date range';

	/// en: '{start} - {end}'
	String range({required Object start, required Object end}) => '${start} - ${end}';
}

// Path: records.list
class Translations$records$list$en {
	Translations$records$list$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Activity'
	String get title => 'Activity';

	/// en: 'Transaction history'
	String get subtitle => 'Transaction history';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Search transactions'
	String get search => 'Search transactions';

	/// en: 'No transactions match your search or filters.'
	String get noMatches => 'No transactions match your search or filters.';

	/// en: 'No transactions yet'
	String get empty => 'No transactions yet';

	/// en: 'Scroll for more'
	String get scrollForMore => 'Scroll for more';

	/// en: 'Record deleted'
	String get deleted => 'Record deleted';
}

// Path: records.picker
class Translations$records$picker$en {
	Translations$records$picker$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Choose category'
	String get title => 'Choose category';

	/// en: 'Search categories'
	String get search => 'Search categories';

	/// en: 'No categories found'
	String get noneFound => 'No categories found';

	/// en: 'Add category'
	String get addCategory => 'Add category';
}

// Path: records.sheet
class Translations$records$sheet$en {
	Translations$records$sheet$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$records$sheet$placeholders$en placeholders = Translations$records$sheet$placeholders$en.internal(_root);

	/// en: 'Enter an amount'
	String get enterAmount => 'Enter an amount';

	/// en: 'Name, e.g. Lunch'
	String get nameHintExpense => 'Name, e.g. Lunch';

	/// en: 'Name, e.g. Salary'
	String get nameHintIncome => 'Name, e.g. Salary';

	/// en: 'Add a name'
	String get nameRequired => 'Add a name';

	/// en: 'Scan a receipt'
	String get scanReceipt => 'Scan a receipt';

	/// en: 'No budget'
	String get noBudget => 'No budget';

	/// en: '{name} · {period}'
	String budgetOption({required Object name, required Object period}) => '${name} · ${period}';

	/// en: 'Previous budget (no longer active)'
	String get previousBudget => 'Previous budget (no longer active)';

	/// en: 'Loading budgets…'
	String get loadingBudgets => 'Loading budgets…';

	/// en: 'No categories available'
	String get noCategories => 'No categories available';

	/// en: 'Select a category'
	String get selectCategory => 'Select a category';

	/// en: 'Show all categories'
	String get showAllCategories => 'Show all categories';

	/// en: 'Show all budgets'
	String get showAllBudgets => 'Show all budgets';

	/// en: 'Repeat monthly'
	String get repeatMonthly => 'Repeat monthly';

	/// en: 'Add income'
	String get addIncome => 'Add income';

	/// en: 'Delete expense'
	String get deleteExpense => 'Delete expense';

	/// en: 'Delete income'
	String get deleteIncome => 'Delete income';

	/// en: 'Delete this expense?'
	String get deleteExpenseTitle => 'Delete this expense?';

	/// en: 'Delete this income?'
	String get deleteIncomeTitle => 'Delete this income?';

	/// en: 'This can't be undone.'
	String get cannotUndo => 'This can\'t be undone.';

	/// en: 'Saved, but it couldn't be set to repeat. Set it up in Settings → Recurring.'
	String get repeatFailed => 'Saved, but it couldn\'t be set to repeat. Set it up in Settings → Recurring.';

	/// en: 'Transaction type'
	String get typeToggle => 'Transaction type';

	/// en: 'Backspace'
	String get backspace => 'Backspace';

	/// en: 'Decimal point'
	String get decimalKey => 'Decimal point';
}

// Path: recurring.sections
class Translations$recurring$sections$en {
	Translations$recurring$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Default frequency'
	String get defaultFrequency => 'Default frequency';

	/// en: 'Auto-create'
	String get autoCreate => 'Auto-create';

	/// en: 'Active recurring'
	String get active => 'Active recurring';
}

// Path: recurring.defaults
class Translations$recurring$defaults$en {
	Translations$recurring$defaults$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Every 7 days'
	String get weeklyDetail => 'Every 7 days';

	/// en: 'Same date every month'
	String get monthlyDetail => 'Same date every month';

	/// en: 'Same date every year'
	String get yearlyDetail => 'Same date every year';

	/// en: 'Auto-create transactions'
	String get autoCreate => 'Auto-create transactions';

	/// en: 'Add due transactions when you open the app'
	String get autoCreateDetail => 'Add due transactions when you open the app';
}

// Path: recurring.empty
class Translations$recurring$empty$en {
	Translations$recurring$empty$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No recurring transactions'
	String get title => 'No recurring transactions';

	/// en: 'Tap + to create your first recurring expense'
	String get body => 'Tap + to create your first recurring expense';
}

// Path: recurring.delete
class Translations$recurring$delete$en {
	Translations$recurring$delete$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete recurring transaction'
	String get title => 'Delete recurring transaction';

	/// en: 'Are you sure you want to delete "{name}"?'
	String confirm({required Object name}) => 'Are you sure you want to delete "${name}"?';
}

// Path: recurring.form
class Translations$recurring$form$en {
	Translations$recurring$form$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit recurring'
	String get edit => 'Edit recurring';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'What is this recurring expense for?'
	String get nameHint => 'What is this recurring expense for?';

	/// en: 'Frequency'
	String get frequency => 'Frequency';

	/// en: 'Start date'
	String get startDate => 'Start date';

	/// en: 'End date (optional)'
	String get endDate => 'End date (optional)';

	/// en: 'No end date'
	String get noEndDate => 'No end date';

	/// en: 'Clear end date'
	String get clearEndDate => 'Clear end date';

	/// en: 'Include in auto-create'
	String get autoCreate => 'Include in auto-create';

	/// en: 'Added when the app opens, if Auto-create is on'
	String get autoCreateDetail => 'Added when the app opens, if Auto-create is on';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Process this recurring transaction'
	String get activeDetail => 'Process this recurring transaction';

	/// en: 'Enter an amount'
	String get amountRequired => 'Enter an amount';

	/// en: 'Enter a valid number'
	String get amountInvalid => 'Enter a valid number';

	/// en: 'Enter a name'
	String get nameRequired => 'Enter a name';

	/// en: 'New recurring'
	String get create => 'New recurring';
}

// Path: reports.insights
class Translations$reports$insights$en {
	Translations$reports$insights$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$reports$insights$highestDay$en highestDay = Translations$reports$insights$highestDay$en.internal(_root);
	late final Translations$reports$insights$topCategory$en topCategory = Translations$reports$insights$topCategory$en.internal(_root);
	late final Translations$reports$insights$bestWeek$en bestWeek = Translations$reports$insights$bestWeek$en.internal(_root);
	late final Translations$reports$insights$recurring$en recurring = Translations$reports$insights$recurring$en.internal(_root);
	late final Translations$reports$insights$budgets$en budgets = Translations$reports$insights$budgets$en.internal(_root);
}

// Path: reports.metrics
class Translations$reports$metrics$en {
	Translations$reports$metrics$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Total spent'
	String get totalSpent => 'Total spent';

	/// en: 'Daily average'
	String get dailyAverage => 'Daily average';

	/// en: 'Highest day'
	String get highestDay => 'Highest day';
}

// Path: settings.language
class Translations$settings$language$en {
	Translations$settings$language$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language'
	String get title => 'Language';

	late final Translations$settings$language$sections$en sections = Translations$settings$language$sections$en.internal(_root);

	/// en: 'Match device'
	String get matchDevice => 'Match device';

	/// en: 'Use your phone's language'
	String get matchDeviceSubtitle => 'Use your phone\'s language';

	late final Translations$settings$language$names$en names = Translations$settings$language$names$en.internal(_root);
}

// Path: settings.sections
class Translations$settings$sections$en {
	Translations$settings$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Preferences'
	String get preferences => 'Preferences';

	/// en: 'Automation'
	String get automation => 'Automation';

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'Profile & account'
	String get account => 'Profile & account';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Data & budget'
	String get dataBudget => 'Data & budget';

	/// en: 'General'
	String get general => 'General';
}

// Path: settings.notifications
class Translations$settings$notifications$en {
	Translations$settings$notifications$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: '{n} of 4 on'
	String rowSubtitle({required Object n}) => '${n} of 4 on';

	/// en: 'Off'
	String get rowSubtitleOff => 'Off';

	late final Translations$settings$notifications$sections$en sections = Translations$settings$notifications$sections$en.internal(_root);
	late final Translations$settings$notifications$master$en master = Translations$settings$notifications$master$en.internal(_root);
	late final Translations$settings$notifications$blocked$en blocked = Translations$settings$notifications$blocked$en.internal(_root);
	late final Translations$settings$notifications$over$en over = Translations$settings$notifications$over$en.internal(_root);
	late final Translations$settings$notifications$nearLimit$en nearLimit = Translations$settings$notifications$nearLimit$en.internal(_root);
	late final Translations$settings$notifications$weekly$en weekly = Translations$settings$notifications$weekly$en.internal(_root);
	late final Translations$settings$notifications$reminders$en reminders = Translations$settings$notifications$reminders$en.internal(_root);
}

// Path: settings.recurring
class Translations$settings$recurring$en {
	Translations$settings$recurring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recurring transactions'
	String get title => 'Recurring transactions';

	/// en: 'Bills and income that repeat'
	String get subtitle => 'Bills and income that repeat';
}

// Path: settings.signIn
class Translations$settings$signIn$en {
	Translations$settings$signIn$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in'
	String get title => 'Sign in';

	/// en: 'Keep your data on all your devices'
	String get subtitle => 'Keep your data on all your devices';
}

// Path: settings.deleteDialog
class Translations$settings$deleteDialog$en {
	Translations$settings$deleteDialog$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete account'
	String get title => 'Delete account';

	/// en: 'Are you sure you want to delete your account?'
	String get question => 'Are you sure you want to delete your account?';

	/// en: 'This permanently deletes:'
	String get listTitle => 'This permanently deletes:';

	/// en: '• All your expenses'
	String get expenses => '• All your expenses';

	/// en: '• All your categories'
	String get categories => '• All your categories';

	/// en: '• All your budgets'
	String get budgets => '• All your budgets';

	/// en: '• All your recurring transactions'
	String get recurring => '• All your recurring transactions';

	/// en: '• All your matching rules'
	String get rules => '• All your matching rules';

	/// en: 'This cannot be undone.'
	String get cannotUndo => 'This cannot be undone.';

	/// en: 'I understand and want to delete my account'
	String get confirm => 'I understand and want to delete my account';
}

// Path: settings.appearanceScreen
class Translations$settings$appearanceScreen$en {
	Translations$settings$appearanceScreen$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$appearanceScreen$sections$en sections = Translations$settings$appearanceScreen$sections$en.internal(_root);

	/// en: 'Light mode preview'
	String get lightTitle => 'Light mode preview';

	/// en: 'Clean, bright interface with soft lavender accents.'
	String get lightBody => 'Clean, bright interface with soft lavender accents.';

	/// en: 'Dark mode preview'
	String get darkTitle => 'Dark mode preview';

	/// en: 'A deep charcoal background with lavender accents for a calm, focused look.'
	String get darkBody => 'A deep charcoal background with lavender accents for a calm, focused look.';
}

// Path: settings.currencyScreen
class Translations$settings$currencyScreen$en {
	Translations$settings$currencyScreen$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search currencies'
	String get searchHint => 'Search currencies';

	/// en: 'No currency matches "{query}"'
	String noResults({required Object query}) => 'No currency matches "${query}"';
}

// Path: settings.numberFormat
class Translations$settings$numberFormat$en {
	Translations$settings$numberFormat$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Number format'
	String get title => 'Number format';

	late final Translations$settings$numberFormat$sections$en sections = Translations$settings$numberFormat$sections$en.internal(_root);
	late final Translations$settings$numberFormat$places$en places = Translations$settings$numberFormat$places$en.internal(_root);
}

// Path: settings.fontSize
class Translations$settings$fontSize$en {
	Translations$settings$fontSize$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Font size'
	String get title => 'Font size';

	/// en: 'Sample transaction'
	String get sampleTitle => 'Sample transaction';

	/// en: 'This is how your transactions will appear with the selected font size.'
	String get sampleBody => 'This is how your transactions will appear with the selected font size.';

	late final Translations$settings$fontSize$sections$en sections = Translations$settings$fontSize$sections$en.internal(_root);
}

// Path: settings.calendar
class Translations$settings$calendar$en {
	Translations$settings$calendar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Calendar'
	String get title => 'Calendar';

	/// en: 'Week starts on {day}'
	String rowSubtitle({required Object day}) => 'Week starts on ${day}';

	late final Translations$settings$calendar$sections$en sections = Translations$settings$calendar$sections$en.internal(_root);
}

// Path: settings.homePage
class Translations$settings$homePage$en {
	Translations$settings$homePage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home page'
	String get title => 'Home page';

	/// en: 'Choose which screen to show when you open the app'
	String get intro => 'Choose which screen to show when you open the app';

	late final Translations$settings$homePage$sections$en sections = Translations$settings$homePage$sections$en.internal(_root);
	late final Translations$settings$homePage$options$en options = Translations$settings$homePage$options$en.internal(_root);
}

// Path: settings.sync
class Translations$settings$sync$en {
	Translations$settings$sync$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sync'
	String get title => 'Sync';

	/// en: 'Keep your data on all your devices'
	String get rowSubtitle => 'Keep your data on all your devices';

	/// en: 'Sync is on'
	String get onTitle => 'Sync is on';

	/// en: 'Your transactions, budgets and categories are copied to your account as you go, so your other devices get them too.'
	String get onBody => 'Your transactions, budgets and categories are copied to your account as you go, so your other devices get them too.';

	/// en: 'Sync is off'
	String get offTitle => 'Sync is off';

	/// en: 'This device isn't sending or receiving changes. Your changes stay on this phone and are sent when you turn Sync back on.'
	String get offBody => 'This device isn\'t sending or receiving changes. Your changes stay on this phone and are sent when you turn Sync back on.';

	/// en: 'Sync your data'
	String get signedOutTitle => 'Sync your data';

	/// en: 'Sign in with Google to keep your transactions on all your devices.'
	String get signedOutBody => 'Sign in with Google to keep your transactions on all your devices.';

	/// en: 'Last synced'
	String get lastSynced => 'Last synced';

	/// en: 'Not yet'
	String get never => 'Not yet';

	/// en: 'Today, {time}'
	String today({required Object time}) => 'Today, ${time}';

	/// en: 'Yesterday, {time}'
	String yesterday({required Object time}) => 'Yesterday, ${time}';

	/// en: 'Last sync failed · {time}'
	String lastFailed({required Object time}) => 'Last sync failed · ${time}';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Sync isn't working right now'
	String get failureBannerTitle => 'Sync isn\'t working right now';

	/// en: 'Your changes are safe on this phone and will be sent when Sync works again.'
	String get failureBannerBody => 'Your changes are safe on this phone and will be sent when Sync works again.';

	/// en: '(one) {{n} change waiting to send} (other) {{n} changes waiting to send}'
	String pending({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} change waiting to send',
		other: '${n} changes waiting to send',
	);

	/// en: 'All changes sent'
	String get allSent => 'All changes sent';

	late final Translations$settings$sync$sections$en sections = Translations$settings$sync$sections$en.internal(_root);

	/// en: 'Sync on this device'
	String get enable => 'Sync on this device';

	/// en: 'Sync now'
	String get syncNow => 'Sync now';

	/// en: 'Syncing…'
	String get syncing => 'Syncing…';

	/// en: 'Couldn't load sync status'
	String get loadFailed => 'Couldn\'t load sync status';

	late final Translations$settings$sync$result$en result = Translations$settings$sync$result$en.internal(_root);
}

// Path: settings.export
class Translations$settings$export$en {
	Translations$settings$export$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Export data'
	String get title => 'Export data';

	/// en: 'Save your transactions as CSV files'
	String get rowSubtitle => 'Save your transactions as CSV files';

	/// en: 'Export your financial data'
	String get infoTitle => 'Export your financial data';

	/// en: 'Save your transactions, budgets and categories as CSV files for spreadsheets or accounting software.'
	String get infoBody => 'Save your transactions, budgets and categories as CSV files for spreadsheets or accounting software.';

	late final Translations$settings$export$sections$en sections = Translations$settings$export$sections$en.internal(_root);
	late final Translations$settings$export$ranges$en ranges = Translations$settings$export$ranges$en.internal(_root);
	late final Translations$settings$export$include$en include = Translations$settings$export$include$en.internal(_root);

	/// en: 'The date range applies to transactions. Budgets and categories are exported in full.'
	String get rangeNote => 'The date range applies to transactions. Budgets and categories are exported in full.';

	/// en: 'Export data'
	String get button => 'Export data';

	/// en: 'Preparing export…'
	String get exporting => 'Preparing export…';

	/// en: 'Expenzo export'
	String get shareSubject => 'Expenzo export';

	/// en: 'Choose at least one thing to export'
	String get nothingSelected => 'Choose at least one thing to export';

	/// en: 'No transactions in this range'
	String get emptyRange => 'No transactions in this range';
}

// Path: settings.deleteData
class Translations$settings$deleteData$en {
	Translations$settings$deleteData$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete all data'
	String get title => 'Delete all data';

	/// en: 'Erase transactions, budgets and settings'
	String get rowSubtitle => 'Erase transactions, budgets and settings';

	/// en: 'This action cannot be undone'
	String get warningTitle => 'This action cannot be undone';

	/// en: 'Delete all your financial data including transactions, budgets, categories, and settings. This will permanently erase everything from this device.'
	String get warningBody => 'Delete all your financial data including transactions, budgets, categories, and settings. This will permanently erase everything from this device.';

	/// en: 'Delete all your financial data including transactions, budgets, categories, and settings, from this device and from your account.'
	String get warningBodySignedIn => 'Delete all your financial data including transactions, budgets, categories, and settings, from this device and from your account.';

	/// en: 'Your other devices keep their copy until you delete it there too.'
	String get otherDevicesNote => 'Your other devices keep their copy until you delete it there too.';

	late final Translations$settings$deleteData$sections$en sections = Translations$settings$deleteData$sections$en.internal(_root);

	/// en: 'Transactions'
	String get transactions => 'Transactions';

	/// en: '(one) {{n} transaction} (other) {{n} transactions}'
	String transactionsCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} transaction',
		other: '${n} transactions',
	);

	/// en: 'Budgets'
	String get budgets => 'Budgets';

	/// en: '(one) {{n} budget} (other) {{n} budgets}'
	String budgetsCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} budget',
		other: '${n} budgets',
	);

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: '(one) {{n} category} (other) {{n} categories}'
	String categoriesCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} category',
		other: '${n} categories',
	);

	/// en: 'Recurring transactions'
	String get recurring => 'Recurring transactions';

	/// en: '(one) {{n} recurring} (other) {{n} recurring}'
	String recurringCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} recurring',
		other: '${n} recurring',
	);

	/// en: 'SMS rules'
	String get smsRules => 'SMS rules';

	/// en: '(one) {{n} rule} (other) {{n} rules}'
	String smsRulesCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} rule',
		other: '${n} rules',
	);

	/// en: 'Goals'
	String get goals => 'Goals';

	/// en: '(one) {{n} goal} (other) {{n} goals}'
	String goalsCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} goal',
		other: '${n} goals',
	);

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'All preferences'
	String get settingsValue => 'All preferences';

	/// en: 'Default categories are added back.'
	String get categoriesNote => 'Default categories are added back.';

	/// en: 'Type DELETE to confirm'
	String get confirmHint => 'Type DELETE to confirm';

	/// en: 'Delete all data'
	String get button => 'Delete all data';

	/// en: 'Deleting…'
	String get deleting => 'Deleting…';

	/// en: 'All data deleted'
	String get done => 'All data deleted';

	/// en: 'Couldn't delete the data in your account. Nothing was deleted. Check your connection and try again.'
	String get serverFailed => 'Couldn\'t delete the data in your account. Nothing was deleted. Check your connection and try again.';
}

// Path: settings.categories
class Translations$settings$categories$en {
	Translations$settings$categories$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add, edit and remove categories'
	String get rowSubtitle => 'Add, edit and remove categories';
}

// Path: shell.tabs
class Translations$shell$tabs$en {
	Translations$shell$tabs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Activity'
	String get activity => 'Activity';

	/// en: 'Budgets'
	String get budgets => 'Budgets';

	/// en: 'Reports'
	String get reports => 'Reports';
}

// Path: shell.reportsTabs
class Translations$shell$reportsTabs$en {
	Translations$shell$reportsTabs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Trend'
	String get trend => 'Trend';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Insights'
	String get insights => 'Insights';
}

// Path: smsParser.range
class Translations$smsParser$range$en {
	Translations$smsParser$range$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Last 7 days'
	String get last7Days => 'Last 7 days';

	/// en: 'Last 30 days'
	String get last30Days => 'Last 30 days';

	/// en: 'Last 3 months'
	String get last3Months => 'Last 3 months';

	/// en: 'All time'
	String get allTime => 'All time';

	/// en: 'Custom date range'
	String get custom => 'Custom date range';

	/// en: 'From {date}'
	String from({required Object date}) => 'From ${date}';

	/// en: 'Until {date}'
	String until({required Object date}) => 'Until ${date}';

	/// en: 'Select date'
	String get selectDate => 'Select date';
}

// Path: smsParser.summary
class Translations$smsParser$summary$en {
	Translations$smsParser$summary$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Range'
	String get range => 'Range';

	/// en: 'Matches'
	String get matches => 'Matches';

	/// en: 'Selected'
	String get selected => 'Selected';
}

// Path: smsParser.card
class Translations$smsParser$card$en {
	Translations$smsParser$card$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rule: {id}'
	String rule({required Object id}) => 'Rule: ${id}';
}

// Path: smsParser.options
class Translations$smsParser$options$en {
	Translations$smsParser$options$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan past SMS for records'
	String get title => 'Scan past SMS for records';
}

// Path: smsParser.toolbar
class Translations$smsParser$toolbar$en {
	Translations$smsParser$toolbar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sender'
	String get sender => 'Sender';

	/// en: 'Flat list'
	String get flatList => 'Flat list';

	/// en: 'Clear'
	String get clear => 'Clear';
}

// Path: smsParser.section
class Translations$smsParser$section$en {
	Translations$smsParser$section$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select all'
	String get selectAll => 'Select all';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: '(one) {{n} message · {selected} selected} (other) {{n} messages · {selected} selected}'
	String counts({required num n, required Object selected}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} message · ${selected} selected',
		other: '${n} messages · ${selected} selected',
	);
}

// Path: smsParser.customRange
class Translations$smsParser$customRange$en {
	Translations$smsParser$customRange$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select custom range'
	String get title => 'Select custom range';

	/// en: 'Choose a start and end date before scanning past SMS for records.'
	String get body => 'Choose a start and end date before scanning past SMS for records.';

	/// en: 'Start date'
	String get start => 'Start date';

	/// en: 'End date'
	String get end => 'End date';

	/// en: 'Pick a valid start and end date.'
	String get invalid => 'Pick a valid start and end date.';

	/// en: 'Apply'
	String get apply => 'Apply';
}

// Path: smsParser.results
class Translations$smsParser$results$en {
	Translations$smsParser$results$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan results'
	String get title => 'Scan results';

	/// en: 'No new records found'
	String get empty => 'No new records found';

	/// en: 'Try scanning again or add more matching rules'
	String get emptyBody => 'Try scanning again or add more matching rules';

	/// en: '(one) {Add {n} selected record} (other) {Add {n} selected records}'
	String create({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Add ${n} selected record',
		other: 'Add ${n} selected records',
	);
}

// Path: smsParser.autoImport
class Translations$smsParser$autoImport$en {
	Translations$smsParser$autoImport$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan past SMS'
	String get scanPast => 'Scan past SMS';
}

// Path: budgets.details.periodBudget
class Translations$budgets$details$periodBudget$en {
	Translations$budgets$details$periodBudget$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weekly budget'
	String get weekly => 'Weekly budget';

	/// en: 'Monthly budget'
	String get monthly => 'Monthly budget';

	/// en: 'Yearly budget'
	String get yearly => 'Yearly budget';
}

// Path: categories.settings.sections
class Translations$categories$settings$sections$en {
	Translations$categories$settings$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expense categories'
	String get expense => 'Expense categories';

	/// en: 'Income categories'
	String get income => 'Income categories';
}

// Path: dashboard.range.net
class Translations$dashboard$range$net$en {
	Translations$dashboard$range$net$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Net this month'
	String get thisMonth => 'Net this month';

	/// en: 'Net last month'
	String get lastMonth => 'Net last month';

	/// en: 'Net this year'
	String get thisYear => 'Net this year';
}

// Path: dashboard.range.previous
class Translations$dashboard$range$previous$en {
	Translations$dashboard$range$previous$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'last month'
	String get thisMonth => 'last month';

	/// en: 'the month before'
	String get lastMonth => 'the month before';

	/// en: 'last year'
	String get thisYear => 'last year';
}

// Path: enums.fontSize.small
class Translations$enums$fontSize$small$en {
	Translations$enums$fontSize$small$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Small'
	String get title => 'Small';

	/// en: 'Compact view, more content on screen'
	String get description => 'Compact view, more content on screen';
}

// Path: enums.fontSize.medium
class Translations$enums$fontSize$medium$en {
	Translations$enums$fontSize$medium$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Medium'
	String get title => 'Medium';

	/// en: 'Balanced size for everyday use'
	String get description => 'Balanced size for everyday use';
}

// Path: enums.fontSize.large
class Translations$enums$fontSize$large$en {
	Translations$enums$fontSize$large$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Large'
	String get title => 'Large';

	/// en: 'Larger text for better readability'
	String get description => 'Larger text for better readability';
}

// Path: enums.fontSize.extraLarge
class Translations$enums$fontSize$extraLarge$en {
	Translations$enums$fontSize$extraLarge$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Extra large'
	String get title => 'Extra large';

	/// en: 'Maximum size for accessibility'
	String get description => 'Maximum size for accessibility';
}

// Path: records.sheet.placeholders
class Translations$records$sheet$placeholders$en {
	Translations$records$sheet$placeholders$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	List<String> get expense => [
		'Groceries',
		'Uber to office',
		'Lunch with colleague',
		'Netflix subscription',
		'Electricity bill',
		'Gas station',
	];
	List<String> get income => [
		'Salary',
		'Freelance payment',
		'Side hustle',
		'Refund',
		'Bonus',
		'Investment dividend',
	];
}

// Path: reports.insights.highestDay
class Translations$reports$insights$highestDay$en {
	Translations$reports$insights$highestDay$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Highest spending day'
	String get title => 'Highest spending day';

	/// en: '{day} is your biggest spending day, {percent}% above your daily average.'
	String description({required Object day, required Object percent}) => '${day} is your biggest spending day, ${percent}% above your daily average.';
}

// Path: reports.insights.topCategory
class Translations$reports$insights$topCategory$en {
	Translations$reports$insights$topCategory$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Most frequent category'
	String get title => 'Most frequent category';

	/// en: '{category} accounts for {percent}% of your spending.'
	String description({required Object category, required Object percent}) => '${category} accounts for ${percent}% of your spending.';
}

// Path: reports.insights.bestWeek
class Translations$reports$insights$bestWeek$en {
	Translations$reports$insights$bestWeek$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Best savings week'
	String get title => 'Best savings week';

	/// en: '{range} was your lowest spending week.'
	String description({required Object range}) => '${range} was your lowest spending week.';
}

// Path: reports.insights.recurring
class Translations$reports$insights$recurring$en {
	Translations$reports$insights$recurring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recurring expenses'
	String get title => 'Recurring expenses';

	/// en: 'Check your recurring transactions for upcoming charges.'
	String get description => 'Check your recurring transactions for upcoming charges.';
}

// Path: reports.insights.budgets
class Translations$reports$insights$budgets$en {
	Translations$reports$insights$budgets$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budget status'
	String get title => 'Budget status';

	/// en: 'Review your budgets to stay on track this month.'
	String get description => 'Review your budgets to stay on track this month.';
}

// Path: settings.language.sections
class Translations$settings$language$sections$en {
	Translations$settings$language$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App language'
	String get appLanguage => 'App language';
}

// Path: settings.language.names
class Translations$settings$language$names$en {
	Translations$settings$language$names$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'English'
	String get en => 'English';

	/// en: 'Bengali'
	String get bn => 'Bengali';
}

// Path: settings.notifications.sections
class Translations$settings$notifications$sections$en {
	Translations$settings$notifications$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'General'
	String get general => 'General';

	/// en: 'Budget alerts'
	String get budgetAlerts => 'Budget alerts';

	/// en: 'Recurring transactions'
	String get recurring => 'Recurring transactions';
}

// Path: settings.notifications.master
class Translations$settings$notifications$master$en {
	Translations$settings$notifications$master$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Allow notifications'
	String get title => 'Allow notifications';

	/// en: 'Budget alerts, weekly summary and reminders'
	String get subtitle => 'Budget alerts, weekly summary and reminders';
}

// Path: settings.notifications.blocked
class Translations$settings$notifications$blocked$en {
	Translations$settings$notifications$blocked$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications are blocked'
	String get title => 'Notifications are blocked';

	/// en: 'Open settings'
	String get action => 'Open settings';
}

// Path: settings.notifications.over
class Translations$settings$notifications$over$en {
	Translations$settings$notifications$over$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Over budget alert'
	String get title => 'Over budget alert';

	/// en: 'When spending exceeds budget limit'
	String get subtitle => 'When spending exceeds budget limit';
}

// Path: settings.notifications.nearLimit
class Translations$settings$notifications$nearLimit$en {
	Translations$settings$notifications$nearLimit$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '80% threshold'
	String get title => '80% threshold';

	/// en: 'When 80% of budget is used'
	String get subtitle => 'When 80% of budget is used';
}

// Path: settings.notifications.weekly
class Translations$settings$notifications$weekly$en {
	Translations$settings$notifications$weekly$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weekly summary'
	String get title => 'Weekly summary';

	/// en: '{day} evening: this week's spending compared with last week'
	String subtitle({required Object day}) => '${day} evening: this week\'s spending compared with last week';
}

// Path: settings.notifications.reminders
class Translations$settings$notifications$reminders$en {
	Translations$settings$notifications$reminders$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reminder alerts'
	String get title => 'Reminder alerts';

	/// en: 'Get reminded a day before recurring transactions'
	String get subtitle => 'Get reminded a day before recurring transactions';
}

// Path: settings.appearanceScreen.sections
class Translations$settings$appearanceScreen$sections$en {
	Translations$settings$appearanceScreen$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'Preview'
	String get preview => 'Preview';
}

// Path: settings.numberFormat.sections
class Translations$settings$numberFormat$sections$en {
	Translations$settings$numberFormat$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Decimal places'
	String get decimalPlaces => 'Decimal places';

	/// en: 'Digit grouping'
	String get grouping => 'Digit grouping';
}

// Path: settings.numberFormat.places
class Translations$settings$numberFormat$places$en {
	Translations$settings$numberFormat$places$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{n} places'
	String count({required Object n}) => '${n} places';

	/// en: '{currency} has no decimal places'
	String noMinorUnits({required Object currency}) => '${currency} has no decimal places';
}

// Path: settings.fontSize.sections
class Translations$settings$fontSize$sections$en {
	Translations$settings$fontSize$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Font size'
	String get fontSize => 'Font size';
}

// Path: settings.calendar.sections
class Translations$settings$calendar$sections$en {
	Translations$settings$calendar$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'First day of week'
	String get firstDayOfWeek => 'First day of week';
}

// Path: settings.homePage.sections
class Translations$settings$homePage$sections$en {
	Translations$settings$homePage$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Default home page'
	String get defaultHomePage => 'Default home page';
}

// Path: settings.homePage.options
class Translations$settings$homePage$options$en {
	Translations$settings$homePage$options$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$homePage$options$home$en home = Translations$settings$homePage$options$home$en.internal(_root);
	late final Translations$settings$homePage$options$activity$en activity = Translations$settings$homePage$options$activity$en.internal(_root);
	late final Translations$settings$homePage$options$budgets$en budgets = Translations$settings$homePage$options$budgets$en.internal(_root);
	late final Translations$settings$homePage$options$reports$en reports = Translations$settings$homePage$options$reports$en.internal(_root);
}

// Path: settings.sync.sections
class Translations$settings$sync$sections$en {
	Translations$settings$sync$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This device'
	String get device => 'This device';
}

// Path: settings.sync.result
class Translations$settings$sync$result$en {
	Translations$settings$sync$result$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sync complete'
	String get success => 'Sync complete';

	/// en: 'You're offline. Changes will be sent when you're back online.'
	String get offline => 'You\'re offline. Changes will be sent when you\'re back online.';

	/// en: 'Sync didn't finish. It will try again on its own.'
	String get failed => 'Sync didn\'t finish. It will try again on its own.';

	/// en: 'Turn on Sync first'
	String get disabled => 'Turn on Sync first';

	/// en: 'Sign in to sync'
	String get signedOut => 'Sign in to sync';

	/// en: 'Finishing sign-in. Try again in a moment.'
	String get firstSyncPending => 'Finishing sign-in. Try again in a moment.';
}

// Path: settings.export.sections
class Translations$settings$export$sections$en {
	Translations$settings$export$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Date range'
	String get dateRange => 'Date range';

	/// en: 'Include'
	String get include => 'Include';
}

// Path: settings.export.ranges
class Translations$settings$export$ranges$en {
	Translations$settings$export$ranges$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All time'
	String get allTime => 'All time';

	/// en: 'Export everything'
	String get allTimeSubtitle => 'Export everything';

	/// en: 'This year'
	String get thisYear => 'This year';

	/// en: 'Last 6 months'
	String get lastSixMonths => 'Last 6 months';

	/// en: 'Last 3 months'
	String get lastThreeMonths => 'Last 3 months';

	/// en: 'Custom range'
	String get custom => 'Custom range';

	/// en: 'Select start and end dates'
	String get customSubtitle => 'Select start and end dates';

	/// en: '{start} – Present'
	String untilToday({required Object start}) => '${start} – Present';

	/// en: '{start} – {end}'
	String between({required Object start, required Object end}) => '${start} – ${end}';
}

// Path: settings.export.include
class Translations$settings$export$include$en {
	Translations$settings$export$include$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transactions'
	String get transactions => 'Transactions';

	/// en: 'Budgets'
	String get budgets => 'Budgets';

	/// en: 'Categories'
	String get categories => 'Categories';
}

// Path: settings.deleteData.sections
class Translations$settings$deleteData$sections$en {
	Translations$settings$deleteData$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Data that will be deleted'
	String get summary => 'Data that will be deleted';

	/// en: 'Confirmation'
	String get confirmation => 'Confirmation';
}

// Path: settings.homePage.options.home
class Translations$settings$homePage$options$home$en {
	Translations$settings$homePage$options$home$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get title => 'Home';

	/// en: 'Overview with net, budgets and recent activity'
	String get subtitle => 'Overview with net, budgets and recent activity';
}

// Path: settings.homePage.options.activity
class Translations$settings$homePage$options$activity$en {
	Translations$settings$homePage$options$activity$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Activity'
	String get title => 'Activity';

	/// en: 'Full transaction history list'
	String get subtitle => 'Full transaction history list';
}

// Path: settings.homePage.options.budgets
class Translations$settings$homePage$options$budgets$en {
	Translations$settings$homePage$options$budgets$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budgets'
	String get title => 'Budgets';

	/// en: 'Budget overview and progress tracking'
	String get subtitle => 'Budget overview and progress tracking';
}

// Path: settings.homePage.options.reports
class Translations$settings$homePage$options$reports$en {
	Translations$settings$homePage$options$reports$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reports'
	String get title => 'Reports';

	/// en: 'Trends, categories and insights'
	String get subtitle => 'Trends, categories and insights';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'aiAssistant.title' => 'AI assistant',
			'aiAssistant.inputHint' => 'Ask about your spending',
			'aiAssistant.send' => 'Send message',
			'aiAssistant.disclaimer' => 'Expenzo AI provides suggestions based on your data. It is not a licensed financial advisor.',
			'aiAssistant.suggestions.topExpenses' => 'Top expenses',
			'aiAssistant.suggestions.budget' => 'How\'s my budget?',
			'aiAssistant.refusals.outOfScope' => 'I can only help with your Expenzo finances: spending, budgets, categories, income, balance, savings, transactions, reports and recurring bills. Ask a question about your own data.',
			'aiAssistant.refusals.promptInjection' => 'I can\'t help with hidden instructions, internal context, secrets or requests to override my rules. Ask about your finances in Expenzo.',
			'aiAssistant.refusals.tooLong' => 'That message is too long. Ask a shorter question about your Expenzo finances.',
			'aiAssistant.refusals.empty' => 'Type a question about your Expenzo finances.',
			'aiAssistant.refusals.cooldown' => 'Wait a few seconds before sending another question.',
			'aiAssistant.refusals.contextUnavailable' => 'I can\'t read your finance data right now. Try again shortly.',
			'aiAssistant.errors.contextFailed' => 'Couldn\'t load your finance data. Try again.',
			'auth.errors.cannotConnect' => 'Can\'t connect. Check your internet connection and try again.',
			'auth.errors.serverProblem' => 'Something went wrong on our end. Try again later.',
			'auth.errors.timedOut' => 'The request timed out. Check your connection and try again.',
			'auth.errors.generic' => 'Something went wrong. Try again.',
			'auth.errors.cancelled' => 'Sign-in was cancelled.',
			'auth.errors.network' => 'Network error. Check your connection and try again.',
			'auth.errors.tooManyAttempts' => 'Too many attempts. Try again later.',
			'auth.errors.failed' => 'Sign-in failed. Try again.',
			'auth.syncConflict.title' => 'Sync conflict',
			'auth.syncConflict.body' => 'You have records on this phone and in your account. Choose which to keep.',
			'auth.syncConflict.merge' => 'Merge my data',
			'auth.syncConflict.mergeDetail' => 'Keep records from both',
			'auth.syncConflict.useAccount' => 'Use my account data',
			'auth.syncConflict.useAccountDetail' => 'Delete the records on this phone and use your account copy',
			'auth.syncConflict.keepPhone' => 'Keep this phone\'s data',
			'auth.syncConflict.keepPhoneDetail' => 'Replace your account copy with the records on this phone',
			'auth.syncConflict.replaceTitle' => 'Replace data on this phone?',
			'auth.syncConflict.replaceBody' => 'This permanently deletes the records on this phone and replaces them with your account copy.',
			'auth.syncConflict.replace' => 'Replace',
			'auth.syncConflict.namesUploadFailed' => 'Couldn\'t upload your budget names. Check your connection and try again.',
			'auth.syncConflict.preparing' => 'Preparing…',
			'auth.syncConflict.clearing' => 'Clearing this phone…',
			'auth.syncConflict.done' => 'Done',
			'auth.syncConflict.syncing' => 'Syncing…',
			'auth.login.google' => 'Sign in with Google',
			'auth.login.logo' => 'Expenzo logo',
			'auth.login.pitch' => 'Sign in to back up your records and keep them in sync on all your devices.',
			'auth.login.signingIn' => 'Signing in…',
			'budgets.title' => 'Budgets',
			'budgets.subtitle' => 'Track your monthly limits',
			'budgets.unnamed' => 'Unnamed budget',
			'budgets.empty.title' => 'No budgets yet',
			'budgets.empty.body' => 'Set a monthly limit to see how much you have left.',
			'budgets.saved' => 'Budget saved',
			'budgets.loadPrompt' => 'Load budgets to see data',
			'budgets.edit' => 'Edit',
			'budgets.delete.title' => 'Delete budget',
			'budgets.delete.confirm' => ({required Object name}) => 'Delete "${name}" budget?',
			'budgets.card.overBy' => ({required Object amount}) => 'Over by ${amount}',
			'budgets.card.left' => ({required Object amount}) => '${amount} left',
			'budgets.card.spentOf' => ({required Object spent, required Object total}) => '${spent} of ${total} spent',
			'budgets.card.a11y' => ({required Object name, required Object headline, required Object daysLeft}) => '${name}, ${headline}, ${daysLeft}. Long press for options.',
			'budgets.days.ended' => 'Period ended',
			'budgets.days.lastDay' => 'Last day',
			'budgets.days.left' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} day left', other: '${n} days left', ), 
			'budgets.form.add' => 'Add budget',
			'budgets.form.edit' => 'Edit budget',
			'budgets.form.amount' => 'Amount',
			'budgets.form.name' => 'Name',
			'budgets.form.nameHint' => 'e.g. Food & Drinks',
			'budgets.form.period' => 'Period',
			'budgets.form.rollover' => 'Roll over unspent money',
			'budgets.form.rolloverDetail' => 'Carry forward unspent amount',
			'budgets.form.amountRequired' => 'Enter an amount',
			'budgets.form.amountInvalid' => 'Enter a valid number',
			'budgets.form.nameRequired' => 'Enter a name',
			'budgets.form.nameReserved' => 'Pick a different name',
			'budgets.details.title' => 'Budget details',
			'budgets.details.loadFailed' => 'Couldn\'t load budget details. Try again.',
			'budgets.details.notFound' => 'Budget not found.',
			'budgets.details.ofTotal' => ({required Object total}) => ' / ${total}',
			'budgets.details.periodBudget.weekly' => 'Weekly budget',
			'budgets.details.periodBudget.monthly' => 'Monthly budget',
			'budgets.details.periodBudget.yearly' => 'Yearly budget',
			'budgets.details.used' => ({required Object percent}) => '${percent}% used',
			'budgets.details.over' => 'Over budget',
			'budgets.details.transactionsFailed' => 'Couldn\'t load transactions',
			'budgets.details.noExpenses' => 'No expenses in this budget yet',
			'budgets.details.noExpensesBody' => 'Expenses you link to this budget show up here.',
			'budgets.details.transactions' => 'Transactions',
			'budgets.details.unableToLoad' => 'Couldn\'t load budget',
			'budgets.details.unableToLoadBody' => 'Budget details could not be loaded.',
			'budgets.picker.title' => 'Choose budget',
			'budgets.picker.subtitle' => 'Pick the budget this expense counts toward',
			'budgets.picker.sectionAvailable' => 'Available budgets',
			'budgets.picker.noBudget' => 'No budget',
			'budgets.picker.noBudgetHint' => 'Don\'t link to a budget',
			'budgets.picker.previousBudget' => 'Previous budget (no longer active)',
			'budgets.picker.previousBudgetHint' => 'Keep the current link',
			'budgets.picker.progress' => ({required Object period, required Object spent, required Object limit}) => '${period} · ${spent} / ${limit}',
			'budgets.picker.empty' => 'No active budgets',
			'categories.uncategorized' => 'Uncategorized',
			'categories.defaults.default_in_salary' => 'Salary',
			'categories.defaults.default_in_freelance' => 'Freelance',
			'categories.defaults.default_in_investment' => 'Investment',
			'categories.defaults.default_in_refund' => 'Refund',
			'categories.defaults.default_in_gift' => 'Gift',
			'categories.defaults.default_in_general' => 'General',
			'categories.defaults.default_out_food' => 'Food & Dining',
			'categories.defaults.default_out_shopping' => 'Shopping',
			'categories.defaults.default_out_transport' => 'Transport',
			'categories.defaults.default_out_home' => 'Home',
			'categories.defaults.default_out_health' => 'Health',
			'categories.defaults.default_out_entertainment' => 'Entertainment',
			'categories.defaults.default_out_bills' => 'Bills & Utilities',
			'categories.defaults.default_out_travel' => 'Travel',
			'categories.defaults.default_out_education' => 'Education',
			'categories.defaults.default_out_investment' => 'Investment',
			'categories.defaults.default_out_gifts' => 'Gifts',
			'categories.defaults.default_out_general' => 'General',
			'categories.empty' => 'No categories created',
			'categories.settings.title' => 'Category settings',
			'categories.settings.sections.expense' => 'Expense categories',
			'categories.settings.sections.income' => 'Income categories',
			'categories.settings.recordCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} transaction', other: '${n} transactions', ), 
			'categories.settings.deleteFailed' => 'Couldn\'t delete the category. Try again.',
			'categories.defaultCannotDelete' => 'Default categories cannot be deleted',
			'categories.form.add' => 'Add category',
			'categories.form.edit' => 'Edit category',
			'categories.form.name' => 'Name',
			'categories.form.nameHint' => 'Groceries',
			'categories.form.nameRequired' => 'Enter a name',
			'categories.form.icon' => 'Icon',
			'categories.form.color' => 'Choose color',
			'categories.delete.title' => 'Delete category?',
			'categories.delete.confirm' => ({required Object name}) => 'Are you sure you want to delete "${name}"?',
			'categories.delete.withRecords' => ({required num n, required Object name}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Are you sure you want to delete "${name}"? ${n} transaction using this category will be uncategorized.', other: 'Are you sure you want to delete "${name}"? ${n} transactions using this category will be uncategorized.', ), 
			'categories.iconLabel' => ({required Object name}) => '${name} icon',
			'categories.icons.shoppingCart' => 'Shopping cart',
			'categories.icons.forkKnife' => 'Fork and knife',
			'categories.icons.car' => 'Car',
			'categories.icons.bag' => 'Bag',
			'categories.icons.heart' => 'Heart',
			'categories.icons.bookOpen' => 'Book',
			'categories.icons.filmStrip' => 'Film',
			'categories.icons.lightning' => 'Lightning',
			'categories.icons.coffee' => 'Coffee',
			'categories.icons.gift' => 'Gift',
			'categories.icons.dog' => 'Dog',
			'categories.icons.airplane' => 'Airplane',
			'categories.colors.Lavender' => 'Lavender',
			'categories.colors.Rose' => 'Rose',
			'categories.colors.Mint' => 'Mint',
			'categories.colors.Sky' => 'Sky',
			'categories.colors.Amber' => 'Amber',
			'categories.colors.Teal' => 'Teal',
			'categories.colors.Peach' => 'Peach',
			'categories.colors.Slate' => 'Slate',
			'common.appName' => 'Expenzo',
			'common.add' => 'Add',
			'common.save' => 'Save',
			'common.delete' => 'Delete',
			'common.cancel' => 'Cancel',
			'common.close' => 'Close',
			'common.done' => 'Done',
			'common.next' => 'Next',
			'common.back' => 'Back',
			'common.undo' => 'Undo',
			'common.tryAgain' => 'Try again',
			'common.notNow' => 'Not now',
			'common.openSettings' => 'Open settings',
			'common.addExpense' => 'Add expense',
			'common.newBudget' => 'New budget',
			'common.sendFeedback' => 'Send feedback',
			'common.autoImport' => 'Auto-import from SMS',
			'common.matchingRules' => 'Matching rules',
			'common.errors.generic' => 'Something went wrong. Try again.',
			'common.errors.storage' => 'Couldn\'t read or save your data. Try again.',
			'common.errors.network' => 'You\'re offline. Check your connection and try again.',
			'common.errors.server' => 'The server didn\'t respond. Try again in a moment.',
			'common.errors.auth' => 'There was a problem with your sign-in. Sign in again and retry.',
			'common.errors.permission' => 'Expenzo doesn\'t have permission to do this. Allow it in system settings.',
			'common.errors.notFound' => 'This item no longer exists.',
			'common.errors.smsScan' => 'Couldn\'t read your messages. Try again.',
			'common.dates.today' => 'Today',
			'common.dates.yesterday' => 'Yesterday',
			'common.a11y.expenseAmount' => ({required Object amount, required Object currency}) => 'Expense, ${amount} ${currency}',
			'common.a11y.incomeAmount' => ({required Object amount, required Object currency}) => 'Income, ${amount} ${currency}',
			'common.feedback.subject' => 'Expenzo feedback',
			'common.feedback.noMailApp' => ({required Object email}) => 'No email app was found. Write to us at ${email}.',
			'common.feedback.copyAddress' => 'Copy address',
			'common.search' => 'Search',
			'common.clearSearch' => 'Clear search',
			'common.addTransaction' => 'Add transaction',
			'common.noTransactionsInPeriod' => 'No transactions in this period',
			'common.fallback.initTitle' => 'App could not start',
			'common.fallback.errorTitle' => 'Something went wrong',
			'common.fallback.initBody' => 'We could not finish setting up the app. This is usually temporary. Try again, or restart the app.',
			'common.fallback.errorBody' => 'We hit an unexpected error. You can try again, restart the app, or send us feedback so we can fix it.',
			'common.fallback.reference' => ({required Object id}) => 'Ref: ${id}',
			'common.fallback.closeApp' => 'Close app',
			'common.fallback.debugDetails' => 'Details (debug)',
			'common.fallback.criticalTitle' => 'Unexpected error occurred',
			'common.fallback.criticalBody' => 'The app will close shortly.',
			'common.smsGate.title' => 'SMS access required',
			'common.smsGate.body' => 'Expenzo needs access to your SMS to automatically track expenses from your bank and payment apps. Your messages never leave your device.',
			'common.smsGate.allow' => 'Allow access',
			'common.smsGate.deniedTitle' => 'Permission needed',
			'common.smsGate.deniedBody' => 'SMS permission is permanently denied. Enable it in app settings to use the smart scanner.',
			'currencies.names.BDT' => 'Bangladeshi taka',
			'currencies.names.USD' => 'US dollar',
			'currencies.names.EUR' => 'Euro',
			'currencies.names.GBP' => 'British pound',
			'currencies.names.INR' => 'Indian rupee',
			'currencies.names.PKR' => 'Pakistani rupee',
			'currencies.names.NPR' => 'Nepalese rupee',
			'currencies.names.LKR' => 'Sri Lankan rupee',
			'currencies.names.AED' => 'UAE dirham',
			'currencies.names.SAR' => 'Saudi riyal',
			'currencies.names.MYR' => 'Malaysian ringgit',
			'currencies.names.SGD' => 'Singapore dollar',
			'currencies.names.THB' => 'Thai baht',
			'currencies.names.PHP' => 'Philippine peso',
			'currencies.names.IDR' => 'Indonesian rupiah',
			'currencies.names.VND' => 'Vietnamese dong',
			'currencies.names.JPY' => 'Japanese yen',
			'currencies.names.KRW' => 'South Korean won',
			'currencies.names.CNY' => 'Chinese yuan',
			'currencies.names.AUD' => 'Australian dollar',
			'currencies.names.CAD' => 'Canadian dollar',
			'currencies.names.CHF' => 'Swiss franc',
			'currencies.names.SEK' => 'Swedish krona',
			'currencies.names.PLN' => 'Polish złoty',
			'currencies.names.TRY' => 'Turkish lira',
			'currencies.names.RUB' => 'Russian ruble',
			'currencies.names.BRL' => 'Brazilian real',
			'currencies.names.ZAR' => 'South African rand',
			'dashboard.range.thisMonth' => 'This month',
			'dashboard.range.lastMonth' => 'Last month',
			'dashboard.range.thisYear' => 'This year',
			'dashboard.range.net.thisMonth' => 'Net this month',
			'dashboard.range.net.lastMonth' => 'Net last month',
			'dashboard.range.net.thisYear' => 'Net this year',
			'dashboard.range.previous.thisMonth' => 'last month',
			'dashboard.range.previous.lastMonth' => 'the month before',
			'dashboard.range.previous.thisYear' => 'last year',
			'dashboard.greeting' => ({required Object name}) => 'Hi, ${name}',
			'dashboard.userFallback' => 'User',
			'dashboard.income' => 'Income',
			'dashboard.expense' => 'Expense',
			'dashboard.sections.budgets' => 'Budgets',
			'dashboard.sections.recentActivity' => 'Recent activity',
			'dashboard.sections.spendingPatterns' => 'Spending patterns',
			'dashboard.sections.seeAll' => 'See all',
			'dashboard.noBudgets' => 'No budgets yet',
			'dashboard.noTransactions' => 'No transactions yet',
			'dashboard.menu.profile' => 'Profile',
			'dashboard.menu.signIn' => 'Sign in',
			'dashboard.menu.settings' => 'Settings',
			'dashboard.menu.signOut' => 'Sign out',
			'dashboard.budgetSpentOf' => ({required Object spent, required Object total}) => '${spent} of ${total}',
			'dashboard.trend.noPrevious' => ({required Object period}) => 'No spending ${period} to compare',
			'dashboard.trend.same' => ({required Object period}) => 'Same as ${period}',
			'dashboard.trend.up' => ({required Object percent, required Object period}) => '+${percent}% vs ${period}',
			'dashboard.trend.down' => ({required Object percent, required Object period}) => '-${percent}% vs ${period}',
			'dashboard.trend.spent' => ({required Object amount}) => '${amount} spent',
			'dashboard.trend.noData' => 'No trend data yet',
			'dashboard.autoImport.title' => 'Add expenses from SMS',
			'dashboard.autoImport.body' => 'Let Expenzo read bank and payment messages and add them for you. Messages stay on this phone.',
			'dashboard.autoImport.setUp' => 'Set up',
			'dashboard.scanReceipt' => 'Scan a receipt',
			'enums.recordType.income' => 'Income',
			'enums.recordType.expense' => 'Expense',
			'enums.period.weekly' => 'Weekly',
			'enums.period.monthly' => 'Monthly',
			'enums.period.yearly' => 'Yearly',
			'enums.frequency.daily' => 'Daily',
			'enums.frequency.weekly' => 'Weekly',
			'enums.frequency.biweekly' => 'Biweekly',
			'enums.frequency.monthly' => 'Monthly',
			'enums.frequency.yearly' => 'Yearly',
			'enums.source.manual' => 'Manual',
			'enums.source.sms' => 'SMS',
			'enums.source.email' => 'Email',
			'enums.source.recurring' => 'Recurring',
			'enums.source.both' => 'Both',
			'enums.theme.system' => 'Match device',
			'enums.theme.light' => 'Light',
			'enums.theme.dark' => 'Dark',
			'enums.digitGrouping.comma' => 'Comma separator',
			'enums.digitGrouping.dot' => 'Dot separator',
			'enums.digitGrouping.space' => 'Space separator',
			'enums.fontSize.small.title' => 'Small',
			'enums.fontSize.small.description' => 'Compact view, more content on screen',
			'enums.fontSize.medium.title' => 'Medium',
			'enums.fontSize.medium.description' => 'Balanced size for everyday use',
			'enums.fontSize.large.title' => 'Large',
			'enums.fontSize.large.description' => 'Larger text for better readability',
			'enums.fontSize.extraLarge.title' => 'Extra large',
			'enums.fontSize.extraLarge.description' => 'Maximum size for accessibility',
			'enums.firstDayOfWeek.sunday' => 'Sunday',
			'enums.firstDayOfWeek.monday' => 'Monday',
			'enums.firstDayOfWeek.saturday' => 'Saturday',
			'messageTemplates.errors.deleteFailed' => 'Couldn\'t delete the SMS format. Try again.',
			'messageTemplates.errors.restoreFailed' => 'Couldn\'t restore the SMS format. Try again.',
			'messageTemplates.alreadyExists' => 'SMS format already exists',
			'messageTemplates.edit' => 'Edit SMS format',
			'messageTemplates.delete' => 'Delete SMS format',
			'messageTemplates.deleted' => 'SMS format deleted',
			'messageTemplates.dismiss' => 'Dismiss',
			'messageTemplates.retro.title' => 'Scanning past messages',
			'messageTemplates.retro.scanning' => 'Looking for past expenses that match this SMS format…',
			'messageTemplates.retro.saved' => 'SMS format saved. New messages like this are added automatically.',
			'messageTemplates.retro.review' => 'Go to Settings → Auto-import from SMS to review and add any past expenses we found.',
			'messageTemplates.editor.noNumbers' => 'No numbers found in this message.',
			'messageTemplates.editor.amountsFound' => 'Amounts found in this message:',
			'messageTemplates.editor.step1' => 'Step 1 of 3: Choose a key word',
			'messageTemplates.editor.step1Body' => 'Choose a word that appears in every message of this type, like "debited", "paid" or "spent".',
			'messageTemplates.editor.wordsInMessage' => 'Words in this message',
			'messageTemplates.editor.step1Hint' => 'Choose a word to continue.',
			'messageTemplates.editor.step2' => 'Step 2 of 3: Choose the amount',
			'messageTemplates.editor.step2Body' => 'Which number is the amount you spent?',
			'messageTemplates.editor.step2Hint' => 'Choose the amount to continue.',
			'messageTemplates.editor.step3' => 'Step 3 of 3: Review',
			'messageTemplates.editor.step3Body' => 'From now on, messages like this one are added as expenses automatically.',
			'messageTemplates.editor.sender' => 'Sender',
			'messageTemplates.editor.keyWord' => 'Key word',
			'messageTemplates.editor.amountInMessage' => 'Amount in this message',
			'messageTemplates.editor.saveFailed' => ({required Object reason}) => 'Couldn\'t save the SMS format: ${reason}',
			'messageTemplates.editor.updated' => 'SMS format updated',
			'messageTemplates.editor.saved' => 'SMS format saved',
			'messageTemplates.analyzer.title' => ({required Object sender}) => 'Messages from ${sender}',
			'messageTemplates.analyzer.intro' => 'Pick a message to teach Expenzo this SMS format. Similar messages will then be added as records automatically.',
			'messageTemplates.analyzer.useMessage' => 'Use this message',
			'messageTemplates.analyzer.noMessages' => 'No recent messages from this sender.',
			'messageTemplates.contacts.subtitle' => 'Pick the senders that text you about payments. Expenzo learns their message format and adds records for you.',
			'messageTemplates.contacts.search' => 'Search senders',
			'messageTemplates.contacts.active' => 'Active',
			'messageTemplates.contacts.empty' => 'No text messages on this phone yet. Senders show up here once you receive SMS.',
			'messageTemplates.contacts.noMatch' => ({required Object query}) => 'No senders match "${query}".',
			'messageTemplates.create' => 'New SMS format',
			'notifications.channel.name' => 'App notifications',
			'notifications.channel.description' => 'Budget alerts, weekly summary, recurring reminders and scan results',
			'notifications.budget.title' => 'Budget alert',
			'notifications.budget.over' => ({required Object budget}) => 'You went over your "${budget}" budget.',
			'notifications.budget.used' => ({required Object percent, required Object budget}) => 'You have used ${percent}% of your "${budget}" budget.',
			'notifications.recurringDue.title' => 'Recurring transaction tomorrow',
			'notifications.weeklySummary.title' => 'Your week in spending',
			'notifications.weeklySummary.up' => ({required Object amount, required Object percent}) => 'You spent ${amount} this week, ${percent}% more than last week.',
			'notifications.weeklySummary.down' => ({required Object amount, required Object percent}) => 'You spent ${amount} this week, ${percent}% less than last week.',
			'notifications.weeklySummary.same' => ({required Object amount}) => 'You spent ${amount} this week, the same as last week.',
			'notifications.weeklySummary.noComparison' => ({required Object amount}) => 'You spent ${amount} this week.',
			'notifications.weeklySummary.nothing' => 'No spending recorded this week.',
			'notifications.scan.smsTitle' => 'SMS scan complete',
			'notifications.scan.emailTitle' => 'Email scan complete',
			'notifications.scan.found' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} new expense found', other: '${n} new expenses found', ), 
			'notifications.syncError.title' => 'Sync error',
			'parsingRules.addFromFormats' => 'Add rules from SMS formats',
			'parsingRules.newRule' => 'New rule',
			'parsingRules.editRule' => 'Edit rule',
			'parsingRules.add' => 'Add',
			'parsingRules.added' => ({required Object name}) => 'Added "${name}"',
			'parsingRules.empty.title' => 'No rules yet',
			'parsingRules.empty.body' => 'Add a rule to turn matching SMS and emails into records.',
			'parsingRules.empty.add' => 'Add rule',
			'parsingRules.created' => 'Rule created',
			'parsingRules.updated' => 'Rule updated',
			'parsingRules.delete.title' => 'Delete rule',
			'parsingRules.delete.confirm' => ({required Object name}) => 'Are you sure you want to delete "${name}"?',
			'parsingRules.validation.nameRequired' => 'Name is required',
			'parsingRules.validation.triggerRequired' => 'At least one key word is required',
			'parsingRules.validation.amountRequired' => 'Amount pattern is required',
			'parsingRules.validation.invalidRegex' => 'Invalid regex pattern',
			'parsingRules.validation.invalidRegexDetail' => ({required Object detail}) => 'Invalid regex: ${detail}',
			'parsingRules.validation.valid' => 'Valid pattern',
			'parsingRules.form.name' => 'Name *',
			'parsingRules.form.nameHint' => 'e.g., HDFC Bank SMS',
			'parsingRules.form.keyWords' => 'Key words *',
			'parsingRules.form.keyWordsHint' => 'HDFC, debit, account (comma-separated)',
			'parsingRules.form.keyWordsHelper' => 'Words that indicate this rule should be tried',
			'parsingRules.form.amountPattern' => 'Amount pattern (regex) *',
			'parsingRules.form.amountRegex' => 'Amount regex',
			'parsingRules.form.datePattern' => 'Date pattern (optional)',
			'parsingRules.form.dateRegex' => 'Date regex (optional)',
			'parsingRules.form.dateHelper' => 'Leave empty if date is not needed',
			'parsingRules.form.source' => 'Source',
			'parsingRules.form.priority' => 'Priority',
			'parsingRules.form.priorityHelper' => 'Higher priority rules are tried first',
			'parsingRules.form.enabled' => 'Enabled',
			'parsingRules.form.enabledDetail' => 'Use this rule when reading messages',
			'parsingRules.tester.timeout' => 'Timed out: the pattern took more than 2 seconds',
			'parsingRules.tester.error' => 'Error',
			'parsingRules.tester.match' => 'Match found',
			'parsingRules.tester.noMatch' => 'No match',
			'parsingRules.tester.elapsed' => ({required Object ms}) => '${ms} ms',
			'parsingRules.tester.amount' => 'Amount',
			'parsingRules.tester.date' => 'Date',
			'parsingRules.tester.confidence' => ({required Object percent}) => '${percent}% confidence',
			'parsingRules.tester.sample' => 'Sample message to test',
			'parsingRules.tester.sampleHint' => 'Enter a sample SMS or email text',
			'parsingRules.tester.enterSample' => 'Enter a sample message above to test the pattern',
			'parsingRules.templates.hdfc_bank_sms' => 'Parses debit notifications from HDFC Bank',
			'parsingRules.templates.icici_bank_sms' => 'Parses debit notifications from ICICI Bank',
			'parsingRules.templates.sbi_sms' => 'Parses debit notifications from State Bank of India',
			'parsingRules.templates.upi_payment_sms' => 'Parses UPI payment notifications (PhonePe, Google Pay, Paytm)',
			'parsingRules.templates.amazon_order_sms' => 'Parses Amazon order confirmation and delivery SMS',
			'parsingRules.templates.amazon_order_email' => 'Parses Amazon order emails',
			'parsingRules.templates.swiggy_order_email' => 'Parses Swiggy order confirmation emails',
			'parsingRules.templates.zomato_order_email' => 'Parses Zomato order confirmation emails',
			'parsingRules.templates.flipkart_order_email' => 'Parses Flipkart order emails',
			'parsingRules.templates.generic_payment_email' => 'Parses generic payment confirmation emails',
			'receiptScan.permissionRequired' => 'Camera permission is required to scan receipts.',
			'receiptScan.noCamera' => 'No camera available on this device.',
			'receiptScan.cameraFailed' => 'Couldn\'t open the camera.',
			'receiptScan.captureFailed' => 'Couldn\'t take the photo. Try again.',
			'receiptScan.readFailed' => 'Couldn\'t read the receipt. Try again or add it by hand.',
			'receiptScan.chooseFromGallery' => 'Choose from gallery',
			'receiptScan.flashOff' => 'Turn flash off',
			'receiptScan.flashOn' => 'Turn flash on',
			'receiptScan.align' => 'Align receipt with the frame',
			'receiptScan.reading' => 'Reading your receipt',
			'receiptScan.takePhoto' => 'Take photo',
			'records.filter.title' => 'Filter',
			'records.filter.dateRange' => 'Date range',
			'records.filter.type' => 'Type',
			'records.filter.all' => 'All',
			'records.filter.categories' => 'Categories',
			'records.filter.clear' => 'Clear',
			'records.filter.apply' => 'Apply',
			'records.filter.noCategories' => 'No categories',
			'records.filter.allCategories' => 'All categories',
			'records.filter.allCount' => ({required Object n}) => 'All (${n})',
			'records.filter.selectedCount' => ({required Object n}) => '${n} selected',
			'records.filter.selectDateRange' => 'Select date range',
			'records.filter.range' => ({required Object start, required Object end}) => '${start} - ${end}',
			'records.list.title' => 'Activity',
			'records.list.subtitle' => 'Transaction history',
			'records.list.filter' => 'Filter',
			'records.list.search' => 'Search transactions',
			'records.list.noMatches' => 'No transactions match your search or filters.',
			'records.list.empty' => 'No transactions yet',
			'records.list.scrollForMore' => 'Scroll for more',
			'records.list.deleted' => 'Record deleted',
			'records.picker.title' => 'Choose category',
			'records.picker.search' => 'Search categories',
			'records.picker.noneFound' => 'No categories found',
			'records.picker.addCategory' => 'Add category',
			'records.sheet.placeholders.expense.0' => 'Groceries',
			'records.sheet.placeholders.expense.1' => 'Uber to office',
			'records.sheet.placeholders.expense.2' => 'Lunch with colleague',
			'records.sheet.placeholders.expense.3' => 'Netflix subscription',
			'records.sheet.placeholders.expense.4' => 'Electricity bill',
			'records.sheet.placeholders.expense.5' => 'Gas station',
			'records.sheet.placeholders.income.0' => 'Salary',
			'records.sheet.placeholders.income.1' => 'Freelance payment',
			'records.sheet.placeholders.income.2' => 'Side hustle',
			'records.sheet.placeholders.income.3' => 'Refund',
			'records.sheet.placeholders.income.4' => 'Bonus',
			'records.sheet.placeholders.income.5' => 'Investment dividend',
			'records.sheet.enterAmount' => 'Enter an amount',
			'records.sheet.nameHintExpense' => 'Name, e.g. Lunch',
			'records.sheet.nameHintIncome' => 'Name, e.g. Salary',
			'records.sheet.nameRequired' => 'Add a name',
			'records.sheet.scanReceipt' => 'Scan a receipt',
			'records.sheet.noBudget' => 'No budget',
			'records.sheet.budgetOption' => ({required Object name, required Object period}) => '${name} · ${period}',
			'records.sheet.previousBudget' => 'Previous budget (no longer active)',
			'records.sheet.loadingBudgets' => 'Loading budgets…',
			'records.sheet.noCategories' => 'No categories available',
			'records.sheet.selectCategory' => 'Select a category',
			'records.sheet.showAllCategories' => 'Show all categories',
			'records.sheet.showAllBudgets' => 'Show all budgets',
			'records.sheet.repeatMonthly' => 'Repeat monthly',
			'records.sheet.addIncome' => 'Add income',
			'records.sheet.deleteExpense' => 'Delete expense',
			'records.sheet.deleteIncome' => 'Delete income',
			'records.sheet.deleteExpenseTitle' => 'Delete this expense?',
			'records.sheet.deleteIncomeTitle' => 'Delete this income?',
			'records.sheet.cannotUndo' => 'This can\'t be undone.',
			'records.sheet.repeatFailed' => 'Saved, but it couldn\'t be set to repeat. Set it up in Settings → Recurring.',
			'records.sheet.typeToggle' => 'Transaction type',
			'records.sheet.backspace' => 'Backspace',
			'records.sheet.decimalKey' => 'Decimal point',
			'recurring.title' => 'Recurring transactions',
			'recurring.saved' => 'Recurring transaction saved',
			'recurring.posted' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} transaction added', other: '${n} transactions added', ), 
			'recurring.nothingDue' => 'No transactions due',
			'recurring.sections.defaultFrequency' => 'Default frequency',
			'recurring.sections.autoCreate' => 'Auto-create',
			'recurring.sections.active' => 'Active recurring',
			'recurring.defaults.weeklyDetail' => 'Every 7 days',
			'recurring.defaults.monthlyDetail' => 'Same date every month',
			'recurring.defaults.yearlyDetail' => 'Same date every year',
			'recurring.defaults.autoCreate' => 'Auto-create transactions',
			'recurring.defaults.autoCreateDetail' => 'Add due transactions when you open the app',
			'recurring.empty.title' => 'No recurring transactions',
			'recurring.empty.body' => 'Tap + to create your first recurring expense',
			'recurring.amountEvery' => ({required Object amount, required Object frequency}) => '${amount} · ${frequency}',
			'recurring.next' => ({required Object date}) => 'Next: ${date}',
			'recurring.processPending' => 'Process pending',
			'recurring.newTooltip' => 'New recurring transaction',
			'recurring.delete.title' => 'Delete recurring transaction',
			'recurring.delete.confirm' => ({required Object name}) => 'Are you sure you want to delete "${name}"?',
			'recurring.form.edit' => 'Edit recurring',
			'recurring.form.amount' => 'Amount',
			'recurring.form.name' => 'Name',
			'recurring.form.nameHint' => 'What is this recurring expense for?',
			'recurring.form.frequency' => 'Frequency',
			'recurring.form.startDate' => 'Start date',
			'recurring.form.endDate' => 'End date (optional)',
			'recurring.form.noEndDate' => 'No end date',
			'recurring.form.clearEndDate' => 'Clear end date',
			'recurring.form.autoCreate' => 'Include in auto-create',
			'recurring.form.autoCreateDetail' => 'Added when the app opens, if Auto-create is on',
			'recurring.form.active' => 'Active',
			'recurring.form.activeDetail' => 'Process this recurring transaction',
			'recurring.form.amountRequired' => 'Enter an amount',
			'recurring.form.amountInvalid' => 'Enter a valid number',
			'recurring.form.nameRequired' => 'Enter a name',
			_ => null,
		} ?? switch (path) {
			'recurring.form.create' => 'New recurring',
			'reports.insights.highestDay.title' => 'Highest spending day',
			'reports.insights.highestDay.description' => ({required Object day, required Object percent}) => '${day} is your biggest spending day, ${percent}% above your daily average.',
			'reports.insights.topCategory.title' => 'Most frequent category',
			'reports.insights.topCategory.description' => ({required Object category, required Object percent}) => '${category} accounts for ${percent}% of your spending.',
			'reports.insights.bestWeek.title' => 'Best savings week',
			'reports.insights.bestWeek.description' => ({required Object range}) => '${range} was your lowest spending week.',
			'reports.insights.recurring.title' => 'Recurring expenses',
			'reports.insights.recurring.description' => 'Check your recurring transactions for upcoming charges.',
			'reports.insights.budgets.title' => 'Budget status',
			'reports.insights.budgets.description' => 'Review your budgets to stay on track this month.',
			'reports.title' => 'Reports',
			'reports.askAi' => 'Ask AI',
			'reports.last7Days' => 'Last 7 days',
			'reports.last30Days' => 'Last 30 days',
			'reports.noCategoryData' => 'No category data',
			'reports.noTrendData' => 'No trend data yet',
			'reports.noSpending' => 'No spending data yet',
			'reports.totalSpentInPeriod' => ({required Object amount}) => 'Total spent: ${amount} in this period',
			'reports.metrics.totalSpent' => 'Total spent',
			'reports.metrics.dailyAverage' => 'Daily average',
			'reports.metrics.highestDay' => 'Highest day',
			'reports.spendingByCategory' => 'Spending by category',
			'reports.observations' => 'Key observations from your spending this month',
			'reports.noData' => 'No data',
			'settings.language.title' => 'Language',
			'settings.language.sections.appLanguage' => 'App language',
			'settings.language.matchDevice' => 'Match device',
			'settings.language.matchDeviceSubtitle' => 'Use your phone\'s language',
			'settings.language.names.en' => 'English',
			'settings.language.names.bn' => 'Bengali',
			'settings.title' => 'Settings',
			'settings.currency' => 'Default currency',
			'settings.appearance' => 'Appearance',
			'settings.notificationsBlocked' => 'Allow notifications for Expenzo in system settings to get budget alerts.',
			'settings.sections.preferences' => 'Preferences',
			'settings.sections.automation' => 'Automation',
			'settings.sections.support' => 'Support',
			'settings.sections.account' => 'Profile & account',
			'settings.sections.notifications' => 'Notifications',
			'settings.sections.dataBudget' => 'Data & budget',
			'settings.sections.general' => 'General',
			'settings.notifications.title' => 'Notifications',
			'settings.notifications.rowSubtitle' => ({required Object n}) => '${n} of 4 on',
			'settings.notifications.rowSubtitleOff' => 'Off',
			'settings.notifications.sections.general' => 'General',
			'settings.notifications.sections.budgetAlerts' => 'Budget alerts',
			'settings.notifications.sections.recurring' => 'Recurring transactions',
			'settings.notifications.master.title' => 'Allow notifications',
			'settings.notifications.master.subtitle' => 'Budget alerts, weekly summary and reminders',
			'settings.notifications.blocked.title' => 'Notifications are blocked',
			'settings.notifications.blocked.action' => 'Open settings',
			'settings.notifications.over.title' => 'Over budget alert',
			'settings.notifications.over.subtitle' => 'When spending exceeds budget limit',
			'settings.notifications.nearLimit.title' => '80% threshold',
			'settings.notifications.nearLimit.subtitle' => 'When 80% of budget is used',
			'settings.notifications.weekly.title' => 'Weekly summary',
			'settings.notifications.weekly.subtitle' => ({required Object day}) => '${day} evening: this week\'s spending compared with last week',
			'settings.notifications.reminders.title' => 'Reminder alerts',
			'settings.notifications.reminders.subtitle' => 'Get reminded a day before recurring transactions',
			'settings.autoImportSubtitle' => 'Turn bank and payment messages into transactions',
			'settings.matchingRulesSubtitle' => 'Patterns for messages auto-import can\'t read yet',
			'settings.recurring.title' => 'Recurring transactions',
			'settings.recurring.subtitle' => 'Bills and income that repeat',
			'settings.feedbackSubtitle' => 'Report a problem or suggest an idea',
			'settings.signOut' => 'Sign out',
			'settings.deleteAccount' => 'Delete account',
			'settings.signIn.title' => 'Sign in',
			'settings.signIn.subtitle' => 'Keep your data on all your devices',
			'settings.deleteDialog.title' => 'Delete account',
			'settings.deleteDialog.question' => 'Are you sure you want to delete your account?',
			'settings.deleteDialog.listTitle' => 'This permanently deletes:',
			'settings.deleteDialog.expenses' => '• All your expenses',
			'settings.deleteDialog.categories' => '• All your categories',
			'settings.deleteDialog.budgets' => '• All your budgets',
			'settings.deleteDialog.recurring' => '• All your recurring transactions',
			'settings.deleteDialog.rules' => '• All your matching rules',
			'settings.deleteDialog.cannotUndo' => 'This cannot be undone.',
			'settings.deleteDialog.confirm' => 'I understand and want to delete my account',
			'settings.loadFailed' => 'Couldn\'t load your settings.',
			'settings.appearanceScreen.sections.theme' => 'Theme',
			'settings.appearanceScreen.sections.preview' => 'Preview',
			'settings.appearanceScreen.lightTitle' => 'Light mode preview',
			'settings.appearanceScreen.lightBody' => 'Clean, bright interface with soft lavender accents.',
			'settings.appearanceScreen.darkTitle' => 'Dark mode preview',
			'settings.appearanceScreen.darkBody' => 'A deep charcoal background with lavender accents for a calm, focused look.',
			'settings.currencyScreen.searchHint' => 'Search currencies',
			'settings.currencyScreen.noResults' => ({required Object query}) => 'No currency matches "${query}"',
			'settings.numberFormat.title' => 'Number format',
			'settings.numberFormat.sections.preview' => 'Preview',
			'settings.numberFormat.sections.decimalPlaces' => 'Decimal places',
			'settings.numberFormat.sections.grouping' => 'Digit grouping',
			'settings.numberFormat.places.count' => ({required Object n}) => '${n} places',
			'settings.numberFormat.places.noMinorUnits' => ({required Object currency}) => '${currency} has no decimal places',
			'settings.fontSize.title' => 'Font size',
			'settings.fontSize.sampleTitle' => 'Sample transaction',
			'settings.fontSize.sampleBody' => 'This is how your transactions will appear with the selected font size.',
			'settings.fontSize.sections.preview' => 'Preview',
			'settings.fontSize.sections.fontSize' => 'Font size',
			'settings.calendar.title' => 'Calendar',
			'settings.calendar.rowSubtitle' => ({required Object day}) => 'Week starts on ${day}',
			'settings.calendar.sections.firstDayOfWeek' => 'First day of week',
			'settings.homePage.title' => 'Home page',
			'settings.homePage.intro' => 'Choose which screen to show when you open the app',
			'settings.homePage.sections.defaultHomePage' => 'Default home page',
			'settings.homePage.options.home.title' => 'Home',
			'settings.homePage.options.home.subtitle' => 'Overview with net, budgets and recent activity',
			'settings.homePage.options.activity.title' => 'Activity',
			'settings.homePage.options.activity.subtitle' => 'Full transaction history list',
			'settings.homePage.options.budgets.title' => 'Budgets',
			'settings.homePage.options.budgets.subtitle' => 'Budget overview and progress tracking',
			'settings.homePage.options.reports.title' => 'Reports',
			'settings.homePage.options.reports.subtitle' => 'Trends, categories and insights',
			'settings.sync.title' => 'Sync',
			'settings.sync.rowSubtitle' => 'Keep your data on all your devices',
			'settings.sync.onTitle' => 'Sync is on',
			'settings.sync.onBody' => 'Your transactions, budgets and categories are copied to your account as you go, so your other devices get them too.',
			'settings.sync.offTitle' => 'Sync is off',
			'settings.sync.offBody' => 'This device isn\'t sending or receiving changes. Your changes stay on this phone and are sent when you turn Sync back on.',
			'settings.sync.signedOutTitle' => 'Sync your data',
			'settings.sync.signedOutBody' => 'Sign in with Google to keep your transactions on all your devices.',
			'settings.sync.lastSynced' => 'Last synced',
			'settings.sync.never' => 'Not yet',
			'settings.sync.today' => ({required Object time}) => 'Today, ${time}',
			'settings.sync.yesterday' => ({required Object time}) => 'Yesterday, ${time}',
			'settings.sync.lastFailed' => ({required Object time}) => 'Last sync failed · ${time}',
			'settings.sync.retry' => 'Retry',
			'settings.sync.failureBannerTitle' => 'Sync isn\'t working right now',
			'settings.sync.failureBannerBody' => 'Your changes are safe on this phone and will be sent when Sync works again.',
			'settings.sync.pending' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} change waiting to send', other: '${n} changes waiting to send', ), 
			'settings.sync.allSent' => 'All changes sent',
			'settings.sync.sections.device' => 'This device',
			'settings.sync.enable' => 'Sync on this device',
			'settings.sync.syncNow' => 'Sync now',
			'settings.sync.syncing' => 'Syncing…',
			'settings.sync.loadFailed' => 'Couldn\'t load sync status',
			'settings.sync.result.success' => 'Sync complete',
			'settings.sync.result.offline' => 'You\'re offline. Changes will be sent when you\'re back online.',
			'settings.sync.result.failed' => 'Sync didn\'t finish. It will try again on its own.',
			'settings.sync.result.disabled' => 'Turn on Sync first',
			'settings.sync.result.signedOut' => 'Sign in to sync',
			'settings.sync.result.firstSyncPending' => 'Finishing sign-in. Try again in a moment.',
			'settings.export.title' => 'Export data',
			'settings.export.rowSubtitle' => 'Save your transactions as CSV files',
			'settings.export.infoTitle' => 'Export your financial data',
			'settings.export.infoBody' => 'Save your transactions, budgets and categories as CSV files for spreadsheets or accounting software.',
			'settings.export.sections.dateRange' => 'Date range',
			'settings.export.sections.include' => 'Include',
			'settings.export.ranges.allTime' => 'All time',
			'settings.export.ranges.allTimeSubtitle' => 'Export everything',
			'settings.export.ranges.thisYear' => 'This year',
			'settings.export.ranges.lastSixMonths' => 'Last 6 months',
			'settings.export.ranges.lastThreeMonths' => 'Last 3 months',
			'settings.export.ranges.custom' => 'Custom range',
			'settings.export.ranges.customSubtitle' => 'Select start and end dates',
			'settings.export.ranges.untilToday' => ({required Object start}) => '${start} – Present',
			'settings.export.ranges.between' => ({required Object start, required Object end}) => '${start} – ${end}',
			'settings.export.include.transactions' => 'Transactions',
			'settings.export.include.budgets' => 'Budgets',
			'settings.export.include.categories' => 'Categories',
			'settings.export.rangeNote' => 'The date range applies to transactions. Budgets and categories are exported in full.',
			'settings.export.button' => 'Export data',
			'settings.export.exporting' => 'Preparing export…',
			'settings.export.shareSubject' => 'Expenzo export',
			'settings.export.nothingSelected' => 'Choose at least one thing to export',
			'settings.export.emptyRange' => 'No transactions in this range',
			'settings.deleteData.title' => 'Delete all data',
			'settings.deleteData.rowSubtitle' => 'Erase transactions, budgets and settings',
			'settings.deleteData.warningTitle' => 'This action cannot be undone',
			'settings.deleteData.warningBody' => 'Delete all your financial data including transactions, budgets, categories, and settings. This will permanently erase everything from this device.',
			'settings.deleteData.warningBodySignedIn' => 'Delete all your financial data including transactions, budgets, categories, and settings, from this device and from your account.',
			'settings.deleteData.otherDevicesNote' => 'Your other devices keep their copy until you delete it there too.',
			'settings.deleteData.sections.summary' => 'Data that will be deleted',
			'settings.deleteData.sections.confirmation' => 'Confirmation',
			'settings.deleteData.transactions' => 'Transactions',
			'settings.deleteData.transactionsCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} transaction', other: '${n} transactions', ), 
			'settings.deleteData.budgets' => 'Budgets',
			'settings.deleteData.budgetsCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} budget', other: '${n} budgets', ), 
			'settings.deleteData.categories' => 'Categories',
			'settings.deleteData.categoriesCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} category', other: '${n} categories', ), 
			'settings.deleteData.recurring' => 'Recurring transactions',
			'settings.deleteData.recurringCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} recurring', other: '${n} recurring', ), 
			'settings.deleteData.smsRules' => 'SMS rules',
			'settings.deleteData.smsRulesCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} rule', other: '${n} rules', ), 
			'settings.deleteData.goals' => 'Goals',
			'settings.deleteData.goalsCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} goal', other: '${n} goals', ), 
			'settings.deleteData.settings' => 'Settings',
			'settings.deleteData.settingsValue' => 'All preferences',
			'settings.deleteData.categoriesNote' => 'Default categories are added back.',
			'settings.deleteData.confirmHint' => 'Type DELETE to confirm',
			'settings.deleteData.button' => 'Delete all data',
			'settings.deleteData.deleting' => 'Deleting…',
			'settings.deleteData.done' => 'All data deleted',
			'settings.deleteData.serverFailed' => 'Couldn\'t delete the data in your account. Nothing was deleted. Check your connection and try again.',
			'settings.categories.rowSubtitle' => 'Add, edit and remove categories',
			'shell.tabs.home' => 'Home',
			'shell.tabs.activity' => 'Activity',
			'shell.tabs.budgets' => 'Budgets',
			'shell.tabs.reports' => 'Reports',
			'shell.reportsTabs.trend' => 'Trend',
			'shell.reportsTabs.categories' => 'Categories',
			'shell.reportsTabs.insights' => 'Insights',
			'smsParser.range.last7Days' => 'Last 7 days',
			'smsParser.range.last30Days' => 'Last 30 days',
			'smsParser.range.last3Months' => 'Last 3 months',
			'smsParser.range.allTime' => 'All time',
			'smsParser.range.custom' => 'Custom date range',
			'smsParser.range.from' => ({required Object date}) => 'From ${date}',
			'smsParser.range.until' => ({required Object date}) => 'Until ${date}',
			'smsParser.range.selectDate' => 'Select date',
			'smsParser.summary.range' => 'Range',
			'smsParser.summary.matches' => 'Matches',
			'smsParser.summary.selected' => 'Selected',
			'smsParser.card.rule' => ({required Object id}) => 'Rule: ${id}',
			'smsParser.options.title' => 'Scan past SMS for records',
			'smsParser.toolbar.sender' => 'Sender',
			'smsParser.toolbar.flatList' => 'Flat list',
			'smsParser.toolbar.clear' => 'Clear',
			'smsParser.section.selectAll' => 'Select all',
			'smsParser.section.clear' => 'Clear',
			'smsParser.section.counts' => ({required num n, required Object selected}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} message · ${selected} selected', other: '${n} messages · ${selected} selected', ), 
			'smsParser.customRange.title' => 'Select custom range',
			'smsParser.customRange.body' => 'Choose a start and end date before scanning past SMS for records.',
			'smsParser.customRange.start' => 'Start date',
			'smsParser.customRange.end' => 'End date',
			'smsParser.customRange.invalid' => 'Pick a valid start and end date.',
			'smsParser.customRange.apply' => 'Apply',
			'smsParser.results.title' => 'Scan results',
			'smsParser.results.empty' => 'No new records found',
			'smsParser.results.emptyBody' => 'Try scanning again or add more matching rules',
			'smsParser.results.create' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Add ${n} selected record', other: 'Add ${n} selected records', ), 
			'smsParser.autoImport.scanPast' => 'Scan past SMS',
			_ => null,
		};
	}
}
