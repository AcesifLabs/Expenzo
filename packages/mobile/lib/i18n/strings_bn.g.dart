///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsBn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsBn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.bn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <bn>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsBn _root = this; // ignore: unused_field

	@override 
	TranslationsBn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsBn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$aiAssistant$bn aiAssistant = _Translations$aiAssistant$bn._(_root);
	@override late final _Translations$auth$bn auth = _Translations$auth$bn._(_root);
	@override late final _Translations$budgets$bn budgets = _Translations$budgets$bn._(_root);
	@override late final _Translations$categories$bn categories = _Translations$categories$bn._(_root);
	@override late final _Translations$common$bn common = _Translations$common$bn._(_root);
	@override late final _Translations$currencies$bn currencies = _Translations$currencies$bn._(_root);
	@override late final _Translations$dashboard$bn dashboard = _Translations$dashboard$bn._(_root);
	@override late final _Translations$enums$bn enums = _Translations$enums$bn._(_root);
	@override late final _Translations$family$bn family = _Translations$family$bn._(_root);
	@override late final _Translations$goals$bn goals = _Translations$goals$bn._(_root);
	@override late final _Translations$messageTemplates$bn messageTemplates = _Translations$messageTemplates$bn._(_root);
	@override late final _Translations$notifications$bn notifications = _Translations$notifications$bn._(_root);
	@override late final _Translations$onboarding$bn onboarding = _Translations$onboarding$bn._(_root);
	@override late final _Translations$receiptScan$bn receiptScan = _Translations$receiptScan$bn._(_root);
	@override late final _Translations$records$bn records = _Translations$records$bn._(_root);
	@override late final _Translations$recurring$bn recurring = _Translations$recurring$bn._(_root);
	@override late final _Translations$reports$bn reports = _Translations$reports$bn._(_root);
	@override late final _Translations$settings$bn settings = _Translations$settings$bn._(_root);
	@override late final _Translations$shell$bn shell = _Translations$shell$bn._(_root);
	@override late final _Translations$smsParser$bn smsParser = _Translations$smsParser$bn._(_root);
	@override late final _Translations$support$bn support = _Translations$support$bn._(_root);
}

// Path: aiAssistant
class _Translations$aiAssistant$bn extends Translations$aiAssistant$en {
	_Translations$aiAssistant$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Expie';
	@override String get inputHint => 'আপনার খরচ নিয়ে জিজ্ঞেস করুন';
	@override String get send => 'মেসেজ পাঠান';
	@override String get disclaimer => 'Expie আপনার ডেটা দেখে পরামর্শ দেয়। এটি কোনো লাইসেন্সপ্রাপ্ত আর্থিক উপদেষ্টা নয়।';
	@override late final _Translations$aiAssistant$suggestions$bn suggestions = _Translations$aiAssistant$suggestions$bn._(_root);
	@override late final _Translations$aiAssistant$refusals$bn refusals = _Translations$aiAssistant$refusals$bn._(_root);
	@override late final _Translations$aiAssistant$errors$bn errors = _Translations$aiAssistant$errors$bn._(_root);
}

// Path: auth
class _Translations$auth$bn extends Translations$auth$en {
	_Translations$auth$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$auth$errors$bn errors = _Translations$auth$errors$bn._(_root);
	@override late final _Translations$auth$syncConflict$bn syncConflict = _Translations$auth$syncConflict$bn._(_root);
	@override late final _Translations$auth$login$bn login = _Translations$auth$login$bn._(_root);
}

// Path: budgets
class _Translations$budgets$bn extends Translations$budgets$en {
	_Translations$budgets$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেট';
	@override String get subtitle => 'আপনার মাসিক সীমা দেখুন';
	@override String get unnamed => 'নামহীন বাজেট';
	@override late final _Translations$budgets$empty$bn empty = _Translations$budgets$empty$bn._(_root);
	@override String get saved => 'বাজেট সংরক্ষণ হয়েছে';
	@override String get loadPrompt => 'ডেটা দেখতে বাজেট লোড করুন';
	@override String get edit => 'সম্পাদনা';
	@override late final _Translations$budgets$delete$bn delete = _Translations$budgets$delete$bn._(_root);
	@override late final _Translations$budgets$card$bn card = _Translations$budgets$card$bn._(_root);
	@override late final _Translations$budgets$days$bn days = _Translations$budgets$days$bn._(_root);
	@override late final _Translations$budgets$form$bn form = _Translations$budgets$form$bn._(_root);
	@override late final _Translations$budgets$details$bn details = _Translations$budgets$details$bn._(_root);
	@override late final _Translations$budgets$picker$bn picker = _Translations$budgets$picker$bn._(_root);
	@override late final _Translations$budgets$plan$bn plan = _Translations$budgets$plan$bn._(_root);
	@override String get sharedBadge => 'শেয়ার করা';
}

// Path: categories
class _Translations$categories$bn extends Translations$categories$en {
	_Translations$categories$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get uncategorized => 'ক্যাটাগরি নেই';
	@override Map<String, String> get defaults => {
		'default_in_salary': 'বেতন',
		'default_in_freelance': 'ফ্রিল্যান্স',
		'default_in_investment': 'বিনিয়োগ',
		'default_in_refund': 'ফেরত',
		'default_in_gift': 'উপহার',
		'default_in_general': 'সাধারণ',
		'default_out_food': 'খাবার ও রেস্তোরাঁ',
		'default_out_shopping': 'কেনাকাটা',
		'default_out_transport': 'যাতায়াত',
		'default_out_home': 'বাসা',
		'default_out_health': 'স্বাস্থ্য',
		'default_out_entertainment': 'বিনোদন',
		'default_out_bills': 'বিল ও ইউটিলিটি',
		'default_out_travel': 'ভ্রমণ',
		'default_out_education': 'শিক্ষা',
		'default_out_investment': 'বিনিয়োগ',
		'default_out_gifts': 'উপহার',
		'default_out_general': 'সাধারণ',
	};
	@override String get empty => 'কোনো ক্যাটাগরি তৈরি করা হয়নি';
	@override late final _Translations$categories$settings$bn settings = _Translations$categories$settings$bn._(_root);
	@override String get defaultCannotDelete => 'ডিফল্ট ক্যাটাগরি মোছা যায় না';
	@override late final _Translations$categories$form$bn form = _Translations$categories$form$bn._(_root);
	@override late final _Translations$categories$delete$bn delete = _Translations$categories$delete$bn._(_root);
	@override String iconLabel({required Object name}) => '${name} আইকন';
	@override Map<String, String> get icons => {
		'shoppingCart': 'শপিং কার্ট',
		'forkKnife': 'কাঁটাচামচ ও ছুরি',
		'car': 'গাড়ি',
		'bag': 'ব্যাগ',
		'heart': 'হৃদয়',
		'bookOpen': 'বই',
		'filmStrip': 'সিনেমা',
		'lightning': 'বিদ্যুৎ',
		'coffee': 'কফি',
		'gift': 'উপহার',
		'dog': 'কুকুর',
		'airplane': 'বিমান',
	};
	@override Map<String, String> get colors => {
		'Lavender': 'ল্যাভেন্ডার',
		'Rose': 'গোলাপি',
		'Mint': 'পুদিনা সবুজ',
		'Sky': 'আকাশি',
		'Amber': 'অ্যাম্বার',
		'Teal': 'টিল',
		'Peach': 'পীচ',
		'Slate': 'স্লেট',
	};
}

// Path: common
class _Translations$common$bn extends Translations$common$en {
	_Translations$common$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Expenzo';
	@override String get add => 'যোগ করুন';
	@override String get save => 'সংরক্ষণ করুন';
	@override String get delete => 'মুছুন';
	@override String get cancel => 'বাতিল';
	@override String get close => 'বন্ধ করুন';
	@override String get done => 'সম্পন্ন';
	@override String get next => 'পরবর্তী';
	@override String get back => 'পেছনে';
	@override String get undo => 'আগের অবস্থায় ফেরান';
	@override String get tryAgain => 'আবার চেষ্টা করুন';
	@override String get notNow => 'এখন নয়';
	@override String get openSettings => 'সেটিংস খুলুন';
	@override String get addExpense => 'খরচ যোগ করুন';
	@override String get newBudget => 'নতুন বাজেট';
	@override String get sendFeedback => 'মতামত পাঠান';
	@override String get autoImport => 'SMS থেকে স্বয়ংক্রিয় ইমপোর্ট';
	@override late final _Translations$common$errors$bn errors = _Translations$common$errors$bn._(_root);
	@override late final _Translations$common$dates$bn dates = _Translations$common$dates$bn._(_root);
	@override late final _Translations$common$a11y$bn a11y = _Translations$common$a11y$bn._(_root);
	@override late final _Translations$common$feedback$bn feedback = _Translations$common$feedback$bn._(_root);
	@override String get clearSearch => 'খোঁজা মুছুন';
	@override String get addTransaction => 'লেনদেন যোগ করুন';
	@override String get noTransactionsInPeriod => 'এই সময়ে কোনো লেনদেন নেই';
	@override late final _Translations$common$fallback$bn fallback = _Translations$common$fallback$bn._(_root);
	@override late final _Translations$common$smsGate$bn smsGate = _Translations$common$smsGate$bn._(_root);
}

// Path: currencies
class _Translations$currencies$bn extends Translations$currencies$en {
	_Translations$currencies$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override Map<String, String> get names => {
		'BDT': 'বাংলাদেশি টাকা',
		'USD': 'মার্কিন ডলার',
		'EUR': 'ইউরো',
		'GBP': 'ব্রিটিশ পাউন্ড',
		'INR': 'ভারতীয় রুপি',
		'PKR': 'পাকিস্তানি রুপি',
		'NPR': 'নেপালি রুপি',
		'LKR': 'শ্রীলঙ্কান রুপি',
		'AED': 'আমিরাতি দিরহাম',
		'SAR': 'সৌদি রিয়াল',
		'MYR': 'মালয়েশিয়ান রিঙ্গিত',
		'SGD': 'সিঙ্গাপুর ডলার',
		'THB': 'থাই বাত',
		'PHP': 'ফিলিপাইন পেসো',
		'IDR': 'ইন্দোনেশিয়ান রুপিয়া',
		'VND': 'ভিয়েতনামি ডং',
		'JPY': 'জাপানি ইয়েন',
		'KRW': 'দক্ষিণ কোরিয়ান উয়ন',
		'CNY': 'চীনা ইউয়ান',
		'AUD': 'অস্ট্রেলিয়ান ডলার',
		'CAD': 'কানাডিয়ান ডলার',
		'CHF': 'সুইস ফ্রাঁ',
		'SEK': 'সুইডিশ ক্রোনা',
		'PLN': 'পোলিশ জ্লোটি',
		'TRY': 'তুর্কি লিরা',
		'RUB': 'রুশ রুবল',
		'BRL': 'ব্রাজিলিয়ান রিয়াল',
		'ZAR': 'দক্ষিণ আফ্রিকান র‍্যান্ড',
	};
}

// Path: dashboard
class _Translations$dashboard$bn extends Translations$dashboard$en {
	_Translations$dashboard$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$dashboard$range$bn range = _Translations$dashboard$range$bn._(_root);
	@override String get userFallback => 'ব্যবহারকারী';
	@override String get income => 'আয়';
	@override String get expense => 'খরচ';
	@override late final _Translations$dashboard$sections$bn sections = _Translations$dashboard$sections$bn._(_root);
	@override String get noBudgets => 'এখনো কোনো বাজেট নেই';
	@override String get noTransactions => 'এখনো কোনো লেনদেন নেই';
	@override String get settings => 'সেটিংস';
	@override String budgetSpentOf({required Object total, required Object spent}) => '${total}-এর মধ্যে ${spent}';
	@override late final _Translations$dashboard$trend$bn trend = _Translations$dashboard$trend$bn._(_root);
	@override late final _Translations$dashboard$autoImport$bn autoImport = _Translations$dashboard$autoImport$bn._(_root);
	@override String get scanReceipt => 'রসিদ স্ক্যান করুন';
}

// Path: enums
class _Translations$enums$bn extends Translations$enums$en {
	_Translations$enums$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$enums$recordType$bn recordType = _Translations$enums$recordType$bn._(_root);
	@override late final _Translations$enums$period$bn period = _Translations$enums$period$bn._(_root);
	@override late final _Translations$enums$frequency$bn frequency = _Translations$enums$frequency$bn._(_root);
	@override late final _Translations$enums$source$bn source = _Translations$enums$source$bn._(_root);
	@override late final _Translations$enums$theme$bn theme = _Translations$enums$theme$bn._(_root);
	@override late final _Translations$enums$digitGrouping$bn digitGrouping = _Translations$enums$digitGrouping$bn._(_root);
	@override late final _Translations$enums$fontSize$bn fontSize = _Translations$enums$fontSize$bn._(_root);
	@override late final _Translations$enums$firstDayOfWeek$bn firstDayOfWeek = _Translations$enums$firstDayOfWeek$bn._(_root);
}

// Path: family
class _Translations$family$bn extends Translations$family$en {
	_Translations$family$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$family$create$bn create = _Translations$family$create$bn._(_root);
	@override late final _Translations$family$join$bn join = _Translations$family$join$bn._(_root);
	@override late final _Translations$family$invite$bn invite = _Translations$family$invite$bn._(_root);
	@override late final _Translations$family$dashboard$bn dashboard = _Translations$family$dashboard$bn._(_root);
	@override late final _Translations$family$members$bn members = _Translations$family$members$bn._(_root);
	@override late final _Translations$family$roles$bn roles = _Translations$family$roles$bn._(_root);
	@override late final _Translations$family$roleHints$bn roleHints = _Translations$family$roleHints$bn._(_root);
	@override late final _Translations$family$errors$bn errors = _Translations$family$errors$bn._(_root);
}

// Path: goals
class _Translations$goals$bn extends Translations$goals$en {
	_Translations$goals$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$goals$errors$bn errors = _Translations$goals$errors$bn._(_root);
	@override late final _Translations$goals$card$bn card = _Translations$goals$card$bn._(_root);
	@override late final _Translations$goals$addSheet$bn addSheet = _Translations$goals$addSheet$bn._(_root);
	@override String added({required Object name, required Object amount}) => '${name}-এ ${amount} যোগ হয়েছে';
	@override late final _Translations$goals$list$bn list = _Translations$goals$list$bn._(_root);
	@override late final _Translations$goals$form$bn form = _Translations$goals$form$bn._(_root);
}

// Path: messageTemplates
class _Translations$messageTemplates$bn extends Translations$messageTemplates$en {
	_Translations$messageTemplates$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$messageTemplates$errors$bn errors = _Translations$messageTemplates$errors$bn._(_root);
	@override String get alreadyExists => 'SMS ফরম্যাটটি আগে থেকেই আছে';
	@override String get edit => 'SMS ফরম্যাট সম্পাদনা';
	@override String get delete => 'SMS ফরম্যাট মুছুন';
	@override String get deleted => 'SMS ফরম্যাট মুছে ফেলা হয়েছে';
	@override String get dismiss => 'বন্ধ করুন';
	@override late final _Translations$messageTemplates$retro$bn retro = _Translations$messageTemplates$retro$bn._(_root);
	@override late final _Translations$messageTemplates$editor$bn editor = _Translations$messageTemplates$editor$bn._(_root);
	@override late final _Translations$messageTemplates$analyzer$bn analyzer = _Translations$messageTemplates$analyzer$bn._(_root);
	@override late final _Translations$messageTemplates$contacts$bn contacts = _Translations$messageTemplates$contacts$bn._(_root);
	@override String get create => 'নতুন SMS ফরম্যাট';
	@override late final _Translations$messageTemplates$watchlist$bn watchlist = _Translations$messageTemplates$watchlist$bn._(_root);
}

// Path: notifications
class _Translations$notifications$bn extends Translations$notifications$en {
	_Translations$notifications$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$notifications$channel$bn channel = _Translations$notifications$channel$bn._(_root);
	@override late final _Translations$notifications$budget$bn budget = _Translations$notifications$budget$bn._(_root);
	@override late final _Translations$notifications$recurringDue$bn recurringDue = _Translations$notifications$recurringDue$bn._(_root);
	@override late final _Translations$notifications$weeklySummary$bn weeklySummary = _Translations$notifications$weeklySummary$bn._(_root);
	@override late final _Translations$notifications$scan$bn scan = _Translations$notifications$scan$bn._(_root);
	@override late final _Translations$notifications$autoImport$bn autoImport = _Translations$notifications$autoImport$bn._(_root);
	@override late final _Translations$notifications$syncError$bn syncError = _Translations$notifications$syncError$bn._(_root);
}

// Path: onboarding
class _Translations$onboarding$bn extends Translations$onboarding$en {
	_Translations$onboarding$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$onboarding$common$bn common = _Translations$onboarding$common$bn._(_root);
	@override late final _Translations$onboarding$income$bn income = _Translations$onboarding$income$bn._(_root);
	@override late final _Translations$onboarding$recurring$bn recurring = _Translations$onboarding$recurring$bn._(_root);
	@override late final _Translations$onboarding$plan$bn plan = _Translations$onboarding$plan$bn._(_root);
	@override late final _Translations$onboarding$goal$bn goal = _Translations$onboarding$goal$bn._(_root);
	@override late final _Translations$onboarding$timeline$bn timeline = _Translations$onboarding$timeline$bn._(_root);
	@override late final _Translations$onboarding$complete$bn complete = _Translations$onboarding$complete$bn._(_root);
	@override late final _Translations$onboarding$tutorial$bn tutorial = _Translations$onboarding$tutorial$bn._(_root);
}

// Path: receiptScan
class _Translations$receiptScan$bn extends Translations$receiptScan$en {
	_Translations$receiptScan$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get permissionRequired => 'রসিদ স্ক্যান করতে ক্যামেরার অনুমতি দরকার।';
	@override String get permissionBlocked => 'Expenzo-র জন্য ক্যামেরা বন্ধ আছে। রসিদ স্ক্যান করতে সেটিংসে চালু করুন।';
	@override String get noCamera => 'এই ডিভাইসে কোনো ক্যামেরা নেই।';
	@override String get cameraFailed => 'ক্যামেরা চালু করা যায়নি।';
	@override String get captureFailed => 'ছবি তোলা যায়নি। আবার চেষ্টা করুন।';
	@override String get readFailed => 'রসিদটি পড়া যায়নি। আবার চেষ্টা করুন অথবা নিজে যোগ করুন।';
	@override String get totalUnreadable => 'এই রসিদে মোট পরিমাণ খুঁজে পাওয়া যায়নি। আরও পরিষ্কার একটি ছবি তুলুন।';
	@override String get serviceUnavailable => 'এখন রসিদ পড়া যাচ্ছে না। নিজে যোগ করুন।';
	@override String get chooseFromGallery => 'গ্যালারি থেকে বেছে নিন';
	@override String get flashOff => 'ফ্ল্যাশ বন্ধ করুন';
	@override String get flashOn => 'ফ্ল্যাশ চালু করুন';
	@override String get align => 'রসিদটি ফ্রেমের মধ্যে রাখুন';
	@override String get reading => 'আপনার রসিদ পড়া হচ্ছে';
	@override String get takePhoto => 'ছবি তুলুন';
}

// Path: records
class _Translations$records$bn extends Translations$records$en {
	_Translations$records$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$records$filter$bn filter = _Translations$records$filter$bn._(_root);
	@override late final _Translations$records$list$bn list = _Translations$records$list$bn._(_root);
	@override late final _Translations$records$picker$bn picker = _Translations$records$picker$bn._(_root);
	@override late final _Translations$records$sheet$bn sheet = _Translations$records$sheet$bn._(_root);
}

// Path: recurring
class _Translations$recurring$bn extends Translations$recurring$en {
	_Translations$recurring$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পুনরাবৃত্ত লেনদেন';
	@override String get saved => 'পুনরাবৃত্ত লেনদেন সংরক্ষণ হয়েছে';
	@override String posted({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি লেনদেন যোগ হয়েছে',
		other: '${n}টি লেনদেন যোগ হয়েছে',
	);
	@override String get nothingDue => 'কোনো বকেয়া লেনদেন নেই';
	@override late final _Translations$recurring$sections$bn sections = _Translations$recurring$sections$bn._(_root);
	@override late final _Translations$recurring$defaults$bn defaults = _Translations$recurring$defaults$bn._(_root);
	@override late final _Translations$recurring$empty$bn empty = _Translations$recurring$empty$bn._(_root);
	@override String amountEvery({required Object amount, required Object frequency}) => '${amount} · ${frequency}';
	@override String next({required Object date}) => 'পরবর্তী: ${date}';
	@override String get processPending => 'বাকিগুলো প্রসেস করুন';
	@override String get newTooltip => 'নতুন পুনরাবৃত্ত লেনদেন';
	@override late final _Translations$recurring$delete$bn delete = _Translations$recurring$delete$bn._(_root);
	@override late final _Translations$recurring$form$bn form = _Translations$recurring$form$bn._(_root);
}

// Path: reports
class _Translations$reports$bn extends Translations$reports$en {
	_Translations$reports$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$reports$insights$bn insights = _Translations$reports$insights$bn._(_root);
	@override String get title => 'রিপোর্ট';
	@override String get askAi => 'Expie-কে জিজ্ঞেস করুন';
	@override String get last7Days => 'গত 7 দিন';
	@override String get last30Days => 'গত 30 দিন';
	@override String get noCategoryData => 'ক্যাটাগরির কোনো ডেটা নেই';
	@override String get noTrendData => 'এখনো প্রবণতার ডেটা নেই';
	@override String get noSpending => 'এখনো খরচের ডেটা নেই';
	@override String totalSpentInPeriod({required Object amount}) => 'এই সময়ে মোট খরচ: ${amount}';
	@override late final _Translations$reports$metrics$bn metrics = _Translations$reports$metrics$bn._(_root);
	@override String get spendingByCategory => 'ক্যাটাগরি অনুযায়ী খরচ';
	@override String get observations => 'এই মাসের খরচ থেকে মূল পর্যবেক্ষণ';
	@override String get noData => 'কোনো ডেটা নেই';
}

// Path: settings
class _Translations$settings$bn extends Translations$settings$en {
	_Translations$settings$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$settings$language$bn language = _Translations$settings$language$bn._(_root);
	@override String get title => 'সেটিংস';
	@override String get currency => 'ডিফল্ট মুদ্রা';
	@override String get appearance => 'থিম';
	@override String get notificationsBlocked => 'বাজেট সতর্কতা পেতে সিস্টেম সেটিংসে Expenzo-র নোটিফিকেশন চালু করুন।';
	@override late final _Translations$settings$sections$bn sections = _Translations$settings$sections$bn._(_root);
	@override late final _Translations$settings$notifications$bn notifications = _Translations$settings$notifications$bn._(_root);
	@override String get autoImportSubtitle => 'ব্যাংক ও পেমেন্টের মেসেজ থেকে লেনদেন তৈরি করুন';
	@override String get smsWatchlist => 'SMS ওয়াচলিস্ট';
	@override String get smsWatchlistSubtitle => 'যেসব প্রেরকের মেসেজ Expenzo পড়ে';
	@override late final _Translations$settings$recurring$bn recurring = _Translations$settings$recurring$bn._(_root);
	@override late final _Translations$settings$help$bn help = _Translations$settings$help$bn._(_root);
	@override late final _Translations$settings$crashReports$bn crashReports = _Translations$settings$crashReports$bn._(_root);
	@override String get signOut => 'সাইন আউট';
	@override String get deleteAccount => 'অ্যাকাউন্ট মুছুন';
	@override late final _Translations$settings$signIn$bn signIn = _Translations$settings$signIn$bn._(_root);
	@override late final _Translations$settings$profile$bn profile = _Translations$settings$profile$bn._(_root);
	@override late final _Translations$settings$deleteDialog$bn deleteDialog = _Translations$settings$deleteDialog$bn._(_root);
	@override String get loadFailed => 'আপনার সেটিংস লোড করা যায়নি।';
	@override late final _Translations$settings$appearanceScreen$bn appearanceScreen = _Translations$settings$appearanceScreen$bn._(_root);
	@override late final _Translations$settings$currencyScreen$bn currencyScreen = _Translations$settings$currencyScreen$bn._(_root);
	@override late final _Translations$settings$numberFormat$bn numberFormat = _Translations$settings$numberFormat$bn._(_root);
	@override late final _Translations$settings$fontSize$bn fontSize = _Translations$settings$fontSize$bn._(_root);
	@override late final _Translations$settings$calendar$bn calendar = _Translations$settings$calendar$bn._(_root);
	@override late final _Translations$settings$homePage$bn homePage = _Translations$settings$homePage$bn._(_root);
	@override late final _Translations$settings$sync$bn sync = _Translations$settings$sync$bn._(_root);
	@override late final _Translations$settings$export$bn export = _Translations$settings$export$bn._(_root);
	@override late final _Translations$settings$deleteData$bn deleteData = _Translations$settings$deleteData$bn._(_root);
	@override late final _Translations$settings$categories$bn categories = _Translations$settings$categories$bn._(_root);
	@override late final _Translations$settings$family$bn family = _Translations$settings$family$bn._(_root);
}

// Path: shell
class _Translations$shell$bn extends Translations$shell$en {
	_Translations$shell$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$shell$tabs$bn tabs = _Translations$shell$tabs$bn._(_root);
	@override late final _Translations$shell$reportsTabs$bn reportsTabs = _Translations$shell$reportsTabs$bn._(_root);
}

// Path: smsParser
class _Translations$smsParser$bn extends Translations$smsParser$en {
	_Translations$smsParser$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$smsParser$range$bn range = _Translations$smsParser$range$bn._(_root);
	@override late final _Translations$smsParser$summary$bn summary = _Translations$smsParser$summary$bn._(_root);
	@override late final _Translations$smsParser$card$bn card = _Translations$smsParser$card$bn._(_root);
	@override late final _Translations$smsParser$options$bn options = _Translations$smsParser$options$bn._(_root);
	@override late final _Translations$smsParser$toolbar$bn toolbar = _Translations$smsParser$toolbar$bn._(_root);
	@override late final _Translations$smsParser$section$bn section = _Translations$smsParser$section$bn._(_root);
	@override late final _Translations$smsParser$customRange$bn customRange = _Translations$smsParser$customRange$bn._(_root);
	@override late final _Translations$smsParser$results$bn results = _Translations$smsParser$results$bn._(_root);
	@override late final _Translations$smsParser$autoImport$bn autoImport = _Translations$smsParser$autoImport$bn._(_root);
}

// Path: support
class _Translations$support$bn extends Translations$support$en {
	_Translations$support$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$support$help$bn help = _Translations$support$help$bn._(_root);
	@override late final _Translations$support$about$bn about = _Translations$support$about$bn._(_root);
	@override late final _Translations$support$faq$bn faq = _Translations$support$faq$bn._(_root);
	@override late final _Translations$support$rate$bn rate = _Translations$support$rate$bn._(_root);
}

// Path: aiAssistant.suggestions
class _Translations$aiAssistant$suggestions$bn extends Translations$aiAssistant$suggestions$en {
	_Translations$aiAssistant$suggestions$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get topExpenses => 'সবচেয়ে বড় খরচ';
	@override String get budget => 'আমার বাজেট কেমন চলছে?';
}

// Path: aiAssistant.refusals
class _Translations$aiAssistant$refusals$bn extends Translations$aiAssistant$refusals$en {
	_Translations$aiAssistant$refusals$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get outOfScope => 'আমি শুধু আপনার Expenzo-র হিসাব নিয়ে সাহায্য করতে পারি: খরচ, বাজেট, ক্যাটাগরি, আয়, ব্যালেন্স, সঞ্চয়, লেনদেন, রিপোর্ট ও পুনরাবৃত্ত বিল। আপনার নিজের ডেটা নিয়ে প্রশ্ন করুন।';
	@override String get promptInjection => 'গোপন নির্দেশনা, ভেতরের তথ্য, গোপন কী বা আমার নিয়ম বদলানোর অনুরোধে আমি সাহায্য করতে পারি না। Expenzo-তে আপনার হিসাব নিয়ে জিজ্ঞেস করুন।';
	@override String get tooLong => 'মেসেজটি অনেক বড়। আপনার Expenzo-র হিসাব নিয়ে ছোট করে জিজ্ঞেস করুন।';
	@override String get empty => 'আপনার Expenzo-র হিসাব নিয়ে একটি প্রশ্ন লিখুন।';
	@override String get cooldown => 'আরেকটি প্রশ্ন পাঠানোর আগে কয়েক সেকেন্ড অপেক্ষা করুন।';
	@override String get contextUnavailable => 'এই মুহূর্তে আপনার হিসাবের ডেটা পড়তে পারছি না। একটু পরে আবার চেষ্টা করুন।';
}

// Path: aiAssistant.errors
class _Translations$aiAssistant$errors$bn extends Translations$aiAssistant$errors$en {
	_Translations$aiAssistant$errors$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get contextFailed => 'আপনার হিসাবের ডেটা লোড করা যায়নি। আবার চেষ্টা করুন।';
}

// Path: auth.errors
class _Translations$auth$errors$bn extends Translations$auth$errors$en {
	_Translations$auth$errors$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get cannotConnect => 'সংযোগ করা যাচ্ছে না। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।';
	@override String get serverProblem => 'আমাদের দিকে কিছু সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।';
	@override String get timedOut => 'অনুরোধের সময় শেষ হয়ে গেছে। সংযোগ দেখে আবার চেষ্টা করুন।';
	@override String get generic => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';
	@override String get cancelled => 'সাইন-ইন বাতিল করা হয়েছে।';
	@override String get network => 'নেটওয়ার্কে সমস্যা। সংযোগ দেখে আবার চেষ্টা করুন।';
	@override String get tooManyAttempts => 'অনেকবার চেষ্টা করা হয়েছে। পরে আবার চেষ্টা করুন।';
	@override String get failed => 'সাইন-ইন হয়নি। আবার চেষ্টা করুন।';
}

// Path: auth.syncConflict
class _Translations$auth$syncConflict$bn extends Translations$auth$syncConflict$en {
	_Translations$auth$syncConflict$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সিঙ্কে গরমিল';
	@override String get body => 'এই ফোনে এবং আপনার অ্যাকাউন্টে দুই জায়গাতেই রেকর্ড আছে। কোনগুলো রাখবেন বেছে নিন।';
	@override String get merge => 'আমার ডেটা একসাথে করুন';
	@override String get mergeDetail => 'দুই জায়গার রেকর্ডই রাখুন';
	@override String get useAccount => 'অ্যাকাউন্টের ডেটা ব্যবহার করুন';
	@override String get useAccountDetail => 'এই ফোনের রেকর্ড মুছে অ্যাকাউন্টের কপি ব্যবহার করুন';
	@override String get keepPhone => 'এই ফোনের ডেটা রাখুন';
	@override String get keepPhoneDetail => 'অ্যাকাউন্টের কপির জায়গায় এই ফোনের রেকর্ড রাখুন';
	@override String get replaceTitle => 'এই ফোনের ডেটা বদলাবেন?';
	@override String get replaceBody => 'এতে এই ফোনের রেকর্ড স্থায়ীভাবে মুছে যাবে এবং আপনার অ্যাকাউন্টের কপি বসবে।';
	@override String get replace => 'বদলান';
	@override String get namesUploadFailed => 'আপনার বাজেটের নাম আপলোড করা যায়নি। সংযোগ দেখে আবার চেষ্টা করুন।';
	@override String get preparing => 'প্রস্তুত হচ্ছে…';
	@override String get clearing => 'এই ফোন খালি করা হচ্ছে…';
	@override String get done => 'সম্পন্ন';
	@override String get syncing => 'সিঙ্ক হচ্ছে…';
}

// Path: auth.login
class _Translations$auth$login$bn extends Translations$auth$login$en {
	_Translations$auth$login$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get google => 'Google দিয়ে সাইন ইন';
	@override String get logo => 'Expenzo লোগো';
	@override String get pitch => 'রেকর্ডের ব্যাকআপ রাখতে এবং সব ডিভাইসে সিঙ্কে রাখতে সাইন ইন করুন।';
	@override String get signingIn => 'সাইন ইন হচ্ছে…';
}

// Path: budgets.empty
class _Translations$budgets$empty$bn extends Translations$budgets$empty$en {
	_Translations$budgets$empty$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'এখনো কোনো বাজেট নেই';
	@override String get body => 'কত টাকা বাকি আছে দেখতে একটি মাসিক সীমা ঠিক করুন।';
}

// Path: budgets.delete
class _Translations$budgets$delete$bn extends Translations$budgets$delete$en {
	_Translations$budgets$delete$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেট মুছুন';
	@override String confirm({required Object name}) => '"${name}" বাজেট মুছবেন?';
}

// Path: budgets.card
class _Translations$budgets$card$bn extends Translations$budgets$card$en {
	_Translations$budgets$card$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String overBy({required Object amount}) => '${amount} বেশি খরচ';
	@override String left({required Object amount}) => '${amount} বাকি';
	@override String spentOf({required Object total, required Object spent}) => '${total}-এর মধ্যে ${spent} খরচ';
	@override String a11y({required Object name, required Object headline, required Object daysLeft}) => '${name}, ${headline}, ${daysLeft}। অপশন দেখতে চেপে ধরে রাখুন।';
}

// Path: budgets.days
class _Translations$budgets$days$bn extends Translations$budgets$days$en {
	_Translations$budgets$days$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get ended => 'সময় শেষ';
	@override String get lastDay => 'শেষ দিন';
	@override String left({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n} দিন বাকি',
		other: '${n} দিন বাকি',
	);
}

// Path: budgets.form
class _Translations$budgets$form$bn extends Translations$budgets$form$en {
	_Translations$budgets$form$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get add => 'বাজেট যোগ করুন';
	@override String get edit => 'বাজেট সম্পাদনা';
	@override String get amount => 'পরিমাণ';
	@override String get name => 'নাম';
	@override String get nameHint => 'যেমন: খাবার ও পানীয়';
	@override String get period => 'সময়কাল';
	@override String get rollover => 'অব্যবহৃত টাকা পরের সময়ে নিন';
	@override String get rolloverDetail => 'যে টাকা খরচ হয়নি তা পরের সময়ে যোগ হবে';
	@override String get amountRequired => 'একটি পরিমাণ লিখুন';
	@override String get amountInvalid => 'সঠিক সংখ্যা লিখুন';
	@override String get nameRequired => 'একটি নাম লিখুন';
	@override String get nameReserved => 'অন্য একটি নাম দিন';
	@override String get sharedReadOnly => 'পরিবারের অ্যাডমিন এটি শেয়ার করেছেন। শুধু তিনিই এটি বদলাতে পারবেন।';
	@override String get sharedTitle => 'শেয়ার করা বাজেট';
	@override String get share => 'পরিবারের সাথে শেয়ার করুন';
	@override String shareDetail({required Object name}) => '${name}-এর সদস্যরা এটি দেখতে এবং এতে খরচ যোগ করতে পারবেন';
	@override String get unshareTitle => 'শেয়ার বন্ধ করবেন?';
	@override String get unshareBody => 'সদস্যরা আর এই বাজেট দেখতে পাবেন না। আগে যোগ করা লেনদেন যেমন আছে তেমনই থাকবে।';
	@override String get unshareConfirm => 'শেয়ার বন্ধ করুন';
}

// Path: budgets.details
class _Translations$budgets$details$bn extends Translations$budgets$details$en {
	_Translations$budgets$details$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেটের বিস্তারিত';
	@override String get loadFailed => 'বাজেটের বিস্তারিত লোড করা যায়নি। আবার চেষ্টা করুন।';
	@override String get notFound => 'বাজেট পাওয়া যায়নি।';
	@override String ofTotal({required Object total}) => ' / ${total}';
	@override late final _Translations$budgets$details$periodBudget$bn periodBudget = _Translations$budgets$details$periodBudget$bn._(_root);
	@override String carriedOver({required Object amount}) => 'আগের সময় থেকে আসা ${amount} সহ';
	@override String used({required Object percent}) => '${percent}% খরচ হয়েছে';
	@override String get over => 'বাজেট ছাড়িয়ে গেছে';
	@override String get transactionsFailed => 'লেনদেন লোড করা যায়নি';
	@override String get noExpenses => 'এই বাজেটে এখনো কোনো খরচ নেই';
	@override String get noExpensesBody => 'এই বাজেটের সাথে যুক্ত খরচ এখানে দেখা যাবে।';
	@override String get transactions => 'লেনদেন';
	@override String get unableToLoad => 'বাজেট লোড করা যায়নি';
	@override String get unableToLoadBody => 'বাজেটের বিস্তারিত লোড করা যায়নি।';
}

// Path: budgets.picker
class _Translations$budgets$picker$bn extends Translations$budgets$picker$en {
	_Translations$budgets$picker$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেট বেছে নিন';
	@override String get subtitle => 'এই খরচটি কোন বাজেটে গণ্য হবে তা বেছে নিন';
	@override String get sectionAvailable => 'উপলব্ধ বাজেট';
	@override String get noBudget => 'কোনো বাজেট নয়';
	@override String get noBudgetHint => 'কোনো বাজেটের সাথে যুক্ত করবেন না';
	@override String get previousBudget => 'আগের বাজেট (আর সক্রিয় নয়)';
	@override String get previousBudgetHint => 'বর্তমান সংযোগ রাখুন';
	@override String progress({required Object period, required Object spent, required Object limit}) => '${period} · ${spent} / ${limit}';
	@override String get empty => 'কোনো সক্রিয় বাজেট নেই';
}

// Path: budgets.plan
class _Translations$budgets$plan$bn extends Translations$budgets$plan$en {
	_Translations$budgets$plan$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেট পরিকল্পনা';
	@override String get rowSubtitle => 'আয় ও মাসিক বাজেট';
	@override String get editPlan => 'পরিকল্পনা বদলান';
	@override String get income => 'মাসিক আয়';
	@override late final _Translations$budgets$plan$names$bn names = _Translations$budgets$plan$names$bn._(_root);
	@override String perMonth({required Object amount}) => '${amount}/মাস';
	@override String toPlan({required Object amount}) => 'নিয়মিত খরচের পরে মাসে ${amount}';
	@override String remaining({required Object amount}) => 'ভাগ করার বাকি ${amount}';
	@override String overBy({required Object amount}) => '${amount} বেশি';
	@override String get name => 'নাম';
	@override String get amount => 'পরিমাণ';
	@override String get addBudget => 'বাজেট যোগ করুন';
	@override String removeBudget({required Object name}) => '${name} সরান';
	@override String get removeUnnamed => 'বাজেট সরান';
	@override String get suggestSplit => 'ভাগ করার পরামর্শ';
	@override String nameTooLong({required Object max}) => '${max} অক্ষর বা তার কম ব্যবহার করুন';
	@override String get nameDuplicate => 'অন্য একটি বাজেটের এই নাম আছে';
	@override String get amountPositive => '0-এর বেশি একটি পরিমাণ লিখুন';
	@override String chartLabel({required Object entries}) => 'বাজেট পরিকল্পনা: ${entries}';
	@override String get deleteTitle => 'বাজেট মুছবেন?';
	@override String deleteBody({required Object names}) => 'সংরক্ষণ করলে এই বাজেটগুলো মুছে যাবে: ${names}। এদের খরচগুলো থাকবে, কোনো বাজেট ছাড়া।';
	@override String get saved => 'বাজেট পরিকল্পনা সংরক্ষিত হয়েছে';
	@override String get saveFailed => 'সব পরিবর্তন সংরক্ষণ করা যায়নি। এখন যা সংরক্ষিত আছে তা দেখানো হচ্ছে।';
	@override String get loadFailed => 'আপনার বাজেট পরিকল্পনা লোড করা যায়নি।';
	@override String get empty => 'এখনো কোনো মাসিক বাজেট নেই। পরিকল্পনা শুরু করতে একটি যোগ করুন।';
}

// Path: categories.settings
class _Translations$categories$settings$bn extends Translations$categories$settings$en {
	_Translations$categories$settings$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ক্যাটাগরি সেটিংস';
	@override late final _Translations$categories$settings$sections$bn sections = _Translations$categories$settings$sections$bn._(_root);
	@override String recordCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি লেনদেন',
		other: '${n}টি লেনদেন',
	);
	@override String get deleteFailed => 'ক্যাটাগরি মোছা যায়নি। আবার চেষ্টা করুন।';
}

// Path: categories.form
class _Translations$categories$form$bn extends Translations$categories$form$en {
	_Translations$categories$form$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get add => 'ক্যাটাগরি যোগ করুন';
	@override String get edit => 'ক্যাটাগরি সম্পাদনা';
	@override String get name => 'নাম';
	@override String get nameHint => 'বাজার-সদাই';
	@override String get nameRequired => 'একটি নাম লিখুন';
	@override String get icon => 'আইকন';
	@override String get color => 'রং বেছে নিন';
}

// Path: categories.delete
class _Translations$categories$delete$bn extends Translations$categories$delete$en {
	_Translations$categories$delete$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ক্যাটাগরি মুছবেন?';
	@override String confirm({required Object name}) => 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান?';
	@override String withRecords({required num n, required Object name}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান? এই ক্যাটাগরির ${n}টি লেনদেন ক্যাটাগরি ছাড়া থাকবে।',
		other: 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান? এই ক্যাটাগরির ${n}টি লেনদেন ক্যাটাগরি ছাড়া থাকবে।',
	);
}

// Path: common.errors
class _Translations$common$errors$bn extends Translations$common$errors$en {
	_Translations$common$errors$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get generic => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';
	@override String get storage => 'আপনার ডেটা পড়া বা সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';
	@override String get network => 'আপনি অফলাইনে আছেন। সংযোগ দেখে আবার চেষ্টা করুন।';
	@override String get server => 'সার্ভার সাড়া দেয়নি। একটু পরে আবার চেষ্টা করুন।';
	@override String get auth => 'সাইন-ইনে সমস্যা হয়েছে। আবার সাইন ইন করে চেষ্টা করুন।';
	@override String get permission => 'এই কাজের অনুমতি Expenzo-র নেই। সিস্টেম সেটিংসে অনুমতি দিন।';
	@override String get notFound => 'এই আইটেমটি আর নেই।';
	@override String get smsScan => 'আপনার মেসেজ পড়া যায়নি। আবার চেষ্টা করুন।';
	@override String get requiresRecentLogin => 'নিরাপত্তার জন্য আবার সাইন ইন করুন, তারপর অ্যাকাউন্ট মুছুন।';
}

// Path: common.dates
class _Translations$common$dates$bn extends Translations$common$dates$en {
	_Translations$common$dates$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get today => 'আজ';
	@override String get yesterday => 'গতকাল';
}

// Path: common.a11y
class _Translations$common$a11y$bn extends Translations$common$a11y$en {
	_Translations$common$a11y$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String expenseAmount({required Object amount, required Object currency}) => 'খরচ, ${amount} ${currency}';
	@override String incomeAmount({required Object amount, required Object currency}) => 'আয়, ${amount} ${currency}';
}

// Path: common.feedback
class _Translations$common$feedback$bn extends Translations$common$feedback$en {
	_Translations$common$feedback$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get subject => 'Expenzo নিয়ে মতামত';
	@override String noMailApp({required Object email}) => 'কোনো ইমেইল অ্যাপ পাওয়া যায়নি। আমাদের লিখুন ${email} ঠিকানায়।';
	@override String get copyAddress => 'ঠিকানা কপি করুন';
}

// Path: common.fallback
class _Translations$common$fallback$bn extends Translations$common$fallback$en {
	_Translations$common$fallback$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get initTitle => 'অ্যাপ চালু হয়নি';
	@override String get errorTitle => 'কিছু একটা ভুল হয়েছে';
	@override String get initBody => 'অ্যাপটি চালু করা শেষ করা যায়নি। এটি সাধারণত সাময়িক। আবার চেষ্টা করুন, অথবা অ্যাপটি আবার চালু করুন।';
	@override String get errorBody => 'একটি অপ্রত্যাশিত সমস্যা হয়েছে। আবার চেষ্টা করতে পারেন, অ্যাপটি আবার চালু করতে পারেন, অথবা আমাদের মতামত পাঠাতে পারেন যাতে আমরা ঠিক করতে পারি।';
	@override String reference({required Object id}) => 'রেফারেন্স: ${id}';
	@override String get closeApp => 'অ্যাপ বন্ধ করুন';
	@override String get debugDetails => 'বিস্তারিত (ডিবাগ)';
	@override String get storageBody => 'এই ফোনে রাখা ডেটা পড়া যাচ্ছে না। Expenzo ব্যবহার চালিয়ে যেতে এটি রিসেট করুন। সিঙ্ক করা ডেটা সাইন ইন করলে ফিরে আসবে।';
	@override String get resetLocalData => 'লোকাল ডেটা রিসেট করুন';
	@override String get resetConfirm => 'এতে এই ফোনে রাখা লেনদেন, বাজেট ও ক্যাটাগরি মুছে যাবে। সিঙ্ক করা ডেটা সাইন ইন করলে ফিরে আসবে। যে পরিবর্তন সিঙ্ক হয়নি তা হারিয়ে যাবে।';
	@override String get resetConfirmAction => 'মুছে আবার শুরু করুন';
}

// Path: common.smsGate
class _Translations$common$smsGate$bn extends Translations$common$smsGate$en {
	_Translations$common$smsGate$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'SMS পড়ার অনুমতি দরকার';
	@override String get body => 'আপনার ব্যাংক ও পেমেন্ট অ্যাপের খরচ স্বয়ংক্রিয়ভাবে হিসাব রাখতে Expenzo-র আপনার SMS পড়ার অনুমতি দরকার। আপনার মেসেজ কখনো আপনার ফোনের বাইরে যায় না।';
	@override String get allow => 'অনুমতি দিন';
	@override String get deniedTitle => 'অনুমতি দরকার';
	@override String get deniedBody => 'SMS পড়ার অনুমতি স্থায়ীভাবে বন্ধ করা আছে। স্মার্ট স্ক্যানার ব্যবহার করতে অ্যাপ সেটিংসে এটি চালু করুন।';
}

// Path: dashboard.range
class _Translations$dashboard$range$bn extends Translations$dashboard$range$en {
	_Translations$dashboard$range$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get thisMonth => 'এই মাস';
	@override String get lastMonth => 'গত মাস';
	@override String get thisYear => 'এই বছর';
	@override late final _Translations$dashboard$range$net$bn net = _Translations$dashboard$range$net$bn._(_root);
	@override late final _Translations$dashboard$range$previous$bn previous = _Translations$dashboard$range$previous$bn._(_root);
}

// Path: dashboard.sections
class _Translations$dashboard$sections$bn extends Translations$dashboard$sections$en {
	_Translations$dashboard$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get budgets => 'বাজেট';
	@override String get recentActivity => 'সাম্প্রতিক লেনদেন';
	@override String get spendingPatterns => 'খরচের ধরন';
	@override String get seeAll => 'সব দেখুন';
}

// Path: dashboard.trend
class _Translations$dashboard$trend$bn extends Translations$dashboard$trend$en {
	_Translations$dashboard$trend$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String noPrevious({required Object period}) => '${period}-এর সাথে তুলনা করার মতো খরচ নেই';
	@override String same({required Object period}) => '${period}-এর সমান';
	@override String up({required Object period, required Object percent}) => '${period}-এর চেয়ে +${percent}%';
	@override String down({required Object period, required Object percent}) => '${period}-এর চেয়ে -${percent}%';
	@override String spent({required Object amount}) => '${amount} খরচ';
	@override String get noData => 'এখনো প্রবণতার ডেটা নেই';
}

// Path: dashboard.autoImport
class _Translations$dashboard$autoImport$bn extends Translations$dashboard$autoImport$en {
	_Translations$dashboard$autoImport$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'SMS থেকে খরচ যোগ করুন';
	@override String get body => 'Expenzo-কে ব্যাংক ও পেমেন্টের মেসেজ পড়ে আপনার হয়ে খরচ যোগ করতে দিন। মেসেজ এই ফোনেই থাকে।';
	@override String get setUp => 'সেট আপ করুন';
}

// Path: enums.recordType
class _Translations$enums$recordType$bn extends Translations$enums$recordType$en {
	_Translations$enums$recordType$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get income => 'আয়';
	@override String get expense => 'খরচ';
}

// Path: enums.period
class _Translations$enums$period$bn extends Translations$enums$period$en {
	_Translations$enums$period$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get weekly => 'সাপ্তাহিক';
	@override String get monthly => 'মাসিক';
	@override String get yearly => 'বার্ষিক';
}

// Path: enums.frequency
class _Translations$enums$frequency$bn extends Translations$enums$frequency$en {
	_Translations$enums$frequency$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get daily => 'দৈনিক';
	@override String get weekly => 'সাপ্তাহিক';
	@override String get biweekly => 'প্রতি দুই সপ্তাহে';
	@override String get monthly => 'মাসিক';
	@override String get yearly => 'বার্ষিক';
}

// Path: enums.source
class _Translations$enums$source$bn extends Translations$enums$source$en {
	_Translations$enums$source$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get manual => 'নিজে যোগ করা';
	@override String get sms => 'SMS';
	@override String get email => 'ইমেইল';
	@override String get recurring => 'পুনরাবৃত্ত';
}

// Path: enums.theme
class _Translations$enums$theme$bn extends Translations$enums$theme$en {
	_Translations$enums$theme$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get system => 'ডিভাইসের মতো';
	@override String get light => 'লাইট';
	@override String get dark => 'ডার্ক';
}

// Path: enums.digitGrouping
class _Translations$enums$digitGrouping$bn extends Translations$enums$digitGrouping$en {
	_Translations$enums$digitGrouping$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get comma => 'কমা দিয়ে আলাদা';
	@override String get dot => 'ডট দিয়ে আলাদা';
	@override String get space => 'ফাঁকা জায়গা দিয়ে আলাদা';
}

// Path: enums.fontSize
class _Translations$enums$fontSize$bn extends Translations$enums$fontSize$en {
	_Translations$enums$fontSize$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$enums$fontSize$small$bn small = _Translations$enums$fontSize$small$bn._(_root);
	@override late final _Translations$enums$fontSize$medium$bn medium = _Translations$enums$fontSize$medium$bn._(_root);
	@override late final _Translations$enums$fontSize$large$bn large = _Translations$enums$fontSize$large$bn._(_root);
	@override late final _Translations$enums$fontSize$extraLarge$bn extraLarge = _Translations$enums$fontSize$extraLarge$bn._(_root);
}

// Path: enums.firstDayOfWeek
class _Translations$enums$firstDayOfWeek$bn extends Translations$enums$firstDayOfWeek$en {
	_Translations$enums$firstDayOfWeek$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get sunday => 'রবিবার';
	@override String get monday => 'সোমবার';
	@override String get saturday => 'শনিবার';
}

// Path: family.create
class _Translations$family$create$bn extends Translations$family$create$en {
	_Translations$family$create$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পারিবারিক গ্রুপ তৈরি করুন';
	@override String get heading => 'আপনার পারিবারিক পরিকল্পনা শুরু করুন';
	@override String get body => 'আপনার পরিবারের জন্য একটি শেয়ার করা বাজেটের জায়গা তৈরি করুন।';
	@override String get nameLabel => 'গ্রুপের নাম';
	@override String get nameHint => 'রহমান পরিবার';
	@override String get nameRequired => 'গ্রুপের নাম লিখুন';
	@override String get budgetLabel => 'মাসিক পারিবারিক বাজেট (ঐচ্ছিক)';
	@override String get budgetInvalid => 'শূন্যের বেশি একটি পরিমাণ লিখুন';
	@override String currencyNote({required Object code}) => 'মুদ্রা: ${code} (আপনার সেটিংস থেকে)';
	@override String get submit => 'গ্রুপ তৈরি করুন';
	@override String get haveCode => 'ইনভাইট কোড আছে? পরিবারে যোগ দিন';
}

// Path: family.join
class _Translations$family$join$bn extends Translations$family$join$en {
	_Translations$family$join$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পরিবারে যোগ দিন';
	@override String get body => 'পরিবারের অ্যাডমিনের শেয়ার করা 6 অক্ষরের কোডটি লিখুন।';
	@override String get codeLabel => 'ইনভাইট কোড';
	@override String get codeInvalid => 'কোডে 6টি অক্ষর ও সংখ্যা থাকে';
	@override String currencyNote({required Object code}) => 'আপনার মুদ্রা: ${code}';
	@override String get submit => 'গ্রুপে যোগ দিন';
	@override String joined({required Object name}) => 'আপনি ${name}-এ যোগ দিয়েছেন';
	@override String get syncOff => 'আপনি যোগ দিয়েছেন। শেয়ার করা বাজেট দেখতে সেটিংসে সিঙ্ক চালু করুন।';
}

// Path: family.invite
class _Translations$family$invite$bn extends Translations$family$invite$en {
	_Translations$family$invite$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সদস্য আমন্ত্রণ করুন';
	@override String get heading => 'আপনার পরিবারকে আমন্ত্রণ করুন';
	@override String get limitNote => 'আপনিসহ সর্বোচ্চ 10 জন সদস্য';
	@override String get codeCaption => 'এই ইনভাইট কোডটি শেয়ার করুন';
	@override String validUntil({required Object time}) => '${time} পর্যন্ত বৈধ';
	@override String get share => 'ইনভাইট শেয়ার করুন';
	@override String shareText({required Object name, required Object code, required Object time}) => 'Expenzo-তে আমার পরিবার "${name}"-এ যোগ দিন: সেটিংস > পারিবারিক গ্রুপ > পরিবারে যোগ দিন খুলে ${code} লিখুন। কোডটি ${time} পর্যন্ত কাজ করবে।';
	@override String get regenerate => 'নতুন কোড তৈরি করুন';
	@override String get regenerateTitle => 'নতুন কোড তৈরি করবেন?';
	@override String get regenerateBody => 'বর্তমান কোডটি আর কাজ করবে না।';
	@override String get copied => 'কোড কপি হয়েছে';
	@override String get offline => 'আপনি অফলাইনে আছেন। ইনভাইট কোড পেতে ইন্টারনেটে যুক্ত হোন।';
	@override String get expired => 'এই কোডের মেয়াদ শেষ। নতুন কোড তৈরি করুন।';
}

// Path: family.dashboard
class _Translations$family$dashboard$bn extends Translations$family$dashboard$en {
	_Translations$family$dashboard$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get spentOfPlanned => 'পরিকল্পনার মধ্যে খরচ';
	@override String spentOfPlannedValue({required Object planned, required Object spent}) => '${planned}-এর মধ্যে ${spent}';
	@override String expense({required Object amount}) => 'খরচ: ${amount}';
	@override String sharedBudgetTotal({required Object amount}) => 'শেয়ার করা বাজেটের মোট: ${amount}';
	@override String ofMonthlyBudget({required Object budget, required Object spent}) => 'এই মাসে ${budget}-এর মধ্যে ${spent}';
	@override String get onlySharedNote => 'এখানে শুধু শেয়ার করা বাজেটের লেনদেন গোনা হয়।';
	@override String you({required Object name}) => '${name} (আপনি)';
	@override String get memberFallback => 'পরিবারের সদস্য';
	@override String moreMembers({required Object n}) => '+${n}';
	@override String get noSharedBudgets => 'এখনো কোনো শেয়ার করা বাজেট নেই। অ্যাডমিন বাজেট ফর্ম থেকে একটি বাজেট শেয়ার করতে পারেন।';
	@override String get seeAllBudgets => 'সব বাজেট দেখুন';
	@override String lastUpdated({required Object time}) => 'সর্বশেষ আপডেট ${time}';
	@override String get loadFailed => 'আপনার পরিবারের তথ্য লোড করা যায়নি। সংযোগ দেখে আবার চেষ্টা করুন।';
	@override String get summaryFailed => 'সর্বশেষ হিসাব লোড করা যায়নি।';
	@override String get manageMembers => 'সদস্য পরিচালনা';
}

// Path: family.members
class _Translations$family$members$bn extends Translations$family$members$en {
	_Translations$family$members$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String title({required Object count}) => 'সদস্য (${count})';
	@override String get inviteMore => 'আরও আমন্ত্রণ করুন';
	@override String get leave => 'গ্রুপ ছেড়ে দিন';
	@override String leaveTitle({required Object name}) => '${name} ছেড়ে দেবেন?';
	@override String get leaveBody => 'এই গ্রুপের শেয়ার করা বাজেটগুলো আপনার ফোন থেকে সরে যাবে। আপনার নিজের লেনদেন আপনার কাছেই থাকবে।';
	@override String get leaveLastBody => 'আপনিই শেষ সদস্য। ছেড়ে দিলে গ্রুপটি মুছে যাবে।';
	@override String get changeRole => 'ভূমিকা বদলান';
	@override String get remove => 'গ্রুপ থেকে সরান';
	@override String removeTitle({required Object name}) => '${name}-কে সরাবেন?';
	@override String get deleteGroup => 'গ্রুপ মুছুন';
	@override String deleteTitle({required Object name}) => '${name} মুছবেন?';
	@override String get deleteBody => 'সবাইকে সরিয়ে দেওয়া হবে। শেয়ার করা বাজেটগুলো তাদের মালিকের ব্যক্তিগত বাজেট হয়ে যাবে।';
}

// Path: family.roles
class _Translations$family$roles$bn extends Translations$family$roles$en {
	_Translations$family$roles$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get admin => 'অ্যাডমিন';
	@override String get member => 'সদস্য';
	@override String get viewer => 'দর্শক';
}

// Path: family.roleHints
class _Translations$family$roleHints$bn extends Translations$family$roleHints$en {
	_Translations$family$roleHints$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get admin => 'সদস্য ও শেয়ার করা বাজেট পরিচালনা করেন';
	@override String get member => 'ড্যাশবোর্ড দেখেন এবং শেয়ার করা বাজেটে লেনদেন যোগ করেন';
	@override String get viewer => 'শুধু ড্যাশবোর্ড দেখেন';
}

// Path: family.errors
class _Translations$family$errors$bn extends Translations$family$errors$en {
	_Translations$family$errors$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get alreadyInGroup => 'আপনি ইতিমধ্যে একটি পারিবারিক গ্রুপে আছেন। আগে সেটি ছেড়ে দিন।';
	@override String get currencyMismatch => 'এই পরিবার অন্য একটি মুদ্রা ব্যবহার করে। সেটিংসে একই মুদ্রা বেছে নিয়ে তারপর যোগ দিন।';
	@override String get groupFull => 'গ্রুপ পূর্ণ। একটি পারিবারিক গ্রুপে সর্বোচ্চ 10 জন সদস্য থাকতে পারেন।';
	@override String get inviteExpired => 'এই কোডের মেয়াদ শেষ। অ্যাডমিনের কাছে নতুন কোড চান।';
	@override String get inviteNotFound => 'এই কোডের কোনো পরিবার নেই। কোডটি দেখে আবার চেষ্টা করুন।';
	@override String get lastAdmin => 'আগে অন্য কাউকে অ্যাডমিন করুন।';
	@override String get notInGroup => 'আপনি আর এই গ্রুপে নেই।';
	@override String get signInRequired => 'পারিবারিক গ্রুপ ব্যবহার করতে সাইন ইন করুন।';
}

// Path: goals.errors
class _Translations$goals$errors$bn extends Translations$goals$errors$en {
	_Translations$goals$errors$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get nameRequired => 'আপনার লক্ষ্যের একটি নাম দিন।';
	@override String get targetPositive => 'শূন্যের বেশি একটি লক্ষ্য পরিমাণ লিখুন।';
	@override String get amountPositive => 'শূন্যের বেশি একটি পরিমাণ লিখুন।';
	@override String get amountTooLarge => 'সর্বোচ্চ 9,999,999,999.99 পর্যন্ত পরিমাণ লিখুন।';
}

// Path: goals.card
class _Translations$goals$card$bn extends Translations$goals$card$en {
	_Translations$goals$card$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get section => 'সঞ্চয়ের লক্ষ্য';
	@override String progress({required Object target, required Object saved}) => '${target}-এর মধ্যে ${saved}';
	@override String monthsLeft({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: 'আর ${n} মাস বাকি',
		other: 'আর ${n} মাস বাকি',
	);
	@override String get dueThisMonth => 'এই মাসেই শেষ সময়';
	@override String get reached => 'লক্ষ্য পূরণ হয়েছে';
	@override String plan({required Object amount}) => 'পরিকল্পনা: মাসে ${amount}';
	@override String get addToGoal => 'লক্ষ্যে যোগ করুন';
	@override String get newGoal => 'নতুন লক্ষ্য';
	@override String get edit => 'লক্ষ্য সম্পাদনা';
	@override String get setGoal => 'একটি সঞ্চয়ের লক্ষ্য ঠিক করুন';
}

// Path: goals.addSheet
class _Translations$goals$addSheet$bn extends Translations$goals$addSheet$en {
	_Translations$goals$addSheet$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String title({required Object name}) => '${name}-এ যোগ করুন';
	@override String get amount => 'পরিমাণ';
	@override String get note => 'এটি শুধু লক্ষ্য আপডেট করে, কোনো লেনদেন যোগ করে না।';
}

// Path: goals.list
class _Translations$goals$list$bn extends Translations$goals$list$en {
	_Translations$goals$list$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'লক্ষ্যসমূহ';
	@override String get subtitle => 'নতুনগুলো আগে। সম্পাদনা করতে কোনো লক্ষ্যে ট্যাপ করুন।';
	@override String get empty => 'এখনো কোনো সঞ্চয়ের লক্ষ্য নেই।';
	@override String get loadFailed => 'আপনার লক্ষ্যগুলো লোড করা যায়নি। আবার চেষ্টা করুন।';
}

// Path: goals.form
class _Translations$goals$form$bn extends Translations$goals$form$en {
	_Translations$goals$form$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'লক্ষ্য সম্পাদনা';
	@override String get createTitle => 'নতুন সঞ্চয়ের লক্ষ্য';
	@override String get name => 'লক্ষ্যের নাম';
	@override String get target => 'লক্ষ্য পরিমাণ';
	@override String get saved => 'এ পর্যন্ত সঞ্চয়';
	@override String get targetDate => 'লক্ষ্যের তারিখ';
	@override String get clearDate => 'তারিখ মুছুন';
	@override String get pickDate => 'লক্ষ্যের তারিখ বেছে নিতে চাপুন';
	@override String get monthly => 'মাসিক জমা';
	@override String suggestMonthly({required Object amount}) => 'প্রস্তাবিত: মাসে ${amount}';
	@override String get deleteTitle => 'লক্ষ্য মুছবেন?';
	@override String get deleteBody => 'এতে লক্ষ্য ও এর সঞ্চিত পরিমাণ মুছে যাবে। আপনার লেনদেনে কোনো প্রভাব পড়বে না।';
	@override String get savedMessage => 'লক্ষ্য সংরক্ষিত হয়েছে';
	@override String get createdMessage => 'লক্ষ্য তৈরি হয়েছে';
	@override String get deleted => 'লক্ষ্য মুছে ফেলা হয়েছে';
}

// Path: messageTemplates.errors
class _Translations$messageTemplates$errors$bn extends Translations$messageTemplates$errors$en {
	_Translations$messageTemplates$errors$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get deleteFailed => 'SMS ফরম্যাট মোছা যায়নি। আবার চেষ্টা করুন।';
	@override String get restoreFailed => 'SMS ফরম্যাট ফেরানো যায়নি। আবার চেষ্টা করুন।';
}

// Path: messageTemplates.retro
class _Translations$messageTemplates$retro$bn extends Translations$messageTemplates$retro$en {
	_Translations$messageTemplates$retro$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পুরোনো মেসেজ স্ক্যান হচ্ছে';
	@override String get scanning => 'এই SMS ফরম্যাটের সাথে মেলে এমন পুরোনো খরচ খোঁজা হচ্ছে…';
	@override String get saved => 'SMS ফরম্যাট সংরক্ষণ হয়েছে। এ রকম নতুন মেসেজ নিজে থেকে যোগ হবে।';
	@override String get review => 'যে পুরোনো খরচ পাওয়া গেছে তা দেখে যোগ করতে সেটিংস → SMS থেকে স্বয়ংক্রিয় ইমপোর্ট-এ যান।';
}

// Path: messageTemplates.editor
class _Translations$messageTemplates$editor$bn extends Translations$messageTemplates$editor$en {
	_Translations$messageTemplates$editor$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get noNumbers => 'এই মেসেজে কোনো সংখ্যা পাওয়া যায়নি।';
	@override String get amountsFound => 'এই মেসেজে পাওয়া পরিমাণ:';
	@override String get step1 => 'ধাপ 1/3: একটি মূল শব্দ বেছে নিন';
	@override String get step1Body => 'এমন একটি শব্দ বেছে নিন যা এই ধরনের প্রতিটি মেসেজে থাকে, যেমন "debited", "paid" বা "spent"।';
	@override String get wordsInMessage => 'এই মেসেজের শব্দগুলো';
	@override String get step1Hint => 'চালিয়ে যেতে একটি শব্দ বেছে নিন।';
	@override String get step2 => 'ধাপ 2/3: পরিমাণ বেছে নিন';
	@override String get step2Body => 'কোন সংখ্যাটি আপনার খরচের পরিমাণ?';
	@override String get step2Hint => 'চালিয়ে যেতে পরিমাণ বেছে নিন।';
	@override String get step3 => 'ধাপ 3/3: দেখে নিন';
	@override String get step3Body => 'এখন থেকে এ রকম মেসেজ নিজে থেকে খরচ হিসেবে যোগ হবে।';
	@override String get sender => 'প্রেরক';
	@override String get keyWord => 'মূল শব্দ';
	@override String get amountInMessage => 'এই মেসেজের পরিমাণ';
	@override String saveFailed({required Object reason}) => 'SMS ফরম্যাট সংরক্ষণ করা যায়নি: ${reason}';
	@override String get updated => 'SMS ফরম্যাট আপডেট হয়েছে';
	@override String get saved => 'SMS ফরম্যাট সংরক্ষণ হয়েছে';
}

// Path: messageTemplates.analyzer
class _Translations$messageTemplates$analyzer$bn extends Translations$messageTemplates$analyzer$en {
	_Translations$messageTemplates$analyzer$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String title({required Object sender}) => '${sender} থেকে আসা মেসেজ';
	@override String get intro => 'Expenzo-কে এই SMS ফরম্যাট শেখাতে একটি মেসেজ বেছে নিন। এরপর এ রকম মেসেজ নিজে থেকে রেকর্ড হিসেবে যোগ হবে।';
	@override String get useMessage => 'এই মেসেজটি ব্যবহার করুন';
	@override String get noMessages => 'এই প্রেরকের সাম্প্রতিক কোনো মেসেজ নেই।';
}

// Path: messageTemplates.contacts
class _Translations$messageTemplates$contacts$bn extends Translations$messageTemplates$contacts$en {
	_Translations$messageTemplates$contacts$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'যেসব প্রেরক আপনাকে পেমেন্টের মেসেজ পাঠায় তাদের বেছে নিন। Expenzo তাদের মেসেজের ফরম্যাট শিখে আপনার জন্য রেকর্ড যোগ করে।';
	@override String get search => 'প্রেরক খুঁজুন';
	@override String get active => 'চালু';
	@override String get empty => 'এই ফোনে এখনো কোনো মেসেজ নেই। SMS এলে প্রেরকেরা এখানে দেখা যাবে।';
	@override String noMatch({required Object query}) => '"${query}" এর সাথে মেলে এমন কোনো প্রেরক নেই।';
}

// Path: messageTemplates.watchlist
class _Translations$messageTemplates$watchlist$bn extends Translations$messageTemplates$watchlist$en {
	_Translations$messageTemplates$watchlist$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'SMS ওয়াচলিস্ট';
	@override String get subtitle => 'এই প্রেরকদের মেসেজ লেনদেন হিসেবে যোগ হয়। কোনো প্রেরককে উপেক্ষা করতে বিরতি দিন।';
	@override String formats({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি SMS ফরম্যাট',
		other: '${n}টি SMS ফরম্যাট',
	);
	@override String get paused => 'বিরতিতে';
	@override String toggle({required Object name}) => '${name} এর মেসেজ পড়ুন';
	@override String get empty => 'এখনো কোনো প্রেরক নেই। অটো-ইমপোর্ট থেকে একটি নমুনা মেসেজ দেখিয়ে প্রেরক যোগ করুন।';
	@override String get addSender => 'প্রেরক বেছে নিন';
	@override String get loadFailed => 'ওয়াচলিস্ট লোড করা যায়নি। আবার চেষ্টা করুন।';
}

// Path: notifications.channel
class _Translations$notifications$channel$bn extends Translations$notifications$channel$en {
	_Translations$notifications$channel$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get name => 'অ্যাপের নোটিফিকেশন';
	@override String get description => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ, পুনরাবৃত্ত রিমাইন্ডার, স্ক্যানের ফলাফল ও স্বয়ংক্রিয় ইমপোর্ট করা লেনদেন';
}

// Path: notifications.budget
class _Translations$notifications$budget$bn extends Translations$notifications$budget$en {
	_Translations$notifications$budget$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেট সতর্কতা';
	@override String over({required Object budget}) => 'আপনার "${budget}" বাজেট ছাড়িয়ে গেছে।';
	@override String used({required Object budget, required Object percent}) => 'আপনার "${budget}" বাজেটের ${percent}% খরচ হয়েছে।';
}

// Path: notifications.recurringDue
class _Translations$notifications$recurringDue$bn extends Translations$notifications$recurringDue$en {
	_Translations$notifications$recurringDue$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'আগামীকাল পুনরাবৃত্ত লেনদেন';
}

// Path: notifications.weeklySummary
class _Translations$notifications$weeklySummary$bn extends Translations$notifications$weeklySummary$en {
	_Translations$notifications$weeklySummary$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'এই সপ্তাহের খরচ';
	@override String up({required Object amount, required Object percent}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন, গত সপ্তাহের চেয়ে ${percent}% বেশি।';
	@override String down({required Object amount, required Object percent}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন, গত সপ্তাহের চেয়ে ${percent}% কম।';
	@override String same({required Object amount}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন, গত সপ্তাহের সমান।';
	@override String noComparison({required Object amount}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন।';
	@override String get nothing => 'এই সপ্তাহে কোনো খরচ লেখা হয়নি।';
}

// Path: notifications.scan
class _Translations$notifications$scan$bn extends Translations$notifications$scan$en {
	_Translations$notifications$scan$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get smsTitle => 'SMS স্ক্যান শেষ';
	@override String get emailTitle => 'ইমেইল স্ক্যান শেষ';
	@override String found({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি নতুন খরচ পাওয়া গেছে',
		other: '${n}টি নতুন খরচ পাওয়া গেছে',
	);
}

// Path: notifications.autoImport
class _Translations$notifications$autoImport$bn extends Translations$notifications$autoImport$en {
	_Translations$notifications$autoImport$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get expenseTitle => 'খরচ যোগ হয়েছে';
	@override String get incomeTitle => 'আয় যোগ হয়েছে';
	@override String body({required Object amount, required Object description}) => '${amount} · ${description}';
	@override String bodyFromSender({required Object sender, required Object amount}) => '${sender} থেকে ${amount}';
	@override String get summaryTitle => 'SMS থেকে লেনদেন যোগ হয়েছে';
	@override String summary({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: 'SMS থেকে ${n}টি লেনদেন যোগ হয়েছে',
		other: 'SMS থেকে ${n}টি লেনদেন যোগ হয়েছে',
	);
}

// Path: notifications.syncError
class _Translations$notifications$syncError$bn extends Translations$notifications$syncError$en {
	_Translations$notifications$syncError$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সিঙ্কে সমস্যা';
}

// Path: onboarding.common
class _Translations$onboarding$common$bn extends Translations$onboarding$common$en {
	_Translations$onboarding$common$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get skip => 'এড়িয়ে যান';
	@override String get continueLabel => 'চালিয়ে যান';
	@override String stepOf({required Object current, required Object total}) => 'ধাপ ${current}/${total}';
}

// Path: onboarding.income
class _Translations$onboarding$income$bn extends Translations$onboarding$income$en {
	_Translations$onboarding$income$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'চলুন আপনার বাজেট সাজাই';
	@override String get subtitle => 'প্রথমে আপনার মাসিক আয় জানান, যাতে আমরা আপনার জন্য মানানসই একটি বাজেট তৈরি করতে পারি।';
	@override String get amountLabel => 'মাসিক নিট আয়';
	@override String get amountInvalid => 'সর্বোচ্চ 9,999,999,999.99 পর্যন্ত পরিমাণ লিখুন।';
	@override String get frequencyLabel => 'আয়ের ব্যবধান';
	@override late final _Translations$onboarding$income$frequency$bn frequency = _Translations$onboarding$income$frequency$bn._(_root);
	@override String perMonth({required Object amount}) => '${amount}/মাস';
}

// Path: onboarding.recurring
class _Translations$onboarding$recurring$bn extends Translations$onboarding$recurring$en {
	_Translations$onboarding$recurring$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'কোনো নিয়মিত পেমেন্ট আছে?';
	@override String get subtitle => 'আপনার নিয়মিত নির্দিষ্ট খরচগুলো যোগ করুন, যাতে বাজেটে সেগুলো হিসাব করা যায়।';
	@override String get addAnother => 'আরেকটি যোগ করুন';
	@override String get addFirst => 'একটি পেমেন্ট যোগ করুন';
	@override String get total => 'মোট নিয়মিত';
	@override String remove({required Object name}) => '${name} সরান';
	@override late final _Translations$onboarding$recurring$sheet$bn sheet = _Translations$onboarding$recurring$sheet$bn._(_root);
}

// Path: onboarding.plan
class _Translations$onboarding$plan$bn extends Translations$onboarding$plan$en {
	_Translations$onboarding$plan$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'আপনার বাজেট পরিকল্পনা';
	@override String get subtitle => 'নিয়মিত খরচের পরে যা থাকে, তার 50/30/20 ভাগ আমরা পরামর্শ দিচ্ছি। যেকোনো নাম বা পরিমাণ বদলাতে পারেন।';
	@override String get noIncome => 'ভাগের পরামর্শ পেতে প্রথম ধাপে আপনার আয় যোগ করুন, অথবা নিচে পরিমাণ লিখুন।';
	@override String get noRoom => 'নিয়মিত খরচে আপনার পুরো আয় চলে যায়। তবুও নিচে পরিমাণ লিখতে পারেন।';
	@override String get skip => 'এখন বাজেট বাদ দিন';
}

// Path: onboarding.goal
class _Translations$onboarding$goal$bn extends Translations$onboarding$goal$en {
	_Translations$onboarding$goal$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'আপনি কীসের জন্য সঞ্চয় করছেন?';
	@override String get subtitle => 'একটি সঞ্চয়ের লক্ষ্য ঠিক করুন, আমরা অগ্রগতি দেখতে সাহায্য করব।';
	@override String get nameLabel => 'লক্ষ্যের নাম';
	@override String get nameHint => 'যেমন: নতুন ল্যাপটপ';
	@override String get amountLabel => 'লক্ষ্য পরিমাণ';
	@override String get notNow => 'এখন কোনো লক্ষ্য নয়';
}

// Path: onboarding.timeline
class _Translations$onboarding$timeline$bn extends Translations$onboarding$timeline$en {
	_Translations$onboarding$timeline$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সময়সীমা বাছুন';
	@override String canAfford({required Object amount, required Object months, required Object name}) => 'মাসে ${amount} সঞ্চয় করলে ${months} মাসে ${name} কিনতে পারবেন।';
	@override String cannotAfford({required Object amount}) => 'মাসে ${amount} সঞ্চয় দিয়ে এগুলো হবে না। আরও পরের একটি নিজস্ব তারিখ বাছুন।';
	@override String months({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n} মাস',
		other: '${n} মাস',
	);
	@override String perMonth({required Object amount}) => '${amount}/মাস';
	@override String get custom => 'নিজস্ব';
	@override String get customHint => 'নিজে ঠিক করুন';
	@override late final _Translations$onboarding$timeline$fit$bn fit = _Translations$onboarding$timeline$fit$bn._(_root);
}

// Path: onboarding.complete
class _Translations$onboarding$complete$bn extends Translations$onboarding$complete$en {
	_Translations$onboarding$complete$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সেটআপ সম্পন্ন!';
	@override String get budgets => 'বাজেট তৈরি হয়েছে';
	@override String recurring({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি নিয়মিত পেমেন্ট',
		other: '${n}টি নিয়মিত পেমেন্ট',
	);
	@override String goal({required Object name}) => 'সঞ্চয়ের লক্ষ্য: ${name}';
	@override String get tip => 'আপনি যেকোনো সময় বাজেট ও লক্ষ্য বদলাতে পারবেন।';
	@override String get finish => 'সেটআপ শেষ করুন';
	@override String get saving => 'আপনার সেটআপ সংরক্ষণ হচ্ছে…';
	@override String get partialFailure => 'কিছু আইটেম সংরক্ষণ করা যায়নি। পরে যোগ করতে পারবেন।';
}

// Path: onboarding.tutorial
class _Translations$onboarding$tutorial$bn extends Translations$onboarding$tutorial$en {
	_Translations$onboarding$tutorial$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$onboarding$tutorial$dashboard$bn dashboard = _Translations$onboarding$tutorial$dashboard$bn._(_root);
	@override late final _Translations$onboarding$tutorial$addTransaction$bn addTransaction = _Translations$onboarding$tutorial$addTransaction$bn._(_root);
	@override late final _Translations$onboarding$tutorial$reports$bn reports = _Translations$onboarding$tutorial$reports$bn._(_root);
	@override String pageOf({required Object current, required Object total}) => 'পৃষ্ঠা ${current}/${total}';
	@override late final _Translations$onboarding$tutorial$cta$bn cta = _Translations$onboarding$tutorial$cta$bn._(_root);
}

// Path: records.filter
class _Translations$records$filter$bn extends Translations$records$filter$en {
	_Translations$records$filter$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ফিল্টার';
	@override String get dateRange => 'তারিখের সীমা';
	@override String get type => 'ধরন';
	@override String get all => 'সব';
	@override String get categories => 'ক্যাটাগরি';
	@override String get clear => 'মুছুন';
	@override String get apply => 'প্রয়োগ করুন';
	@override String get noCategories => 'কোনো ক্যাটাগরি নেই';
	@override String get allCategories => 'সব ক্যাটাগরি';
	@override String allCount({required Object n}) => 'সব (${n})';
	@override String selectedCount({required Object n}) => '${n}টি বাছাই করা';
	@override String get selectDateRange => 'তারিখের সীমা বেছে নিন';
	@override String range({required Object start, required Object end}) => '${start} - ${end}';
}

// Path: records.list
class _Translations$records$list$bn extends Translations$records$list$en {
	_Translations$records$list$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'লেনদেন';
	@override String get subtitle => 'লেনদেনের ইতিহাস';
	@override String get filter => 'ফিল্টার';
	@override String get search => 'লেনদেন খুঁজুন';
	@override String get noMatches => 'আপনার খোঁজ বা ফিল্টারের সাথে মেলে এমন কোনো লেনদেন নেই।';
	@override String get empty => 'এখনো কোনো লেনদেন নেই';
	@override String get scrollForMore => 'আরও দেখতে স্ক্রল করুন';
	@override String get deleted => 'রেকর্ড মুছে ফেলা হয়েছে';
}

// Path: records.picker
class _Translations$records$picker$bn extends Translations$records$picker$en {
	_Translations$records$picker$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ক্যাটাগরি বেছে নিন';
	@override String get search => 'ক্যাটাগরি খুঁজুন';
	@override String get noneFound => 'কোনো ক্যাটাগরি পাওয়া যায়নি';
	@override String get addCategory => 'ক্যাটাগরি যোগ করুন';
}

// Path: records.sheet
class _Translations$records$sheet$bn extends Translations$records$sheet$en {
	_Translations$records$sheet$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$records$sheet$placeholders$bn placeholders = _Translations$records$sheet$placeholders$bn._(_root);
	@override String get enterAmount => 'একটি পরিমাণ লিখুন';
	@override String get nameHintExpense => 'নাম, যেমন: দুপুরের খাবার';
	@override String get nameHintIncome => 'নাম, যেমন: বেতন';
	@override String get nameRequired => 'একটি নাম দিন';
	@override String get scanReceipt => 'রসিদ স্ক্যান করুন';
	@override String get noBudget => 'কোনো বাজেট নয়';
	@override String budgetOption({required Object name, required Object period}) => '${name} · ${period}';
	@override String get previousBudget => 'আগের বাজেট (এখন আর চালু নেই)';
	@override String get loadingBudgets => 'বাজেট লোড হচ্ছে…';
	@override String get noCategories => 'কোনো ক্যাটাগরি নেই';
	@override String get selectCategory => 'একটি ক্যাটাগরি বেছে নিন';
	@override String get showAllCategories => 'সব ক্যাটাগরি দেখুন';
	@override String get showAllBudgets => 'সব বাজেট দেখুন';
	@override String get repeatMonthly => 'প্রতি মাসে পুনরাবৃত্তি';
	@override String get addIncome => 'আয় যোগ করুন';
	@override String get deleteExpense => 'খরচ মুছুন';
	@override String get deleteIncome => 'আয় মুছুন';
	@override String get deleteExpenseTitle => 'এই খরচটি মুছবেন?';
	@override String get deleteIncomeTitle => 'এই আয়টি মুছবেন?';
	@override String get cannotUndo => 'এটি আর ফেরানো যাবে না।';
	@override String get repeatFailed => 'সংরক্ষণ হয়েছে, কিন্তু পুনরাবৃত্তি চালু করা যায়নি। সেটিংস → পুনরাবৃত্ত থেকে সেট আপ করুন।';
	@override String get typeToggle => 'লেনদেনের ধরন';
	@override String get backspace => 'মুছুন';
	@override String get decimalKey => 'দশমিক';
}

// Path: recurring.sections
class _Translations$recurring$sections$bn extends Translations$recurring$sections$en {
	_Translations$recurring$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get defaultFrequency => 'ডিফল্ট পুনরাবৃত্তি';
	@override String get autoCreate => 'নিজে থেকে তৈরি';
	@override String get active => 'সক্রিয় পুনরাবৃত্ত';
}

// Path: recurring.defaults
class _Translations$recurring$defaults$bn extends Translations$recurring$defaults$en {
	_Translations$recurring$defaults$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get weeklyDetail => 'প্রতি 7 দিনে';
	@override String get monthlyDetail => 'প্রতি মাসে একই তারিখে';
	@override String get yearlyDetail => 'প্রতি বছর একই তারিখে';
	@override String get autoCreate => 'নিজে থেকে লেনদেন তৈরি';
	@override String get autoCreateDetail => 'অ্যাপ খুললে বকেয়া লেনদেন যোগ করুন';
}

// Path: recurring.empty
class _Translations$recurring$empty$bn extends Translations$recurring$empty$en {
	_Translations$recurring$empty$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'কোনো পুনরাবৃত্ত লেনদেন নেই';
	@override String get body => 'প্রথম পুনরাবৃত্ত খরচ তৈরি করতে + চাপুন';
}

// Path: recurring.delete
class _Translations$recurring$delete$bn extends Translations$recurring$delete$en {
	_Translations$recurring$delete$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পুনরাবৃত্ত লেনদেন মুছুন';
	@override String confirm({required Object name}) => 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান?';
}

// Path: recurring.form
class _Translations$recurring$form$bn extends Translations$recurring$form$en {
	_Translations$recurring$form$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get edit => 'পুনরাবৃত্ত সম্পাদনা';
	@override String get amount => 'পরিমাণ';
	@override String get name => 'নাম';
	@override String get nameHint => 'এই পুনরাবৃত্ত খরচটি কিসের জন্য?';
	@override String get frequency => 'কত দিন পরপর';
	@override String get startDate => 'শুরুর তারিখ';
	@override String get endDate => 'শেষের তারিখ (ঐচ্ছিক)';
	@override String get noEndDate => 'শেষের তারিখ নেই';
	@override String get clearEndDate => 'শেষের তারিখ মুছুন';
	@override String get autoCreate => 'নিজে থেকে তৈরিতে রাখুন';
	@override String get autoCreateDetail => '‘নিজে থেকে তৈরি’ চালু থাকলে অ্যাপ খুললে যোগ হবে';
	@override String get active => 'চালু';
	@override String get activeDetail => 'এই পুনরাবৃত্ত লেনদেনটি প্রসেস করুন';
	@override String get amountRequired => 'একটি পরিমাণ লিখুন';
	@override String get amountInvalid => 'সঠিক সংখ্যা লিখুন';
	@override String get nameRequired => 'একটি নাম লিখুন';
	@override String get create => 'নতুন পুনরাবৃত্ত';
}

// Path: reports.insights
class _Translations$reports$insights$bn extends Translations$reports$insights$en {
	_Translations$reports$insights$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$reports$insights$highestDay$bn highestDay = _Translations$reports$insights$highestDay$bn._(_root);
	@override late final _Translations$reports$insights$topCategory$bn topCategory = _Translations$reports$insights$topCategory$bn._(_root);
	@override late final _Translations$reports$insights$bestWeek$bn bestWeek = _Translations$reports$insights$bestWeek$bn._(_root);
	@override late final _Translations$reports$insights$recurring$bn recurring = _Translations$reports$insights$recurring$bn._(_root);
	@override late final _Translations$reports$insights$budgets$bn budgets = _Translations$reports$insights$budgets$bn._(_root);
}

// Path: reports.metrics
class _Translations$reports$metrics$bn extends Translations$reports$metrics$en {
	_Translations$reports$metrics$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get totalSpent => 'মোট খরচ';
	@override String get dailyAverage => 'দৈনিক গড়';
	@override String get highestDay => 'সর্বোচ্চ দিন';
}

// Path: settings.language
class _Translations$settings$language$bn extends Translations$settings$language$en {
	_Translations$settings$language$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ভাষা';
	@override late final _Translations$settings$language$sections$bn sections = _Translations$settings$language$sections$bn._(_root);
	@override String get matchDevice => 'ডিভাইসের মতো';
	@override String get matchDeviceSubtitle => 'ফোনের ভাষা ব্যবহার করুন';
	@override late final _Translations$settings$language$names$bn names = _Translations$settings$language$names$bn._(_root);
}

// Path: settings.sections
class _Translations$settings$sections$bn extends Translations$settings$sections$en {
	_Translations$settings$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get preferences => 'পছন্দ';
	@override String get automation => 'স্বয়ংক্রিয়';
	@override String get support => 'সহায়তা';
	@override String get account => 'প্রোফাইল ও অ্যাকাউন্ট';
	@override String get notifications => 'নোটিফিকেশন';
	@override String get dataBudget => 'ডেটা ও বাজেট';
	@override String get general => 'সাধারণ';
}

// Path: settings.notifications
class _Translations$settings$notifications$bn extends Translations$settings$notifications$en {
	_Translations$settings$notifications$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'নোটিফিকেশন';
	@override String rowSubtitle({required Object total, required Object n}) => '${total}টির মধ্যে ${n}টি চালু';
	@override String get rowSubtitleOff => 'বন্ধ';
	@override late final _Translations$settings$notifications$sections$bn sections = _Translations$settings$notifications$sections$bn._(_root);
	@override late final _Translations$settings$notifications$master$bn master = _Translations$settings$notifications$master$bn._(_root);
	@override late final _Translations$settings$notifications$blocked$bn blocked = _Translations$settings$notifications$blocked$bn._(_root);
	@override late final _Translations$settings$notifications$over$bn over = _Translations$settings$notifications$over$bn._(_root);
	@override late final _Translations$settings$notifications$nearLimit$bn nearLimit = _Translations$settings$notifications$nearLimit$bn._(_root);
	@override late final _Translations$settings$notifications$weekly$bn weekly = _Translations$settings$notifications$weekly$bn._(_root);
	@override late final _Translations$settings$notifications$reminders$bn reminders = _Translations$settings$notifications$reminders$bn._(_root);
	@override late final _Translations$settings$notifications$autoImport$bn autoImport = _Translations$settings$notifications$autoImport$bn._(_root);
}

// Path: settings.recurring
class _Translations$settings$recurring$bn extends Translations$settings$recurring$en {
	_Translations$settings$recurring$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পুনরাবৃত্ত লেনদেন';
	@override String get subtitle => 'নিয়মিত আসা বিল ও আয়';
}

// Path: settings.help
class _Translations$settings$help$bn extends Translations$settings$help$en {
	_Translations$settings$help$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সাহায্য ও সহায়তা';
	@override String get rowSubtitle => 'প্রশ্নোত্তর, যোগাযোগ, রেটিং, আইনি তথ্য';
}

// Path: settings.crashReports
class _Translations$settings$crashReports$bn extends Translations$settings$crashReports$en {
	_Translations$settings$crashReports$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ক্র্যাশ রিপোর্ট পাঠান';
	@override String get subtitle => 'শুধু ত্রুটির তথ্য। টাকার অঙ্ক, নম্বর ও SMS-এর লেখা বাদ দেওয়া হয়।';
}

// Path: settings.signIn
class _Translations$settings$signIn$bn extends Translations$settings$signIn$en {
	_Translations$settings$signIn$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সাইন ইন';
	@override String get subtitle => 'আপনার সব ডিভাইসে ডেটা রাখুন';
}

// Path: settings.profile
class _Translations$settings$profile$bn extends Translations$settings$profile$en {
	_Translations$settings$profile$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'আমার প্রোফাইল';
	@override String get rowSubtitle => 'আপনার Google অ্যাকাউন্ট';
	@override String get nameLabel => 'নাম';
	@override String get emailLabel => 'ইমেইল';
	@override String get noName => 'এই Google অ্যাকাউন্টে কোনো নাম নেই';
	@override String get signedInWith => 'Google দিয়ে সাইন ইন করা';
	@override String get googleNote => 'আপনার নাম ও ছবি Google অ্যাকাউন্ট থেকে আসে। সেখানে পরিবর্তন করুন।';
	@override String get deletingAccount => 'আপনার অ্যাকাউন্ট মুছে ফেলা হচ্ছে…';
	@override String get accountDeleted => 'আপনার অ্যাকাউন্ট মুছে ফেলা হয়েছে';
	@override String get signedOutTitle => 'আপনি সাইন ইন করেননি';
	@override String get signedOutBody => 'সব ডিভাইসে আপনার লেনদেন রাখতে Google দিয়ে সাইন ইন করুন।';
	@override String get guestName => 'অতিথি';
	@override String get guestSubtitle => 'ডেটা সিঙ্ক করতে সাইন ইন করুন';
}

// Path: settings.deleteDialog
class _Translations$settings$deleteDialog$bn extends Translations$settings$deleteDialog$en {
	_Translations$settings$deleteDialog$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'অ্যাকাউন্ট মুছুন';
	@override String get question => 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট মুছে ফেলতে চান?';
	@override String get listTitle => 'আপনার অ্যাকাউন্ট ও এই ফোন থেকে স্থায়ীভাবে মুছে যাবে:';
	@override String get transactions => '• আপনার সব লেনদেন';
	@override String get categories => '• আপনার সব ক্যাটাগরি';
	@override String get budgets => '• আপনার সব বাজেট';
	@override String get recurring => '• আপনার সব পুনরাবৃত্ত লেনদেন';
	@override String get rules => '• আপনার সব মিলানোর নিয়ম';
	@override String get cannotUndo => 'এটি আর ফেরানো যাবে না।';
	@override String get confirm => 'আমি বুঝেছি এবং আমার অ্যাকাউন্ট মুছতে চাই';
}

// Path: settings.appearanceScreen
class _Translations$settings$appearanceScreen$bn extends Translations$settings$appearanceScreen$en {
	_Translations$settings$appearanceScreen$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$settings$appearanceScreen$sections$bn sections = _Translations$settings$appearanceScreen$sections$bn._(_root);
	@override String get lightTitle => 'লাইট মোড প্রিভিউ';
	@override String get lightBody => 'নরম ল্যাভেন্ডার রঙের ছোঁয়ায় পরিষ্কার, উজ্জ্বল ইন্টারফেস।';
	@override String get darkTitle => 'ডার্ক মোড প্রিভিউ';
	@override String get darkBody => 'শান্ত, মনোযোগী অভিজ্ঞতার জন্য গাঢ় চারকোল পটভূমি আর ল্যাভেন্ডার রং।';
}

// Path: settings.currencyScreen
class _Translations$settings$currencyScreen$bn extends Translations$settings$currencyScreen$en {
	_Translations$settings$currencyScreen$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get searchHint => 'মুদ্রা খুঁজুন';
	@override String noResults({required Object query}) => '"${query}"-এর সাথে মেলে এমন কোনো মুদ্রা নেই';
}

// Path: settings.numberFormat
class _Translations$settings$numberFormat$bn extends Translations$settings$numberFormat$en {
	_Translations$settings$numberFormat$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সংখ্যার ফরম্যাট';
	@override late final _Translations$settings$numberFormat$sections$bn sections = _Translations$settings$numberFormat$sections$bn._(_root);
	@override late final _Translations$settings$numberFormat$places$bn places = _Translations$settings$numberFormat$places$bn._(_root);
}

// Path: settings.fontSize
class _Translations$settings$fontSize$bn extends Translations$settings$fontSize$en {
	_Translations$settings$fontSize$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'লেখার আকার';
	@override String get sampleTitle => 'নমুনা লেনদেন';
	@override String get sampleBody => 'বেছে নেওয়া আকারে আপনার লেনদেন এভাবে দেখাবে।';
	@override late final _Translations$settings$fontSize$sections$bn sections = _Translations$settings$fontSize$sections$bn._(_root);
}

// Path: settings.calendar
class _Translations$settings$calendar$bn extends Translations$settings$calendar$en {
	_Translations$settings$calendar$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ক্যালেন্ডার';
	@override String rowSubtitle({required Object day}) => 'সপ্তাহ শুরু ${day}';
	@override late final _Translations$settings$calendar$sections$bn sections = _Translations$settings$calendar$sections$bn._(_root);
}

// Path: settings.homePage
class _Translations$settings$homePage$bn extends Translations$settings$homePage$en {
	_Translations$settings$homePage$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'হোম পেজ';
	@override String get intro => 'অ্যাপ খুললে কোন স্ক্রিন দেখাবে তা বেছে নিন';
	@override late final _Translations$settings$homePage$sections$bn sections = _Translations$settings$homePage$sections$bn._(_root);
	@override late final _Translations$settings$homePage$options$bn options = _Translations$settings$homePage$options$bn._(_root);
}

// Path: settings.sync
class _Translations$settings$sync$bn extends Translations$settings$sync$en {
	_Translations$settings$sync$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সিঙ্ক';
	@override String get rowSubtitle => 'আপনার সব ডিভাইসে ডেটা রাখুন';
	@override String get onTitle => 'সিঙ্ক চালু আছে';
	@override String get onBody => 'আপনার লেনদেন, বাজেট ও ক্যাটাগরি সাথে সাথে আপনার অ্যাকাউন্টে কপি হয়, তাই অন্য ডিভাইসেও পাবেন।';
	@override String get offTitle => 'সিঙ্ক বন্ধ';
	@override String get offBody => 'এই ডিভাইস কোনো পরিবর্তন পাঠাচ্ছে না বা পাচ্ছে না। পরিবর্তনগুলো এই ফোনে থাকবে এবং সিঙ্ক আবার চালু করলে পাঠানো হবে।';
	@override String get signedOutTitle => 'আপনার ডেটা সিঙ্ক করুন';
	@override String get signedOutBody => 'সব ডিভাইসে আপনার লেনদেন রাখতে Google দিয়ে সাইন ইন করুন।';
	@override String get lastSynced => 'শেষ সিঙ্ক';
	@override String get never => 'এখনও হয়নি';
	@override String today({required Object time}) => 'আজ, ${time}';
	@override String yesterday({required Object time}) => 'গতকাল, ${time}';
	@override String lastFailed({required Object time}) => 'শেষ সিঙ্ক ব্যর্থ · ${time}';
	@override String get retry => 'আবার চেষ্টা করুন';
	@override String get failureBannerTitle => 'সিঙ্ক এখন কাজ করছে না';
	@override String get failureBannerBody => 'আপনার পরিবর্তনগুলো এই ফোনে নিরাপদ আছে এবং সিঙ্ক আবার কাজ করলে পাঠানো হবে।';
	@override String pending({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি পরিবর্তন পাঠানোর অপেক্ষায়',
		other: '${n}টি পরিবর্তন পাঠানোর অপেক্ষায়',
	);
	@override String get allSent => 'সব পরিবর্তন পাঠানো হয়েছে';
	@override String failed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি পরিবর্তন সিঙ্ক হয়নি',
		other: '${n}টি পরিবর্তন সিঙ্ক হয়নি',
	);
	@override late final _Translations$settings$sync$sections$bn sections = _Translations$settings$sync$sections$bn._(_root);
	@override String get enable => 'এই ডিভাইসে সিঙ্ক';
	@override String get syncNow => 'এখনই সিঙ্ক করুন';
	@override String get syncing => 'সিঙ্ক হচ্ছে…';
	@override String get loadFailed => 'সিঙ্কের অবস্থা দেখানো যায়নি';
	@override late final _Translations$settings$sync$result$bn result = _Translations$settings$sync$result$bn._(_root);
}

// Path: settings.export
class _Translations$settings$export$bn extends Translations$settings$export$en {
	_Translations$settings$export$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ডেটা এক্সপোর্ট';
	@override String get rowSubtitle => 'আপনার লেনদেন CSV ফাইলে সংরক্ষণ করুন';
	@override String get infoTitle => 'আপনার আর্থিক ডেটা এক্সপোর্ট করুন';
	@override String get infoBody => 'স্প্রেডশিট বা হিসাব সফটওয়্যারে ব্যবহারের জন্য আপনার লেনদেন, বাজেট ও ক্যাটাগরি CSV ফাইলে সংরক্ষণ করুন।';
	@override late final _Translations$settings$export$sections$bn sections = _Translations$settings$export$sections$bn._(_root);
	@override late final _Translations$settings$export$ranges$bn ranges = _Translations$settings$export$ranges$bn._(_root);
	@override late final _Translations$settings$export$include$bn include = _Translations$settings$export$include$bn._(_root);
	@override String get rangeNote => 'তারিখের সীমা শুধু লেনদেনে প্রযোজ্য। বাজেট ও ক্যাটাগরি সম্পূর্ণ এক্সপোর্ট হয়।';
	@override String get button => 'ডেটা এক্সপোর্ট';
	@override String get exporting => 'এক্সপোর্ট তৈরি হচ্ছে…';
	@override String get shareSubject => 'Expenzo এক্সপোর্ট';
	@override String get nothingSelected => 'এক্সপোর্টের জন্য অন্তত একটি বেছে নিন';
	@override String get emptyRange => 'এই সময়সীমায় কোনো লেনদেন নেই';
}

// Path: settings.deleteData
class _Translations$settings$deleteData$bn extends Translations$settings$deleteData$en {
	_Translations$settings$deleteData$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সব ডেটা মুছুন';
	@override String get rowSubtitle => 'লেনদেন, বাজেট ও সেটিংস মুছে ফেলুন';
	@override String get warningTitle => 'এই কাজ আর ফেরানো যাবে না';
	@override String get warningBody => 'লেনদেন, বাজেট, ক্যাটাগরি ও সেটিংসসহ আপনার সব আর্থিক ডেটা মুছে যাবে। এই ডিভাইস থেকে সবকিছু স্থায়ীভাবে মুছে যাবে।';
	@override String get warningBodySignedIn => 'লেনদেন, বাজেট, ক্যাটাগরি ও সেটিংসসহ আপনার সব আর্থিক ডেটা এই ডিভাইস ও আপনার অ্যাকাউন্ট থেকে মুছে যাবে।';
	@override String get otherDevicesNote => 'আপনার অন্য ডিভাইসগুলোতে সেখানে না মোছা পর্যন্ত ডেটা থেকে যাবে।';
	@override late final _Translations$settings$deleteData$sections$bn sections = _Translations$settings$deleteData$sections$bn._(_root);
	@override String get transactions => 'লেনদেন';
	@override String transactionsCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি লেনদেন',
		other: '${n}টি লেনদেন',
	);
	@override String get budgets => 'বাজেট';
	@override String budgetsCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি বাজেট',
		other: '${n}টি বাজেট',
	);
	@override String get categories => 'ক্যাটাগরি';
	@override String categoriesCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি ক্যাটাগরি',
		other: '${n}টি ক্যাটাগরি',
	);
	@override String get recurring => 'পুনরাবৃত্ত লেনদেন';
	@override String recurringCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি পুনরাবৃত্ত',
		other: '${n}টি পুনরাবৃত্ত',
	);
	@override String get smsRules => 'SMS নিয়ম';
	@override String smsRulesCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি নিয়ম',
		other: '${n}টি নিয়ম',
	);
	@override String get goals => 'লক্ষ্য';
	@override String goalsCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি লক্ষ্য',
		other: '${n}টি লক্ষ্য',
	);
	@override String get settings => 'সেটিংস';
	@override String get settingsValue => 'সব পছন্দ';
	@override String get categoriesNote => 'ডিফল্ট ক্যাটাগরিগুলো আবার যোগ হবে।';
	@override String get confirmHint => 'নিশ্চিত করতে DELETE লিখুন';
	@override String get button => 'সব ডেটা মুছুন';
	@override String get deleting => 'মুছে ফেলা হচ্ছে…';
	@override String get done => 'সব ডেটা মুছে ফেলা হয়েছে';
	@override String get serverFailed => 'আপনার অ্যাকাউন্টের ডেটা মুছতে পারা যায়নি। কিছুই মোছা হয়নি। সংযোগ দেখে আবার চেষ্টা করুন।';
	@override String get familyAdminNote => 'আপনার তৈরি শেয়ার করা বাজেটগুলো আপনার পরিবারের জন্যও মুছে যাবে।';
}

// Path: settings.categories
class _Translations$settings$categories$bn extends Translations$settings$categories$en {
	_Translations$settings$categories$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get rowSubtitle => 'ক্যাটাগরি যোগ, সম্পাদনা ও মুছে ফেলুন';
}

// Path: settings.family
class _Translations$settings$family$bn extends Translations$settings$family$en {
	_Translations$settings$family$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পারিবারিক গ্রুপ';
	@override String get rowSubtitle => 'পরিবারের সাথে বাজেট শেয়ার করুন';
	@override late final _Translations$settings$family$sections$bn sections = _Translations$settings$family$sections$bn._(_root);
}

// Path: shell.tabs
class _Translations$shell$tabs$bn extends Translations$shell$tabs$en {
	_Translations$shell$tabs$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get home => 'হোম';
	@override String get activity => 'লেনদেন';
	@override String get budgets => 'বাজেট';
	@override String get reports => 'রিপোর্ট';
}

// Path: shell.reportsTabs
class _Translations$shell$reportsTabs$bn extends Translations$shell$reportsTabs$en {
	_Translations$shell$reportsTabs$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get trend => 'প্রবণতা';
	@override String get categories => 'ক্যাটাগরি';
	@override String get insights => 'বিশ্লেষণ';
}

// Path: smsParser.range
class _Translations$smsParser$range$bn extends Translations$smsParser$range$en {
	_Translations$smsParser$range$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get last7Days => 'গত 7 দিন';
	@override String get last30Days => 'গত 30 দিন';
	@override String get last3Months => 'গত 3 মাস';
	@override String get allTime => 'সব সময়';
	@override String get custom => 'নির্দিষ্ট তারিখের সীমা';
	@override String from({required Object date}) => '${date} থেকে';
	@override String until({required Object date}) => '${date} পর্যন্ত';
	@override String get selectDate => 'তারিখ বেছে নিন';
}

// Path: smsParser.summary
class _Translations$smsParser$summary$bn extends Translations$smsParser$summary$en {
	_Translations$smsParser$summary$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get range => 'সময়সীমা';
	@override String get matches => 'মিলেছে';
	@override String get selected => 'বাছাই করা';
}

// Path: smsParser.card
class _Translations$smsParser$card$bn extends Translations$smsParser$card$en {
	_Translations$smsParser$card$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String rule({required Object id}) => 'নিয়ম: ${id}';
	@override String get noAmount => 'পরিমাণ নেই';
}

// Path: smsParser.options
class _Translations$smsParser$options$bn extends Translations$smsParser$options$en {
	_Translations$smsParser$options$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'রেকর্ডের জন্য পুরোনো SMS স্ক্যান করুন';
}

// Path: smsParser.toolbar
class _Translations$smsParser$toolbar$bn extends Translations$smsParser$toolbar$en {
	_Translations$smsParser$toolbar$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get sender => 'প্রেরক';
	@override String get flatList => 'সাধারণ তালিকা';
	@override String get clear => 'মুছুন';
}

// Path: smsParser.section
class _Translations$smsParser$section$bn extends Translations$smsParser$section$en {
	_Translations$smsParser$section$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get selectAll => 'সব বাছাই করুন';
	@override String get clear => 'মুছুন';
	@override String counts({required num n, required Object selected}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: '${n}টি মেসেজ · ${selected}টি বাছাই করা',
		other: '${n}টি মেসেজ · ${selected}টি বাছাই করা',
	);
}

// Path: smsParser.customRange
class _Translations$smsParser$customRange$bn extends Translations$smsParser$customRange$en {
	_Translations$smsParser$customRange$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'নিজের মতো সময়সীমা বেছে নিন';
	@override String get body => 'পুরোনো SMS স্ক্যান করার আগে শুরু ও শেষের তারিখ বেছে নিন।';
	@override String get start => 'শুরুর তারিখ';
	@override String get end => 'শেষের তারিখ';
	@override String get invalid => 'সঠিক শুরু ও শেষের তারিখ বেছে নিন।';
	@override String get apply => 'প্রয়োগ করুন';
}

// Path: smsParser.results
class _Translations$smsParser$results$bn extends Translations$smsParser$results$en {
	_Translations$smsParser$results$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'স্ক্যানের ফলাফল';
	@override String get empty => 'নতুন কোনো রেকর্ড পাওয়া যায়নি';
	@override String get emptyBody => 'আবার স্ক্যান করুন অথবা আরও মিলানোর নিয়ম যোগ করুন';
	@override String create({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n,
		one: 'বাছাই করা ${n}টি রেকর্ড যোগ করুন',
		other: 'বাছাই করা ${n}টি রেকর্ড যোগ করুন',
	);
}

// Path: smsParser.autoImport
class _Translations$smsParser$autoImport$bn extends Translations$smsParser$autoImport$en {
	_Translations$smsParser$autoImport$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get scanPast => 'পুরোনো SMS স্ক্যান করুন';
}

// Path: support.help
class _Translations$support$help$bn extends Translations$support$help$en {
	_Translations$support$help$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get watchTutorial => 'টিউটোরিয়াল দেখুন';
	@override late final _Translations$support$help$replaySetup$bn replaySetup = _Translations$support$help$replaySetup$bn._(_root);
	@override String get title => 'সাহায্য ও সহায়তা';
	@override String get faq => 'সাধারণ প্রশ্ন';
	@override String get contactSupport => 'সহায়তার জন্য যোগাযোগ';
	@override String get rateApp => 'অ্যাপটি রেট করুন';
	@override String get privacyPolicy => 'গোপনীয়তা নীতি';
	@override String get termsOfService => 'পরিষেবার শর্তাবলি';
	@override String get about => 'সম্পর্কে';
	@override String get linkFailed => 'পেজটি খোলা যায়নি। পরে আবার চেষ্টা করুন।';
}

// Path: support.about
class _Translations$support$about$bn extends Translations$support$about$en {
	_Translations$support$about$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Expenzo সম্পর্কে';
	@override String version({required Object version, required Object build}) => 'সংস্করণ ${version} (${build})';
	@override String get description => 'Expenzo আপনার খরচ, বাজেট ও নিয়মিত বিল ট্র্যাক করে, এবং ব্যাংকের SMS পড়ে আপনার হয়ে লেনদেন লিখে রাখতে পারে।';
	@override String get madeBy => 'তৈরি করেছে Acesif Labs';
}

// Path: support.faq
class _Translations$support$faq$bn extends Translations$support$faq$en {
	_Translations$support$faq$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সাধারণ প্রশ্ন';
	@override String get searchHint => 'প্রশ্ন খুঁজুন...';
	@override String noResults({required Object query}) => '"${query}"-এর সাথে কোনো প্রশ্ন মেলেনি।';
	@override late final _Translations$support$faq$addTransaction$bn addTransaction = _Translations$support$faq$addTransaction$bn._(_root);
	@override late final _Translations$support$faq$autoImport$bn autoImport = _Translations$support$faq$autoImport$bn._(_root);
	@override late final _Translations$support$faq$budget$bn budget = _Translations$support$faq$budget$bn._(_root);
	@override late final _Translations$support$faq$recurring$bn recurring = _Translations$support$faq$recurring$bn._(_root);
	@override late final _Translations$support$faq$export$bn export = _Translations$support$faq$export$bn._(_root);
	@override late final _Translations$support$faq$sync$bn sync = _Translations$support$faq$sync$bn._(_root);
	@override late final _Translations$support$faq$aiAssistant$bn aiAssistant = _Translations$support$faq$aiAssistant$bn._(_root);
	@override late final _Translations$support$faq$currency$bn currency = _Translations$support$faq$currency$bn._(_root);
}

// Path: support.rate
class _Translations$support$rate$bn extends Translations$support$rate$en {
	_Translations$support$rate$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Expenzo ভালো লাগছে?';
	@override String get heading => 'Expenzo উপভোগ করছেন?';
	@override String get subtitle => 'আপনার মতামত আমাদের আরও ভালো করতে সাহায্য করে। অ্যাপটি রেট করতে একটি তারায় ট্যাপ করুন।';
	@override String get writeReview => 'রিভিউ লিখুন';
	@override String get tellUs => 'কী ভালো করা দরকার জানান';
	@override String get maybeLater => 'পরে দেখব';
	@override String get noThanks => 'না, ধন্যবাদ';
	@override String starLabel({required Object n}) => '5টির মধ্যে ${n}টি তারা';
}

// Path: budgets.details.periodBudget
class _Translations$budgets$details$periodBudget$bn extends Translations$budgets$details$periodBudget$en {
	_Translations$budgets$details$periodBudget$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get weekly => 'সাপ্তাহিক বাজেট';
	@override String get monthly => 'মাসিক বাজেট';
	@override String get yearly => 'বার্ষিক বাজেট';
}

// Path: budgets.plan.names
class _Translations$budgets$plan$names$bn extends Translations$budgets$plan$names$en {
	_Translations$budgets$plan$names$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get needs => 'প্রয়োজন';
	@override String get wants => 'চাহিদা';
	@override String get savings => 'সঞ্চয়';
}

// Path: categories.settings.sections
class _Translations$categories$settings$sections$bn extends Translations$categories$settings$sections$en {
	_Translations$categories$settings$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get expense => 'খরচের ক্যাটাগরি';
	@override String get income => 'আয়ের ক্যাটাগরি';
}

// Path: dashboard.range.net
class _Translations$dashboard$range$net$bn extends Translations$dashboard$range$net$en {
	_Translations$dashboard$range$net$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get thisMonth => 'এই মাসের নিট';
	@override String get lastMonth => 'গত মাসের নিট';
	@override String get thisYear => 'এই বছরের নিট';
}

// Path: dashboard.range.previous
class _Translations$dashboard$range$previous$bn extends Translations$dashboard$range$previous$en {
	_Translations$dashboard$range$previous$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get thisMonth => 'গত মাস';
	@override String get lastMonth => 'তার আগের মাস';
	@override String get thisYear => 'গত বছর';
}

// Path: enums.fontSize.small
class _Translations$enums$fontSize$small$bn extends Translations$enums$fontSize$small$en {
	_Translations$enums$fontSize$small$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'ছোট';
	@override String get description => 'ঘন সাজানো, স্ক্রিনে বেশি তথ্য';
}

// Path: enums.fontSize.medium
class _Translations$enums$fontSize$medium$bn extends Translations$enums$fontSize$medium$en {
	_Translations$enums$fontSize$medium$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'মাঝারি';
	@override String get description => 'প্রতিদিনের ব্যবহারের জন্য';
}

// Path: enums.fontSize.large
class _Translations$enums$fontSize$large$bn extends Translations$enums$fontSize$large$en {
	_Translations$enums$fontSize$large$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বড়';
	@override String get description => 'পড়তে সহজ বড় লেখা';
}

// Path: enums.fontSize.extraLarge
class _Translations$enums$fontSize$extraLarge$bn extends Translations$enums$fontSize$extraLarge$en {
	_Translations$enums$fontSize$extraLarge$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'অনেক বড়';
	@override String get description => 'সহজে দেখার জন্য সবচেয়ে বড়';
}

// Path: onboarding.income.frequency
class _Translations$onboarding$income$frequency$bn extends Translations$onboarding$income$frequency$en {
	_Translations$onboarding$income$frequency$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get monthly => 'মাসিক';
	@override String get biWeekly => 'দুই সপ্তাহ পরপর';
	@override String get weekly => 'সাপ্তাহিক';
}

// Path: onboarding.recurring.sheet
class _Translations$onboarding$recurring$sheet$bn extends Translations$onboarding$recurring$sheet$en {
	_Translations$onboarding$recurring$sheet$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'নিয়মিত পেমেন্ট';
	@override String get name => 'নাম';
	@override String get nameHint => 'যেমন: ভাড়া';
	@override String get amount => 'পরিমাণ';
	@override String get frequency => 'পুনরাবৃত্তি';
}

// Path: onboarding.timeline.fit
class _Translations$onboarding$timeline$fit$bn extends Translations$onboarding$timeline$fit$en {
	_Translations$onboarding$timeline$fit$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get affordable => 'আপনার সঞ্চয়ে হবে';
	@override String get tooExpensive => 'আপনার সঞ্চয়ের চেয়ে বেশি';
	@override String get slow => 'অনেক সময় লাগবে';
}

// Path: onboarding.tutorial.dashboard
class _Translations$onboarding$tutorial$dashboard$bn extends Translations$onboarding$tutorial$dashboard$en {
	_Translations$onboarding$tutorial$dashboard$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'এক নজরে আপনার টাকা';
	@override String get body => 'হোমে এই মাসের নিট হিসাব, বাজেট ও সাম্প্রতিক লেনদেন দেখা যায়।';
}

// Path: onboarding.tutorial.addTransaction
class _Translations$onboarding$tutorial$addTransaction$bn extends Translations$onboarding$tutorial$addTransaction$en {
	_Translations$onboarding$tutorial$addTransaction$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'কয়েক সেকেন্ডে লেনদেন যোগ করুন';
	@override String get body => 'যেকোনো ট্যাবে + চাপুন, পরিমাণ লিখুন এবং একটি ক্যাটাগরি বাছুন।';
}

// Path: onboarding.tutorial.reports
class _Translations$onboarding$tutorial$reports$bn extends Translations$onboarding$tutorial$reports$en {
	_Translations$onboarding$tutorial$reports$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'দেখুন টাকা কোথায় যায়';
	@override String get body => 'রিপোর্টে ট্রেন্ড, ক্যাটাগরি ও বিশ্লেষণ দেখা যায়।';
}

// Path: onboarding.tutorial.cta
class _Translations$onboarding$tutorial$cta$bn extends Translations$onboarding$tutorial$cta$en {
	_Translations$onboarding$tutorial$cta$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সব প্রস্তুত!';
	@override String get body => 'আপনি এখন মূল বিষয়গুলো জানেন। চলুন আপনার আর্থিক হিসাব রাখা শুরু করি!';
	@override String get start => 'চলুন শুরু করি!';
}

// Path: records.sheet.placeholders
class _Translations$records$sheet$placeholders$bn extends Translations$records$sheet$placeholders$en {
	_Translations$records$sheet$placeholders$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override List<String> get expense => [
		'বাজার-সদাই',
		'অফিসে উবার',
		'সহকর্মীর সাথে দুপুরের খাবার',
		'নেটফ্লিক্স সাবস্ক্রিপশন',
		'বিদ্যুৎ বিল',
		'পেট্রোল পাম্প',
	];
	@override List<String> get income => [
		'বেতন',
		'ফ্রিল্যান্স পেমেন্ট',
		'বাড়তি আয়',
		'ফেরত',
		'বোনাস',
		'বিনিয়োগের লভ্যাংশ',
	];
}

// Path: reports.insights.highestDay
class _Translations$reports$insights$highestDay$bn extends Translations$reports$insights$highestDay$en {
	_Translations$reports$insights$highestDay$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সবচেয়ে বেশি খরচের দিন';
	@override String description({required Object day, required Object percent}) => '${day} আপনার সবচেয়ে বেশি খরচের দিন, দৈনিক গড়ের চেয়ে ${percent}% বেশি।';
}

// Path: reports.insights.topCategory
class _Translations$reports$insights$topCategory$bn extends Translations$reports$insights$topCategory$en {
	_Translations$reports$insights$topCategory$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সবচেয়ে বেশি খরচের ক্যাটাগরি';
	@override String description({required Object percent, required Object category}) => 'আপনার খরচের ${percent}% ${category}-এ।';
}

// Path: reports.insights.bestWeek
class _Translations$reports$insights$bestWeek$bn extends Translations$reports$insights$bestWeek$en {
	_Translations$reports$insights$bestWeek$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সবচেয়ে সাশ্রয়ী সপ্তাহ';
	@override String description({required Object range}) => '${range} ছিল আপনার সবচেয়ে কম খরচের সপ্তাহ।';
}

// Path: reports.insights.recurring
class _Translations$reports$insights$recurring$bn extends Translations$reports$insights$recurring$en {
	_Translations$reports$insights$recurring$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পুনরাবৃত্ত খরচ';
	@override String get description => 'আসন্ন খরচের জন্য আপনার পুনরাবৃত্ত লেনদেনগুলো দেখুন।';
}

// Path: reports.insights.budgets
class _Translations$reports$insights$budgets$bn extends Translations$reports$insights$budgets$en {
	_Translations$reports$insights$budgets$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেটের অবস্থা';
	@override String get description => 'এই মাসে ঠিক পথে থাকতে আপনার বাজেটগুলো দেখুন।';
}

// Path: settings.language.sections
class _Translations$settings$language$sections$bn extends Translations$settings$language$sections$en {
	_Translations$settings$language$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get appLanguage => 'অ্যাপের ভাষা';
}

// Path: settings.language.names
class _Translations$settings$language$names$bn extends Translations$settings$language$names$en {
	_Translations$settings$language$names$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get en => 'ইংরেজি';
	@override String get bn => 'বাংলা';
}

// Path: settings.notifications.sections
class _Translations$settings$notifications$sections$bn extends Translations$settings$notifications$sections$en {
	_Translations$settings$notifications$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get general => 'সাধারণ';
	@override String get budgetAlerts => 'বাজেট সতর্কতা';
	@override String get recurring => 'পুনরাবৃত্ত লেনদেন';
	@override String get autoImport => 'স্বয়ংক্রিয় ইমপোর্ট';
}

// Path: settings.notifications.master
class _Translations$settings$notifications$master$bn extends Translations$settings$notifications$master$en {
	_Translations$settings$notifications$master$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'নোটিফিকেশন চালু রাখুন';
	@override String get subtitle => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ, রিমাইন্ডার ও স্বয়ংক্রিয় ইমপোর্ট';
}

// Path: settings.notifications.blocked
class _Translations$settings$notifications$blocked$bn extends Translations$settings$notifications$blocked$en {
	_Translations$settings$notifications$blocked$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'নোটিফিকেশন বন্ধ করা আছে';
	@override String get action => 'সেটিংস খুলুন';
}

// Path: settings.notifications.over
class _Translations$settings$notifications$over$bn extends Translations$settings$notifications$over$en {
	_Translations$settings$notifications$over$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেট ছাড়ানোর সতর্কতা';
	@override String get subtitle => 'খরচ বাজেটের সীমা ছাড়ালে';
}

// Path: settings.notifications.nearLimit
class _Translations$settings$notifications$nearLimit$bn extends Translations$settings$notifications$nearLimit$en {
	_Translations$settings$notifications$nearLimit$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => '80% সীমা';
	@override String get subtitle => 'বাজেটের 80% খরচ হলে';
}

// Path: settings.notifications.weekly
class _Translations$settings$notifications$weekly$bn extends Translations$settings$notifications$weekly$en {
	_Translations$settings$notifications$weekly$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সাপ্তাহিক সারাংশ';
	@override String subtitle({required Object day}) => '${day} সন্ধ্যায়: এই সপ্তাহের খরচ, গত সপ্তাহের তুলনায়';
}

// Path: settings.notifications.reminders
class _Translations$settings$notifications$reminders$bn extends Translations$settings$notifications$reminders$en {
	_Translations$settings$notifications$reminders$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'রিমাইন্ডার';
	@override String get subtitle => 'পুনরাবৃত্ত লেনদেনের এক দিন আগে মনে করিয়ে দিন';
}

// Path: settings.notifications.autoImport
class _Translations$settings$notifications$autoImport$bn extends Translations$settings$notifications$autoImport$en {
	_Translations$settings$notifications$autoImport$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'স্বয়ংক্রিয় ইমপোর্ট করা লেনদেন';
	@override String get subtitle => 'SMS থেকে কোনো লেনদেন যোগ হলে';
}

// Path: settings.appearanceScreen.sections
class _Translations$settings$appearanceScreen$sections$bn extends Translations$settings$appearanceScreen$sections$en {
	_Translations$settings$appearanceScreen$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get theme => 'থিম';
	@override String get preview => 'প্রিভিউ';
}

// Path: settings.numberFormat.sections
class _Translations$settings$numberFormat$sections$bn extends Translations$settings$numberFormat$sections$en {
	_Translations$settings$numberFormat$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get preview => 'প্রিভিউ';
	@override String get decimalPlaces => 'দশমিকের পরের ঘর';
	@override String get grouping => 'অঙ্কের গুচ্ছ';
}

// Path: settings.numberFormat.places
class _Translations$settings$numberFormat$places$bn extends Translations$settings$numberFormat$places$en {
	_Translations$settings$numberFormat$places$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String count({required Object n}) => '${n} ঘর';
	@override String noMinorUnits({required Object currency}) => '${currency}-এ দশমিকের ঘর নেই';
}

// Path: settings.fontSize.sections
class _Translations$settings$fontSize$sections$bn extends Translations$settings$fontSize$sections$en {
	_Translations$settings$fontSize$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get preview => 'প্রিভিউ';
	@override String get fontSize => 'লেখার আকার';
}

// Path: settings.calendar.sections
class _Translations$settings$calendar$sections$bn extends Translations$settings$calendar$sections$en {
	_Translations$settings$calendar$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get firstDayOfWeek => 'সপ্তাহের প্রথম দিন';
}

// Path: settings.homePage.sections
class _Translations$settings$homePage$sections$bn extends Translations$settings$homePage$sections$en {
	_Translations$settings$homePage$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get defaultHomePage => 'ডিফল্ট হোম পেজ';
}

// Path: settings.homePage.options
class _Translations$settings$homePage$options$bn extends Translations$settings$homePage$options$en {
	_Translations$settings$homePage$options$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$settings$homePage$options$home$bn home = _Translations$settings$homePage$options$home$bn._(_root);
	@override late final _Translations$settings$homePage$options$activity$bn activity = _Translations$settings$homePage$options$activity$bn._(_root);
	@override late final _Translations$settings$homePage$options$budgets$bn budgets = _Translations$settings$homePage$options$budgets$bn._(_root);
	@override late final _Translations$settings$homePage$options$reports$bn reports = _Translations$settings$homePage$options$reports$bn._(_root);
}

// Path: settings.sync.sections
class _Translations$settings$sync$sections$bn extends Translations$settings$sync$sections$en {
	_Translations$settings$sync$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get device => 'এই ডিভাইস';
}

// Path: settings.sync.result
class _Translations$settings$sync$result$bn extends Translations$settings$sync$result$en {
	_Translations$settings$sync$result$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get success => 'সিঙ্ক সম্পন্ন';
	@override String get offline => 'আপনি অফলাইনে আছেন। অনলাইনে ফিরলে পরিবর্তন পাঠানো হবে।';
	@override String get failed => 'সিঙ্ক শেষ হয়নি। এটি নিজে থেকে আবার চেষ্টা করবে।';
	@override String get disabled => 'আগে সিঙ্ক চালু করুন';
	@override String get signedOut => 'সিঙ্কের জন্য সাইন ইন করুন';
	@override String get firstSyncPending => 'সাইন ইন শেষ হচ্ছে। একটু পরে আবার চেষ্টা করুন।';
}

// Path: settings.export.sections
class _Translations$settings$export$sections$bn extends Translations$settings$export$sections$en {
	_Translations$settings$export$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get dateRange => 'তারিখের সীমা';
	@override String get include => 'অন্তর্ভুক্ত করুন';
}

// Path: settings.export.ranges
class _Translations$settings$export$ranges$bn extends Translations$settings$export$ranges$en {
	_Translations$settings$export$ranges$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get allTime => 'সব সময়';
	@override String get allTimeSubtitle => 'সবকিছু এক্সপোর্ট করুন';
	@override String get thisYear => 'এই বছর';
	@override String get lastSixMonths => 'গত 6 মাস';
	@override String get lastThreeMonths => 'গত 3 মাস';
	@override String get custom => 'নিজে বেছে নিন';
	@override String get customSubtitle => 'শুরু ও শেষের তারিখ বেছে নিন';
	@override String untilToday({required Object start}) => '${start} – এখন পর্যন্ত';
	@override String between({required Object start, required Object end}) => '${start} – ${end}';
}

// Path: settings.export.include
class _Translations$settings$export$include$bn extends Translations$settings$export$include$en {
	_Translations$settings$export$include$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get transactions => 'লেনদেন';
	@override String get budgets => 'বাজেট';
	@override String get categories => 'ক্যাটাগরি';
}

// Path: settings.deleteData.sections
class _Translations$settings$deleteData$sections$bn extends Translations$settings$deleteData$sections$en {
	_Translations$settings$deleteData$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get summary => 'যে ডেটা মুছে যাবে';
	@override String get confirmation => 'নিশ্চিতকরণ';
}

// Path: settings.family.sections
class _Translations$settings$family$sections$bn extends Translations$settings$family$sections$en {
	_Translations$settings$family$sections$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get spendingByMember => 'সদস্য অনুযায়ী খরচ';
	@override String get sharedBudgets => 'শেয়ার করা বাজেটের অগ্রগতি';
}

// Path: support.help.replaySetup
class _Translations$support$help$replaySetup$bn extends Translations$support$help$replaySetup$en {
	_Translations$support$help$replaySetup$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'আবার সেটআপ করুন';
	@override String get rowSubtitle => 'আয়, বাজেট ও লক্ষ্য আবার ঠিক করুন';
	@override String get confirmTitle => 'আবার সেটআপ করবেন?';
	@override String get confirmBody => 'আপনার লেনদেন যেমন আছে তেমনই থাকবে। আবার যোগ করা বাজেট, নিয়মিত পেমেন্ট ও লক্ষ্য নতুন আইটেম হিসেবে তৈরি হবে।';
}

// Path: support.faq.addTransaction
class _Translations$support$faq$addTransaction$bn extends Translations$support$faq$addTransaction$en {
	_Translations$support$faq$addTransaction$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'কীভাবে লেনদেন যোগ করব?';
	@override String get a => 'যেকোনো ট্যাবের নিচের + বোতামে ট্যাপ করুন। খরচ বা আয় বেছে নিন, পরিমাণ লিখুন, একটি ক্যাটাগরি বাছুন, তারপর খরচ যোগ করুন বা আয় যোগ করুন-এ ট্যাপ করুন।';
}

// Path: support.faq.autoImport
class _Translations$support$faq$autoImport$bn extends Translations$support$faq$autoImport$en {
	_Translations$support$faq$autoImport$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'স্বয়ংক্রিয় ইমপোর্ট কীভাবে কাজ করে?';
	@override String get a => 'সেটিংস → SMS থেকে স্বয়ংক্রিয় ইমপোর্ট-এ গিয়ে SMS পড়ার অনুমতি দিন। Expenzo আপনার ফোনের ব্যাংক ও পেমেন্ট মেসেজ পড়ে সেগুলোকে লেনদেনে রূপান্তর করে। মেসেজের লেখা ফোনেই থাকে; এ থেকে তৈরি লেনদেন অন্য লেনদেনের মতোই সিঙ্ক হয়। পুরোনো মেসেজ আনতে ওই পেজে পুরোনো SMS স্ক্যান করুন-এ ট্যাপ করুন।';
}

// Path: support.faq.budget
class _Translations$support$faq$budget$bn extends Translations$support$faq$budget$en {
	_Translations$support$faq$budget$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'কীভাবে বাজেট তৈরি করব?';
	@override String get a => 'বাজেট ট্যাব খুলে নতুন বাজেট-এ ট্যাপ করুন। একটি নাম, পরিমাণ ও সময়কাল (সাপ্তাহিক, মাসিক বা বার্ষিক) দিন। খরচ যোগ করার সময় সেটি কোন বাজেটে গণ্য হবে তা বেছে নিন, আর বাজেটে দেখাবে কত বাকি আছে। আয় কোনো বাজেটে গণ্য হয় না।';
}

// Path: support.faq.recurring
class _Translations$support$faq$recurring$bn extends Translations$support$faq$recurring$en {
	_Translations$support$faq$recurring$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'পুনরাবৃত্ত লেনদেন কীভাবে কাজ করে?';
	@override String get a => 'সেটিংস → পুনরাবৃত্ত লেনদেন-এ গিয়ে একটি বিল বা আয় এবং কত দিন পরপর হয় তা যোগ করুন। নিজে থেকে লেনদেন তৈরি চালু করলে অ্যাপ খুললেই Expenzo বকেয়া লেনদেন যোগ করে দেয়। বন্ধ থাকলে পুনরাবৃত্ত লেনদেন খুলে ওপরের বাকিগুলো প্রসেস করুন বোতামে (গোল তীর চিহ্ন) ট্যাপ করুন।';
}

// Path: support.faq.export
class _Translations$support$faq$export$bn extends Translations$support$faq$export$en {
	_Translations$support$faq$export$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'আমি কি আমার ডেটা এক্সপোর্ট করতে পারি?';
	@override String get a => 'হ্যাঁ। সেটিংস → ডেটা এক্সপোর্ট-এ গিয়ে তারিখের পরিসর এবং কী কী রাখবেন (লেনদেন, বাজেট, ক্যাটাগরি) বেছে নিন। একটি ধরন হলে CSV ফাইল হিসেবে, একাধিক হলে CSV ফাইলের একটি ZIP হিসেবে শেয়ার হয়।';
}

// Path: support.faq.sync
class _Translations$support$faq$sync$bn extends Translations$support$faq$sync$en {
	_Translations$support$faq$sync$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'ফোন হারালে কি আমার ডেটা নিরাপদ থাকবে?';
	@override String get a => 'Google দিয়ে সাইন ইন করা থাকলে এবং সিঙ্ক চালু থাকলে (এটি ডিফল্টভাবে চালু), আপনার লেনদেন, বাজেট, ক্যাটাগরি, পুনরাবৃত্ত লেনদেন এবং স্বয়ংক্রিয় ইমপোর্টের প্রেরক ও নিয়ম আপনার অ্যাকাউন্টে থাকে। নতুন ফোনে সাইন ইন করলে সেগুলো ফিরে পাবেন। অ্যাপের সেটিংস প্রতিটি ফোনে আলাদা থাকে। সাইন ইন না করলে ডেটা শুধু এই ফোনেই থাকে।';
}

// Path: support.faq.aiAssistant
class _Translations$support$faq$aiAssistant$bn extends Translations$support$faq$aiAssistant$en {
	_Translations$support$faq$aiAssistant$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'Expie কীভাবে কাজ করে?';
	@override String get a => 'রিপোর্ট ট্যাবে রোবট বাটনে ট্যাপ করে Expie-কে আপনার খরচ, বাজেট বা আয় নিয়ে প্রশ্ন করুন। Expie এই মাসের ডেটার একটি সারাংশ থেকে উত্তর দেয়; ইমেইল ও ফোন নম্বরের মতো ব্যক্তিগত তথ্য বাদ দিয়ে সারাংশটি আমাদের AI প্রদানকারী Groq-এ পাঠানো হয়। এটি পরামর্শ দেয়, আর্থিক উপদেশ নয়।';
}

// Path: support.faq.currency
class _Translations$support$faq$currency$bn extends Translations$support$faq$currency$en {
	_Translations$support$faq$currency$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get q => 'কীভাবে মুদ্রা বদলাব?';
	@override String get a => 'সেটিংস → ডিফল্ট মুদ্রা-তে যান। পরিমাণ রূপান্তর হয় না; শুধু চিহ্ন ও ফরম্যাট বদলায়।';
}

// Path: settings.homePage.options.home
class _Translations$settings$homePage$options$home$bn extends Translations$settings$homePage$options$home$en {
	_Translations$settings$homePage$options$home$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'হোম';
	@override String get subtitle => 'নিট, বাজেট ও সাম্প্রতিক লেনদেনের সারসংক্ষেপ';
}

// Path: settings.homePage.options.activity
class _Translations$settings$homePage$options$activity$bn extends Translations$settings$homePage$options$activity$en {
	_Translations$settings$homePage$options$activity$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'লেনদেন';
	@override String get subtitle => 'সব লেনদেনের পূর্ণ তালিকা';
}

// Path: settings.homePage.options.budgets
class _Translations$settings$homePage$options$budgets$bn extends Translations$settings$homePage$options$budgets$en {
	_Translations$settings$homePage$options$budgets$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'বাজেট';
	@override String get subtitle => 'বাজেটের সারসংক্ষেপ ও অগ্রগতি';
}

// Path: settings.homePage.options.reports
class _Translations$settings$homePage$options$reports$bn extends Translations$settings$homePage$options$reports$en {
	_Translations$settings$homePage$options$reports$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'রিপোর্ট';
	@override String get subtitle => 'প্রবণতা, ক্যাটাগরি ও বিশ্লেষণ';
}

/// The flat map containing all translations for locale <bn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsBn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'aiAssistant.title' => 'Expie',
			'aiAssistant.inputHint' => 'আপনার খরচ নিয়ে জিজ্ঞেস করুন',
			'aiAssistant.send' => 'মেসেজ পাঠান',
			'aiAssistant.disclaimer' => 'Expie আপনার ডেটা দেখে পরামর্শ দেয়। এটি কোনো লাইসেন্সপ্রাপ্ত আর্থিক উপদেষ্টা নয়।',
			'aiAssistant.suggestions.topExpenses' => 'সবচেয়ে বড় খরচ',
			'aiAssistant.suggestions.budget' => 'আমার বাজেট কেমন চলছে?',
			'aiAssistant.refusals.outOfScope' => 'আমি শুধু আপনার Expenzo-র হিসাব নিয়ে সাহায্য করতে পারি: খরচ, বাজেট, ক্যাটাগরি, আয়, ব্যালেন্স, সঞ্চয়, লেনদেন, রিপোর্ট ও পুনরাবৃত্ত বিল। আপনার নিজের ডেটা নিয়ে প্রশ্ন করুন।',
			'aiAssistant.refusals.promptInjection' => 'গোপন নির্দেশনা, ভেতরের তথ্য, গোপন কী বা আমার নিয়ম বদলানোর অনুরোধে আমি সাহায্য করতে পারি না। Expenzo-তে আপনার হিসাব নিয়ে জিজ্ঞেস করুন।',
			'aiAssistant.refusals.tooLong' => 'মেসেজটি অনেক বড়। আপনার Expenzo-র হিসাব নিয়ে ছোট করে জিজ্ঞেস করুন।',
			'aiAssistant.refusals.empty' => 'আপনার Expenzo-র হিসাব নিয়ে একটি প্রশ্ন লিখুন।',
			'aiAssistant.refusals.cooldown' => 'আরেকটি প্রশ্ন পাঠানোর আগে কয়েক সেকেন্ড অপেক্ষা করুন।',
			'aiAssistant.refusals.contextUnavailable' => 'এই মুহূর্তে আপনার হিসাবের ডেটা পড়তে পারছি না। একটু পরে আবার চেষ্টা করুন।',
			'aiAssistant.errors.contextFailed' => 'আপনার হিসাবের ডেটা লোড করা যায়নি। আবার চেষ্টা করুন।',
			'auth.errors.cannotConnect' => 'সংযোগ করা যাচ্ছে না। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।',
			'auth.errors.serverProblem' => 'আমাদের দিকে কিছু সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।',
			'auth.errors.timedOut' => 'অনুরোধের সময় শেষ হয়ে গেছে। সংযোগ দেখে আবার চেষ্টা করুন।',
			'auth.errors.generic' => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।',
			'auth.errors.cancelled' => 'সাইন-ইন বাতিল করা হয়েছে।',
			'auth.errors.network' => 'নেটওয়ার্কে সমস্যা। সংযোগ দেখে আবার চেষ্টা করুন।',
			'auth.errors.tooManyAttempts' => 'অনেকবার চেষ্টা করা হয়েছে। পরে আবার চেষ্টা করুন।',
			'auth.errors.failed' => 'সাইন-ইন হয়নি। আবার চেষ্টা করুন।',
			'auth.syncConflict.title' => 'সিঙ্কে গরমিল',
			'auth.syncConflict.body' => 'এই ফোনে এবং আপনার অ্যাকাউন্টে দুই জায়গাতেই রেকর্ড আছে। কোনগুলো রাখবেন বেছে নিন।',
			'auth.syncConflict.merge' => 'আমার ডেটা একসাথে করুন',
			'auth.syncConflict.mergeDetail' => 'দুই জায়গার রেকর্ডই রাখুন',
			'auth.syncConflict.useAccount' => 'অ্যাকাউন্টের ডেটা ব্যবহার করুন',
			'auth.syncConflict.useAccountDetail' => 'এই ফোনের রেকর্ড মুছে অ্যাকাউন্টের কপি ব্যবহার করুন',
			'auth.syncConflict.keepPhone' => 'এই ফোনের ডেটা রাখুন',
			'auth.syncConflict.keepPhoneDetail' => 'অ্যাকাউন্টের কপির জায়গায় এই ফোনের রেকর্ড রাখুন',
			'auth.syncConflict.replaceTitle' => 'এই ফোনের ডেটা বদলাবেন?',
			'auth.syncConflict.replaceBody' => 'এতে এই ফোনের রেকর্ড স্থায়ীভাবে মুছে যাবে এবং আপনার অ্যাকাউন্টের কপি বসবে।',
			'auth.syncConflict.replace' => 'বদলান',
			'auth.syncConflict.namesUploadFailed' => 'আপনার বাজেটের নাম আপলোড করা যায়নি। সংযোগ দেখে আবার চেষ্টা করুন।',
			'auth.syncConflict.preparing' => 'প্রস্তুত হচ্ছে…',
			'auth.syncConflict.clearing' => 'এই ফোন খালি করা হচ্ছে…',
			'auth.syncConflict.done' => 'সম্পন্ন',
			'auth.syncConflict.syncing' => 'সিঙ্ক হচ্ছে…',
			'auth.login.google' => 'Google দিয়ে সাইন ইন',
			'auth.login.logo' => 'Expenzo লোগো',
			'auth.login.pitch' => 'রেকর্ডের ব্যাকআপ রাখতে এবং সব ডিভাইসে সিঙ্কে রাখতে সাইন ইন করুন।',
			'auth.login.signingIn' => 'সাইন ইন হচ্ছে…',
			'budgets.title' => 'বাজেট',
			'budgets.subtitle' => 'আপনার মাসিক সীমা দেখুন',
			'budgets.unnamed' => 'নামহীন বাজেট',
			'budgets.empty.title' => 'এখনো কোনো বাজেট নেই',
			'budgets.empty.body' => 'কত টাকা বাকি আছে দেখতে একটি মাসিক সীমা ঠিক করুন।',
			'budgets.saved' => 'বাজেট সংরক্ষণ হয়েছে',
			'budgets.loadPrompt' => 'ডেটা দেখতে বাজেট লোড করুন',
			'budgets.edit' => 'সম্পাদনা',
			'budgets.delete.title' => 'বাজেট মুছুন',
			'budgets.delete.confirm' => ({required Object name}) => '"${name}" বাজেট মুছবেন?',
			'budgets.card.overBy' => ({required Object amount}) => '${amount} বেশি খরচ',
			'budgets.card.left' => ({required Object amount}) => '${amount} বাকি',
			'budgets.card.spentOf' => ({required Object total, required Object spent}) => '${total}-এর মধ্যে ${spent} খরচ',
			'budgets.card.a11y' => ({required Object name, required Object headline, required Object daysLeft}) => '${name}, ${headline}, ${daysLeft}। অপশন দেখতে চেপে ধরে রাখুন।',
			'budgets.days.ended' => 'সময় শেষ',
			'budgets.days.lastDay' => 'শেষ দিন',
			'budgets.days.left' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n} দিন বাকি', other: '${n} দিন বাকি', ), 
			'budgets.form.add' => 'বাজেট যোগ করুন',
			'budgets.form.edit' => 'বাজেট সম্পাদনা',
			'budgets.form.amount' => 'পরিমাণ',
			'budgets.form.name' => 'নাম',
			'budgets.form.nameHint' => 'যেমন: খাবার ও পানীয়',
			'budgets.form.period' => 'সময়কাল',
			'budgets.form.rollover' => 'অব্যবহৃত টাকা পরের সময়ে নিন',
			'budgets.form.rolloverDetail' => 'যে টাকা খরচ হয়নি তা পরের সময়ে যোগ হবে',
			'budgets.form.amountRequired' => 'একটি পরিমাণ লিখুন',
			'budgets.form.amountInvalid' => 'সঠিক সংখ্যা লিখুন',
			'budgets.form.nameRequired' => 'একটি নাম লিখুন',
			'budgets.form.nameReserved' => 'অন্য একটি নাম দিন',
			'budgets.form.sharedReadOnly' => 'পরিবারের অ্যাডমিন এটি শেয়ার করেছেন। শুধু তিনিই এটি বদলাতে পারবেন।',
			'budgets.form.sharedTitle' => 'শেয়ার করা বাজেট',
			'budgets.form.share' => 'পরিবারের সাথে শেয়ার করুন',
			'budgets.form.shareDetail' => ({required Object name}) => '${name}-এর সদস্যরা এটি দেখতে এবং এতে খরচ যোগ করতে পারবেন',
			'budgets.form.unshareTitle' => 'শেয়ার বন্ধ করবেন?',
			'budgets.form.unshareBody' => 'সদস্যরা আর এই বাজেট দেখতে পাবেন না। আগে যোগ করা লেনদেন যেমন আছে তেমনই থাকবে।',
			'budgets.form.unshareConfirm' => 'শেয়ার বন্ধ করুন',
			'budgets.details.title' => 'বাজেটের বিস্তারিত',
			'budgets.details.loadFailed' => 'বাজেটের বিস্তারিত লোড করা যায়নি। আবার চেষ্টা করুন।',
			'budgets.details.notFound' => 'বাজেট পাওয়া যায়নি।',
			'budgets.details.ofTotal' => ({required Object total}) => ' / ${total}',
			'budgets.details.periodBudget.weekly' => 'সাপ্তাহিক বাজেট',
			'budgets.details.periodBudget.monthly' => 'মাসিক বাজেট',
			'budgets.details.periodBudget.yearly' => 'বার্ষিক বাজেট',
			'budgets.details.carriedOver' => ({required Object amount}) => 'আগের সময় থেকে আসা ${amount} সহ',
			'budgets.details.used' => ({required Object percent}) => '${percent}% খরচ হয়েছে',
			'budgets.details.over' => 'বাজেট ছাড়িয়ে গেছে',
			'budgets.details.transactionsFailed' => 'লেনদেন লোড করা যায়নি',
			'budgets.details.noExpenses' => 'এই বাজেটে এখনো কোনো খরচ নেই',
			'budgets.details.noExpensesBody' => 'এই বাজেটের সাথে যুক্ত খরচ এখানে দেখা যাবে।',
			'budgets.details.transactions' => 'লেনদেন',
			'budgets.details.unableToLoad' => 'বাজেট লোড করা যায়নি',
			'budgets.details.unableToLoadBody' => 'বাজেটের বিস্তারিত লোড করা যায়নি।',
			'budgets.picker.title' => 'বাজেট বেছে নিন',
			'budgets.picker.subtitle' => 'এই খরচটি কোন বাজেটে গণ্য হবে তা বেছে নিন',
			'budgets.picker.sectionAvailable' => 'উপলব্ধ বাজেট',
			'budgets.picker.noBudget' => 'কোনো বাজেট নয়',
			'budgets.picker.noBudgetHint' => 'কোনো বাজেটের সাথে যুক্ত করবেন না',
			'budgets.picker.previousBudget' => 'আগের বাজেট (আর সক্রিয় নয়)',
			'budgets.picker.previousBudgetHint' => 'বর্তমান সংযোগ রাখুন',
			'budgets.picker.progress' => ({required Object period, required Object spent, required Object limit}) => '${period} · ${spent} / ${limit}',
			'budgets.picker.empty' => 'কোনো সক্রিয় বাজেট নেই',
			'budgets.plan.title' => 'বাজেট পরিকল্পনা',
			'budgets.plan.rowSubtitle' => 'আয় ও মাসিক বাজেট',
			'budgets.plan.editPlan' => 'পরিকল্পনা বদলান',
			'budgets.plan.income' => 'মাসিক আয়',
			'budgets.plan.names.needs' => 'প্রয়োজন',
			'budgets.plan.names.wants' => 'চাহিদা',
			'budgets.plan.names.savings' => 'সঞ্চয়',
			'budgets.plan.perMonth' => ({required Object amount}) => '${amount}/মাস',
			'budgets.plan.toPlan' => ({required Object amount}) => 'নিয়মিত খরচের পরে মাসে ${amount}',
			'budgets.plan.remaining' => ({required Object amount}) => 'ভাগ করার বাকি ${amount}',
			'budgets.plan.overBy' => ({required Object amount}) => '${amount} বেশি',
			'budgets.plan.name' => 'নাম',
			'budgets.plan.amount' => 'পরিমাণ',
			'budgets.plan.addBudget' => 'বাজেট যোগ করুন',
			'budgets.plan.removeBudget' => ({required Object name}) => '${name} সরান',
			'budgets.plan.removeUnnamed' => 'বাজেট সরান',
			'budgets.plan.suggestSplit' => 'ভাগ করার পরামর্শ',
			'budgets.plan.nameTooLong' => ({required Object max}) => '${max} অক্ষর বা তার কম ব্যবহার করুন',
			'budgets.plan.nameDuplicate' => 'অন্য একটি বাজেটের এই নাম আছে',
			'budgets.plan.amountPositive' => '0-এর বেশি একটি পরিমাণ লিখুন',
			'budgets.plan.chartLabel' => ({required Object entries}) => 'বাজেট পরিকল্পনা: ${entries}',
			'budgets.plan.deleteTitle' => 'বাজেট মুছবেন?',
			'budgets.plan.deleteBody' => ({required Object names}) => 'সংরক্ষণ করলে এই বাজেটগুলো মুছে যাবে: ${names}। এদের খরচগুলো থাকবে, কোনো বাজেট ছাড়া।',
			'budgets.plan.saved' => 'বাজেট পরিকল্পনা সংরক্ষিত হয়েছে',
			'budgets.plan.saveFailed' => 'সব পরিবর্তন সংরক্ষণ করা যায়নি। এখন যা সংরক্ষিত আছে তা দেখানো হচ্ছে।',
			'budgets.plan.loadFailed' => 'আপনার বাজেট পরিকল্পনা লোড করা যায়নি।',
			'budgets.plan.empty' => 'এখনো কোনো মাসিক বাজেট নেই। পরিকল্পনা শুরু করতে একটি যোগ করুন।',
			'budgets.sharedBadge' => 'শেয়ার করা',
			'categories.uncategorized' => 'ক্যাটাগরি নেই',
			'categories.defaults.default_in_salary' => 'বেতন',
			'categories.defaults.default_in_freelance' => 'ফ্রিল্যান্স',
			'categories.defaults.default_in_investment' => 'বিনিয়োগ',
			'categories.defaults.default_in_refund' => 'ফেরত',
			'categories.defaults.default_in_gift' => 'উপহার',
			'categories.defaults.default_in_general' => 'সাধারণ',
			'categories.defaults.default_out_food' => 'খাবার ও রেস্তোরাঁ',
			'categories.defaults.default_out_shopping' => 'কেনাকাটা',
			'categories.defaults.default_out_transport' => 'যাতায়াত',
			'categories.defaults.default_out_home' => 'বাসা',
			'categories.defaults.default_out_health' => 'স্বাস্থ্য',
			'categories.defaults.default_out_entertainment' => 'বিনোদন',
			'categories.defaults.default_out_bills' => 'বিল ও ইউটিলিটি',
			'categories.defaults.default_out_travel' => 'ভ্রমণ',
			'categories.defaults.default_out_education' => 'শিক্ষা',
			'categories.defaults.default_out_investment' => 'বিনিয়োগ',
			'categories.defaults.default_out_gifts' => 'উপহার',
			'categories.defaults.default_out_general' => 'সাধারণ',
			'categories.empty' => 'কোনো ক্যাটাগরি তৈরি করা হয়নি',
			'categories.settings.title' => 'ক্যাটাগরি সেটিংস',
			'categories.settings.sections.expense' => 'খরচের ক্যাটাগরি',
			'categories.settings.sections.income' => 'আয়ের ক্যাটাগরি',
			'categories.settings.recordCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি লেনদেন', other: '${n}টি লেনদেন', ), 
			'categories.settings.deleteFailed' => 'ক্যাটাগরি মোছা যায়নি। আবার চেষ্টা করুন।',
			'categories.defaultCannotDelete' => 'ডিফল্ট ক্যাটাগরি মোছা যায় না',
			'categories.form.add' => 'ক্যাটাগরি যোগ করুন',
			'categories.form.edit' => 'ক্যাটাগরি সম্পাদনা',
			'categories.form.name' => 'নাম',
			'categories.form.nameHint' => 'বাজার-সদাই',
			'categories.form.nameRequired' => 'একটি নাম লিখুন',
			'categories.form.icon' => 'আইকন',
			'categories.form.color' => 'রং বেছে নিন',
			'categories.delete.title' => 'ক্যাটাগরি মুছবেন?',
			'categories.delete.confirm' => ({required Object name}) => 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান?',
			'categories.delete.withRecords' => ({required num n, required Object name}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান? এই ক্যাটাগরির ${n}টি লেনদেন ক্যাটাগরি ছাড়া থাকবে।', other: 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান? এই ক্যাটাগরির ${n}টি লেনদেন ক্যাটাগরি ছাড়া থাকবে।', ), 
			'categories.iconLabel' => ({required Object name}) => '${name} আইকন',
			'categories.icons.shoppingCart' => 'শপিং কার্ট',
			'categories.icons.forkKnife' => 'কাঁটাচামচ ও ছুরি',
			'categories.icons.car' => 'গাড়ি',
			'categories.icons.bag' => 'ব্যাগ',
			'categories.icons.heart' => 'হৃদয়',
			'categories.icons.bookOpen' => 'বই',
			'categories.icons.filmStrip' => 'সিনেমা',
			'categories.icons.lightning' => 'বিদ্যুৎ',
			'categories.icons.coffee' => 'কফি',
			'categories.icons.gift' => 'উপহার',
			'categories.icons.dog' => 'কুকুর',
			'categories.icons.airplane' => 'বিমান',
			'categories.colors.Lavender' => 'ল্যাভেন্ডার',
			'categories.colors.Rose' => 'গোলাপি',
			'categories.colors.Mint' => 'পুদিনা সবুজ',
			'categories.colors.Sky' => 'আকাশি',
			'categories.colors.Amber' => 'অ্যাম্বার',
			'categories.colors.Teal' => 'টিল',
			'categories.colors.Peach' => 'পীচ',
			'categories.colors.Slate' => 'স্লেট',
			'common.appName' => 'Expenzo',
			'common.add' => 'যোগ করুন',
			'common.save' => 'সংরক্ষণ করুন',
			'common.delete' => 'মুছুন',
			'common.cancel' => 'বাতিল',
			'common.close' => 'বন্ধ করুন',
			'common.done' => 'সম্পন্ন',
			'common.next' => 'পরবর্তী',
			'common.back' => 'পেছনে',
			'common.undo' => 'আগের অবস্থায় ফেরান',
			'common.tryAgain' => 'আবার চেষ্টা করুন',
			'common.notNow' => 'এখন নয়',
			'common.openSettings' => 'সেটিংস খুলুন',
			'common.addExpense' => 'খরচ যোগ করুন',
			'common.newBudget' => 'নতুন বাজেট',
			'common.sendFeedback' => 'মতামত পাঠান',
			'common.autoImport' => 'SMS থেকে স্বয়ংক্রিয় ইমপোর্ট',
			'common.errors.generic' => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।',
			'common.errors.storage' => 'আপনার ডেটা পড়া বা সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।',
			'common.errors.network' => 'আপনি অফলাইনে আছেন। সংযোগ দেখে আবার চেষ্টা করুন।',
			'common.errors.server' => 'সার্ভার সাড়া দেয়নি। একটু পরে আবার চেষ্টা করুন।',
			'common.errors.auth' => 'সাইন-ইনে সমস্যা হয়েছে। আবার সাইন ইন করে চেষ্টা করুন।',
			'common.errors.permission' => 'এই কাজের অনুমতি Expenzo-র নেই। সিস্টেম সেটিংসে অনুমতি দিন।',
			'common.errors.notFound' => 'এই আইটেমটি আর নেই।',
			'common.errors.smsScan' => 'আপনার মেসেজ পড়া যায়নি। আবার চেষ্টা করুন।',
			'common.errors.requiresRecentLogin' => 'নিরাপত্তার জন্য আবার সাইন ইন করুন, তারপর অ্যাকাউন্ট মুছুন।',
			'common.dates.today' => 'আজ',
			'common.dates.yesterday' => 'গতকাল',
			'common.a11y.expenseAmount' => ({required Object amount, required Object currency}) => 'খরচ, ${amount} ${currency}',
			'common.a11y.incomeAmount' => ({required Object amount, required Object currency}) => 'আয়, ${amount} ${currency}',
			'common.feedback.subject' => 'Expenzo নিয়ে মতামত',
			'common.feedback.noMailApp' => ({required Object email}) => 'কোনো ইমেইল অ্যাপ পাওয়া যায়নি। আমাদের লিখুন ${email} ঠিকানায়।',
			'common.feedback.copyAddress' => 'ঠিকানা কপি করুন',
			'common.clearSearch' => 'খোঁজা মুছুন',
			'common.addTransaction' => 'লেনদেন যোগ করুন',
			'common.noTransactionsInPeriod' => 'এই সময়ে কোনো লেনদেন নেই',
			'common.fallback.initTitle' => 'অ্যাপ চালু হয়নি',
			'common.fallback.errorTitle' => 'কিছু একটা ভুল হয়েছে',
			'common.fallback.initBody' => 'অ্যাপটি চালু করা শেষ করা যায়নি। এটি সাধারণত সাময়িক। আবার চেষ্টা করুন, অথবা অ্যাপটি আবার চালু করুন।',
			'common.fallback.errorBody' => 'একটি অপ্রত্যাশিত সমস্যা হয়েছে। আবার চেষ্টা করতে পারেন, অ্যাপটি আবার চালু করতে পারেন, অথবা আমাদের মতামত পাঠাতে পারেন যাতে আমরা ঠিক করতে পারি।',
			'common.fallback.reference' => ({required Object id}) => 'রেফারেন্স: ${id}',
			'common.fallback.closeApp' => 'অ্যাপ বন্ধ করুন',
			'common.fallback.debugDetails' => 'বিস্তারিত (ডিবাগ)',
			'common.fallback.storageBody' => 'এই ফোনে রাখা ডেটা পড়া যাচ্ছে না। Expenzo ব্যবহার চালিয়ে যেতে এটি রিসেট করুন। সিঙ্ক করা ডেটা সাইন ইন করলে ফিরে আসবে।',
			'common.fallback.resetLocalData' => 'লোকাল ডেটা রিসেট করুন',
			'common.fallback.resetConfirm' => 'এতে এই ফোনে রাখা লেনদেন, বাজেট ও ক্যাটাগরি মুছে যাবে। সিঙ্ক করা ডেটা সাইন ইন করলে ফিরে আসবে। যে পরিবর্তন সিঙ্ক হয়নি তা হারিয়ে যাবে।',
			'common.fallback.resetConfirmAction' => 'মুছে আবার শুরু করুন',
			'common.smsGate.title' => 'SMS পড়ার অনুমতি দরকার',
			'common.smsGate.body' => 'আপনার ব্যাংক ও পেমেন্ট অ্যাপের খরচ স্বয়ংক্রিয়ভাবে হিসাব রাখতে Expenzo-র আপনার SMS পড়ার অনুমতি দরকার। আপনার মেসেজ কখনো আপনার ফোনের বাইরে যায় না।',
			'common.smsGate.allow' => 'অনুমতি দিন',
			'common.smsGate.deniedTitle' => 'অনুমতি দরকার',
			'common.smsGate.deniedBody' => 'SMS পড়ার অনুমতি স্থায়ীভাবে বন্ধ করা আছে। স্মার্ট স্ক্যানার ব্যবহার করতে অ্যাপ সেটিংসে এটি চালু করুন।',
			'currencies.names.BDT' => 'বাংলাদেশি টাকা',
			'currencies.names.USD' => 'মার্কিন ডলার',
			'currencies.names.EUR' => 'ইউরো',
			'currencies.names.GBP' => 'ব্রিটিশ পাউন্ড',
			'currencies.names.INR' => 'ভারতীয় রুপি',
			'currencies.names.PKR' => 'পাকিস্তানি রুপি',
			'currencies.names.NPR' => 'নেপালি রুপি',
			'currencies.names.LKR' => 'শ্রীলঙ্কান রুপি',
			'currencies.names.AED' => 'আমিরাতি দিরহাম',
			'currencies.names.SAR' => 'সৌদি রিয়াল',
			'currencies.names.MYR' => 'মালয়েশিয়ান রিঙ্গিত',
			'currencies.names.SGD' => 'সিঙ্গাপুর ডলার',
			'currencies.names.THB' => 'থাই বাত',
			'currencies.names.PHP' => 'ফিলিপাইন পেসো',
			'currencies.names.IDR' => 'ইন্দোনেশিয়ান রুপিয়া',
			'currencies.names.VND' => 'ভিয়েতনামি ডং',
			'currencies.names.JPY' => 'জাপানি ইয়েন',
			'currencies.names.KRW' => 'দক্ষিণ কোরিয়ান উয়ন',
			'currencies.names.CNY' => 'চীনা ইউয়ান',
			'currencies.names.AUD' => 'অস্ট্রেলিয়ান ডলার',
			'currencies.names.CAD' => 'কানাডিয়ান ডলার',
			'currencies.names.CHF' => 'সুইস ফ্রাঁ',
			'currencies.names.SEK' => 'সুইডিশ ক্রোনা',
			'currencies.names.PLN' => 'পোলিশ জ্লোটি',
			'currencies.names.TRY' => 'তুর্কি লিরা',
			'currencies.names.RUB' => 'রুশ রুবল',
			'currencies.names.BRL' => 'ব্রাজিলিয়ান রিয়াল',
			'currencies.names.ZAR' => 'দক্ষিণ আফ্রিকান র‍্যান্ড',
			'dashboard.range.thisMonth' => 'এই মাস',
			'dashboard.range.lastMonth' => 'গত মাস',
			'dashboard.range.thisYear' => 'এই বছর',
			'dashboard.range.net.thisMonth' => 'এই মাসের নিট',
			'dashboard.range.net.lastMonth' => 'গত মাসের নিট',
			'dashboard.range.net.thisYear' => 'এই বছরের নিট',
			'dashboard.range.previous.thisMonth' => 'গত মাস',
			'dashboard.range.previous.lastMonth' => 'তার আগের মাস',
			'dashboard.range.previous.thisYear' => 'গত বছর',
			'dashboard.userFallback' => 'ব্যবহারকারী',
			'dashboard.income' => 'আয়',
			'dashboard.expense' => 'খরচ',
			'dashboard.sections.budgets' => 'বাজেট',
			'dashboard.sections.recentActivity' => 'সাম্প্রতিক লেনদেন',
			'dashboard.sections.spendingPatterns' => 'খরচের ধরন',
			'dashboard.sections.seeAll' => 'সব দেখুন',
			'dashboard.noBudgets' => 'এখনো কোনো বাজেট নেই',
			'dashboard.noTransactions' => 'এখনো কোনো লেনদেন নেই',
			'dashboard.settings' => 'সেটিংস',
			'dashboard.budgetSpentOf' => ({required Object total, required Object spent}) => '${total}-এর মধ্যে ${spent}',
			'dashboard.trend.noPrevious' => ({required Object period}) => '${period}-এর সাথে তুলনা করার মতো খরচ নেই',
			'dashboard.trend.same' => ({required Object period}) => '${period}-এর সমান',
			'dashboard.trend.up' => ({required Object period, required Object percent}) => '${period}-এর চেয়ে +${percent}%',
			'dashboard.trend.down' => ({required Object period, required Object percent}) => '${period}-এর চেয়ে -${percent}%',
			'dashboard.trend.spent' => ({required Object amount}) => '${amount} খরচ',
			'dashboard.trend.noData' => 'এখনো প্রবণতার ডেটা নেই',
			'dashboard.autoImport.title' => 'SMS থেকে খরচ যোগ করুন',
			'dashboard.autoImport.body' => 'Expenzo-কে ব্যাংক ও পেমেন্টের মেসেজ পড়ে আপনার হয়ে খরচ যোগ করতে দিন। মেসেজ এই ফোনেই থাকে।',
			'dashboard.autoImport.setUp' => 'সেট আপ করুন',
			'dashboard.scanReceipt' => 'রসিদ স্ক্যান করুন',
			'enums.recordType.income' => 'আয়',
			'enums.recordType.expense' => 'খরচ',
			'enums.period.weekly' => 'সাপ্তাহিক',
			'enums.period.monthly' => 'মাসিক',
			'enums.period.yearly' => 'বার্ষিক',
			'enums.frequency.daily' => 'দৈনিক',
			'enums.frequency.weekly' => 'সাপ্তাহিক',
			'enums.frequency.biweekly' => 'প্রতি দুই সপ্তাহে',
			'enums.frequency.monthly' => 'মাসিক',
			'enums.frequency.yearly' => 'বার্ষিক',
			'enums.source.manual' => 'নিজে যোগ করা',
			'enums.source.sms' => 'SMS',
			'enums.source.email' => 'ইমেইল',
			'enums.source.recurring' => 'পুনরাবৃত্ত',
			'enums.theme.system' => 'ডিভাইসের মতো',
			'enums.theme.light' => 'লাইট',
			'enums.theme.dark' => 'ডার্ক',
			'enums.digitGrouping.comma' => 'কমা দিয়ে আলাদা',
			'enums.digitGrouping.dot' => 'ডট দিয়ে আলাদা',
			'enums.digitGrouping.space' => 'ফাঁকা জায়গা দিয়ে আলাদা',
			'enums.fontSize.small.title' => 'ছোট',
			'enums.fontSize.small.description' => 'ঘন সাজানো, স্ক্রিনে বেশি তথ্য',
			'enums.fontSize.medium.title' => 'মাঝারি',
			'enums.fontSize.medium.description' => 'প্রতিদিনের ব্যবহারের জন্য',
			'enums.fontSize.large.title' => 'বড়',
			'enums.fontSize.large.description' => 'পড়তে সহজ বড় লেখা',
			'enums.fontSize.extraLarge.title' => 'অনেক বড়',
			'enums.fontSize.extraLarge.description' => 'সহজে দেখার জন্য সবচেয়ে বড়',
			'enums.firstDayOfWeek.sunday' => 'রবিবার',
			'enums.firstDayOfWeek.monday' => 'সোমবার',
			'enums.firstDayOfWeek.saturday' => 'শনিবার',
			'family.create.title' => 'পারিবারিক গ্রুপ তৈরি করুন',
			'family.create.heading' => 'আপনার পারিবারিক পরিকল্পনা শুরু করুন',
			'family.create.body' => 'আপনার পরিবারের জন্য একটি শেয়ার করা বাজেটের জায়গা তৈরি করুন।',
			'family.create.nameLabel' => 'গ্রুপের নাম',
			'family.create.nameHint' => 'রহমান পরিবার',
			'family.create.nameRequired' => 'গ্রুপের নাম লিখুন',
			'family.create.budgetLabel' => 'মাসিক পারিবারিক বাজেট (ঐচ্ছিক)',
			'family.create.budgetInvalid' => 'শূন্যের বেশি একটি পরিমাণ লিখুন',
			'family.create.currencyNote' => ({required Object code}) => 'মুদ্রা: ${code} (আপনার সেটিংস থেকে)',
			'family.create.submit' => 'গ্রুপ তৈরি করুন',
			'family.create.haveCode' => 'ইনভাইট কোড আছে? পরিবারে যোগ দিন',
			'family.join.title' => 'পরিবারে যোগ দিন',
			'family.join.body' => 'পরিবারের অ্যাডমিনের শেয়ার করা 6 অক্ষরের কোডটি লিখুন।',
			'family.join.codeLabel' => 'ইনভাইট কোড',
			'family.join.codeInvalid' => 'কোডে 6টি অক্ষর ও সংখ্যা থাকে',
			'family.join.currencyNote' => ({required Object code}) => 'আপনার মুদ্রা: ${code}',
			'family.join.submit' => 'গ্রুপে যোগ দিন',
			'family.join.joined' => ({required Object name}) => 'আপনি ${name}-এ যোগ দিয়েছেন',
			'family.join.syncOff' => 'আপনি যোগ দিয়েছেন। শেয়ার করা বাজেট দেখতে সেটিংসে সিঙ্ক চালু করুন।',
			'family.invite.title' => 'সদস্য আমন্ত্রণ করুন',
			'family.invite.heading' => 'আপনার পরিবারকে আমন্ত্রণ করুন',
			'family.invite.limitNote' => 'আপনিসহ সর্বোচ্চ 10 জন সদস্য',
			'family.invite.codeCaption' => 'এই ইনভাইট কোডটি শেয়ার করুন',
			'family.invite.validUntil' => ({required Object time}) => '${time} পর্যন্ত বৈধ',
			'family.invite.share' => 'ইনভাইট শেয়ার করুন',
			'family.invite.shareText' => ({required Object name, required Object code, required Object time}) => 'Expenzo-তে আমার পরিবার "${name}"-এ যোগ দিন: সেটিংস > পারিবারিক গ্রুপ > পরিবারে যোগ দিন খুলে ${code} লিখুন। কোডটি ${time} পর্যন্ত কাজ করবে।',
			'family.invite.regenerate' => 'নতুন কোড তৈরি করুন',
			'family.invite.regenerateTitle' => 'নতুন কোড তৈরি করবেন?',
			'family.invite.regenerateBody' => 'বর্তমান কোডটি আর কাজ করবে না।',
			'family.invite.copied' => 'কোড কপি হয়েছে',
			'family.invite.offline' => 'আপনি অফলাইনে আছেন। ইনভাইট কোড পেতে ইন্টারনেটে যুক্ত হোন।',
			'family.invite.expired' => 'এই কোডের মেয়াদ শেষ। নতুন কোড তৈরি করুন।',
			'family.dashboard.spentOfPlanned' => 'পরিকল্পনার মধ্যে খরচ',
			'family.dashboard.spentOfPlannedValue' => ({required Object planned, required Object spent}) => '${planned}-এর মধ্যে ${spent}',
			'family.dashboard.expense' => ({required Object amount}) => 'খরচ: ${amount}',
			'family.dashboard.sharedBudgetTotal' => ({required Object amount}) => 'শেয়ার করা বাজেটের মোট: ${amount}',
			'family.dashboard.ofMonthlyBudget' => ({required Object budget, required Object spent}) => 'এই মাসে ${budget}-এর মধ্যে ${spent}',
			'family.dashboard.onlySharedNote' => 'এখানে শুধু শেয়ার করা বাজেটের লেনদেন গোনা হয়।',
			'family.dashboard.you' => ({required Object name}) => '${name} (আপনি)',
			'family.dashboard.memberFallback' => 'পরিবারের সদস্য',
			'family.dashboard.moreMembers' => ({required Object n}) => '+${n}',
			'family.dashboard.noSharedBudgets' => 'এখনো কোনো শেয়ার করা বাজেট নেই। অ্যাডমিন বাজেট ফর্ম থেকে একটি বাজেট শেয়ার করতে পারেন।',
			'family.dashboard.seeAllBudgets' => 'সব বাজেট দেখুন',
			'family.dashboard.lastUpdated' => ({required Object time}) => 'সর্বশেষ আপডেট ${time}',
			'family.dashboard.loadFailed' => 'আপনার পরিবারের তথ্য লোড করা যায়নি। সংযোগ দেখে আবার চেষ্টা করুন।',
			'family.dashboard.summaryFailed' => 'সর্বশেষ হিসাব লোড করা যায়নি।',
			'family.dashboard.manageMembers' => 'সদস্য পরিচালনা',
			'family.members.title' => ({required Object count}) => 'সদস্য (${count})',
			'family.members.inviteMore' => 'আরও আমন্ত্রণ করুন',
			'family.members.leave' => 'গ্রুপ ছেড়ে দিন',
			'family.members.leaveTitle' => ({required Object name}) => '${name} ছেড়ে দেবেন?',
			'family.members.leaveBody' => 'এই গ্রুপের শেয়ার করা বাজেটগুলো আপনার ফোন থেকে সরে যাবে। আপনার নিজের লেনদেন আপনার কাছেই থাকবে।',
			'family.members.leaveLastBody' => 'আপনিই শেষ সদস্য। ছেড়ে দিলে গ্রুপটি মুছে যাবে।',
			'family.members.changeRole' => 'ভূমিকা বদলান',
			'family.members.remove' => 'গ্রুপ থেকে সরান',
			'family.members.removeTitle' => ({required Object name}) => '${name}-কে সরাবেন?',
			'family.members.deleteGroup' => 'গ্রুপ মুছুন',
			'family.members.deleteTitle' => ({required Object name}) => '${name} মুছবেন?',
			'family.members.deleteBody' => 'সবাইকে সরিয়ে দেওয়া হবে। শেয়ার করা বাজেটগুলো তাদের মালিকের ব্যক্তিগত বাজেট হয়ে যাবে।',
			'family.roles.admin' => 'অ্যাডমিন',
			'family.roles.member' => 'সদস্য',
			'family.roles.viewer' => 'দর্শক',
			'family.roleHints.admin' => 'সদস্য ও শেয়ার করা বাজেট পরিচালনা করেন',
			'family.roleHints.member' => 'ড্যাশবোর্ড দেখেন এবং শেয়ার করা বাজেটে লেনদেন যোগ করেন',
			'family.roleHints.viewer' => 'শুধু ড্যাশবোর্ড দেখেন',
			'family.errors.alreadyInGroup' => 'আপনি ইতিমধ্যে একটি পারিবারিক গ্রুপে আছেন। আগে সেটি ছেড়ে দিন।',
			'family.errors.currencyMismatch' => 'এই পরিবার অন্য একটি মুদ্রা ব্যবহার করে। সেটিংসে একই মুদ্রা বেছে নিয়ে তারপর যোগ দিন।',
			'family.errors.groupFull' => 'গ্রুপ পূর্ণ। একটি পারিবারিক গ্রুপে সর্বোচ্চ 10 জন সদস্য থাকতে পারেন।',
			'family.errors.inviteExpired' => 'এই কোডের মেয়াদ শেষ। অ্যাডমিনের কাছে নতুন কোড চান।',
			'family.errors.inviteNotFound' => 'এই কোডের কোনো পরিবার নেই। কোডটি দেখে আবার চেষ্টা করুন।',
			'family.errors.lastAdmin' => 'আগে অন্য কাউকে অ্যাডমিন করুন।',
			'family.errors.notInGroup' => 'আপনি আর এই গ্রুপে নেই।',
			'family.errors.signInRequired' => 'পারিবারিক গ্রুপ ব্যবহার করতে সাইন ইন করুন।',
			'goals.errors.nameRequired' => 'আপনার লক্ষ্যের একটি নাম দিন।',
			'goals.errors.targetPositive' => 'শূন্যের বেশি একটি লক্ষ্য পরিমাণ লিখুন।',
			'goals.errors.amountPositive' => 'শূন্যের বেশি একটি পরিমাণ লিখুন।',
			'goals.errors.amountTooLarge' => 'সর্বোচ্চ 9,999,999,999.99 পর্যন্ত পরিমাণ লিখুন।',
			'goals.card.section' => 'সঞ্চয়ের লক্ষ্য',
			'goals.card.progress' => ({required Object target, required Object saved}) => '${target}-এর মধ্যে ${saved}',
			'goals.card.monthsLeft' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: 'আর ${n} মাস বাকি', other: 'আর ${n} মাস বাকি', ), 
			'goals.card.dueThisMonth' => 'এই মাসেই শেষ সময়',
			'goals.card.reached' => 'লক্ষ্য পূরণ হয়েছে',
			'goals.card.plan' => ({required Object amount}) => 'পরিকল্পনা: মাসে ${amount}',
			'goals.card.addToGoal' => 'লক্ষ্যে যোগ করুন',
			'goals.card.newGoal' => 'নতুন লক্ষ্য',
			'goals.card.edit' => 'লক্ষ্য সম্পাদনা',
			'goals.card.setGoal' => 'একটি সঞ্চয়ের লক্ষ্য ঠিক করুন',
			'goals.addSheet.title' => ({required Object name}) => '${name}-এ যোগ করুন',
			'goals.addSheet.amount' => 'পরিমাণ',
			'goals.addSheet.note' => 'এটি শুধু লক্ষ্য আপডেট করে, কোনো লেনদেন যোগ করে না।',
			'goals.added' => ({required Object name, required Object amount}) => '${name}-এ ${amount} যোগ হয়েছে',
			'goals.list.title' => 'লক্ষ্যসমূহ',
			'goals.list.subtitle' => 'নতুনগুলো আগে। সম্পাদনা করতে কোনো লক্ষ্যে ট্যাপ করুন।',
			'goals.list.empty' => 'এখনো কোনো সঞ্চয়ের লক্ষ্য নেই।',
			'goals.list.loadFailed' => 'আপনার লক্ষ্যগুলো লোড করা যায়নি। আবার চেষ্টা করুন।',
			'goals.form.title' => 'লক্ষ্য সম্পাদনা',
			'goals.form.createTitle' => 'নতুন সঞ্চয়ের লক্ষ্য',
			'goals.form.name' => 'লক্ষ্যের নাম',
			'goals.form.target' => 'লক্ষ্য পরিমাণ',
			'goals.form.saved' => 'এ পর্যন্ত সঞ্চয়',
			'goals.form.targetDate' => 'লক্ষ্যের তারিখ',
			'goals.form.clearDate' => 'তারিখ মুছুন',
			'goals.form.pickDate' => 'লক্ষ্যের তারিখ বেছে নিতে চাপুন',
			'goals.form.monthly' => 'মাসিক জমা',
			'goals.form.suggestMonthly' => ({required Object amount}) => 'প্রস্তাবিত: মাসে ${amount}',
			'goals.form.deleteTitle' => 'লক্ষ্য মুছবেন?',
			'goals.form.deleteBody' => 'এতে লক্ষ্য ও এর সঞ্চিত পরিমাণ মুছে যাবে। আপনার লেনদেনে কোনো প্রভাব পড়বে না।',
			'goals.form.savedMessage' => 'লক্ষ্য সংরক্ষিত হয়েছে',
			'goals.form.createdMessage' => 'লক্ষ্য তৈরি হয়েছে',
			'goals.form.deleted' => 'লক্ষ্য মুছে ফেলা হয়েছে',
			'messageTemplates.errors.deleteFailed' => 'SMS ফরম্যাট মোছা যায়নি। আবার চেষ্টা করুন।',
			'messageTemplates.errors.restoreFailed' => 'SMS ফরম্যাট ফেরানো যায়নি। আবার চেষ্টা করুন।',
			'messageTemplates.alreadyExists' => 'SMS ফরম্যাটটি আগে থেকেই আছে',
			'messageTemplates.edit' => 'SMS ফরম্যাট সম্পাদনা',
			'messageTemplates.delete' => 'SMS ফরম্যাট মুছুন',
			'messageTemplates.deleted' => 'SMS ফরম্যাট মুছে ফেলা হয়েছে',
			'messageTemplates.dismiss' => 'বন্ধ করুন',
			'messageTemplates.retro.title' => 'পুরোনো মেসেজ স্ক্যান হচ্ছে',
			'messageTemplates.retro.scanning' => 'এই SMS ফরম্যাটের সাথে মেলে এমন পুরোনো খরচ খোঁজা হচ্ছে…',
			'messageTemplates.retro.saved' => 'SMS ফরম্যাট সংরক্ষণ হয়েছে। এ রকম নতুন মেসেজ নিজে থেকে যোগ হবে।',
			'messageTemplates.retro.review' => 'যে পুরোনো খরচ পাওয়া গেছে তা দেখে যোগ করতে সেটিংস → SMS থেকে স্বয়ংক্রিয় ইমপোর্ট-এ যান।',
			'messageTemplates.editor.noNumbers' => 'এই মেসেজে কোনো সংখ্যা পাওয়া যায়নি।',
			'messageTemplates.editor.amountsFound' => 'এই মেসেজে পাওয়া পরিমাণ:',
			'messageTemplates.editor.step1' => 'ধাপ 1/3: একটি মূল শব্দ বেছে নিন',
			'messageTemplates.editor.step1Body' => 'এমন একটি শব্দ বেছে নিন যা এই ধরনের প্রতিটি মেসেজে থাকে, যেমন "debited", "paid" বা "spent"।',
			'messageTemplates.editor.wordsInMessage' => 'এই মেসেজের শব্দগুলো',
			'messageTemplates.editor.step1Hint' => 'চালিয়ে যেতে একটি শব্দ বেছে নিন।',
			'messageTemplates.editor.step2' => 'ধাপ 2/3: পরিমাণ বেছে নিন',
			'messageTemplates.editor.step2Body' => 'কোন সংখ্যাটি আপনার খরচের পরিমাণ?',
			'messageTemplates.editor.step2Hint' => 'চালিয়ে যেতে পরিমাণ বেছে নিন।',
			'messageTemplates.editor.step3' => 'ধাপ 3/3: দেখে নিন',
			'messageTemplates.editor.step3Body' => 'এখন থেকে এ রকম মেসেজ নিজে থেকে খরচ হিসেবে যোগ হবে।',
			'messageTemplates.editor.sender' => 'প্রেরক',
			'messageTemplates.editor.keyWord' => 'মূল শব্দ',
			'messageTemplates.editor.amountInMessage' => 'এই মেসেজের পরিমাণ',
			'messageTemplates.editor.saveFailed' => ({required Object reason}) => 'SMS ফরম্যাট সংরক্ষণ করা যায়নি: ${reason}',
			'messageTemplates.editor.updated' => 'SMS ফরম্যাট আপডেট হয়েছে',
			'messageTemplates.editor.saved' => 'SMS ফরম্যাট সংরক্ষণ হয়েছে',
			'messageTemplates.analyzer.title' => ({required Object sender}) => '${sender} থেকে আসা মেসেজ',
			'messageTemplates.analyzer.intro' => 'Expenzo-কে এই SMS ফরম্যাট শেখাতে একটি মেসেজ বেছে নিন। এরপর এ রকম মেসেজ নিজে থেকে রেকর্ড হিসেবে যোগ হবে।',
			'messageTemplates.analyzer.useMessage' => 'এই মেসেজটি ব্যবহার করুন',
			'messageTemplates.analyzer.noMessages' => 'এই প্রেরকের সাম্প্রতিক কোনো মেসেজ নেই।',
			'messageTemplates.contacts.subtitle' => 'যেসব প্রেরক আপনাকে পেমেন্টের মেসেজ পাঠায় তাদের বেছে নিন। Expenzo তাদের মেসেজের ফরম্যাট শিখে আপনার জন্য রেকর্ড যোগ করে।',
			'messageTemplates.contacts.search' => 'প্রেরক খুঁজুন',
			'messageTemplates.contacts.active' => 'চালু',
			'messageTemplates.contacts.empty' => 'এই ফোনে এখনো কোনো মেসেজ নেই। SMS এলে প্রেরকেরা এখানে দেখা যাবে।',
			'messageTemplates.contacts.noMatch' => ({required Object query}) => '"${query}" এর সাথে মেলে এমন কোনো প্রেরক নেই।',
			'messageTemplates.create' => 'নতুন SMS ফরম্যাট',
			'messageTemplates.watchlist.title' => 'SMS ওয়াচলিস্ট',
			'messageTemplates.watchlist.subtitle' => 'এই প্রেরকদের মেসেজ লেনদেন হিসেবে যোগ হয়। কোনো প্রেরককে উপেক্ষা করতে বিরতি দিন।',
			'messageTemplates.watchlist.formats' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি SMS ফরম্যাট', other: '${n}টি SMS ফরম্যাট', ), 
			'messageTemplates.watchlist.paused' => 'বিরতিতে',
			'messageTemplates.watchlist.toggle' => ({required Object name}) => '${name} এর মেসেজ পড়ুন',
			'messageTemplates.watchlist.empty' => 'এখনো কোনো প্রেরক নেই। অটো-ইমপোর্ট থেকে একটি নমুনা মেসেজ দেখিয়ে প্রেরক যোগ করুন।',
			'messageTemplates.watchlist.addSender' => 'প্রেরক বেছে নিন',
			'messageTemplates.watchlist.loadFailed' => 'ওয়াচলিস্ট লোড করা যায়নি। আবার চেষ্টা করুন।',
			'notifications.channel.name' => 'অ্যাপের নোটিফিকেশন',
			'notifications.channel.description' => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ, পুনরাবৃত্ত রিমাইন্ডার, স্ক্যানের ফলাফল ও স্বয়ংক্রিয় ইমপোর্ট করা লেনদেন',
			'notifications.budget.title' => 'বাজেট সতর্কতা',
			'notifications.budget.over' => ({required Object budget}) => 'আপনার "${budget}" বাজেট ছাড়িয়ে গেছে।',
			'notifications.budget.used' => ({required Object budget, required Object percent}) => 'আপনার "${budget}" বাজেটের ${percent}% খরচ হয়েছে।',
			'notifications.recurringDue.title' => 'আগামীকাল পুনরাবৃত্ত লেনদেন',
			'notifications.weeklySummary.title' => 'এই সপ্তাহের খরচ',
			'notifications.weeklySummary.up' => ({required Object amount, required Object percent}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন, গত সপ্তাহের চেয়ে ${percent}% বেশি।',
			'notifications.weeklySummary.down' => ({required Object amount, required Object percent}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন, গত সপ্তাহের চেয়ে ${percent}% কম।',
			'notifications.weeklySummary.same' => ({required Object amount}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন, গত সপ্তাহের সমান।',
			'notifications.weeklySummary.noComparison' => ({required Object amount}) => 'এই সপ্তাহে আপনি ${amount} খরচ করেছেন।',
			'notifications.weeklySummary.nothing' => 'এই সপ্তাহে কোনো খরচ লেখা হয়নি।',
			'notifications.scan.smsTitle' => 'SMS স্ক্যান শেষ',
			'notifications.scan.emailTitle' => 'ইমেইল স্ক্যান শেষ',
			'notifications.scan.found' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি নতুন খরচ পাওয়া গেছে', other: '${n}টি নতুন খরচ পাওয়া গেছে', ), 
			'notifications.autoImport.expenseTitle' => 'খরচ যোগ হয়েছে',
			'notifications.autoImport.incomeTitle' => 'আয় যোগ হয়েছে',
			'notifications.autoImport.body' => ({required Object amount, required Object description}) => '${amount} · ${description}',
			'notifications.autoImport.bodyFromSender' => ({required Object sender, required Object amount}) => '${sender} থেকে ${amount}',
			'notifications.autoImport.summaryTitle' => 'SMS থেকে লেনদেন যোগ হয়েছে',
			'notifications.autoImport.summary' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: 'SMS থেকে ${n}টি লেনদেন যোগ হয়েছে', other: 'SMS থেকে ${n}টি লেনদেন যোগ হয়েছে', ), 
			'notifications.syncError.title' => 'সিঙ্কে সমস্যা',
			'onboarding.common.skip' => 'এড়িয়ে যান',
			'onboarding.common.continueLabel' => 'চালিয়ে যান',
			'onboarding.common.stepOf' => ({required Object current, required Object total}) => 'ধাপ ${current}/${total}',
			'onboarding.income.title' => 'চলুন আপনার বাজেট সাজাই',
			'onboarding.income.subtitle' => 'প্রথমে আপনার মাসিক আয় জানান, যাতে আমরা আপনার জন্য মানানসই একটি বাজেট তৈরি করতে পারি।',
			'onboarding.income.amountLabel' => 'মাসিক নিট আয়',
			_ => null,
		} ?? switch (path) {
			'onboarding.income.amountInvalid' => 'সর্বোচ্চ 9,999,999,999.99 পর্যন্ত পরিমাণ লিখুন।',
			'onboarding.income.frequencyLabel' => 'আয়ের ব্যবধান',
			'onboarding.income.frequency.monthly' => 'মাসিক',
			'onboarding.income.frequency.biWeekly' => 'দুই সপ্তাহ পরপর',
			'onboarding.income.frequency.weekly' => 'সাপ্তাহিক',
			'onboarding.income.perMonth' => ({required Object amount}) => '${amount}/মাস',
			'onboarding.recurring.title' => 'কোনো নিয়মিত পেমেন্ট আছে?',
			'onboarding.recurring.subtitle' => 'আপনার নিয়মিত নির্দিষ্ট খরচগুলো যোগ করুন, যাতে বাজেটে সেগুলো হিসাব করা যায়।',
			'onboarding.recurring.addAnother' => 'আরেকটি যোগ করুন',
			'onboarding.recurring.addFirst' => 'একটি পেমেন্ট যোগ করুন',
			'onboarding.recurring.total' => 'মোট নিয়মিত',
			'onboarding.recurring.remove' => ({required Object name}) => '${name} সরান',
			'onboarding.recurring.sheet.title' => 'নিয়মিত পেমেন্ট',
			'onboarding.recurring.sheet.name' => 'নাম',
			'onboarding.recurring.sheet.nameHint' => 'যেমন: ভাড়া',
			'onboarding.recurring.sheet.amount' => 'পরিমাণ',
			'onboarding.recurring.sheet.frequency' => 'পুনরাবৃত্তি',
			'onboarding.plan.title' => 'আপনার বাজেট পরিকল্পনা',
			'onboarding.plan.subtitle' => 'নিয়মিত খরচের পরে যা থাকে, তার 50/30/20 ভাগ আমরা পরামর্শ দিচ্ছি। যেকোনো নাম বা পরিমাণ বদলাতে পারেন।',
			'onboarding.plan.noIncome' => 'ভাগের পরামর্শ পেতে প্রথম ধাপে আপনার আয় যোগ করুন, অথবা নিচে পরিমাণ লিখুন।',
			'onboarding.plan.noRoom' => 'নিয়মিত খরচে আপনার পুরো আয় চলে যায়। তবুও নিচে পরিমাণ লিখতে পারেন।',
			'onboarding.plan.skip' => 'এখন বাজেট বাদ দিন',
			'onboarding.goal.title' => 'আপনি কীসের জন্য সঞ্চয় করছেন?',
			'onboarding.goal.subtitle' => 'একটি সঞ্চয়ের লক্ষ্য ঠিক করুন, আমরা অগ্রগতি দেখতে সাহায্য করব।',
			'onboarding.goal.nameLabel' => 'লক্ষ্যের নাম',
			'onboarding.goal.nameHint' => 'যেমন: নতুন ল্যাপটপ',
			'onboarding.goal.amountLabel' => 'লক্ষ্য পরিমাণ',
			'onboarding.goal.notNow' => 'এখন কোনো লক্ষ্য নয়',
			'onboarding.timeline.title' => 'সময়সীমা বাছুন',
			'onboarding.timeline.canAfford' => ({required Object amount, required Object months, required Object name}) => 'মাসে ${amount} সঞ্চয় করলে ${months} মাসে ${name} কিনতে পারবেন।',
			'onboarding.timeline.cannotAfford' => ({required Object amount}) => 'মাসে ${amount} সঞ্চয় দিয়ে এগুলো হবে না। আরও পরের একটি নিজস্ব তারিখ বাছুন।',
			'onboarding.timeline.months' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n} মাস', other: '${n} মাস', ), 
			'onboarding.timeline.perMonth' => ({required Object amount}) => '${amount}/মাস',
			'onboarding.timeline.custom' => 'নিজস্ব',
			'onboarding.timeline.customHint' => 'নিজে ঠিক করুন',
			'onboarding.timeline.fit.affordable' => 'আপনার সঞ্চয়ে হবে',
			'onboarding.timeline.fit.tooExpensive' => 'আপনার সঞ্চয়ের চেয়ে বেশি',
			'onboarding.timeline.fit.slow' => 'অনেক সময় লাগবে',
			'onboarding.complete.title' => 'সেটআপ সম্পন্ন!',
			'onboarding.complete.budgets' => 'বাজেট তৈরি হয়েছে',
			'onboarding.complete.recurring' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি নিয়মিত পেমেন্ট', other: '${n}টি নিয়মিত পেমেন্ট', ), 
			'onboarding.complete.goal' => ({required Object name}) => 'সঞ্চয়ের লক্ষ্য: ${name}',
			'onboarding.complete.tip' => 'আপনি যেকোনো সময় বাজেট ও লক্ষ্য বদলাতে পারবেন।',
			'onboarding.complete.finish' => 'সেটআপ শেষ করুন',
			'onboarding.complete.saving' => 'আপনার সেটআপ সংরক্ষণ হচ্ছে…',
			'onboarding.complete.partialFailure' => 'কিছু আইটেম সংরক্ষণ করা যায়নি। পরে যোগ করতে পারবেন।',
			'onboarding.tutorial.dashboard.title' => 'এক নজরে আপনার টাকা',
			'onboarding.tutorial.dashboard.body' => 'হোমে এই মাসের নিট হিসাব, বাজেট ও সাম্প্রতিক লেনদেন দেখা যায়।',
			'onboarding.tutorial.addTransaction.title' => 'কয়েক সেকেন্ডে লেনদেন যোগ করুন',
			'onboarding.tutorial.addTransaction.body' => 'যেকোনো ট্যাবে + চাপুন, পরিমাণ লিখুন এবং একটি ক্যাটাগরি বাছুন।',
			'onboarding.tutorial.reports.title' => 'দেখুন টাকা কোথায় যায়',
			'onboarding.tutorial.reports.body' => 'রিপোর্টে ট্রেন্ড, ক্যাটাগরি ও বিশ্লেষণ দেখা যায়।',
			'onboarding.tutorial.pageOf' => ({required Object current, required Object total}) => 'পৃষ্ঠা ${current}/${total}',
			'onboarding.tutorial.cta.title' => 'সব প্রস্তুত!',
			'onboarding.tutorial.cta.body' => 'আপনি এখন মূল বিষয়গুলো জানেন। চলুন আপনার আর্থিক হিসাব রাখা শুরু করি!',
			'onboarding.tutorial.cta.start' => 'চলুন শুরু করি!',
			'receiptScan.permissionRequired' => 'রসিদ স্ক্যান করতে ক্যামেরার অনুমতি দরকার।',
			'receiptScan.permissionBlocked' => 'Expenzo-র জন্য ক্যামেরা বন্ধ আছে। রসিদ স্ক্যান করতে সেটিংসে চালু করুন।',
			'receiptScan.noCamera' => 'এই ডিভাইসে কোনো ক্যামেরা নেই।',
			'receiptScan.cameraFailed' => 'ক্যামেরা চালু করা যায়নি।',
			'receiptScan.captureFailed' => 'ছবি তোলা যায়নি। আবার চেষ্টা করুন।',
			'receiptScan.readFailed' => 'রসিদটি পড়া যায়নি। আবার চেষ্টা করুন অথবা নিজে যোগ করুন।',
			'receiptScan.totalUnreadable' => 'এই রসিদে মোট পরিমাণ খুঁজে পাওয়া যায়নি। আরও পরিষ্কার একটি ছবি তুলুন।',
			'receiptScan.serviceUnavailable' => 'এখন রসিদ পড়া যাচ্ছে না। নিজে যোগ করুন।',
			'receiptScan.chooseFromGallery' => 'গ্যালারি থেকে বেছে নিন',
			'receiptScan.flashOff' => 'ফ্ল্যাশ বন্ধ করুন',
			'receiptScan.flashOn' => 'ফ্ল্যাশ চালু করুন',
			'receiptScan.align' => 'রসিদটি ফ্রেমের মধ্যে রাখুন',
			'receiptScan.reading' => 'আপনার রসিদ পড়া হচ্ছে',
			'receiptScan.takePhoto' => 'ছবি তুলুন',
			'records.filter.title' => 'ফিল্টার',
			'records.filter.dateRange' => 'তারিখের সীমা',
			'records.filter.type' => 'ধরন',
			'records.filter.all' => 'সব',
			'records.filter.categories' => 'ক্যাটাগরি',
			'records.filter.clear' => 'মুছুন',
			'records.filter.apply' => 'প্রয়োগ করুন',
			'records.filter.noCategories' => 'কোনো ক্যাটাগরি নেই',
			'records.filter.allCategories' => 'সব ক্যাটাগরি',
			'records.filter.allCount' => ({required Object n}) => 'সব (${n})',
			'records.filter.selectedCount' => ({required Object n}) => '${n}টি বাছাই করা',
			'records.filter.selectDateRange' => 'তারিখের সীমা বেছে নিন',
			'records.filter.range' => ({required Object start, required Object end}) => '${start} - ${end}',
			'records.list.title' => 'লেনদেন',
			'records.list.subtitle' => 'লেনদেনের ইতিহাস',
			'records.list.filter' => 'ফিল্টার',
			'records.list.search' => 'লেনদেন খুঁজুন',
			'records.list.noMatches' => 'আপনার খোঁজ বা ফিল্টারের সাথে মেলে এমন কোনো লেনদেন নেই।',
			'records.list.empty' => 'এখনো কোনো লেনদেন নেই',
			'records.list.scrollForMore' => 'আরও দেখতে স্ক্রল করুন',
			'records.list.deleted' => 'রেকর্ড মুছে ফেলা হয়েছে',
			'records.picker.title' => 'ক্যাটাগরি বেছে নিন',
			'records.picker.search' => 'ক্যাটাগরি খুঁজুন',
			'records.picker.noneFound' => 'কোনো ক্যাটাগরি পাওয়া যায়নি',
			'records.picker.addCategory' => 'ক্যাটাগরি যোগ করুন',
			'records.sheet.placeholders.expense.0' => 'বাজার-সদাই',
			'records.sheet.placeholders.expense.1' => 'অফিসে উবার',
			'records.sheet.placeholders.expense.2' => 'সহকর্মীর সাথে দুপুরের খাবার',
			'records.sheet.placeholders.expense.3' => 'নেটফ্লিক্স সাবস্ক্রিপশন',
			'records.sheet.placeholders.expense.4' => 'বিদ্যুৎ বিল',
			'records.sheet.placeholders.expense.5' => 'পেট্রোল পাম্প',
			'records.sheet.placeholders.income.0' => 'বেতন',
			'records.sheet.placeholders.income.1' => 'ফ্রিল্যান্স পেমেন্ট',
			'records.sheet.placeholders.income.2' => 'বাড়তি আয়',
			'records.sheet.placeholders.income.3' => 'ফেরত',
			'records.sheet.placeholders.income.4' => 'বোনাস',
			'records.sheet.placeholders.income.5' => 'বিনিয়োগের লভ্যাংশ',
			'records.sheet.enterAmount' => 'একটি পরিমাণ লিখুন',
			'records.sheet.nameHintExpense' => 'নাম, যেমন: দুপুরের খাবার',
			'records.sheet.nameHintIncome' => 'নাম, যেমন: বেতন',
			'records.sheet.nameRequired' => 'একটি নাম দিন',
			'records.sheet.scanReceipt' => 'রসিদ স্ক্যান করুন',
			'records.sheet.noBudget' => 'কোনো বাজেট নয়',
			'records.sheet.budgetOption' => ({required Object name, required Object period}) => '${name} · ${period}',
			'records.sheet.previousBudget' => 'আগের বাজেট (এখন আর চালু নেই)',
			'records.sheet.loadingBudgets' => 'বাজেট লোড হচ্ছে…',
			'records.sheet.noCategories' => 'কোনো ক্যাটাগরি নেই',
			'records.sheet.selectCategory' => 'একটি ক্যাটাগরি বেছে নিন',
			'records.sheet.showAllCategories' => 'সব ক্যাটাগরি দেখুন',
			'records.sheet.showAllBudgets' => 'সব বাজেট দেখুন',
			'records.sheet.repeatMonthly' => 'প্রতি মাসে পুনরাবৃত্তি',
			'records.sheet.addIncome' => 'আয় যোগ করুন',
			'records.sheet.deleteExpense' => 'খরচ মুছুন',
			'records.sheet.deleteIncome' => 'আয় মুছুন',
			'records.sheet.deleteExpenseTitle' => 'এই খরচটি মুছবেন?',
			'records.sheet.deleteIncomeTitle' => 'এই আয়টি মুছবেন?',
			'records.sheet.cannotUndo' => 'এটি আর ফেরানো যাবে না।',
			'records.sheet.repeatFailed' => 'সংরক্ষণ হয়েছে, কিন্তু পুনরাবৃত্তি চালু করা যায়নি। সেটিংস → পুনরাবৃত্ত থেকে সেট আপ করুন।',
			'records.sheet.typeToggle' => 'লেনদেনের ধরন',
			'records.sheet.backspace' => 'মুছুন',
			'records.sheet.decimalKey' => 'দশমিক',
			'recurring.title' => 'পুনরাবৃত্ত লেনদেন',
			'recurring.saved' => 'পুনরাবৃত্ত লেনদেন সংরক্ষণ হয়েছে',
			'recurring.posted' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি লেনদেন যোগ হয়েছে', other: '${n}টি লেনদেন যোগ হয়েছে', ), 
			'recurring.nothingDue' => 'কোনো বকেয়া লেনদেন নেই',
			'recurring.sections.defaultFrequency' => 'ডিফল্ট পুনরাবৃত্তি',
			'recurring.sections.autoCreate' => 'নিজে থেকে তৈরি',
			'recurring.sections.active' => 'সক্রিয় পুনরাবৃত্ত',
			'recurring.defaults.weeklyDetail' => 'প্রতি 7 দিনে',
			'recurring.defaults.monthlyDetail' => 'প্রতি মাসে একই তারিখে',
			'recurring.defaults.yearlyDetail' => 'প্রতি বছর একই তারিখে',
			'recurring.defaults.autoCreate' => 'নিজে থেকে লেনদেন তৈরি',
			'recurring.defaults.autoCreateDetail' => 'অ্যাপ খুললে বকেয়া লেনদেন যোগ করুন',
			'recurring.empty.title' => 'কোনো পুনরাবৃত্ত লেনদেন নেই',
			'recurring.empty.body' => 'প্রথম পুনরাবৃত্ত খরচ তৈরি করতে + চাপুন',
			'recurring.amountEvery' => ({required Object amount, required Object frequency}) => '${amount} · ${frequency}',
			'recurring.next' => ({required Object date}) => 'পরবর্তী: ${date}',
			'recurring.processPending' => 'বাকিগুলো প্রসেস করুন',
			'recurring.newTooltip' => 'নতুন পুনরাবৃত্ত লেনদেন',
			'recurring.delete.title' => 'পুনরাবৃত্ত লেনদেন মুছুন',
			'recurring.delete.confirm' => ({required Object name}) => 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান?',
			'recurring.form.edit' => 'পুনরাবৃত্ত সম্পাদনা',
			'recurring.form.amount' => 'পরিমাণ',
			'recurring.form.name' => 'নাম',
			'recurring.form.nameHint' => 'এই পুনরাবৃত্ত খরচটি কিসের জন্য?',
			'recurring.form.frequency' => 'কত দিন পরপর',
			'recurring.form.startDate' => 'শুরুর তারিখ',
			'recurring.form.endDate' => 'শেষের তারিখ (ঐচ্ছিক)',
			'recurring.form.noEndDate' => 'শেষের তারিখ নেই',
			'recurring.form.clearEndDate' => 'শেষের তারিখ মুছুন',
			'recurring.form.autoCreate' => 'নিজে থেকে তৈরিতে রাখুন',
			'recurring.form.autoCreateDetail' => '‘নিজে থেকে তৈরি’ চালু থাকলে অ্যাপ খুললে যোগ হবে',
			'recurring.form.active' => 'চালু',
			'recurring.form.activeDetail' => 'এই পুনরাবৃত্ত লেনদেনটি প্রসেস করুন',
			'recurring.form.amountRequired' => 'একটি পরিমাণ লিখুন',
			'recurring.form.amountInvalid' => 'সঠিক সংখ্যা লিখুন',
			'recurring.form.nameRequired' => 'একটি নাম লিখুন',
			'recurring.form.create' => 'নতুন পুনরাবৃত্ত',
			'reports.insights.highestDay.title' => 'সবচেয়ে বেশি খরচের দিন',
			'reports.insights.highestDay.description' => ({required Object day, required Object percent}) => '${day} আপনার সবচেয়ে বেশি খরচের দিন, দৈনিক গড়ের চেয়ে ${percent}% বেশি।',
			'reports.insights.topCategory.title' => 'সবচেয়ে বেশি খরচের ক্যাটাগরি',
			'reports.insights.topCategory.description' => ({required Object percent, required Object category}) => 'আপনার খরচের ${percent}% ${category}-এ।',
			'reports.insights.bestWeek.title' => 'সবচেয়ে সাশ্রয়ী সপ্তাহ',
			'reports.insights.bestWeek.description' => ({required Object range}) => '${range} ছিল আপনার সবচেয়ে কম খরচের সপ্তাহ।',
			'reports.insights.recurring.title' => 'পুনরাবৃত্ত খরচ',
			'reports.insights.recurring.description' => 'আসন্ন খরচের জন্য আপনার পুনরাবৃত্ত লেনদেনগুলো দেখুন।',
			'reports.insights.budgets.title' => 'বাজেটের অবস্থা',
			'reports.insights.budgets.description' => 'এই মাসে ঠিক পথে থাকতে আপনার বাজেটগুলো দেখুন।',
			'reports.title' => 'রিপোর্ট',
			'reports.askAi' => 'Expie-কে জিজ্ঞেস করুন',
			'reports.last7Days' => 'গত 7 দিন',
			'reports.last30Days' => 'গত 30 দিন',
			'reports.noCategoryData' => 'ক্যাটাগরির কোনো ডেটা নেই',
			'reports.noTrendData' => 'এখনো প্রবণতার ডেটা নেই',
			'reports.noSpending' => 'এখনো খরচের ডেটা নেই',
			'reports.totalSpentInPeriod' => ({required Object amount}) => 'এই সময়ে মোট খরচ: ${amount}',
			'reports.metrics.totalSpent' => 'মোট খরচ',
			'reports.metrics.dailyAverage' => 'দৈনিক গড়',
			'reports.metrics.highestDay' => 'সর্বোচ্চ দিন',
			'reports.spendingByCategory' => 'ক্যাটাগরি অনুযায়ী খরচ',
			'reports.observations' => 'এই মাসের খরচ থেকে মূল পর্যবেক্ষণ',
			'reports.noData' => 'কোনো ডেটা নেই',
			'settings.language.title' => 'ভাষা',
			'settings.language.sections.appLanguage' => 'অ্যাপের ভাষা',
			'settings.language.matchDevice' => 'ডিভাইসের মতো',
			'settings.language.matchDeviceSubtitle' => 'ফোনের ভাষা ব্যবহার করুন',
			'settings.language.names.en' => 'ইংরেজি',
			'settings.language.names.bn' => 'বাংলা',
			'settings.title' => 'সেটিংস',
			'settings.currency' => 'ডিফল্ট মুদ্রা',
			'settings.appearance' => 'থিম',
			'settings.notificationsBlocked' => 'বাজেট সতর্কতা পেতে সিস্টেম সেটিংসে Expenzo-র নোটিফিকেশন চালু করুন।',
			'settings.sections.preferences' => 'পছন্দ',
			'settings.sections.automation' => 'স্বয়ংক্রিয়',
			'settings.sections.support' => 'সহায়তা',
			'settings.sections.account' => 'প্রোফাইল ও অ্যাকাউন্ট',
			'settings.sections.notifications' => 'নোটিফিকেশন',
			'settings.sections.dataBudget' => 'ডেটা ও বাজেট',
			'settings.sections.general' => 'সাধারণ',
			'settings.notifications.title' => 'নোটিফিকেশন',
			'settings.notifications.rowSubtitle' => ({required Object total, required Object n}) => '${total}টির মধ্যে ${n}টি চালু',
			'settings.notifications.rowSubtitleOff' => 'বন্ধ',
			'settings.notifications.sections.general' => 'সাধারণ',
			'settings.notifications.sections.budgetAlerts' => 'বাজেট সতর্কতা',
			'settings.notifications.sections.recurring' => 'পুনরাবৃত্ত লেনদেন',
			'settings.notifications.sections.autoImport' => 'স্বয়ংক্রিয় ইমপোর্ট',
			'settings.notifications.master.title' => 'নোটিফিকেশন চালু রাখুন',
			'settings.notifications.master.subtitle' => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ, রিমাইন্ডার ও স্বয়ংক্রিয় ইমপোর্ট',
			'settings.notifications.blocked.title' => 'নোটিফিকেশন বন্ধ করা আছে',
			'settings.notifications.blocked.action' => 'সেটিংস খুলুন',
			'settings.notifications.over.title' => 'বাজেট ছাড়ানোর সতর্কতা',
			'settings.notifications.over.subtitle' => 'খরচ বাজেটের সীমা ছাড়ালে',
			'settings.notifications.nearLimit.title' => '80% সীমা',
			'settings.notifications.nearLimit.subtitle' => 'বাজেটের 80% খরচ হলে',
			'settings.notifications.weekly.title' => 'সাপ্তাহিক সারাংশ',
			'settings.notifications.weekly.subtitle' => ({required Object day}) => '${day} সন্ধ্যায়: এই সপ্তাহের খরচ, গত সপ্তাহের তুলনায়',
			'settings.notifications.reminders.title' => 'রিমাইন্ডার',
			'settings.notifications.reminders.subtitle' => 'পুনরাবৃত্ত লেনদেনের এক দিন আগে মনে করিয়ে দিন',
			'settings.notifications.autoImport.title' => 'স্বয়ংক্রিয় ইমপোর্ট করা লেনদেন',
			'settings.notifications.autoImport.subtitle' => 'SMS থেকে কোনো লেনদেন যোগ হলে',
			'settings.autoImportSubtitle' => 'ব্যাংক ও পেমেন্টের মেসেজ থেকে লেনদেন তৈরি করুন',
			'settings.smsWatchlist' => 'SMS ওয়াচলিস্ট',
			'settings.smsWatchlistSubtitle' => 'যেসব প্রেরকের মেসেজ Expenzo পড়ে',
			'settings.recurring.title' => 'পুনরাবৃত্ত লেনদেন',
			'settings.recurring.subtitle' => 'নিয়মিত আসা বিল ও আয়',
			'settings.help.title' => 'সাহায্য ও সহায়তা',
			'settings.help.rowSubtitle' => 'প্রশ্নোত্তর, যোগাযোগ, রেটিং, আইনি তথ্য',
			'settings.crashReports.title' => 'ক্র্যাশ রিপোর্ট পাঠান',
			'settings.crashReports.subtitle' => 'শুধু ত্রুটির তথ্য। টাকার অঙ্ক, নম্বর ও SMS-এর লেখা বাদ দেওয়া হয়।',
			'settings.signOut' => 'সাইন আউট',
			'settings.deleteAccount' => 'অ্যাকাউন্ট মুছুন',
			'settings.signIn.title' => 'সাইন ইন',
			'settings.signIn.subtitle' => 'আপনার সব ডিভাইসে ডেটা রাখুন',
			'settings.profile.title' => 'আমার প্রোফাইল',
			'settings.profile.rowSubtitle' => 'আপনার Google অ্যাকাউন্ট',
			'settings.profile.nameLabel' => 'নাম',
			'settings.profile.emailLabel' => 'ইমেইল',
			'settings.profile.noName' => 'এই Google অ্যাকাউন্টে কোনো নাম নেই',
			'settings.profile.signedInWith' => 'Google দিয়ে সাইন ইন করা',
			'settings.profile.googleNote' => 'আপনার নাম ও ছবি Google অ্যাকাউন্ট থেকে আসে। সেখানে পরিবর্তন করুন।',
			'settings.profile.deletingAccount' => 'আপনার অ্যাকাউন্ট মুছে ফেলা হচ্ছে…',
			'settings.profile.accountDeleted' => 'আপনার অ্যাকাউন্ট মুছে ফেলা হয়েছে',
			'settings.profile.signedOutTitle' => 'আপনি সাইন ইন করেননি',
			'settings.profile.signedOutBody' => 'সব ডিভাইসে আপনার লেনদেন রাখতে Google দিয়ে সাইন ইন করুন।',
			'settings.profile.guestName' => 'অতিথি',
			'settings.profile.guestSubtitle' => 'ডেটা সিঙ্ক করতে সাইন ইন করুন',
			'settings.deleteDialog.title' => 'অ্যাকাউন্ট মুছুন',
			'settings.deleteDialog.question' => 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট মুছে ফেলতে চান?',
			'settings.deleteDialog.listTitle' => 'আপনার অ্যাকাউন্ট ও এই ফোন থেকে স্থায়ীভাবে মুছে যাবে:',
			'settings.deleteDialog.transactions' => '• আপনার সব লেনদেন',
			'settings.deleteDialog.categories' => '• আপনার সব ক্যাটাগরি',
			'settings.deleteDialog.budgets' => '• আপনার সব বাজেট',
			'settings.deleteDialog.recurring' => '• আপনার সব পুনরাবৃত্ত লেনদেন',
			'settings.deleteDialog.rules' => '• আপনার সব মিলানোর নিয়ম',
			'settings.deleteDialog.cannotUndo' => 'এটি আর ফেরানো যাবে না।',
			'settings.deleteDialog.confirm' => 'আমি বুঝেছি এবং আমার অ্যাকাউন্ট মুছতে চাই',
			'settings.loadFailed' => 'আপনার সেটিংস লোড করা যায়নি।',
			'settings.appearanceScreen.sections.theme' => 'থিম',
			'settings.appearanceScreen.sections.preview' => 'প্রিভিউ',
			'settings.appearanceScreen.lightTitle' => 'লাইট মোড প্রিভিউ',
			'settings.appearanceScreen.lightBody' => 'নরম ল্যাভেন্ডার রঙের ছোঁয়ায় পরিষ্কার, উজ্জ্বল ইন্টারফেস।',
			'settings.appearanceScreen.darkTitle' => 'ডার্ক মোড প্রিভিউ',
			'settings.appearanceScreen.darkBody' => 'শান্ত, মনোযোগী অভিজ্ঞতার জন্য গাঢ় চারকোল পটভূমি আর ল্যাভেন্ডার রং।',
			'settings.currencyScreen.searchHint' => 'মুদ্রা খুঁজুন',
			'settings.currencyScreen.noResults' => ({required Object query}) => '"${query}"-এর সাথে মেলে এমন কোনো মুদ্রা নেই',
			'settings.numberFormat.title' => 'সংখ্যার ফরম্যাট',
			'settings.numberFormat.sections.preview' => 'প্রিভিউ',
			'settings.numberFormat.sections.decimalPlaces' => 'দশমিকের পরের ঘর',
			'settings.numberFormat.sections.grouping' => 'অঙ্কের গুচ্ছ',
			'settings.numberFormat.places.count' => ({required Object n}) => '${n} ঘর',
			'settings.numberFormat.places.noMinorUnits' => ({required Object currency}) => '${currency}-এ দশমিকের ঘর নেই',
			'settings.fontSize.title' => 'লেখার আকার',
			'settings.fontSize.sampleTitle' => 'নমুনা লেনদেন',
			'settings.fontSize.sampleBody' => 'বেছে নেওয়া আকারে আপনার লেনদেন এভাবে দেখাবে।',
			'settings.fontSize.sections.preview' => 'প্রিভিউ',
			'settings.fontSize.sections.fontSize' => 'লেখার আকার',
			'settings.calendar.title' => 'ক্যালেন্ডার',
			'settings.calendar.rowSubtitle' => ({required Object day}) => 'সপ্তাহ শুরু ${day}',
			'settings.calendar.sections.firstDayOfWeek' => 'সপ্তাহের প্রথম দিন',
			'settings.homePage.title' => 'হোম পেজ',
			'settings.homePage.intro' => 'অ্যাপ খুললে কোন স্ক্রিন দেখাবে তা বেছে নিন',
			'settings.homePage.sections.defaultHomePage' => 'ডিফল্ট হোম পেজ',
			'settings.homePage.options.home.title' => 'হোম',
			'settings.homePage.options.home.subtitle' => 'নিট, বাজেট ও সাম্প্রতিক লেনদেনের সারসংক্ষেপ',
			'settings.homePage.options.activity.title' => 'লেনদেন',
			'settings.homePage.options.activity.subtitle' => 'সব লেনদেনের পূর্ণ তালিকা',
			'settings.homePage.options.budgets.title' => 'বাজেট',
			'settings.homePage.options.budgets.subtitle' => 'বাজেটের সারসংক্ষেপ ও অগ্রগতি',
			'settings.homePage.options.reports.title' => 'রিপোর্ট',
			'settings.homePage.options.reports.subtitle' => 'প্রবণতা, ক্যাটাগরি ও বিশ্লেষণ',
			'settings.sync.title' => 'সিঙ্ক',
			'settings.sync.rowSubtitle' => 'আপনার সব ডিভাইসে ডেটা রাখুন',
			'settings.sync.onTitle' => 'সিঙ্ক চালু আছে',
			'settings.sync.onBody' => 'আপনার লেনদেন, বাজেট ও ক্যাটাগরি সাথে সাথে আপনার অ্যাকাউন্টে কপি হয়, তাই অন্য ডিভাইসেও পাবেন।',
			'settings.sync.offTitle' => 'সিঙ্ক বন্ধ',
			'settings.sync.offBody' => 'এই ডিভাইস কোনো পরিবর্তন পাঠাচ্ছে না বা পাচ্ছে না। পরিবর্তনগুলো এই ফোনে থাকবে এবং সিঙ্ক আবার চালু করলে পাঠানো হবে।',
			'settings.sync.signedOutTitle' => 'আপনার ডেটা সিঙ্ক করুন',
			'settings.sync.signedOutBody' => 'সব ডিভাইসে আপনার লেনদেন রাখতে Google দিয়ে সাইন ইন করুন।',
			'settings.sync.lastSynced' => 'শেষ সিঙ্ক',
			'settings.sync.never' => 'এখনও হয়নি',
			'settings.sync.today' => ({required Object time}) => 'আজ, ${time}',
			'settings.sync.yesterday' => ({required Object time}) => 'গতকাল, ${time}',
			'settings.sync.lastFailed' => ({required Object time}) => 'শেষ সিঙ্ক ব্যর্থ · ${time}',
			'settings.sync.retry' => 'আবার চেষ্টা করুন',
			'settings.sync.failureBannerTitle' => 'সিঙ্ক এখন কাজ করছে না',
			'settings.sync.failureBannerBody' => 'আপনার পরিবর্তনগুলো এই ফোনে নিরাপদ আছে এবং সিঙ্ক আবার কাজ করলে পাঠানো হবে।',
			'settings.sync.pending' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি পরিবর্তন পাঠানোর অপেক্ষায়', other: '${n}টি পরিবর্তন পাঠানোর অপেক্ষায়', ), 
			'settings.sync.allSent' => 'সব পরিবর্তন পাঠানো হয়েছে',
			'settings.sync.failed' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি পরিবর্তন সিঙ্ক হয়নি', other: '${n}টি পরিবর্তন সিঙ্ক হয়নি', ), 
			'settings.sync.sections.device' => 'এই ডিভাইস',
			'settings.sync.enable' => 'এই ডিভাইসে সিঙ্ক',
			'settings.sync.syncNow' => 'এখনই সিঙ্ক করুন',
			'settings.sync.syncing' => 'সিঙ্ক হচ্ছে…',
			'settings.sync.loadFailed' => 'সিঙ্কের অবস্থা দেখানো যায়নি',
			'settings.sync.result.success' => 'সিঙ্ক সম্পন্ন',
			'settings.sync.result.offline' => 'আপনি অফলাইনে আছেন। অনলাইনে ফিরলে পরিবর্তন পাঠানো হবে।',
			'settings.sync.result.failed' => 'সিঙ্ক শেষ হয়নি। এটি নিজে থেকে আবার চেষ্টা করবে।',
			'settings.sync.result.disabled' => 'আগে সিঙ্ক চালু করুন',
			'settings.sync.result.signedOut' => 'সিঙ্কের জন্য সাইন ইন করুন',
			'settings.sync.result.firstSyncPending' => 'সাইন ইন শেষ হচ্ছে। একটু পরে আবার চেষ্টা করুন।',
			'settings.export.title' => 'ডেটা এক্সপোর্ট',
			'settings.export.rowSubtitle' => 'আপনার লেনদেন CSV ফাইলে সংরক্ষণ করুন',
			'settings.export.infoTitle' => 'আপনার আর্থিক ডেটা এক্সপোর্ট করুন',
			'settings.export.infoBody' => 'স্প্রেডশিট বা হিসাব সফটওয়্যারে ব্যবহারের জন্য আপনার লেনদেন, বাজেট ও ক্যাটাগরি CSV ফাইলে সংরক্ষণ করুন।',
			'settings.export.sections.dateRange' => 'তারিখের সীমা',
			'settings.export.sections.include' => 'অন্তর্ভুক্ত করুন',
			'settings.export.ranges.allTime' => 'সব সময়',
			'settings.export.ranges.allTimeSubtitle' => 'সবকিছু এক্সপোর্ট করুন',
			'settings.export.ranges.thisYear' => 'এই বছর',
			'settings.export.ranges.lastSixMonths' => 'গত 6 মাস',
			'settings.export.ranges.lastThreeMonths' => 'গত 3 মাস',
			'settings.export.ranges.custom' => 'নিজে বেছে নিন',
			'settings.export.ranges.customSubtitle' => 'শুরু ও শেষের তারিখ বেছে নিন',
			'settings.export.ranges.untilToday' => ({required Object start}) => '${start} – এখন পর্যন্ত',
			'settings.export.ranges.between' => ({required Object start, required Object end}) => '${start} – ${end}',
			'settings.export.include.transactions' => 'লেনদেন',
			'settings.export.include.budgets' => 'বাজেট',
			'settings.export.include.categories' => 'ক্যাটাগরি',
			'settings.export.rangeNote' => 'তারিখের সীমা শুধু লেনদেনে প্রযোজ্য। বাজেট ও ক্যাটাগরি সম্পূর্ণ এক্সপোর্ট হয়।',
			'settings.export.button' => 'ডেটা এক্সপোর্ট',
			'settings.export.exporting' => 'এক্সপোর্ট তৈরি হচ্ছে…',
			'settings.export.shareSubject' => 'Expenzo এক্সপোর্ট',
			'settings.export.nothingSelected' => 'এক্সপোর্টের জন্য অন্তত একটি বেছে নিন',
			'settings.export.emptyRange' => 'এই সময়সীমায় কোনো লেনদেন নেই',
			'settings.deleteData.title' => 'সব ডেটা মুছুন',
			'settings.deleteData.rowSubtitle' => 'লেনদেন, বাজেট ও সেটিংস মুছে ফেলুন',
			'settings.deleteData.warningTitle' => 'এই কাজ আর ফেরানো যাবে না',
			'settings.deleteData.warningBody' => 'লেনদেন, বাজেট, ক্যাটাগরি ও সেটিংসসহ আপনার সব আর্থিক ডেটা মুছে যাবে। এই ডিভাইস থেকে সবকিছু স্থায়ীভাবে মুছে যাবে।',
			'settings.deleteData.warningBodySignedIn' => 'লেনদেন, বাজেট, ক্যাটাগরি ও সেটিংসসহ আপনার সব আর্থিক ডেটা এই ডিভাইস ও আপনার অ্যাকাউন্ট থেকে মুছে যাবে।',
			'settings.deleteData.otherDevicesNote' => 'আপনার অন্য ডিভাইসগুলোতে সেখানে না মোছা পর্যন্ত ডেটা থেকে যাবে।',
			'settings.deleteData.sections.summary' => 'যে ডেটা মুছে যাবে',
			'settings.deleteData.sections.confirmation' => 'নিশ্চিতকরণ',
			'settings.deleteData.transactions' => 'লেনদেন',
			'settings.deleteData.transactionsCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি লেনদেন', other: '${n}টি লেনদেন', ), 
			'settings.deleteData.budgets' => 'বাজেট',
			'settings.deleteData.budgetsCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি বাজেট', other: '${n}টি বাজেট', ), 
			'settings.deleteData.categories' => 'ক্যাটাগরি',
			'settings.deleteData.categoriesCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি ক্যাটাগরি', other: '${n}টি ক্যাটাগরি', ), 
			'settings.deleteData.recurring' => 'পুনরাবৃত্ত লেনদেন',
			'settings.deleteData.recurringCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি পুনরাবৃত্ত', other: '${n}টি পুনরাবৃত্ত', ), 
			'settings.deleteData.smsRules' => 'SMS নিয়ম',
			'settings.deleteData.smsRulesCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি নিয়ম', other: '${n}টি নিয়ম', ), 
			'settings.deleteData.goals' => 'লক্ষ্য',
			'settings.deleteData.goalsCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি লক্ষ্য', other: '${n}টি লক্ষ্য', ), 
			'settings.deleteData.settings' => 'সেটিংস',
			'settings.deleteData.settingsValue' => 'সব পছন্দ',
			'settings.deleteData.categoriesNote' => 'ডিফল্ট ক্যাটাগরিগুলো আবার যোগ হবে।',
			'settings.deleteData.confirmHint' => 'নিশ্চিত করতে DELETE লিখুন',
			'settings.deleteData.button' => 'সব ডেটা মুছুন',
			'settings.deleteData.deleting' => 'মুছে ফেলা হচ্ছে…',
			'settings.deleteData.done' => 'সব ডেটা মুছে ফেলা হয়েছে',
			'settings.deleteData.serverFailed' => 'আপনার অ্যাকাউন্টের ডেটা মুছতে পারা যায়নি। কিছুই মোছা হয়নি। সংযোগ দেখে আবার চেষ্টা করুন।',
			'settings.deleteData.familyAdminNote' => 'আপনার তৈরি শেয়ার করা বাজেটগুলো আপনার পরিবারের জন্যও মুছে যাবে।',
			'settings.categories.rowSubtitle' => 'ক্যাটাগরি যোগ, সম্পাদনা ও মুছে ফেলুন',
			'settings.family.title' => 'পারিবারিক গ্রুপ',
			'settings.family.rowSubtitle' => 'পরিবারের সাথে বাজেট শেয়ার করুন',
			'settings.family.sections.spendingByMember' => 'সদস্য অনুযায়ী খরচ',
			'settings.family.sections.sharedBudgets' => 'শেয়ার করা বাজেটের অগ্রগতি',
			'shell.tabs.home' => 'হোম',
			'shell.tabs.activity' => 'লেনদেন',
			'shell.tabs.budgets' => 'বাজেট',
			'shell.tabs.reports' => 'রিপোর্ট',
			'shell.reportsTabs.trend' => 'প্রবণতা',
			'shell.reportsTabs.categories' => 'ক্যাটাগরি',
			'shell.reportsTabs.insights' => 'বিশ্লেষণ',
			'smsParser.range.last7Days' => 'গত 7 দিন',
			'smsParser.range.last30Days' => 'গত 30 দিন',
			'smsParser.range.last3Months' => 'গত 3 মাস',
			'smsParser.range.allTime' => 'সব সময়',
			'smsParser.range.custom' => 'নির্দিষ্ট তারিখের সীমা',
			'smsParser.range.from' => ({required Object date}) => '${date} থেকে',
			'smsParser.range.until' => ({required Object date}) => '${date} পর্যন্ত',
			'smsParser.range.selectDate' => 'তারিখ বেছে নিন',
			'smsParser.summary.range' => 'সময়সীমা',
			'smsParser.summary.matches' => 'মিলেছে',
			'smsParser.summary.selected' => 'বাছাই করা',
			'smsParser.card.rule' => ({required Object id}) => 'নিয়ম: ${id}',
			'smsParser.card.noAmount' => 'পরিমাণ নেই',
			'smsParser.options.title' => 'রেকর্ডের জন্য পুরোনো SMS স্ক্যান করুন',
			'smsParser.toolbar.sender' => 'প্রেরক',
			'smsParser.toolbar.flatList' => 'সাধারণ তালিকা',
			'smsParser.toolbar.clear' => 'মুছুন',
			'smsParser.section.selectAll' => 'সব বাছাই করুন',
			'smsParser.section.clear' => 'মুছুন',
			'smsParser.section.counts' => ({required num n, required Object selected}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: '${n}টি মেসেজ · ${selected}টি বাছাই করা', other: '${n}টি মেসেজ · ${selected}টি বাছাই করা', ), 
			'smsParser.customRange.title' => 'নিজের মতো সময়সীমা বেছে নিন',
			'smsParser.customRange.body' => 'পুরোনো SMS স্ক্যান করার আগে শুরু ও শেষের তারিখ বেছে নিন।',
			'smsParser.customRange.start' => 'শুরুর তারিখ',
			'smsParser.customRange.end' => 'শেষের তারিখ',
			'smsParser.customRange.invalid' => 'সঠিক শুরু ও শেষের তারিখ বেছে নিন।',
			'smsParser.customRange.apply' => 'প্রয়োগ করুন',
			'smsParser.results.title' => 'স্ক্যানের ফলাফল',
			'smsParser.results.empty' => 'নতুন কোনো রেকর্ড পাওয়া যায়নি',
			'smsParser.results.emptyBody' => 'আবার স্ক্যান করুন অথবা আরও মিলানোর নিয়ম যোগ করুন',
			'smsParser.results.create' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('bn'))(n, one: 'বাছাই করা ${n}টি রেকর্ড যোগ করুন', other: 'বাছাই করা ${n}টি রেকর্ড যোগ করুন', ), 
			'smsParser.autoImport.scanPast' => 'পুরোনো SMS স্ক্যান করুন',
			'support.help.watchTutorial' => 'টিউটোরিয়াল দেখুন',
			'support.help.replaySetup.title' => 'আবার সেটআপ করুন',
			'support.help.replaySetup.rowSubtitle' => 'আয়, বাজেট ও লক্ষ্য আবার ঠিক করুন',
			'support.help.replaySetup.confirmTitle' => 'আবার সেটআপ করবেন?',
			'support.help.replaySetup.confirmBody' => 'আপনার লেনদেন যেমন আছে তেমনই থাকবে। আবার যোগ করা বাজেট, নিয়মিত পেমেন্ট ও লক্ষ্য নতুন আইটেম হিসেবে তৈরি হবে।',
			'support.help.title' => 'সাহায্য ও সহায়তা',
			'support.help.faq' => 'সাধারণ প্রশ্ন',
			'support.help.contactSupport' => 'সহায়তার জন্য যোগাযোগ',
			'support.help.rateApp' => 'অ্যাপটি রেট করুন',
			'support.help.privacyPolicy' => 'গোপনীয়তা নীতি',
			'support.help.termsOfService' => 'পরিষেবার শর্তাবলি',
			'support.help.about' => 'সম্পর্কে',
			'support.help.linkFailed' => 'পেজটি খোলা যায়নি। পরে আবার চেষ্টা করুন।',
			'support.about.title' => 'Expenzo সম্পর্কে',
			'support.about.version' => ({required Object version, required Object build}) => 'সংস্করণ ${version} (${build})',
			'support.about.description' => 'Expenzo আপনার খরচ, বাজেট ও নিয়মিত বিল ট্র্যাক করে, এবং ব্যাংকের SMS পড়ে আপনার হয়ে লেনদেন লিখে রাখতে পারে।',
			'support.about.madeBy' => 'তৈরি করেছে Acesif Labs',
			'support.faq.title' => 'সাধারণ প্রশ্ন',
			'support.faq.searchHint' => 'প্রশ্ন খুঁজুন...',
			'support.faq.noResults' => ({required Object query}) => '"${query}"-এর সাথে কোনো প্রশ্ন মেলেনি।',
			'support.faq.addTransaction.q' => 'কীভাবে লেনদেন যোগ করব?',
			'support.faq.addTransaction.a' => 'যেকোনো ট্যাবের নিচের + বোতামে ট্যাপ করুন। খরচ বা আয় বেছে নিন, পরিমাণ লিখুন, একটি ক্যাটাগরি বাছুন, তারপর খরচ যোগ করুন বা আয় যোগ করুন-এ ট্যাপ করুন।',
			'support.faq.autoImport.q' => 'স্বয়ংক্রিয় ইমপোর্ট কীভাবে কাজ করে?',
			'support.faq.autoImport.a' => 'সেটিংস → SMS থেকে স্বয়ংক্রিয় ইমপোর্ট-এ গিয়ে SMS পড়ার অনুমতি দিন। Expenzo আপনার ফোনের ব্যাংক ও পেমেন্ট মেসেজ পড়ে সেগুলোকে লেনদেনে রূপান্তর করে। মেসেজের লেখা ফোনেই থাকে; এ থেকে তৈরি লেনদেন অন্য লেনদেনের মতোই সিঙ্ক হয়। পুরোনো মেসেজ আনতে ওই পেজে পুরোনো SMS স্ক্যান করুন-এ ট্যাপ করুন।',
			'support.faq.budget.q' => 'কীভাবে বাজেট তৈরি করব?',
			'support.faq.budget.a' => 'বাজেট ট্যাব খুলে নতুন বাজেট-এ ট্যাপ করুন। একটি নাম, পরিমাণ ও সময়কাল (সাপ্তাহিক, মাসিক বা বার্ষিক) দিন। খরচ যোগ করার সময় সেটি কোন বাজেটে গণ্য হবে তা বেছে নিন, আর বাজেটে দেখাবে কত বাকি আছে। আয় কোনো বাজেটে গণ্য হয় না।',
			'support.faq.recurring.q' => 'পুনরাবৃত্ত লেনদেন কীভাবে কাজ করে?',
			'support.faq.recurring.a' => 'সেটিংস → পুনরাবৃত্ত লেনদেন-এ গিয়ে একটি বিল বা আয় এবং কত দিন পরপর হয় তা যোগ করুন। নিজে থেকে লেনদেন তৈরি চালু করলে অ্যাপ খুললেই Expenzo বকেয়া লেনদেন যোগ করে দেয়। বন্ধ থাকলে পুনরাবৃত্ত লেনদেন খুলে ওপরের বাকিগুলো প্রসেস করুন বোতামে (গোল তীর চিহ্ন) ট্যাপ করুন।',
			'support.faq.export.q' => 'আমি কি আমার ডেটা এক্সপোর্ট করতে পারি?',
			'support.faq.export.a' => 'হ্যাঁ। সেটিংস → ডেটা এক্সপোর্ট-এ গিয়ে তারিখের পরিসর এবং কী কী রাখবেন (লেনদেন, বাজেট, ক্যাটাগরি) বেছে নিন। একটি ধরন হলে CSV ফাইল হিসেবে, একাধিক হলে CSV ফাইলের একটি ZIP হিসেবে শেয়ার হয়।',
			'support.faq.sync.q' => 'ফোন হারালে কি আমার ডেটা নিরাপদ থাকবে?',
			'support.faq.sync.a' => 'Google দিয়ে সাইন ইন করা থাকলে এবং সিঙ্ক চালু থাকলে (এটি ডিফল্টভাবে চালু), আপনার লেনদেন, বাজেট, ক্যাটাগরি, পুনরাবৃত্ত লেনদেন এবং স্বয়ংক্রিয় ইমপোর্টের প্রেরক ও নিয়ম আপনার অ্যাকাউন্টে থাকে। নতুন ফোনে সাইন ইন করলে সেগুলো ফিরে পাবেন। অ্যাপের সেটিংস প্রতিটি ফোনে আলাদা থাকে। সাইন ইন না করলে ডেটা শুধু এই ফোনেই থাকে।',
			'support.faq.aiAssistant.q' => 'Expie কীভাবে কাজ করে?',
			'support.faq.aiAssistant.a' => 'রিপোর্ট ট্যাবে রোবট বাটনে ট্যাপ করে Expie-কে আপনার খরচ, বাজেট বা আয় নিয়ে প্রশ্ন করুন। Expie এই মাসের ডেটার একটি সারাংশ থেকে উত্তর দেয়; ইমেইল ও ফোন নম্বরের মতো ব্যক্তিগত তথ্য বাদ দিয়ে সারাংশটি আমাদের AI প্রদানকারী Groq-এ পাঠানো হয়। এটি পরামর্শ দেয়, আর্থিক উপদেশ নয়।',
			'support.faq.currency.q' => 'কীভাবে মুদ্রা বদলাব?',
			'support.faq.currency.a' => 'সেটিংস → ডিফল্ট মুদ্রা-তে যান। পরিমাণ রূপান্তর হয় না; শুধু চিহ্ন ও ফরম্যাট বদলায়।',
			'support.rate.title' => 'Expenzo ভালো লাগছে?',
			'support.rate.heading' => 'Expenzo উপভোগ করছেন?',
			'support.rate.subtitle' => 'আপনার মতামত আমাদের আরও ভালো করতে সাহায্য করে। অ্যাপটি রেট করতে একটি তারায় ট্যাপ করুন।',
			'support.rate.writeReview' => 'রিভিউ লিখুন',
			'support.rate.tellUs' => 'কী ভালো করা দরকার জানান',
			'support.rate.maybeLater' => 'পরে দেখব',
			'support.rate.noThanks' => 'না, ধন্যবাদ',
			'support.rate.starLabel' => ({required Object n}) => '5টির মধ্যে ${n}টি তারা',
			_ => null,
		};
	}
}
