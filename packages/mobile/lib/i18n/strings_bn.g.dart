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
	@override late final _Translations$messageTemplates$bn messageTemplates = _Translations$messageTemplates$bn._(_root);
	@override late final _Translations$notifications$bn notifications = _Translations$notifications$bn._(_root);
	@override late final _Translations$parsingRules$bn parsingRules = _Translations$parsingRules$bn._(_root);
	@override late final _Translations$receiptScan$bn receiptScan = _Translations$receiptScan$bn._(_root);
	@override late final _Translations$records$bn records = _Translations$records$bn._(_root);
	@override late final _Translations$recurring$bn recurring = _Translations$recurring$bn._(_root);
	@override late final _Translations$reports$bn reports = _Translations$reports$bn._(_root);
	@override late final _Translations$settings$bn settings = _Translations$settings$bn._(_root);
	@override late final _Translations$shell$bn shell = _Translations$shell$bn._(_root);
	@override late final _Translations$smsParser$bn smsParser = _Translations$smsParser$bn._(_root);
}

// Path: aiAssistant
class _Translations$aiAssistant$bn extends Translations$aiAssistant$en {
	_Translations$aiAssistant$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI সহকারী';
	@override String get inputHint => 'আপনার খরচ নিয়ে জিজ্ঞেস করুন';
	@override String get send => 'মেসেজ পাঠান';
	@override String get disclaimer => 'Expenzo AI আপনার ডেটা দেখে পরামর্শ দেয়। এটি কোনো লাইসেন্সপ্রাপ্ত আর্থিক উপদেষ্টা নয়।';
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
	@override String get matchingRules => 'মিলানোর নিয়ম';
	@override late final _Translations$common$errors$bn errors = _Translations$common$errors$bn._(_root);
	@override late final _Translations$common$dates$bn dates = _Translations$common$dates$bn._(_root);
	@override late final _Translations$common$a11y$bn a11y = _Translations$common$a11y$bn._(_root);
	@override late final _Translations$common$feedback$bn feedback = _Translations$common$feedback$bn._(_root);
	@override String get search => 'খুঁজুন';
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
	@override String greeting({required Object name}) => 'হ্যালো, ${name}';
	@override String get userFallback => 'ব্যবহারকারী';
	@override String get income => 'আয়';
	@override String get expense => 'খরচ';
	@override late final _Translations$dashboard$sections$bn sections = _Translations$dashboard$sections$bn._(_root);
	@override String get noBudgets => 'এখনো কোনো বাজেট নেই';
	@override String get noTransactions => 'এখনো কোনো লেনদেন নেই';
	@override late final _Translations$dashboard$menu$bn menu = _Translations$dashboard$menu$bn._(_root);
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
	@override late final _Translations$notifications$syncError$bn syncError = _Translations$notifications$syncError$bn._(_root);
}

// Path: parsingRules
class _Translations$parsingRules$bn extends Translations$parsingRules$en {
	_Translations$parsingRules$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get addFromFormats => 'SMS ফরম্যাট থেকে নিয়ম যোগ করুন';
	@override String get newRule => 'নতুন নিয়ম';
	@override String get editRule => 'নিয়ম সম্পাদনা';
	@override String get add => 'যোগ করুন';
	@override String added({required Object name}) => '"${name}" যোগ হয়েছে';
	@override late final _Translations$parsingRules$empty$bn empty = _Translations$parsingRules$empty$bn._(_root);
	@override String get created => 'নিয়ম তৈরি হয়েছে';
	@override String get updated => 'নিয়ম আপডেট হয়েছে';
	@override late final _Translations$parsingRules$delete$bn delete = _Translations$parsingRules$delete$bn._(_root);
	@override late final _Translations$parsingRules$validation$bn validation = _Translations$parsingRules$validation$bn._(_root);
	@override late final _Translations$parsingRules$form$bn form = _Translations$parsingRules$form$bn._(_root);
	@override late final _Translations$parsingRules$tester$bn tester = _Translations$parsingRules$tester$bn._(_root);
	@override Map<String, String> get templates => {
		'hdfc_bank_sms': 'HDFC ব্যাংকের ডেবিট নোটিফিকেশন পড়ে',
		'icici_bank_sms': 'ICICI ব্যাংকের ডেবিট নোটিফিকেশন পড়ে',
		'sbi_sms': 'স্টেট ব্যাংক অব ইন্ডিয়ার ডেবিট নোটিফিকেশন পড়ে',
		'upi_payment_sms': 'UPI পেমেন্টের নোটিফিকেশন পড়ে (PhonePe, Google Pay, Paytm)',
		'amazon_order_sms': 'Amazon অর্ডার কনফার্মেশন ও ডেলিভারির SMS পড়ে',
		'amazon_order_email': 'Amazon অর্ডারের ইমেইল পড়ে',
		'swiggy_order_email': 'Swiggy অর্ডার কনফার্মেশনের ইমেইল পড়ে',
		'zomato_order_email': 'Zomato অর্ডার কনফার্মেশনের ইমেইল পড়ে',
		'flipkart_order_email': 'Flipkart অর্ডারের ইমেইল পড়ে',
		'generic_payment_email': 'সাধারণ পেমেন্ট কনফার্মেশনের ইমেইল পড়ে',
	};
}

// Path: receiptScan
class _Translations$receiptScan$bn extends Translations$receiptScan$en {
	_Translations$receiptScan$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get permissionRequired => 'রসিদ স্ক্যান করতে ক্যামেরার অনুমতি দরকার।';
	@override String get noCamera => 'এই ডিভাইসে কোনো ক্যামেরা নেই।';
	@override String get cameraFailed => 'ক্যামেরা চালু করা যায়নি।';
	@override String get captureFailed => 'ছবি তোলা যায়নি। আবার চেষ্টা করুন।';
	@override String get readFailed => 'রসিদটি পড়া যায়নি। আবার চেষ্টা করুন অথবা নিজে যোগ করুন।';
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
	@override String get askAi => 'AI-কে জিজ্ঞেস করুন';
	@override String get last7Days => 'গত ৭ দিন';
	@override String get last30Days => 'গত ৩০ দিন';
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
	@override String get matchingRulesSubtitle => 'যেসব মেসেজ অটো-ইমপোর্ট এখনো পড়তে পারে না, সেগুলোর প্যাটার্ন';
	@override late final _Translations$settings$recurring$bn recurring = _Translations$settings$recurring$bn._(_root);
	@override String get feedbackSubtitle => 'সমস্যা জানান বা কোনো আইডিয়া দিন';
	@override String get signOut => 'সাইন আউট';
	@override String get deleteAccount => 'অ্যাকাউন্ট মুছুন';
	@override late final _Translations$settings$signIn$bn signIn = _Translations$settings$signIn$bn._(_root);
	@override late final _Translations$settings$deleteDialog$bn deleteDialog = _Translations$settings$deleteDialog$bn._(_root);
	@override String get loadFailed => 'আপনার সেটিংস লোড করা যায়নি।';
	@override late final _Translations$settings$appearanceScreen$bn appearanceScreen = _Translations$settings$appearanceScreen$bn._(_root);
	@override late final _Translations$settings$currencyScreen$bn currencyScreen = _Translations$settings$currencyScreen$bn._(_root);
	@override late final _Translations$settings$numberFormat$bn numberFormat = _Translations$settings$numberFormat$bn._(_root);
	@override late final _Translations$settings$fontSize$bn fontSize = _Translations$settings$fontSize$bn._(_root);
	@override late final _Translations$settings$calendar$bn calendar = _Translations$settings$calendar$bn._(_root);
	@override late final _Translations$settings$categories$bn categories = _Translations$settings$categories$bn._(_root);
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
	@override String get criticalTitle => 'অপ্রত্যাশিত সমস্যা হয়েছে';
	@override String get criticalBody => 'অ্যাপটি কিছুক্ষণের মধ্যে বন্ধ হয়ে যাবে।';
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

// Path: dashboard.menu
class _Translations$dashboard$menu$bn extends Translations$dashboard$menu$en {
	_Translations$dashboard$menu$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get profile => 'প্রোফাইল';
	@override String get signIn => 'সাইন ইন';
	@override String get settings => 'সেটিংস';
	@override String get signOut => 'সাইন আউট';
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
	@override String get both => 'দুটোই';
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
	@override String get step1 => 'ধাপ ১/৩: একটি মূল শব্দ বেছে নিন';
	@override String get step1Body => 'এমন একটি শব্দ বেছে নিন যা এই ধরনের প্রতিটি মেসেজে থাকে, যেমন "debited", "paid" বা "spent"।';
	@override String get wordsInMessage => 'এই মেসেজের শব্দগুলো';
	@override String get step1Hint => 'চালিয়ে যেতে একটি শব্দ বেছে নিন।';
	@override String get step2 => 'ধাপ ২/৩: পরিমাণ বেছে নিন';
	@override String get step2Body => 'কোন সংখ্যাটি আপনার খরচের পরিমাণ?';
	@override String get step2Hint => 'চালিয়ে যেতে পরিমাণ বেছে নিন।';
	@override String get step3 => 'ধাপ ৩/৩: দেখে নিন';
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

// Path: notifications.channel
class _Translations$notifications$channel$bn extends Translations$notifications$channel$en {
	_Translations$notifications$channel$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get name => 'অ্যাপের নোটিফিকেশন';
	@override String get description => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ, পুনরাবৃত্ত রিমাইন্ডার ও স্ক্যানের ফলাফল';
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

// Path: notifications.syncError
class _Translations$notifications$syncError$bn extends Translations$notifications$syncError$en {
	_Translations$notifications$syncError$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সিঙ্কে সমস্যা';
}

// Path: parsingRules.empty
class _Translations$parsingRules$empty$bn extends Translations$parsingRules$empty$en {
	_Translations$parsingRules$empty$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'এখনো কোনো নিয়ম নেই';
	@override String get body => 'মিলে যাওয়া SMS ও ইমেইলকে রেকর্ডে বদলাতে একটি নিয়ম যোগ করুন।';
	@override String get add => 'নিয়ম যোগ করুন';
}

// Path: parsingRules.delete
class _Translations$parsingRules$delete$bn extends Translations$parsingRules$delete$en {
	_Translations$parsingRules$delete$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'নিয়ম মুছুন';
	@override String confirm({required Object name}) => 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান?';
}

// Path: parsingRules.validation
class _Translations$parsingRules$validation$bn extends Translations$parsingRules$validation$en {
	_Translations$parsingRules$validation$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get nameRequired => 'নাম দিতে হবে';
	@override String get triggerRequired => 'অন্তত একটি মূল শব্দ দিতে হবে';
	@override String get amountRequired => 'পরিমাণের প্যাটার্ন দিতে হবে';
	@override String get invalidRegex => 'রেগুলার এক্সপ্রেশন সঠিক নয়';
	@override String invalidRegexDetail({required Object detail}) => 'রেগুলার এক্সপ্রেশন সঠিক নয়: ${detail}';
	@override String get valid => 'প্যাটার্ন সঠিক';
}

// Path: parsingRules.form
class _Translations$parsingRules$form$bn extends Translations$parsingRules$form$en {
	_Translations$parsingRules$form$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get name => 'নাম *';
	@override String get nameHint => 'যেমন: HDFC Bank SMS';
	@override String get keyWords => 'মূল শব্দ *';
	@override String get keyWordsHint => 'HDFC, debit, account (কমা দিয়ে আলাদা করুন)';
	@override String get keyWordsHelper => 'যেসব শব্দ থাকলে এই নিয়মটি চেষ্টা করা হবে';
	@override String get amountPattern => 'পরিমাণের প্যাটার্ন (regex) *';
	@override String get amountRegex => 'পরিমাণের regex';
	@override String get datePattern => 'তারিখের প্যাটার্ন (ঐচ্ছিক)';
	@override String get dateRegex => 'তারিখের regex (ঐচ্ছিক)';
	@override String get dateHelper => 'তারিখ না লাগলে খালি রাখুন';
	@override String get source => 'উৎস';
	@override String get priority => 'অগ্রাধিকার';
	@override String get priorityHelper => 'বেশি অগ্রাধিকারের নিয়ম আগে চেষ্টা করা হয়';
	@override String get enabled => 'চালু';
	@override String get enabledDetail => 'মেসেজ পড়ার সময় এই নিয়মটি ব্যবহার করুন';
}

// Path: parsingRules.tester
class _Translations$parsingRules$tester$bn extends Translations$parsingRules$tester$en {
	_Translations$parsingRules$tester$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get timeout => 'সময় শেষ: প্যাটার্নটি ২ সেকেন্ডের বেশি সময় নিয়েছে';
	@override String get error => 'সমস্যা';
	@override String get match => 'মিল পাওয়া গেছে';
	@override String get noMatch => 'মিল নেই';
	@override String elapsed({required Object ms}) => '${ms} ms';
	@override String get amount => 'পরিমাণ';
	@override String get date => 'তারিখ';
	@override String confidence({required Object percent}) => '${percent}% নিশ্চয়তা';
	@override String get sample => 'পরীক্ষার জন্য নমুনা মেসেজ';
	@override String get sampleHint => 'একটি নমুনা SMS বা ইমেইলের লেখা দিন';
	@override String get enterSample => 'প্যাটার্ন পরীক্ষা করতে ওপরে একটি নমুনা মেসেজ দিন';
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
	@override String rowSubtitle({required Object n}) => '4টির মধ্যে ${n}টি চালু';
	@override String get rowSubtitleOff => 'বন্ধ';
	@override late final _Translations$settings$notifications$sections$bn sections = _Translations$settings$notifications$sections$bn._(_root);
	@override late final _Translations$settings$notifications$master$bn master = _Translations$settings$notifications$master$bn._(_root);
	@override late final _Translations$settings$notifications$blocked$bn blocked = _Translations$settings$notifications$blocked$bn._(_root);
	@override late final _Translations$settings$notifications$over$bn over = _Translations$settings$notifications$over$bn._(_root);
	@override late final _Translations$settings$notifications$nearLimit$bn nearLimit = _Translations$settings$notifications$nearLimit$bn._(_root);
	@override late final _Translations$settings$notifications$weekly$bn weekly = _Translations$settings$notifications$weekly$bn._(_root);
	@override late final _Translations$settings$notifications$reminders$bn reminders = _Translations$settings$notifications$reminders$bn._(_root);
}

// Path: settings.recurring
class _Translations$settings$recurring$bn extends Translations$settings$recurring$en {
	_Translations$settings$recurring$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'পুনরাবৃত্ত লেনদেন';
	@override String get subtitle => 'নিয়মিত আসা বিল ও আয়';
}

// Path: settings.signIn
class _Translations$settings$signIn$bn extends Translations$settings$signIn$en {
	_Translations$settings$signIn$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'সাইন ইন';
	@override String get subtitle => 'আপনার সব ডিভাইসে ডেটা রাখুন';
}

// Path: settings.deleteDialog
class _Translations$settings$deleteDialog$bn extends Translations$settings$deleteDialog$en {
	_Translations$settings$deleteDialog$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'অ্যাকাউন্ট মুছুন';
	@override String get question => 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট মুছে ফেলতে চান?';
	@override String get listTitle => 'এতে স্থায়ীভাবে মুছে যাবে:';
	@override String get expenses => '• আপনার সব খরচ';
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

// Path: settings.categories
class _Translations$settings$categories$bn extends Translations$settings$categories$en {
	_Translations$settings$categories$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get rowSubtitle => 'ক্যাটাগরি যোগ, সম্পাদনা ও মুছে ফেলুন';
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
	@override String get last7Days => 'গত ৭ দিন';
	@override String get last30Days => 'গত ৩০ দিন';
	@override String get last3Months => 'গত ৩ মাস';
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

// Path: budgets.details.periodBudget
class _Translations$budgets$details$periodBudget$bn extends Translations$budgets$details$periodBudget$en {
	_Translations$budgets$details$periodBudget$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get weekly => 'সাপ্তাহিক বাজেট';
	@override String get monthly => 'মাসিক বাজেট';
	@override String get yearly => 'বার্ষিক বাজেট';
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
}

// Path: settings.notifications.master
class _Translations$settings$notifications$master$bn extends Translations$settings$notifications$master$en {
	_Translations$settings$notifications$master$bn._(TranslationsBn root) : this._root = root, super.internal(root);

	final TranslationsBn _root; // ignore: unused_field

	// Translations
	@override String get title => 'নোটিফিকেশন চালু রাখুন';
	@override String get subtitle => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ ও রিমাইন্ডার';
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

/// The flat map containing all translations for locale <bn>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsBn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'aiAssistant.title' => 'AI সহকারী',
			'aiAssistant.inputHint' => 'আপনার খরচ নিয়ে জিজ্ঞেস করুন',
			'aiAssistant.send' => 'মেসেজ পাঠান',
			'aiAssistant.disclaimer' => 'Expenzo AI আপনার ডেটা দেখে পরামর্শ দেয়। এটি কোনো লাইসেন্সপ্রাপ্ত আর্থিক উপদেষ্টা নয়।',
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
			'budgets.details.title' => 'বাজেটের বিস্তারিত',
			'budgets.details.loadFailed' => 'বাজেটের বিস্তারিত লোড করা যায়নি। আবার চেষ্টা করুন।',
			'budgets.details.notFound' => 'বাজেট পাওয়া যায়নি।',
			'budgets.details.ofTotal' => ({required Object total}) => ' / ${total}',
			'budgets.details.periodBudget.weekly' => 'সাপ্তাহিক বাজেট',
			'budgets.details.periodBudget.monthly' => 'মাসিক বাজেট',
			'budgets.details.periodBudget.yearly' => 'বার্ষিক বাজেট',
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
			'common.matchingRules' => 'মিলানোর নিয়ম',
			'common.errors.generic' => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।',
			'common.errors.storage' => 'আপনার ডেটা পড়া বা সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।',
			'common.errors.network' => 'আপনি অফলাইনে আছেন। সংযোগ দেখে আবার চেষ্টা করুন।',
			'common.errors.server' => 'সার্ভার সাড়া দেয়নি। একটু পরে আবার চেষ্টা করুন।',
			'common.errors.auth' => 'সাইন-ইনে সমস্যা হয়েছে। আবার সাইন ইন করে চেষ্টা করুন।',
			'common.errors.permission' => 'এই কাজের অনুমতি Expenzo-র নেই। সিস্টেম সেটিংসে অনুমতি দিন।',
			'common.errors.notFound' => 'এই আইটেমটি আর নেই।',
			'common.errors.smsScan' => 'আপনার মেসেজ পড়া যায়নি। আবার চেষ্টা করুন।',
			'common.dates.today' => 'আজ',
			'common.dates.yesterday' => 'গতকাল',
			'common.a11y.expenseAmount' => ({required Object amount, required Object currency}) => 'খরচ, ${amount} ${currency}',
			'common.a11y.incomeAmount' => ({required Object amount, required Object currency}) => 'আয়, ${amount} ${currency}',
			'common.feedback.subject' => 'Expenzo নিয়ে মতামত',
			'common.feedback.noMailApp' => ({required Object email}) => 'কোনো ইমেইল অ্যাপ পাওয়া যায়নি। আমাদের লিখুন ${email} ঠিকানায়।',
			'common.feedback.copyAddress' => 'ঠিকানা কপি করুন',
			'common.search' => 'খুঁজুন',
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
			'common.fallback.criticalTitle' => 'অপ্রত্যাশিত সমস্যা হয়েছে',
			'common.fallback.criticalBody' => 'অ্যাপটি কিছুক্ষণের মধ্যে বন্ধ হয়ে যাবে।',
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
			'dashboard.greeting' => ({required Object name}) => 'হ্যালো, ${name}',
			'dashboard.userFallback' => 'ব্যবহারকারী',
			'dashboard.income' => 'আয়',
			'dashboard.expense' => 'খরচ',
			'dashboard.sections.budgets' => 'বাজেট',
			'dashboard.sections.recentActivity' => 'সাম্প্রতিক লেনদেন',
			'dashboard.sections.spendingPatterns' => 'খরচের ধরন',
			'dashboard.sections.seeAll' => 'সব দেখুন',
			'dashboard.noBudgets' => 'এখনো কোনো বাজেট নেই',
			'dashboard.noTransactions' => 'এখনো কোনো লেনদেন নেই',
			'dashboard.menu.profile' => 'প্রোফাইল',
			'dashboard.menu.signIn' => 'সাইন ইন',
			'dashboard.menu.settings' => 'সেটিংস',
			'dashboard.menu.signOut' => 'সাইন আউট',
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
			'enums.source.both' => 'দুটোই',
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
			'messageTemplates.editor.step1' => 'ধাপ ১/৩: একটি মূল শব্দ বেছে নিন',
			'messageTemplates.editor.step1Body' => 'এমন একটি শব্দ বেছে নিন যা এই ধরনের প্রতিটি মেসেজে থাকে, যেমন "debited", "paid" বা "spent"।',
			'messageTemplates.editor.wordsInMessage' => 'এই মেসেজের শব্দগুলো',
			'messageTemplates.editor.step1Hint' => 'চালিয়ে যেতে একটি শব্দ বেছে নিন।',
			'messageTemplates.editor.step2' => 'ধাপ ২/৩: পরিমাণ বেছে নিন',
			'messageTemplates.editor.step2Body' => 'কোন সংখ্যাটি আপনার খরচের পরিমাণ?',
			'messageTemplates.editor.step2Hint' => 'চালিয়ে যেতে পরিমাণ বেছে নিন।',
			'messageTemplates.editor.step3' => 'ধাপ ৩/৩: দেখে নিন',
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
			'notifications.channel.name' => 'অ্যাপের নোটিফিকেশন',
			'notifications.channel.description' => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ, পুনরাবৃত্ত রিমাইন্ডার ও স্ক্যানের ফলাফল',
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
			'notifications.syncError.title' => 'সিঙ্কে সমস্যা',
			'parsingRules.addFromFormats' => 'SMS ফরম্যাট থেকে নিয়ম যোগ করুন',
			'parsingRules.newRule' => 'নতুন নিয়ম',
			'parsingRules.editRule' => 'নিয়ম সম্পাদনা',
			'parsingRules.add' => 'যোগ করুন',
			'parsingRules.added' => ({required Object name}) => '"${name}" যোগ হয়েছে',
			'parsingRules.empty.title' => 'এখনো কোনো নিয়ম নেই',
			'parsingRules.empty.body' => 'মিলে যাওয়া SMS ও ইমেইলকে রেকর্ডে বদলাতে একটি নিয়ম যোগ করুন।',
			'parsingRules.empty.add' => 'নিয়ম যোগ করুন',
			'parsingRules.created' => 'নিয়ম তৈরি হয়েছে',
			'parsingRules.updated' => 'নিয়ম আপডেট হয়েছে',
			'parsingRules.delete.title' => 'নিয়ম মুছুন',
			'parsingRules.delete.confirm' => ({required Object name}) => 'আপনি কি নিশ্চিত যে "${name}" মুছতে চান?',
			'parsingRules.validation.nameRequired' => 'নাম দিতে হবে',
			'parsingRules.validation.triggerRequired' => 'অন্তত একটি মূল শব্দ দিতে হবে',
			'parsingRules.validation.amountRequired' => 'পরিমাণের প্যাটার্ন দিতে হবে',
			'parsingRules.validation.invalidRegex' => 'রেগুলার এক্সপ্রেশন সঠিক নয়',
			'parsingRules.validation.invalidRegexDetail' => ({required Object detail}) => 'রেগুলার এক্সপ্রেশন সঠিক নয়: ${detail}',
			'parsingRules.validation.valid' => 'প্যাটার্ন সঠিক',
			'parsingRules.form.name' => 'নাম *',
			'parsingRules.form.nameHint' => 'যেমন: HDFC Bank SMS',
			'parsingRules.form.keyWords' => 'মূল শব্দ *',
			'parsingRules.form.keyWordsHint' => 'HDFC, debit, account (কমা দিয়ে আলাদা করুন)',
			'parsingRules.form.keyWordsHelper' => 'যেসব শব্দ থাকলে এই নিয়মটি চেষ্টা করা হবে',
			'parsingRules.form.amountPattern' => 'পরিমাণের প্যাটার্ন (regex) *',
			'parsingRules.form.amountRegex' => 'পরিমাণের regex',
			'parsingRules.form.datePattern' => 'তারিখের প্যাটার্ন (ঐচ্ছিক)',
			'parsingRules.form.dateRegex' => 'তারিখের regex (ঐচ্ছিক)',
			'parsingRules.form.dateHelper' => 'তারিখ না লাগলে খালি রাখুন',
			'parsingRules.form.source' => 'উৎস',
			'parsingRules.form.priority' => 'অগ্রাধিকার',
			'parsingRules.form.priorityHelper' => 'বেশি অগ্রাধিকারের নিয়ম আগে চেষ্টা করা হয়',
			'parsingRules.form.enabled' => 'চালু',
			'parsingRules.form.enabledDetail' => 'মেসেজ পড়ার সময় এই নিয়মটি ব্যবহার করুন',
			'parsingRules.tester.timeout' => 'সময় শেষ: প্যাটার্নটি ২ সেকেন্ডের বেশি সময় নিয়েছে',
			'parsingRules.tester.error' => 'সমস্যা',
			'parsingRules.tester.match' => 'মিল পাওয়া গেছে',
			'parsingRules.tester.noMatch' => 'মিল নেই',
			'parsingRules.tester.elapsed' => ({required Object ms}) => '${ms} ms',
			'parsingRules.tester.amount' => 'পরিমাণ',
			'parsingRules.tester.date' => 'তারিখ',
			'parsingRules.tester.confidence' => ({required Object percent}) => '${percent}% নিশ্চয়তা',
			'parsingRules.tester.sample' => 'পরীক্ষার জন্য নমুনা মেসেজ',
			'parsingRules.tester.sampleHint' => 'একটি নমুনা SMS বা ইমেইলের লেখা দিন',
			'parsingRules.tester.enterSample' => 'প্যাটার্ন পরীক্ষা করতে ওপরে একটি নমুনা মেসেজ দিন',
			'parsingRules.templates.hdfc_bank_sms' => 'HDFC ব্যাংকের ডেবিট নোটিফিকেশন পড়ে',
			'parsingRules.templates.icici_bank_sms' => 'ICICI ব্যাংকের ডেবিট নোটিফিকেশন পড়ে',
			'parsingRules.templates.sbi_sms' => 'স্টেট ব্যাংক অব ইন্ডিয়ার ডেবিট নোটিফিকেশন পড়ে',
			'parsingRules.templates.upi_payment_sms' => 'UPI পেমেন্টের নোটিফিকেশন পড়ে (PhonePe, Google Pay, Paytm)',
			'parsingRules.templates.amazon_order_sms' => 'Amazon অর্ডার কনফার্মেশন ও ডেলিভারির SMS পড়ে',
			'parsingRules.templates.amazon_order_email' => 'Amazon অর্ডারের ইমেইল পড়ে',
			'parsingRules.templates.swiggy_order_email' => 'Swiggy অর্ডার কনফার্মেশনের ইমেইল পড়ে',
			'parsingRules.templates.zomato_order_email' => 'Zomato অর্ডার কনফার্মেশনের ইমেইল পড়ে',
			'parsingRules.templates.flipkart_order_email' => 'Flipkart অর্ডারের ইমেইল পড়ে',
			'parsingRules.templates.generic_payment_email' => 'সাধারণ পেমেন্ট কনফার্মেশনের ইমেইল পড়ে',
			'receiptScan.permissionRequired' => 'রসিদ স্ক্যান করতে ক্যামেরার অনুমতি দরকার।',
			'receiptScan.noCamera' => 'এই ডিভাইসে কোনো ক্যামেরা নেই।',
			'receiptScan.cameraFailed' => 'ক্যামেরা চালু করা যায়নি।',
			'receiptScan.captureFailed' => 'ছবি তোলা যায়নি। আবার চেষ্টা করুন।',
			'receiptScan.readFailed' => 'রসিদটি পড়া যায়নি। আবার চেষ্টা করুন অথবা নিজে যোগ করুন।',
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
			_ => null,
		} ?? switch (path) {
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
			'reports.askAi' => 'AI-কে জিজ্ঞেস করুন',
			'reports.last7Days' => 'গত ৭ দিন',
			'reports.last30Days' => 'গত ৩০ দিন',
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
			'settings.notifications.rowSubtitle' => ({required Object n}) => '4টির মধ্যে ${n}টি চালু',
			'settings.notifications.rowSubtitleOff' => 'বন্ধ',
			'settings.notifications.sections.general' => 'সাধারণ',
			'settings.notifications.sections.budgetAlerts' => 'বাজেট সতর্কতা',
			'settings.notifications.sections.recurring' => 'পুনরাবৃত্ত লেনদেন',
			'settings.notifications.master.title' => 'নোটিফিকেশন চালু রাখুন',
			'settings.notifications.master.subtitle' => 'বাজেট সতর্কতা, সাপ্তাহিক সারাংশ ও রিমাইন্ডার',
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
			'settings.autoImportSubtitle' => 'ব্যাংক ও পেমেন্টের মেসেজ থেকে লেনদেন তৈরি করুন',
			'settings.matchingRulesSubtitle' => 'যেসব মেসেজ অটো-ইমপোর্ট এখনো পড়তে পারে না, সেগুলোর প্যাটার্ন',
			'settings.recurring.title' => 'পুনরাবৃত্ত লেনদেন',
			'settings.recurring.subtitle' => 'নিয়মিত আসা বিল ও আয়',
			'settings.feedbackSubtitle' => 'সমস্যা জানান বা কোনো আইডিয়া দিন',
			'settings.signOut' => 'সাইন আউট',
			'settings.deleteAccount' => 'অ্যাকাউন্ট মুছুন',
			'settings.signIn.title' => 'সাইন ইন',
			'settings.signIn.subtitle' => 'আপনার সব ডিভাইসে ডেটা রাখুন',
			'settings.deleteDialog.title' => 'অ্যাকাউন্ট মুছুন',
			'settings.deleteDialog.question' => 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্ট মুছে ফেলতে চান?',
			'settings.deleteDialog.listTitle' => 'এতে স্থায়ীভাবে মুছে যাবে:',
			'settings.deleteDialog.expenses' => '• আপনার সব খরচ',
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
			'settings.categories.rowSubtitle' => 'ক্যাটাগরি যোগ, সম্পাদনা ও মুছে ফেলুন',
			'shell.tabs.home' => 'হোম',
			'shell.tabs.activity' => 'লেনদেন',
			'shell.tabs.budgets' => 'বাজেট',
			'shell.tabs.reports' => 'রিপোর্ট',
			'shell.reportsTabs.trend' => 'প্রবণতা',
			'shell.reportsTabs.categories' => 'ক্যাটাগরি',
			'shell.reportsTabs.insights' => 'বিশ্লেষণ',
			'smsParser.range.last7Days' => 'গত ৭ দিন',
			'smsParser.range.last30Days' => 'গত ৩০ দিন',
			'smsParser.range.last3Months' => 'গত ৩ মাস',
			'smsParser.range.allTime' => 'সব সময়',
			'smsParser.range.custom' => 'নির্দিষ্ট তারিখের সীমা',
			'smsParser.range.from' => ({required Object date}) => '${date} থেকে',
			'smsParser.range.until' => ({required Object date}) => '${date} পর্যন্ত',
			'smsParser.range.selectDate' => 'তারিখ বেছে নিন',
			'smsParser.summary.range' => 'সময়সীমা',
			'smsParser.summary.matches' => 'মিলেছে',
			'smsParser.summary.selected' => 'বাছাই করা',
			'smsParser.card.rule' => ({required Object id}) => 'নিয়ম: ${id}',
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
			_ => null,
		};
	}
}
