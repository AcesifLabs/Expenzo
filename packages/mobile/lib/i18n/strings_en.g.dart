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
	late final Translations$family$en family = Translations$family$en.internal(_root);
	late final Translations$goals$en goals = Translations$goals$en.internal(_root);
	late final Translations$messageTemplates$en messageTemplates = Translations$messageTemplates$en.internal(_root);
	late final Translations$notifications$en notifications = Translations$notifications$en.internal(_root);
	late final Translations$onboarding$en onboarding = Translations$onboarding$en.internal(_root);
	late final Translations$receiptScan$en receiptScan = Translations$receiptScan$en.internal(_root);
	late final Translations$records$en records = Translations$records$en.internal(_root);
	late final Translations$recurring$en recurring = Translations$recurring$en.internal(_root);
	late final Translations$reports$en reports = Translations$reports$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$shell$en shell = Translations$shell$en.internal(_root);
	late final Translations$smsParser$en smsParser = Translations$smsParser$en.internal(_root);
	late final Translations$support$en support = Translations$support$en.internal(_root);
}

// Path: aiAssistant
class Translations$aiAssistant$en {
	Translations$aiAssistant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expie'
	String get title => 'Expie';

	/// en: 'Ask about your spending'
	String get inputHint => 'Ask about your spending';

	/// en: 'Send message'
	String get send => 'Send message';

	/// en: 'Expie provides suggestions based on your data. It is not a licensed financial advisor.'
	String get disclaimer => 'Expie provides suggestions based on your data. It is not a licensed financial advisor.';

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

	/// en: 'Shared'
	String get sharedBadge => 'Shared';
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

	/// en: 'Settings'
	String get settings => 'Settings';

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

// Path: family
class Translations$family$en {
	Translations$family$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$family$create$en create = Translations$family$create$en.internal(_root);
	late final Translations$family$join$en join = Translations$family$join$en.internal(_root);
	late final Translations$family$invite$en invite = Translations$family$invite$en.internal(_root);
	late final Translations$family$dashboard$en dashboard = Translations$family$dashboard$en.internal(_root);
	late final Translations$family$members$en members = Translations$family$members$en.internal(_root);
	late final Translations$family$roles$en roles = Translations$family$roles$en.internal(_root);
	late final Translations$family$roleHints$en roleHints = Translations$family$roleHints$en.internal(_root);
	late final Translations$family$errors$en errors = Translations$family$errors$en.internal(_root);
}

// Path: goals
class Translations$goals$en {
	Translations$goals$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$goals$errors$en errors = Translations$goals$errors$en.internal(_root);
	late final Translations$goals$card$en card = Translations$goals$card$en.internal(_root);
	late final Translations$goals$addSheet$en addSheet = Translations$goals$addSheet$en.internal(_root);

	/// en: 'Added {amount} to {name}'
	String added({required Object amount, required Object name}) => 'Added ${amount} to ${name}';

	late final Translations$goals$list$en list = Translations$goals$list$en.internal(_root);
	late final Translations$goals$form$en form = Translations$goals$form$en.internal(_root);
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

	late final Translations$messageTemplates$watchlist$en watchlist = Translations$messageTemplates$watchlist$en.internal(_root);
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

// Path: onboarding
class Translations$onboarding$en {
	Translations$onboarding$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$onboarding$budgetNames$en budgetNames = Translations$onboarding$budgetNames$en.internal(_root);
	late final Translations$onboarding$common$en common = Translations$onboarding$common$en.internal(_root);
	late final Translations$onboarding$income$en income = Translations$onboarding$income$en.internal(_root);
	late final Translations$onboarding$recurring$en recurring = Translations$onboarding$recurring$en.internal(_root);
	late final Translations$onboarding$plan$en plan = Translations$onboarding$plan$en.internal(_root);
	late final Translations$onboarding$goal$en goal = Translations$onboarding$goal$en.internal(_root);
	late final Translations$onboarding$timeline$en timeline = Translations$onboarding$timeline$en.internal(_root);
	late final Translations$onboarding$complete$en complete = Translations$onboarding$complete$en.internal(_root);
	late final Translations$onboarding$tutorial$en tutorial = Translations$onboarding$tutorial$en.internal(_root);
}

// Path: receiptScan
class Translations$receiptScan$en {
	Translations$receiptScan$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Camera permission is required to scan receipts.'
	String get permissionRequired => 'Camera permission is required to scan receipts.';

	/// en: 'Camera access is off for Expenzo. Turn it on in Settings to scan receipts.'
	String get permissionBlocked => 'Camera access is off for Expenzo. Turn it on in Settings to scan receipts.';

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

	/// en: 'Ask Expie'
	String get askAi => 'Ask Expie';

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

	/// en: 'SMS Watchlist'
	String get smsWatchlist => 'SMS Watchlist';

	/// en: 'Senders Expenzo reads'
	String get smsWatchlistSubtitle => 'Senders Expenzo reads';

	late final Translations$settings$recurring$en recurring = Translations$settings$recurring$en.internal(_root);
	late final Translations$settings$help$en help = Translations$settings$help$en.internal(_root);
	late final Translations$settings$crashReports$en crashReports = Translations$settings$crashReports$en.internal(_root);

	/// en: 'Sign out'
	String get signOut => 'Sign out';

	/// en: 'Delete account'
	String get deleteAccount => 'Delete account';

	late final Translations$settings$signIn$en signIn = Translations$settings$signIn$en.internal(_root);
	late final Translations$settings$profile$en profile = Translations$settings$profile$en.internal(_root);
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
	late final Translations$settings$family$en family = Translations$settings$family$en.internal(_root);
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

// Path: support
class Translations$support$en {
	Translations$support$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$support$help$en help = Translations$support$help$en.internal(_root);
	late final Translations$support$about$en about = Translations$support$about$en.internal(_root);
	late final Translations$support$faq$en faq = Translations$support$faq$en.internal(_root);
	late final Translations$support$rate$en rate = Translations$support$rate$en.internal(_root);
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

	/// en: 'Shared by your family admin. Only they can change it.'
	String get sharedReadOnly => 'Shared by your family admin. Only they can change it.';

	/// en: 'Shared budget'
	String get sharedTitle => 'Shared budget';

	/// en: 'Share with family'
	String get share => 'Share with family';

	/// en: 'Members of {name} can see it and add expenses to it'
	String shareDetail({required Object name}) => 'Members of ${name} can see it and add expenses to it';

	/// en: 'Stop sharing?'
	String get unshareTitle => 'Stop sharing?';

	/// en: 'Members will no longer see this budget. Transactions already added stay as they are.'
	String get unshareBody => 'Members will no longer see this budget. Transactions already added stay as they are.';

	/// en: 'Stop sharing'
	String get unshareConfirm => 'Stop sharing';
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

	/// en: 'Includes {amount} carried over'
	String carriedOver({required Object amount}) => 'Includes ${amount} carried over';

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

	/// en: 'For your security, sign in again, then delete your account.'
	String get requiresRecentLogin => 'For your security, sign in again, then delete your account.';
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

	/// en: 'The data on this phone can't be read. Reset it to keep using Expenzo. Anything you synced comes back after you sign in.'
	String get storageBody => 'The data on this phone can\'t be read. Reset it to keep using Expenzo. Anything you synced comes back after you sign in.';

	/// en: 'Reset local data'
	String get resetLocalData => 'Reset local data';

	/// en: 'This deletes the transactions, budgets and categories saved on this phone. Synced data comes back after you sign in. Changes that weren't synced are lost.'
	String get resetConfirm => 'This deletes the transactions, budgets and categories saved on this phone. Synced data comes back after you sign in. Changes that weren\'t synced are lost.';

	/// en: 'Delete and start again'
	String get resetConfirmAction => 'Delete and start again';
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

	/// en: 'Recent Activity'
	String get recentActivity => 'Recent Activity';

	/// en: 'Spending Patterns'
	String get spendingPatterns => 'Spending Patterns';

	/// en: 'See all'
	String get seeAll => 'See all';
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

// Path: family.create
class Translations$family$create$en {
	Translations$family$create$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create family group'
	String get title => 'Create family group';

	/// en: 'Start your family plan'
	String get heading => 'Start your family plan';

	/// en: 'Create a shared budget space for your family.'
	String get body => 'Create a shared budget space for your family.';

	/// en: 'Group name'
	String get nameLabel => 'Group name';

	/// en: 'Rahman Family'
	String get nameHint => 'Rahman Family';

	/// en: 'Enter a group name'
	String get nameRequired => 'Enter a group name';

	/// en: 'Monthly family budget (optional)'
	String get budgetLabel => 'Monthly family budget (optional)';

	/// en: 'Enter an amount above zero'
	String get budgetInvalid => 'Enter an amount above zero';

	/// en: 'Currency: {code} (from your settings)'
	String currencyNote({required Object code}) => 'Currency: ${code} (from your settings)';

	/// en: 'Create group'
	String get submit => 'Create group';

	/// en: 'Have an invite code? Join a family'
	String get haveCode => 'Have an invite code? Join a family';
}

// Path: family.join
class Translations$family$join$en {
	Translations$family$join$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Join a family'
	String get title => 'Join a family';

	/// en: 'Enter the 6-character code your family admin shared.'
	String get body => 'Enter the 6-character code your family admin shared.';

	/// en: 'Invite code'
	String get codeLabel => 'Invite code';

	/// en: 'Codes have 6 letters and numbers'
	String get codeInvalid => 'Codes have 6 letters and numbers';

	/// en: 'Your currency: {code}'
	String currencyNote({required Object code}) => 'Your currency: ${code}';

	/// en: 'Join group'
	String get submit => 'Join group';

	/// en: 'You joined {name}'
	String joined({required Object name}) => 'You joined ${name}';

	/// en: 'You joined. Turn on Sync in Settings to see the shared budgets.'
	String get syncOff => 'You joined. Turn on Sync in Settings to see the shared budgets.';
}

// Path: family.invite
class Translations$family$invite$en {
	Translations$family$invite$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invite members'
	String get title => 'Invite members';

	/// en: 'Invite your family'
	String get heading => 'Invite your family';

	/// en: 'Up to 10 members, you included'
	String get limitNote => 'Up to 10 members, you included';

	/// en: 'Share this invite code'
	String get codeCaption => 'Share this invite code';

	/// en: 'Valid until {time}'
	String validUntil({required Object time}) => 'Valid until ${time}';

	/// en: 'Share invite'
	String get share => 'Share invite';

	/// en: 'Join my family "{name}" on Expenzo: open Settings > Family group > Join a family and enter {code}. The code works until {time}.'
	String shareText({required Object name, required Object code, required Object time}) => 'Join my family "${name}" on Expenzo: open Settings > Family group > Join a family and enter ${code}. The code works until ${time}.';

	/// en: 'Regenerate code'
	String get regenerate => 'Regenerate code';

	/// en: 'Make a new code?'
	String get regenerateTitle => 'Make a new code?';

	/// en: 'The current code will stop working.'
	String get regenerateBody => 'The current code will stop working.';

	/// en: 'Code copied'
	String get copied => 'Code copied';

	/// en: 'You're offline. Connect to get an invite code.'
	String get offline => 'You\'re offline. Connect to get an invite code.';

	/// en: 'This code has expired. Make a new one.'
	String get expired => 'This code has expired. Make a new one.';
}

// Path: family.dashboard
class Translations$family$dashboard$en {
	Translations$family$dashboard$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spent of planned'
	String get spentOfPlanned => 'Spent of planned';

	/// en: '{spent} of {planned}'
	String spentOfPlannedValue({required Object spent, required Object planned}) => '${spent} of ${planned}';

	/// en: 'Expense: {amount}'
	String expense({required Object amount}) => 'Expense: ${amount}';

	/// en: 'Shared budget total: {amount}'
	String sharedBudgetTotal({required Object amount}) => 'Shared budget total: ${amount}';

	/// en: '{spent} of {budget} this month'
	String ofMonthlyBudget({required Object spent, required Object budget}) => '${spent} of ${budget} this month';

	/// en: 'Only transactions in shared budgets count here.'
	String get onlySharedNote => 'Only transactions in shared budgets count here.';

	/// en: '{name} (you)'
	String you({required Object name}) => '${name} (you)';

	/// en: 'Family member'
	String get memberFallback => 'Family member';

	/// en: '+{n}'
	String moreMembers({required Object n}) => '+${n}';

	/// en: 'No shared budgets yet. Admins can share one from the budget form.'
	String get noSharedBudgets => 'No shared budgets yet. Admins can share one from the budget form.';

	/// en: 'See all budgets'
	String get seeAllBudgets => 'See all budgets';

	/// en: 'Last updated {time}'
	String lastUpdated({required Object time}) => 'Last updated ${time}';

	/// en: 'Couldn't load your family. Check your connection and try again.'
	String get loadFailed => 'Couldn\'t load your family. Check your connection and try again.';

	/// en: 'Couldn't load the latest numbers.'
	String get summaryFailed => 'Couldn\'t load the latest numbers.';

	/// en: 'Manage members'
	String get manageMembers => 'Manage members';
}

// Path: family.members
class Translations$family$members$en {
	Translations$family$members$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Members ({count})'
	String title({required Object count}) => 'Members (${count})';

	/// en: 'Invite more'
	String get inviteMore => 'Invite more';

	/// en: 'Leave group'
	String get leave => 'Leave group';

	/// en: 'Leave {name}?'
	String leaveTitle({required Object name}) => 'Leave ${name}?';

	/// en: 'Shared budgets from this group will be removed from your phone. Your own transactions stay with you.'
	String get leaveBody => 'Shared budgets from this group will be removed from your phone. Your own transactions stay with you.';

	/// en: 'You are the last member. Leaving deletes the group.'
	String get leaveLastBody => 'You are the last member. Leaving deletes the group.';

	/// en: 'Change role'
	String get changeRole => 'Change role';

	/// en: 'Remove from group'
	String get remove => 'Remove from group';

	/// en: 'Remove {name}?'
	String removeTitle({required Object name}) => 'Remove ${name}?';

	/// en: 'Delete group'
	String get deleteGroup => 'Delete group';

	/// en: 'Delete {name}?'
	String deleteTitle({required Object name}) => 'Delete ${name}?';

	/// en: 'Everyone is removed. Shared budgets become personal budgets of their owner.'
	String get deleteBody => 'Everyone is removed. Shared budgets become personal budgets of their owner.';
}

// Path: family.roles
class Translations$family$roles$en {
	Translations$family$roles$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Admin'
	String get admin => 'Admin';

	/// en: 'Member'
	String get member => 'Member';

	/// en: 'Viewer'
	String get viewer => 'Viewer';
}

// Path: family.roleHints
class Translations$family$roleHints$en {
	Translations$family$roleHints$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Manages members and shared budgets'
	String get admin => 'Manages members and shared budgets';

	/// en: 'Sees the dashboard and adds transactions to shared budgets'
	String get member => 'Sees the dashboard and adds transactions to shared budgets';

	/// en: 'Sees the dashboard only'
	String get viewer => 'Sees the dashboard only';
}

// Path: family.errors
class Translations$family$errors$en {
	Translations$family$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You're already in a family group. Leave it first.'
	String get alreadyInGroup => 'You\'re already in a family group. Leave it first.';

	/// en: 'This family uses a different currency. Switch to the same currency in Settings, then join.'
	String get currencyMismatch => 'This family uses a different currency. Switch to the same currency in Settings, then join.';

	/// en: 'Group is full. A family group can have up to 10 members.'
	String get groupFull => 'Group is full. A family group can have up to 10 members.';

	/// en: 'This code has expired. Ask your admin for a new one.'
	String get inviteExpired => 'This code has expired. Ask your admin for a new one.';

	/// en: 'No family uses this code. Check it and try again.'
	String get inviteNotFound => 'No family uses this code. Check it and try again.';

	/// en: 'Make someone else an admin first.'
	String get lastAdmin => 'Make someone else an admin first.';

	/// en: 'You're no longer in this group.'
	String get notInGroup => 'You\'re no longer in this group.';

	/// en: 'Sign in to use Family group.'
	String get signInRequired => 'Sign in to use Family group.';
}

// Path: goals.errors
class Translations$goals$errors$en {
	Translations$goals$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Give your goal a name.'
	String get nameRequired => 'Give your goal a name.';

	/// en: 'Enter a target amount above zero.'
	String get targetPositive => 'Enter a target amount above zero.';

	/// en: 'Enter an amount above zero.'
	String get amountPositive => 'Enter an amount above zero.';

	/// en: 'Enter an amount up to 9,999,999,999.99.'
	String get amountTooLarge => 'Enter an amount up to 9,999,999,999.99.';
}

// Path: goals.card
class Translations$goals$card$en {
	Translations$goals$card$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Savings Goal'
	String get section => 'Savings Goal';

	/// en: '{saved} of {target}'
	String progress({required Object saved, required Object target}) => '${saved} of ${target}';

	/// en: '(one) {{n} month left} (other) {{n} months left}'
	String monthsLeft({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} month left',
		other: '${n} months left',
	);

	/// en: 'Due this month'
	String get dueThisMonth => 'Due this month';

	/// en: 'Goal reached'
	String get reached => 'Goal reached';

	/// en: 'Plan: {amount}/month'
	String plan({required Object amount}) => 'Plan: ${amount}/month';

	/// en: 'Add to goal'
	String get addToGoal => 'Add to goal';

	/// en: 'New goal'
	String get newGoal => 'New goal';

	/// en: 'Edit goal'
	String get edit => 'Edit goal';

	/// en: 'Set a savings goal'
	String get setGoal => 'Set a savings goal';
}

// Path: goals.addSheet
class Translations$goals$addSheet$en {
	Translations$goals$addSheet$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add to {name}'
	String title({required Object name}) => 'Add to ${name}';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'This only updates the goal. It does not add a transaction.'
	String get note => 'This only updates the goal. It does not add a transaction.';
}

// Path: goals.list
class Translations$goals$list$en {
	Translations$goals$list$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Goals'
	String get title => 'Goals';

	/// en: 'Newest first. Tap a goal to edit it.'
	String get subtitle => 'Newest first. Tap a goal to edit it.';

	/// en: 'No savings goals yet.'
	String get empty => 'No savings goals yet.';

	/// en: 'Couldn't load your goals. Try again.'
	String get loadFailed => 'Couldn\'t load your goals. Try again.';
}

// Path: goals.form
class Translations$goals$form$en {
	Translations$goals$form$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit goal'
	String get title => 'Edit goal';

	/// en: 'New savings goal'
	String get createTitle => 'New savings goal';

	/// en: 'Goal name'
	String get name => 'Goal name';

	/// en: 'Target amount'
	String get target => 'Target amount';

	/// en: 'Saved so far'
	String get saved => 'Saved so far';

	/// en: 'Target date'
	String get targetDate => 'Target date';

	/// en: 'No date'
	String get noDate => 'No date';

	/// en: 'Clear date'
	String get clearDate => 'Clear date';

	/// en: 'Monthly contribution'
	String get monthly => 'Monthly contribution';

	/// en: 'Suggested: {amount}/month'
	String suggestMonthly({required Object amount}) => 'Suggested: ${amount}/month';

	/// en: 'Delete goal?'
	String get deleteTitle => 'Delete goal?';

	/// en: 'This removes the goal and its saved amount. Your transactions are not affected.'
	String get deleteBody => 'This removes the goal and its saved amount. Your transactions are not affected.';

	/// en: 'Goal saved'
	String get savedMessage => 'Goal saved';

	/// en: 'Goal created'
	String get createdMessage => 'Goal created';

	/// en: 'Goal deleted'
	String get deleted => 'Goal deleted';
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

// Path: messageTemplates.watchlist
class Translations$messageTemplates$watchlist$en {
	Translations$messageTemplates$watchlist$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'SMS Watchlist'
	String get title => 'SMS Watchlist';

	/// en: 'Messages from these senders become transactions. Pause a sender to ignore it.'
	String get subtitle => 'Messages from these senders become transactions. Pause a sender to ignore it.';

	/// en: '(one) {{n} SMS format} (other) {{n} SMS formats}'
	String formats({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} SMS format',
		other: '${n} SMS formats',
	);

	/// en: 'Paused'
	String get paused => 'Paused';

	/// en: 'Read messages from {name}'
	String toggle({required Object name}) => 'Read messages from ${name}';

	/// en: 'No senders yet. Add one from Auto-import by teaching Expenzo a sample message.'
	String get empty => 'No senders yet. Add one from Auto-import by teaching Expenzo a sample message.';

	/// en: 'Choose senders'
	String get addSender => 'Choose senders';

	/// en: 'Couldn't load the watchlist. Try again.'
	String get loadFailed => 'Couldn\'t load the watchlist. Try again.';
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

// Path: onboarding.budgetNames
class Translations$onboarding$budgetNames$en {
	Translations$onboarding$budgetNames$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Needs'
	String get needs => 'Needs';

	/// en: 'Wants'
	String get wants => 'Wants';

	/// en: 'Savings'
	String get savings => 'Savings';
}

// Path: onboarding.common
class Translations$onboarding$common$en {
	Translations$onboarding$common$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Continue'
	String get continueLabel => 'Continue';

	/// en: 'Step {current} of {total}'
	String stepOf({required Object current, required Object total}) => 'Step ${current} of ${total}';
}

// Path: onboarding.income
class Translations$onboarding$income$en {
	Translations$onboarding$income$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Let's set up your budget'
	String get title => 'Let\'s set up your budget';

	/// en: 'First, tell us about your monthly income so we can create a budget that works for you.'
	String get subtitle => 'First, tell us about your monthly income so we can create a budget that works for you.';

	/// en: 'Monthly net income'
	String get amountLabel => 'Monthly net income';

	/// en: 'Enter an amount up to 9,999,999,999.99.'
	String get amountInvalid => 'Enter an amount up to 9,999,999,999.99.';

	/// en: 'Income frequency'
	String get frequencyLabel => 'Income frequency';

	late final Translations$onboarding$income$frequency$en frequency = Translations$onboarding$income$frequency$en.internal(_root);

	/// en: '{amount}/month'
	String perMonth({required Object amount}) => '${amount}/month';
}

// Path: onboarding.recurring
class Translations$onboarding$recurring$en {
	Translations$onboarding$recurring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Any recurring payments?'
	String get title => 'Any recurring payments?';

	/// en: 'Add your regular fixed expenses so we can account for them in your budget.'
	String get subtitle => 'Add your regular fixed expenses so we can account for them in your budget.';

	/// en: 'Add another'
	String get addAnother => 'Add another';

	/// en: 'Add a payment'
	String get addFirst => 'Add a payment';

	/// en: 'Total recurring'
	String get total => 'Total recurring';

	/// en: 'Remove {name}'
	String remove({required Object name}) => 'Remove ${name}';

	late final Translations$onboarding$recurring$sheet$en sheet = Translations$onboarding$recurring$sheet$en.internal(_root);
}

// Path: onboarding.plan
class Translations$onboarding$plan$en {
	Translations$onboarding$plan$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your budget plan'
	String get title => 'Your budget plan';

	/// en: 'Based on your income, we suggest this 50/30/20 split.'
	String get subtitle => 'Based on your income, we suggest this 50/30/20 split.';

	/// en: '{amount}/mo'
	String perMonth({required Object amount}) => '${amount}/mo';

	/// en: '{percent}%'
	String share({required Object percent}) => '${percent}%';

	/// en: 'Create these as monthly budgets'
	String get createBudgets => 'Create these as monthly budgets';

	/// en: 'Add your income on the first step to see a plan.'
	String get noIncome => 'Add your income on the first step to see a plan.';

	/// en: 'Your recurring payments use all of your income, so there is nothing left to split.'
	String get noRoom => 'Your recurring payments use all of your income, so there is nothing left to split.';

	/// en: 'Needs {needs}, wants {wants}, savings {savings}'
	String chartLabel({required Object needs, required Object wants, required Object savings}) => 'Needs ${needs}, wants ${wants}, savings ${savings}';
}

// Path: onboarding.goal
class Translations$onboarding$goal$en {
	Translations$onboarding$goal$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What are you saving for?'
	String get title => 'What are you saving for?';

	/// en: 'Set a savings goal and we'll help you track progress.'
	String get subtitle => 'Set a savings goal and we\'ll help you track progress.';

	/// en: 'Goal name'
	String get nameLabel => 'Goal name';

	/// en: 'e.g. New laptop'
	String get nameHint => 'e.g. New laptop';

	/// en: 'Target amount'
	String get amountLabel => 'Target amount';

	/// en: 'No goal for now'
	String get notNow => 'No goal for now';
}

// Path: onboarding.timeline
class Translations$onboarding$timeline$en {
	Translations$onboarding$timeline$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pick your timeline'
	String get title => 'Pick your timeline';

	/// en: 'You can afford {name} in {months} months saving {amount}/month.'
	String canAfford({required Object name, required Object months, required Object amount}) => 'You can afford ${name} in ${months} months saving ${amount}/month.';

	/// en: 'Your savings of {amount}/month don't cover these. Pick a later custom date.'
	String cannotAfford({required Object amount}) => 'Your savings of ${amount}/month don\'t cover these. Pick a later custom date.';

	/// en: '(one) {{n} month} (other) {{n} months}'
	String months({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} month',
		other: '${n} months',
	);

	/// en: '{amount}/mo'
	String perMonth({required Object amount}) => '${amount}/mo';

	/// en: 'Custom'
	String get custom => 'Custom';

	/// en: 'Set your own'
	String get customHint => 'Set your own';

	late final Translations$onboarding$timeline$fit$en fit = Translations$onboarding$timeline$fit$en.internal(_root);
}

// Path: onboarding.complete
class Translations$onboarding$complete$en {
	Translations$onboarding$complete$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Setup complete!'
	String get title => 'Setup complete!';

	/// en: 'Budget created'
	String get budgets => 'Budget created';

	/// en: '(one) {{n} recurring payment} (other) {{n} recurring payments}'
	String recurring({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} recurring payment',
		other: '${n} recurring payments',
	);

	/// en: 'Savings goal: {name}'
	String goal({required Object name}) => 'Savings goal: ${name}';

	/// en: 'You can change your budgets and goal at any time.'
	String get tip => 'You can change your budgets and goal at any time.';

	/// en: 'Finish setup'
	String get finish => 'Finish setup';

	/// en: 'Saving your setup…'
	String get saving => 'Saving your setup…';

	/// en: 'Some items couldn't be saved. You can add them later.'
	String get partialFailure => 'Some items couldn\'t be saved. You can add them later.';
}

// Path: onboarding.tutorial
class Translations$onboarding$tutorial$en {
	Translations$onboarding$tutorial$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$onboarding$tutorial$dashboard$en dashboard = Translations$onboarding$tutorial$dashboard$en.internal(_root);
	late final Translations$onboarding$tutorial$addTransaction$en addTransaction = Translations$onboarding$tutorial$addTransaction$en.internal(_root);
	late final Translations$onboarding$tutorial$reports$en reports = Translations$onboarding$tutorial$reports$en.internal(_root);

	/// en: 'Page {current} of {total}'
	String pageOf({required Object current, required Object total}) => 'Page ${current} of ${total}';

	late final Translations$onboarding$tutorial$cta$en cta = Translations$onboarding$tutorial$cta$en.internal(_root);
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

// Path: settings.help
class Translations$settings$help$en {
	Translations$settings$help$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Help & Support'
	String get title => 'Help & Support';

	/// en: 'FAQ, contact us, rate the app, legal'
	String get rowSubtitle => 'FAQ, contact us, rate the app, legal';
}

// Path: settings.crashReports
class Translations$settings$crashReports$en {
	Translations$settings$crashReports$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Send crash reports'
	String get title => 'Send crash reports';

	/// en: 'Error details only. Amounts, numbers and SMS text are removed.'
	String get subtitle => 'Error details only. Amounts, numbers and SMS text are removed.';
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

// Path: settings.profile
class Translations$settings$profile$en {
	Translations$settings$profile$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My profile'
	String get title => 'My profile';

	/// en: 'Your Google account'
	String get rowSubtitle => 'Your Google account';

	/// en: 'Name'
	String get nameLabel => 'Name';

	/// en: 'Email'
	String get emailLabel => 'Email';

	/// en: 'No name on this Google account'
	String get noName => 'No name on this Google account';

	/// en: 'Signed in with Google'
	String get signedInWith => 'Signed in with Google';

	/// en: 'Your name and photo come from your Google account. Change them there.'
	String get googleNote => 'Your name and photo come from your Google account. Change them there.';

	/// en: 'Deleting your account…'
	String get deletingAccount => 'Deleting your account…';

	/// en: 'Your account was deleted'
	String get accountDeleted => 'Your account was deleted';

	/// en: 'You're not signed in'
	String get signedOutTitle => 'You\'re not signed in';

	/// en: 'Sign in with Google to keep your transactions on all your devices.'
	String get signedOutBody => 'Sign in with Google to keep your transactions on all your devices.';

	/// en: 'Guest'
	String get guestName => 'Guest';

	/// en: 'Sign in to sync your data'
	String get guestSubtitle => 'Sign in to sync your data';
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

	/// en: 'This permanently deletes, from your account and this phone:'
	String get listTitle => 'This permanently deletes, from your account and this phone:';

	/// en: '• All your transactions'
	String get transactions => '• All your transactions';

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

	/// en: '(one) {{n} change couldn't sync} (other) {{n} changes couldn't sync}'
	String failed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} change couldn\'t sync',
		other: '${n} changes couldn\'t sync',
	);

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

	/// en: 'Shared budgets you created will be removed for your family.'
	String get familyAdminNote => 'Shared budgets you created will be removed for your family.';
}

// Path: settings.categories
class Translations$settings$categories$en {
	Translations$settings$categories$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add, edit and remove categories'
	String get rowSubtitle => 'Add, edit and remove categories';
}

// Path: settings.family
class Translations$settings$family$en {
	Translations$settings$family$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Family group'
	String get title => 'Family group';

	/// en: 'Share budgets with your family'
	String get rowSubtitle => 'Share budgets with your family';

	late final Translations$settings$family$sections$en sections = Translations$settings$family$sections$en.internal(_root);
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

	/// en: 'No amount'
	String get noAmount => 'No amount';
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

// Path: support.help
class Translations$support$help$en {
	Translations$support$help$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Watch tutorial'
	String get watchTutorial => 'Watch tutorial';

	late final Translations$support$help$replaySetup$en replaySetup = Translations$support$help$replaySetup$en.internal(_root);

	/// en: 'Help & Support'
	String get title => 'Help & Support';

	/// en: 'FAQ'
	String get faq => 'FAQ';

	/// en: 'Contact support'
	String get contactSupport => 'Contact support';

	/// en: 'Rate the app'
	String get rateApp => 'Rate the app';

	/// en: 'Privacy policy'
	String get privacyPolicy => 'Privacy policy';

	/// en: 'Terms of service'
	String get termsOfService => 'Terms of service';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Couldn't open the page. Try again later.'
	String get linkFailed => 'Couldn\'t open the page. Try again later.';
}

// Path: support.about
class Translations$support$about$en {
	Translations$support$about$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'About Expenzo'
	String get title => 'About Expenzo';

	/// en: 'Version {version} ({build})'
	String version({required Object version, required Object build}) => 'Version ${version} (${build})';

	/// en: 'Expenzo tracks your spending, budgets and recurring bills, and can read bank SMS to log transactions for you.'
	String get description => 'Expenzo tracks your spending, budgets and recurring bills, and can read bank SMS to log transactions for you.';

	/// en: 'Made by Acesif Labs'
	String get madeBy => 'Made by Acesif Labs';
}

// Path: support.faq
class Translations$support$faq$en {
	Translations$support$faq$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'FAQ'
	String get title => 'FAQ';

	/// en: 'Search FAQs...'
	String get searchHint => 'Search FAQs...';

	/// en: 'No questions match "{query}".'
	String noResults({required Object query}) => 'No questions match "${query}".';

	late final Translations$support$faq$addTransaction$en addTransaction = Translations$support$faq$addTransaction$en.internal(_root);
	late final Translations$support$faq$autoImport$en autoImport = Translations$support$faq$autoImport$en.internal(_root);
	late final Translations$support$faq$budget$en budget = Translations$support$faq$budget$en.internal(_root);
	late final Translations$support$faq$recurring$en recurring = Translations$support$faq$recurring$en.internal(_root);
	late final Translations$support$faq$export$en export = Translations$support$faq$export$en.internal(_root);
	late final Translations$support$faq$sync$en sync = Translations$support$faq$sync$en.internal(_root);
	late final Translations$support$faq$aiAssistant$en aiAssistant = Translations$support$faq$aiAssistant$en.internal(_root);
	late final Translations$support$faq$currency$en currency = Translations$support$faq$currency$en.internal(_root);
}

// Path: support.rate
class Translations$support$rate$en {
	Translations$support$rate$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Love Expenzo?'
	String get title => 'Love Expenzo?';

	/// en: 'Enjoying Expenzo?'
	String get heading => 'Enjoying Expenzo?';

	/// en: 'Your feedback helps us improve. Tap a star to rate the app.'
	String get subtitle => 'Your feedback helps us improve. Tap a star to rate the app.';

	/// en: 'Write a review'
	String get writeReview => 'Write a review';

	/// en: 'Tell us what to improve'
	String get tellUs => 'Tell us what to improve';

	/// en: 'Maybe later'
	String get maybeLater => 'Maybe later';

	/// en: 'No thanks'
	String get noThanks => 'No thanks';

	/// en: '{n} of 5 stars'
	String starLabel({required Object n}) => '${n} of 5 stars';
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

// Path: onboarding.income.frequency
class Translations$onboarding$income$frequency$en {
	Translations$onboarding$income$frequency$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Bi-weekly'
	String get biWeekly => 'Bi-weekly';

	/// en: 'Weekly'
	String get weekly => 'Weekly';
}

// Path: onboarding.recurring.sheet
class Translations$onboarding$recurring$sheet$en {
	Translations$onboarding$recurring$sheet$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recurring payment'
	String get title => 'Recurring payment';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'e.g. Rent'
	String get nameHint => 'e.g. Rent';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Repeats'
	String get frequency => 'Repeats';
}

// Path: onboarding.timeline.fit
class Translations$onboarding$timeline$fit$en {
	Translations$onboarding$timeline$fit$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Fits your savings'
	String get affordable => 'Fits your savings';

	/// en: 'More than your savings'
	String get tooExpensive => 'More than your savings';

	/// en: 'Takes a long time'
	String get slow => 'Takes a long time';
}

// Path: onboarding.tutorial.dashboard
class Translations$onboarding$tutorial$dashboard$en {
	Translations$onboarding$tutorial$dashboard$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your money at a glance'
	String get title => 'Your money at a glance';

	/// en: 'Home shows this month's net, your budgets and recent activity.'
	String get body => 'Home shows this month\'s net, your budgets and recent activity.';
}

// Path: onboarding.tutorial.addTransaction
class Translations$onboarding$tutorial$addTransaction$en {
	Translations$onboarding$tutorial$addTransaction$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add a transaction in seconds'
	String get title => 'Add a transaction in seconds';

	/// en: 'Tap + on any tab, type the amount and pick a category.'
	String get body => 'Tap + on any tab, type the amount and pick a category.';
}

// Path: onboarding.tutorial.reports
class Translations$onboarding$tutorial$reports$en {
	Translations$onboarding$tutorial$reports$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'See where your money goes'
	String get title => 'See where your money goes';

	/// en: 'Reports shows trends, categories and insights.'
	String get body => 'Reports shows trends, categories and insights.';
}

// Path: onboarding.tutorial.cta
class Translations$onboarding$tutorial$cta$en {
	Translations$onboarding$tutorial$cta$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You're all set!'
	String get title => 'You\'re all set!';

	/// en: 'You now know the basics. Let's start tracking your finances!'
	String get body => 'You now know the basics. Let\'s start tracking your finances!';

	/// en: 'Let's get started!'
	String get start => 'Let\'s get started!';
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

// Path: settings.family.sections
class Translations$settings$family$sections$en {
	Translations$settings$family$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spending by member'
	String get spendingByMember => 'Spending by member';

	/// en: 'Shared budget progress'
	String get sharedBudgets => 'Shared budget progress';
}

// Path: support.help.replaySetup
class Translations$support$help$replaySetup$en {
	Translations$support$help$replaySetup$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Replay setup'
	String get title => 'Replay setup';

	/// en: 'Go through income, budgets and goal again'
	String get rowSubtitle => 'Go through income, budgets and goal again';

	/// en: 'Replay setup?'
	String get confirmTitle => 'Replay setup?';

	/// en: 'Your transactions stay as they are. Budgets, recurring payments and a goal you add again are created as new items.'
	String get confirmBody => 'Your transactions stay as they are. Budgets, recurring payments and a goal you add again are created as new items.';
}

// Path: support.faq.addTransaction
class Translations$support$faq$addTransaction$en {
	Translations$support$faq$addTransaction$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do I add a transaction?'
	String get q => 'How do I add a transaction?';

	/// en: 'Tap the + button at the bottom of any tab. Choose expense or income, enter the amount, pick a category and tap Add expense or Add income.'
	String get a => 'Tap the + button at the bottom of any tab. Choose expense or income, enter the amount, pick a category and tap Add expense or Add income.';
}

// Path: support.faq.autoImport
class Translations$support$faq$autoImport$en {
	Translations$support$faq$autoImport$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How does Auto-import work?'
	String get q => 'How does Auto-import work?';

	/// en: 'Go to Settings → Auto-import from SMS and allow SMS access. Expenzo reads bank and payment messages on your phone and turns them into transactions. The message text stays on your phone; the transactions it creates sync like any other. Tap Scan past SMS on that page to import older messages.'
	String get a => 'Go to Settings → Auto-import from SMS and allow SMS access. Expenzo reads bank and payment messages on your phone and turns them into transactions. The message text stays on your phone; the transactions it creates sync like any other. Tap Scan past SMS on that page to import older messages.';
}

// Path: support.faq.budget
class Translations$support$faq$budget$en {
	Translations$support$faq$budget$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do I set up a budget?'
	String get q => 'How do I set up a budget?';

	/// en: 'Open the Budgets tab and tap New budget. Give it a name, an amount and a period (weekly, monthly or yearly). When you add an expense, choose the budget it counts toward, and the budget shows how much is left. Income does not count toward budgets.'
	String get a => 'Open the Budgets tab and tap New budget. Give it a name, an amount and a period (weekly, monthly or yearly). When you add an expense, choose the budget it counts toward, and the budget shows how much is left. Income does not count toward budgets.';
}

// Path: support.faq.recurring
class Translations$support$faq$recurring$en {
	Translations$support$faq$recurring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do recurring transactions work?'
	String get q => 'How do recurring transactions work?';

	/// en: 'Go to Settings → Recurring transactions and add a bill or income with how often it repeats. Turn on Auto-create transactions and Expenzo adds due transactions when you open the app. If it is off, open Recurring transactions and tap Process pending (the circular arrows at the top).'
	String get a => 'Go to Settings → Recurring transactions and add a bill or income with how often it repeats. Turn on Auto-create transactions and Expenzo adds due transactions when you open the app. If it is off, open Recurring transactions and tap Process pending (the circular arrows at the top).';
}

// Path: support.faq.export
class Translations$support$faq$export$en {
	Translations$support$faq$export$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Can I export my data?'
	String get q => 'Can I export my data?';

	/// en: 'Yes. Go to Settings → Export data, pick a date range and what to include (transactions, budgets, categories). One type is shared as a CSV file; several come as a ZIP of CSV files.'
	String get a => 'Yes. Go to Settings → Export data, pick a date range and what to include (transactions, budgets, categories). One type is shared as a CSV file; several come as a ZIP of CSV files.';
}

// Path: support.faq.sync
class Translations$support$faq$sync$en {
	Translations$support$faq$sync$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Is my data safe if I lose my phone?'
	String get q => 'Is my data safe if I lose my phone?';

	/// en: 'If you sign in with Google and Sync is on (it is on by default), your transactions, budgets, categories, recurring transactions, and auto-import senders and rules are kept in your account. Sign in on your new phone to get them back. App settings stay on each phone. Without signing in, your data stays only on this phone.'
	String get a => 'If you sign in with Google and Sync is on (it is on by default), your transactions, budgets, categories, recurring transactions, and auto-import senders and rules are kept in your account. Sign in on your new phone to get them back. App settings stay on each phone. Without signing in, your data stays only on this phone.';
}

// Path: support.faq.aiAssistant
class Translations$support$faq$aiAssistant$en {
	Translations$support$faq$aiAssistant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How does Expie work?'
	String get q => 'How does Expie work?';

	/// en: 'Tap the robot button on the Reports tab and ask Expie about your spending, budgets or income. Expie answers from a summary of this month's data, with personal details such as emails and phone numbers removed, sent to our AI provider, Groq. It gives suggestions, not financial advice.'
	String get a => 'Tap the robot button on the Reports tab and ask Expie about your spending, budgets or income. Expie answers from a summary of this month\'s data, with personal details such as emails and phone numbers removed, sent to our AI provider, Groq. It gives suggestions, not financial advice.';
}

// Path: support.faq.currency
class Translations$support$faq$currency$en {
	Translations$support$faq$currency$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do I change the currency?'
	String get q => 'How do I change the currency?';

	/// en: 'Go to Settings → Default currency. Amounts are not converted; only the symbol and format change.'
	String get a => 'Go to Settings → Default currency. Amounts are not converted; only the symbol and format change.';
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
			'aiAssistant.title' => 'Expie',
			'aiAssistant.inputHint' => 'Ask about your spending',
			'aiAssistant.send' => 'Send message',
			'aiAssistant.disclaimer' => 'Expie provides suggestions based on your data. It is not a licensed financial advisor.',
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
			'budgets.form.sharedReadOnly' => 'Shared by your family admin. Only they can change it.',
			'budgets.form.sharedTitle' => 'Shared budget',
			'budgets.form.share' => 'Share with family',
			'budgets.form.shareDetail' => ({required Object name}) => 'Members of ${name} can see it and add expenses to it',
			'budgets.form.unshareTitle' => 'Stop sharing?',
			'budgets.form.unshareBody' => 'Members will no longer see this budget. Transactions already added stay as they are.',
			'budgets.form.unshareConfirm' => 'Stop sharing',
			'budgets.details.title' => 'Budget details',
			'budgets.details.loadFailed' => 'Couldn\'t load budget details. Try again.',
			'budgets.details.notFound' => 'Budget not found.',
			'budgets.details.ofTotal' => ({required Object total}) => ' / ${total}',
			'budgets.details.periodBudget.weekly' => 'Weekly budget',
			'budgets.details.periodBudget.monthly' => 'Monthly budget',
			'budgets.details.periodBudget.yearly' => 'Yearly budget',
			'budgets.details.carriedOver' => ({required Object amount}) => 'Includes ${amount} carried over',
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
			'budgets.sharedBadge' => 'Shared',
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
			'common.errors.generic' => 'Something went wrong. Try again.',
			'common.errors.storage' => 'Couldn\'t read or save your data. Try again.',
			'common.errors.network' => 'You\'re offline. Check your connection and try again.',
			'common.errors.server' => 'The server didn\'t respond. Try again in a moment.',
			'common.errors.auth' => 'There was a problem with your sign-in. Sign in again and retry.',
			'common.errors.permission' => 'Expenzo doesn\'t have permission to do this. Allow it in system settings.',
			'common.errors.notFound' => 'This item no longer exists.',
			'common.errors.smsScan' => 'Couldn\'t read your messages. Try again.',
			'common.errors.requiresRecentLogin' => 'For your security, sign in again, then delete your account.',
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
			'common.fallback.storageBody' => 'The data on this phone can\'t be read. Reset it to keep using Expenzo. Anything you synced comes back after you sign in.',
			'common.fallback.resetLocalData' => 'Reset local data',
			'common.fallback.resetConfirm' => 'This deletes the transactions, budgets and categories saved on this phone. Synced data comes back after you sign in. Changes that weren\'t synced are lost.',
			'common.fallback.resetConfirmAction' => 'Delete and start again',
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
			'dashboard.userFallback' => 'User',
			'dashboard.income' => 'Income',
			'dashboard.expense' => 'Expense',
			'dashboard.sections.budgets' => 'Budgets',
			'dashboard.sections.recentActivity' => 'Recent Activity',
			'dashboard.sections.spendingPatterns' => 'Spending Patterns',
			'dashboard.sections.seeAll' => 'See all',
			'dashboard.noBudgets' => 'No budgets yet',
			'dashboard.noTransactions' => 'No transactions yet',
			'dashboard.settings' => 'Settings',
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
			'family.create.title' => 'Create family group',
			'family.create.heading' => 'Start your family plan',
			'family.create.body' => 'Create a shared budget space for your family.',
			'family.create.nameLabel' => 'Group name',
			'family.create.nameHint' => 'Rahman Family',
			'family.create.nameRequired' => 'Enter a group name',
			'family.create.budgetLabel' => 'Monthly family budget (optional)',
			'family.create.budgetInvalid' => 'Enter an amount above zero',
			'family.create.currencyNote' => ({required Object code}) => 'Currency: ${code} (from your settings)',
			'family.create.submit' => 'Create group',
			'family.create.haveCode' => 'Have an invite code? Join a family',
			'family.join.title' => 'Join a family',
			'family.join.body' => 'Enter the 6-character code your family admin shared.',
			'family.join.codeLabel' => 'Invite code',
			'family.join.codeInvalid' => 'Codes have 6 letters and numbers',
			'family.join.currencyNote' => ({required Object code}) => 'Your currency: ${code}',
			'family.join.submit' => 'Join group',
			'family.join.joined' => ({required Object name}) => 'You joined ${name}',
			'family.join.syncOff' => 'You joined. Turn on Sync in Settings to see the shared budgets.',
			'family.invite.title' => 'Invite members',
			'family.invite.heading' => 'Invite your family',
			'family.invite.limitNote' => 'Up to 10 members, you included',
			'family.invite.codeCaption' => 'Share this invite code',
			'family.invite.validUntil' => ({required Object time}) => 'Valid until ${time}',
			'family.invite.share' => 'Share invite',
			'family.invite.shareText' => ({required Object name, required Object code, required Object time}) => 'Join my family "${name}" on Expenzo: open Settings > Family group > Join a family and enter ${code}. The code works until ${time}.',
			'family.invite.regenerate' => 'Regenerate code',
			'family.invite.regenerateTitle' => 'Make a new code?',
			'family.invite.regenerateBody' => 'The current code will stop working.',
			'family.invite.copied' => 'Code copied',
			'family.invite.offline' => 'You\'re offline. Connect to get an invite code.',
			'family.invite.expired' => 'This code has expired. Make a new one.',
			'family.dashboard.spentOfPlanned' => 'Spent of planned',
			'family.dashboard.spentOfPlannedValue' => ({required Object spent, required Object planned}) => '${spent} of ${planned}',
			'family.dashboard.expense' => ({required Object amount}) => 'Expense: ${amount}',
			'family.dashboard.sharedBudgetTotal' => ({required Object amount}) => 'Shared budget total: ${amount}',
			'family.dashboard.ofMonthlyBudget' => ({required Object spent, required Object budget}) => '${spent} of ${budget} this month',
			'family.dashboard.onlySharedNote' => 'Only transactions in shared budgets count here.',
			'family.dashboard.you' => ({required Object name}) => '${name} (you)',
			'family.dashboard.memberFallback' => 'Family member',
			'family.dashboard.moreMembers' => ({required Object n}) => '+${n}',
			'family.dashboard.noSharedBudgets' => 'No shared budgets yet. Admins can share one from the budget form.',
			'family.dashboard.seeAllBudgets' => 'See all budgets',
			'family.dashboard.lastUpdated' => ({required Object time}) => 'Last updated ${time}',
			'family.dashboard.loadFailed' => 'Couldn\'t load your family. Check your connection and try again.',
			'family.dashboard.summaryFailed' => 'Couldn\'t load the latest numbers.',
			'family.dashboard.manageMembers' => 'Manage members',
			'family.members.title' => ({required Object count}) => 'Members (${count})',
			'family.members.inviteMore' => 'Invite more',
			'family.members.leave' => 'Leave group',
			'family.members.leaveTitle' => ({required Object name}) => 'Leave ${name}?',
			'family.members.leaveBody' => 'Shared budgets from this group will be removed from your phone. Your own transactions stay with you.',
			'family.members.leaveLastBody' => 'You are the last member. Leaving deletes the group.',
			'family.members.changeRole' => 'Change role',
			'family.members.remove' => 'Remove from group',
			'family.members.removeTitle' => ({required Object name}) => 'Remove ${name}?',
			'family.members.deleteGroup' => 'Delete group',
			'family.members.deleteTitle' => ({required Object name}) => 'Delete ${name}?',
			'family.members.deleteBody' => 'Everyone is removed. Shared budgets become personal budgets of their owner.',
			'family.roles.admin' => 'Admin',
			'family.roles.member' => 'Member',
			'family.roles.viewer' => 'Viewer',
			'family.roleHints.admin' => 'Manages members and shared budgets',
			'family.roleHints.member' => 'Sees the dashboard and adds transactions to shared budgets',
			'family.roleHints.viewer' => 'Sees the dashboard only',
			'family.errors.alreadyInGroup' => 'You\'re already in a family group. Leave it first.',
			'family.errors.currencyMismatch' => 'This family uses a different currency. Switch to the same currency in Settings, then join.',
			'family.errors.groupFull' => 'Group is full. A family group can have up to 10 members.',
			'family.errors.inviteExpired' => 'This code has expired. Ask your admin for a new one.',
			'family.errors.inviteNotFound' => 'No family uses this code. Check it and try again.',
			'family.errors.lastAdmin' => 'Make someone else an admin first.',
			'family.errors.notInGroup' => 'You\'re no longer in this group.',
			'family.errors.signInRequired' => 'Sign in to use Family group.',
			'goals.errors.nameRequired' => 'Give your goal a name.',
			'goals.errors.targetPositive' => 'Enter a target amount above zero.',
			'goals.errors.amountPositive' => 'Enter an amount above zero.',
			'goals.errors.amountTooLarge' => 'Enter an amount up to 9,999,999,999.99.',
			'goals.card.section' => 'Savings Goal',
			'goals.card.progress' => ({required Object saved, required Object target}) => '${saved} of ${target}',
			'goals.card.monthsLeft' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} month left', other: '${n} months left', ), 
			'goals.card.dueThisMonth' => 'Due this month',
			'goals.card.reached' => 'Goal reached',
			'goals.card.plan' => ({required Object amount}) => 'Plan: ${amount}/month',
			'goals.card.addToGoal' => 'Add to goal',
			'goals.card.newGoal' => 'New goal',
			'goals.card.edit' => 'Edit goal',
			'goals.card.setGoal' => 'Set a savings goal',
			'goals.addSheet.title' => ({required Object name}) => 'Add to ${name}',
			'goals.addSheet.amount' => 'Amount',
			'goals.addSheet.note' => 'This only updates the goal. It does not add a transaction.',
			'goals.added' => ({required Object amount, required Object name}) => 'Added ${amount} to ${name}',
			'goals.list.title' => 'Goals',
			'goals.list.subtitle' => 'Newest first. Tap a goal to edit it.',
			'goals.list.empty' => 'No savings goals yet.',
			'goals.list.loadFailed' => 'Couldn\'t load your goals. Try again.',
			'goals.form.title' => 'Edit goal',
			'goals.form.createTitle' => 'New savings goal',
			'goals.form.name' => 'Goal name',
			'goals.form.target' => 'Target amount',
			'goals.form.saved' => 'Saved so far',
			'goals.form.targetDate' => 'Target date',
			'goals.form.noDate' => 'No date',
			'goals.form.clearDate' => 'Clear date',
			'goals.form.monthly' => 'Monthly contribution',
			'goals.form.suggestMonthly' => ({required Object amount}) => 'Suggested: ${amount}/month',
			'goals.form.deleteTitle' => 'Delete goal?',
			'goals.form.deleteBody' => 'This removes the goal and its saved amount. Your transactions are not affected.',
			'goals.form.savedMessage' => 'Goal saved',
			'goals.form.createdMessage' => 'Goal created',
			'goals.form.deleted' => 'Goal deleted',
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
			'messageTemplates.watchlist.title' => 'SMS Watchlist',
			'messageTemplates.watchlist.subtitle' => 'Messages from these senders become transactions. Pause a sender to ignore it.',
			'messageTemplates.watchlist.formats' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} SMS format', other: '${n} SMS formats', ), 
			'messageTemplates.watchlist.paused' => 'Paused',
			'messageTemplates.watchlist.toggle' => ({required Object name}) => 'Read messages from ${name}',
			'messageTemplates.watchlist.empty' => 'No senders yet. Add one from Auto-import by teaching Expenzo a sample message.',
			'messageTemplates.watchlist.addSender' => 'Choose senders',
			'messageTemplates.watchlist.loadFailed' => 'Couldn\'t load the watchlist. Try again.',
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
			'onboarding.budgetNames.needs' => 'Needs',
			'onboarding.budgetNames.wants' => 'Wants',
			'onboarding.budgetNames.savings' => 'Savings',
			'onboarding.common.skip' => 'Skip',
			'onboarding.common.continueLabel' => 'Continue',
			'onboarding.common.stepOf' => ({required Object current, required Object total}) => 'Step ${current} of ${total}',
			'onboarding.income.title' => 'Let\'s set up your budget',
			'onboarding.income.subtitle' => 'First, tell us about your monthly income so we can create a budget that works for you.',
			'onboarding.income.amountLabel' => 'Monthly net income',
			'onboarding.income.amountInvalid' => 'Enter an amount up to 9,999,999,999.99.',
			'onboarding.income.frequencyLabel' => 'Income frequency',
			'onboarding.income.frequency.monthly' => 'Monthly',
			'onboarding.income.frequency.biWeekly' => 'Bi-weekly',
			'onboarding.income.frequency.weekly' => 'Weekly',
			'onboarding.income.perMonth' => ({required Object amount}) => '${amount}/month',
			'onboarding.recurring.title' => 'Any recurring payments?',
			'onboarding.recurring.subtitle' => 'Add your regular fixed expenses so we can account for them in your budget.',
			'onboarding.recurring.addAnother' => 'Add another',
			'onboarding.recurring.addFirst' => 'Add a payment',
			'onboarding.recurring.total' => 'Total recurring',
			'onboarding.recurring.remove' => ({required Object name}) => 'Remove ${name}',
			'onboarding.recurring.sheet.title' => 'Recurring payment',
			'onboarding.recurring.sheet.name' => 'Name',
			'onboarding.recurring.sheet.nameHint' => 'e.g. Rent',
			'onboarding.recurring.sheet.amount' => 'Amount',
			'onboarding.recurring.sheet.frequency' => 'Repeats',
			'onboarding.plan.title' => 'Your budget plan',
			'onboarding.plan.subtitle' => 'Based on your income, we suggest this 50/30/20 split.',
			'onboarding.plan.perMonth' => ({required Object amount}) => '${amount}/mo',
			'onboarding.plan.share' => ({required Object percent}) => '${percent}%',
			'onboarding.plan.createBudgets' => 'Create these as monthly budgets',
			'onboarding.plan.noIncome' => 'Add your income on the first step to see a plan.',
			'onboarding.plan.noRoom' => 'Your recurring payments use all of your income, so there is nothing left to split.',
			'onboarding.plan.chartLabel' => ({required Object needs, required Object wants, required Object savings}) => 'Needs ${needs}, wants ${wants}, savings ${savings}',
			'onboarding.goal.title' => 'What are you saving for?',
			'onboarding.goal.subtitle' => 'Set a savings goal and we\'ll help you track progress.',
			'onboarding.goal.nameLabel' => 'Goal name',
			_ => null,
		} ?? switch (path) {
			'onboarding.goal.nameHint' => 'e.g. New laptop',
			'onboarding.goal.amountLabel' => 'Target amount',
			'onboarding.goal.notNow' => 'No goal for now',
			'onboarding.timeline.title' => 'Pick your timeline',
			'onboarding.timeline.canAfford' => ({required Object name, required Object months, required Object amount}) => 'You can afford ${name} in ${months} months saving ${amount}/month.',
			'onboarding.timeline.cannotAfford' => ({required Object amount}) => 'Your savings of ${amount}/month don\'t cover these. Pick a later custom date.',
			'onboarding.timeline.months' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} month', other: '${n} months', ), 
			'onboarding.timeline.perMonth' => ({required Object amount}) => '${amount}/mo',
			'onboarding.timeline.custom' => 'Custom',
			'onboarding.timeline.customHint' => 'Set your own',
			'onboarding.timeline.fit.affordable' => 'Fits your savings',
			'onboarding.timeline.fit.tooExpensive' => 'More than your savings',
			'onboarding.timeline.fit.slow' => 'Takes a long time',
			'onboarding.complete.title' => 'Setup complete!',
			'onboarding.complete.budgets' => 'Budget created',
			'onboarding.complete.recurring' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} recurring payment', other: '${n} recurring payments', ), 
			'onboarding.complete.goal' => ({required Object name}) => 'Savings goal: ${name}',
			'onboarding.complete.tip' => 'You can change your budgets and goal at any time.',
			'onboarding.complete.finish' => 'Finish setup',
			'onboarding.complete.saving' => 'Saving your setup…',
			'onboarding.complete.partialFailure' => 'Some items couldn\'t be saved. You can add them later.',
			'onboarding.tutorial.dashboard.title' => 'Your money at a glance',
			'onboarding.tutorial.dashboard.body' => 'Home shows this month\'s net, your budgets and recent activity.',
			'onboarding.tutorial.addTransaction.title' => 'Add a transaction in seconds',
			'onboarding.tutorial.addTransaction.body' => 'Tap + on any tab, type the amount and pick a category.',
			'onboarding.tutorial.reports.title' => 'See where your money goes',
			'onboarding.tutorial.reports.body' => 'Reports shows trends, categories and insights.',
			'onboarding.tutorial.pageOf' => ({required Object current, required Object total}) => 'Page ${current} of ${total}',
			'onboarding.tutorial.cta.title' => 'You\'re all set!',
			'onboarding.tutorial.cta.body' => 'You now know the basics. Let\'s start tracking your finances!',
			'onboarding.tutorial.cta.start' => 'Let\'s get started!',
			'receiptScan.permissionRequired' => 'Camera permission is required to scan receipts.',
			'receiptScan.permissionBlocked' => 'Camera access is off for Expenzo. Turn it on in Settings to scan receipts.',
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
			'reports.askAi' => 'Ask Expie',
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
			'settings.smsWatchlist' => 'SMS Watchlist',
			'settings.smsWatchlistSubtitle' => 'Senders Expenzo reads',
			'settings.recurring.title' => 'Recurring transactions',
			'settings.recurring.subtitle' => 'Bills and income that repeat',
			'settings.help.title' => 'Help & Support',
			'settings.help.rowSubtitle' => 'FAQ, contact us, rate the app, legal',
			'settings.crashReports.title' => 'Send crash reports',
			'settings.crashReports.subtitle' => 'Error details only. Amounts, numbers and SMS text are removed.',
			'settings.signOut' => 'Sign out',
			'settings.deleteAccount' => 'Delete account',
			'settings.signIn.title' => 'Sign in',
			'settings.signIn.subtitle' => 'Keep your data on all your devices',
			'settings.profile.title' => 'My profile',
			'settings.profile.rowSubtitle' => 'Your Google account',
			'settings.profile.nameLabel' => 'Name',
			'settings.profile.emailLabel' => 'Email',
			'settings.profile.noName' => 'No name on this Google account',
			'settings.profile.signedInWith' => 'Signed in with Google',
			'settings.profile.googleNote' => 'Your name and photo come from your Google account. Change them there.',
			'settings.profile.deletingAccount' => 'Deleting your account…',
			'settings.profile.accountDeleted' => 'Your account was deleted',
			'settings.profile.signedOutTitle' => 'You\'re not signed in',
			'settings.profile.signedOutBody' => 'Sign in with Google to keep your transactions on all your devices.',
			'settings.profile.guestName' => 'Guest',
			'settings.profile.guestSubtitle' => 'Sign in to sync your data',
			'settings.deleteDialog.title' => 'Delete account',
			'settings.deleteDialog.question' => 'Are you sure you want to delete your account?',
			'settings.deleteDialog.listTitle' => 'This permanently deletes, from your account and this phone:',
			'settings.deleteDialog.transactions' => '• All your transactions',
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
			'settings.sync.failed' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} change couldn\'t sync', other: '${n} changes couldn\'t sync', ), 
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
			'settings.deleteData.familyAdminNote' => 'Shared budgets you created will be removed for your family.',
			'settings.categories.rowSubtitle' => 'Add, edit and remove categories',
			'settings.family.title' => 'Family group',
			'settings.family.rowSubtitle' => 'Share budgets with your family',
			'settings.family.sections.spendingByMember' => 'Spending by member',
			'settings.family.sections.sharedBudgets' => 'Shared budget progress',
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
			'smsParser.card.noAmount' => 'No amount',
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
			'support.help.watchTutorial' => 'Watch tutorial',
			'support.help.replaySetup.title' => 'Replay setup',
			'support.help.replaySetup.rowSubtitle' => 'Go through income, budgets and goal again',
			'support.help.replaySetup.confirmTitle' => 'Replay setup?',
			'support.help.replaySetup.confirmBody' => 'Your transactions stay as they are. Budgets, recurring payments and a goal you add again are created as new items.',
			'support.help.title' => 'Help & Support',
			'support.help.faq' => 'FAQ',
			'support.help.contactSupport' => 'Contact support',
			'support.help.rateApp' => 'Rate the app',
			'support.help.privacyPolicy' => 'Privacy policy',
			'support.help.termsOfService' => 'Terms of service',
			'support.help.about' => 'About',
			'support.help.linkFailed' => 'Couldn\'t open the page. Try again later.',
			'support.about.title' => 'About Expenzo',
			'support.about.version' => ({required Object version, required Object build}) => 'Version ${version} (${build})',
			'support.about.description' => 'Expenzo tracks your spending, budgets and recurring bills, and can read bank SMS to log transactions for you.',
			'support.about.madeBy' => 'Made by Acesif Labs',
			'support.faq.title' => 'FAQ',
			'support.faq.searchHint' => 'Search FAQs...',
			'support.faq.noResults' => ({required Object query}) => 'No questions match "${query}".',
			'support.faq.addTransaction.q' => 'How do I add a transaction?',
			'support.faq.addTransaction.a' => 'Tap the + button at the bottom of any tab. Choose expense or income, enter the amount, pick a category and tap Add expense or Add income.',
			'support.faq.autoImport.q' => 'How does Auto-import work?',
			'support.faq.autoImport.a' => 'Go to Settings → Auto-import from SMS and allow SMS access. Expenzo reads bank and payment messages on your phone and turns them into transactions. The message text stays on your phone; the transactions it creates sync like any other. Tap Scan past SMS on that page to import older messages.',
			'support.faq.budget.q' => 'How do I set up a budget?',
			'support.faq.budget.a' => 'Open the Budgets tab and tap New budget. Give it a name, an amount and a period (weekly, monthly or yearly). When you add an expense, choose the budget it counts toward, and the budget shows how much is left. Income does not count toward budgets.',
			'support.faq.recurring.q' => 'How do recurring transactions work?',
			'support.faq.recurring.a' => 'Go to Settings → Recurring transactions and add a bill or income with how often it repeats. Turn on Auto-create transactions and Expenzo adds due transactions when you open the app. If it is off, open Recurring transactions and tap Process pending (the circular arrows at the top).',
			'support.faq.export.q' => 'Can I export my data?',
			'support.faq.export.a' => 'Yes. Go to Settings → Export data, pick a date range and what to include (transactions, budgets, categories). One type is shared as a CSV file; several come as a ZIP of CSV files.',
			'support.faq.sync.q' => 'Is my data safe if I lose my phone?',
			'support.faq.sync.a' => 'If you sign in with Google and Sync is on (it is on by default), your transactions, budgets, categories, recurring transactions, and auto-import senders and rules are kept in your account. Sign in on your new phone to get them back. App settings stay on each phone. Without signing in, your data stays only on this phone.',
			'support.faq.aiAssistant.q' => 'How does Expie work?',
			'support.faq.aiAssistant.a' => 'Tap the robot button on the Reports tab and ask Expie about your spending, budgets or income. Expie answers from a summary of this month\'s data, with personal details such as emails and phone numbers removed, sent to our AI provider, Groq. It gives suggestions, not financial advice.',
			'support.faq.currency.q' => 'How do I change the currency?',
			'support.faq.currency.a' => 'Go to Settings → Default currency. Amounts are not converted; only the symbol and format change.',
			'support.rate.title' => 'Love Expenzo?',
			'support.rate.heading' => 'Enjoying Expenzo?',
			'support.rate.subtitle' => 'Your feedback helps us improve. Tap a star to rate the app.',
			'support.rate.writeReview' => 'Write a review',
			'support.rate.tellUs' => 'Tell us what to improve',
			'support.rate.maybeLater' => 'Maybe later',
			'support.rate.noThanks' => 'No thanks',
			'support.rate.starLabel' => ({required Object n}) => '${n} of 5 stars',
			_ => null,
		};
	}
}
