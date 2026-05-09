import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Centralized icon helper for Lucide Icons integration
class AppIcons {
  AppIcons._();

  static IconData _reg(IconData Function(PhosphorIconsStyle) icon) =>
      icon(PhosphorIconsStyle.regular);

  // ============ NAVIGATION ICONS ============
  static IconData get home => _reg(PhosphorIcons.house);
  static IconData get dashboard => _reg(PhosphorIcons.squaresFour);
  static IconData get scan => _reg(PhosphorIcons.listMagnifyingGlass);
  static IconData get search => _reg(PhosphorIcons.magnifyingGlass);
  static IconData get settings => _reg(PhosphorIcons.faders);

  // ============ ACTION ICONS ============
  static IconData get add => _reg(PhosphorIcons.plus);
  static IconData get delete => _reg(PhosphorIcons.trash);
  static IconData get edit => _reg(PhosphorIcons.pencilSimple);
  static IconData get check => _reg(PhosphorIcons.check);
  static IconData get close => _reg(PhosphorIcons.x);
  static IconData get menu => _reg(PhosphorIcons.list);
  static IconData get filter => _reg(PhosphorIcons.funnel);
  static IconData get refresh => _reg(PhosphorIcons.arrowsClockwise);
  static IconData get save => _reg(PhosphorIcons.floppyDisk);
  static IconData get share => _reg(PhosphorIcons.shareNetwork);
  static IconData get download => _reg(PhosphorIcons.downloadSimple);
  static IconData get upload => _reg(PhosphorIcons.uploadSimple);

  // ============ STATUS ICONS ============
  static IconData get warning => _reg(PhosphorIcons.warning);
  static IconData get error => _reg(PhosphorIcons.warningCircle);
  static IconData get success => _reg(PhosphorIcons.checkCircle);
  static IconData get info => _reg(PhosphorIcons.info);
  static IconData get help => _reg(PhosphorIcons.question);

  // ============ NAVIGATION ARROWS ============
  static IconData get back =>
      PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular);
  static IconData get forward =>
      PhosphorIcons.arrowRight(PhosphorIconsStyle.regular);
  static IconData get chevronRight =>
      PhosphorIcons.caretRight(PhosphorIconsStyle.regular);
  static IconData get chevronDown =>
      PhosphorIcons.caretDown(PhosphorIconsStyle.regular);

  // ============ FINANCE ICONS ============
  static IconData get wallet =>
      PhosphorIcons.wallet(PhosphorIconsStyle.regular);
  static IconData get money =>
      PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular);
  static IconData get receipt =>
      PhosphorIcons.invoice(PhosphorIconsStyle.regular);
  static IconData get card =>
      PhosphorIcons.creditCard(PhosphorIconsStyle.regular);
  static IconData get trendingUp =>
      PhosphorIcons.trendUp(PhosphorIconsStyle.regular);
  static IconData get trendingDown =>
      PhosphorIcons.trendDown(PhosphorIconsStyle.regular);
  static IconData get chart =>
      PhosphorIcons.chartBar(PhosphorIconsStyle.regular);
  static IconData get pieChart =>
      PhosphorIcons.chartPie(PhosphorIconsStyle.regular);

  // ============ CATEGORY ICONS ============
  static const Map<String, IconData Function(PhosphorIconsStyle)>
  _categoryIconMap = {
    'package': PhosphorIcons.package,
    'shoppingCart': PhosphorIcons.shoppingCart,
    'forkKnife': PhosphorIcons.forkKnife,
    'car': PhosphorIcons.car,
    'house': PhosphorIcons.house,
    'heartbeat': PhosphorIcons.heartbeat,
    'gameController': PhosphorIcons.gameController,
    'deviceMobile': PhosphorIcons.deviceMobile,
    'airplane': PhosphorIcons.airplane,
    'graduationCap': PhosphorIcons.graduationCap,
    'currencyDollar': PhosphorIcons.currencyDollar,
    'gift': PhosphorIcons.gift,
    // Income category icons
    'briefcase': PhosphorIcons.briefcase,
    'laptop': PhosphorIcons.laptop,
    'chartLineUp': PhosphorIcons.chartLineUp,
    'arrowULeftDown': PhosphorIcons.arrowULeftDown,
  };

  /// Resolves an icon identifier (stored in Category.emoji) to Phosphor IconData.
  /// Falls back to package icon for unknown names or legacy emoji data.
  static IconData getCategoryIcon(String iconName) {
    final iconFn = _categoryIconMap[iconName];
    if (iconFn != null) return iconFn(PhosphorIconsStyle.regular);
    return PhosphorIcons.package(PhosphorIconsStyle.regular);
  }

  static IconData get category => PhosphorIcons.tag(PhosphorIconsStyle.regular);
  static IconData get food =>
      PhosphorIcons.forkKnife(PhosphorIconsStyle.regular);
  static IconData get grocery =>
      PhosphorIcons.shoppingCart(PhosphorIconsStyle.regular);
  static IconData get shopping => PhosphorIcons.bag(PhosphorIconsStyle.regular);
  static IconData get transport =>
      PhosphorIcons.car(PhosphorIconsStyle.regular);
  static IconData get entertainment =>
      PhosphorIcons.ticket(PhosphorIconsStyle.regular);
  static IconData get health =>
      PhosphorIcons.heartbeat(PhosphorIconsStyle.regular);
  static IconData get utilities =>
      PhosphorIcons.lightning(PhosphorIconsStyle.regular);
  static IconData get education =>
      PhosphorIcons.bookOpen(PhosphorIconsStyle.regular);
  static IconData get travel =>
      PhosphorIcons.airplane(PhosphorIconsStyle.regular);
  static IconData get cafe => PhosphorIcons.coffee(PhosphorIconsStyle.regular);
  static IconData get gift => PhosphorIcons.gift(PhosphorIconsStyle.regular);
  static IconData get other => PhosphorIcons.tag(PhosphorIconsStyle.regular);
  static IconData get package =>
      PhosphorIcons.package(PhosphorIconsStyle.regular);
  static IconData get house => PhosphorIcons.house(PhosphorIconsStyle.regular);
  static IconData get gameController =>
      PhosphorIcons.gameController(PhosphorIconsStyle.regular);
  static IconData get deviceMobile =>
      PhosphorIcons.deviceMobile(PhosphorIconsStyle.regular);
  static IconData get graduationCap =>
      PhosphorIcons.graduationCap(PhosphorIconsStyle.regular);

  // ============ SOURCE ICONS ============
  static IconData get sms => PhosphorIcons.chatDots(PhosphorIconsStyle.regular);
  static IconData get email =>
      PhosphorIcons.envelope(PhosphorIconsStyle.regular);
  static IconData get manual =>
      PhosphorIcons.pencilSimpleLine(PhosphorIconsStyle.regular);
  static IconData get repeat =>
      PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.regular);

  // ============ TIME ICONS ============
  static IconData get calendar =>
      PhosphorIcons.calendar(PhosphorIconsStyle.regular);
  static IconData get clock => PhosphorIcons.clock(PhosphorIconsStyle.regular);
  static IconData get schedule =>
      PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular);
  static IconData get history =>
      PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular);

  // ============ USER ICONS ============
  static IconData get user => PhosphorIcons.user(PhosphorIconsStyle.regular);
  static IconData get profile =>
      PhosphorIcons.userCircle(PhosphorIconsStyle.regular);

  // ============ NOTIFICATION ICONS ============
  static IconData get notification =>
      PhosphorIcons.bell(PhosphorIconsStyle.regular);
  static IconData get cloudDone =>
      PhosphorIcons.cloud(PhosphorIconsStyle.regular);
  static IconData get cloudOff =>
      PhosphorIcons.cloudX(PhosphorIconsStyle.regular);

  // ============ DEVICE/COMM ICONS ============
  static IconData get phone => PhosphorIcons.phone(PhosphorIconsStyle.regular);
  static IconData get location =>
      PhosphorIcons.mapPin(PhosphorIconsStyle.regular);
  static IconData get image => PhosphorIcons.image(PhosphorIconsStyle.regular);
  static IconData get link => PhosphorIcons.link(PhosphorIconsStyle.regular);
  static IconData get wifi =>
      PhosphorIcons.wifiHigh(PhosphorIconsStyle.regular);
  static IconData get printer =>
      PhosphorIcons.printer(PhosphorIconsStyle.regular);

  // ============ SECURITY ICONS ============
  static IconData get lock => PhosphorIcons.lock(PhosphorIconsStyle.regular);
  static IconData get unlock =>
      PhosphorIcons.lockOpen(PhosphorIconsStyle.regular);
  static IconData get security =>
      PhosphorIcons.shield(PhosphorIconsStyle.regular);
  static IconData get visibility =>
      PhosphorIcons.eye(PhosphorIconsStyle.regular);
  static IconData get visibilityOff =>
      PhosphorIcons.eyeClosed(PhosphorIconsStyle.regular);

  // ============ MISC ICONS ============
  static IconData get empty => PhosphorIcons.empty(PhosphorIconsStyle.regular);
  static IconData get apps =>
      PhosphorIcons.squaresFour(PhosphorIconsStyle.regular);
  static IconData get copy => PhosphorIcons.copy(PhosphorIconsStyle.regular);
  static IconData get document =>
      PhosphorIcons.fileText(PhosphorIconsStyle.regular);
  static IconData get folder =>
      PhosphorIcons.folder(PhosphorIconsStyle.regular);
  static IconData get star => PhosphorIcons.star(PhosphorIconsStyle.regular);
  static IconData get heart => PhosphorIcons.heart(PhosphorIconsStyle.regular);
  static IconData get globe => PhosphorIcons.globe(PhosphorIconsStyle.regular);

  /// Maps source enum to icons
  static IconData getSourceIcon(ExpenseSource source) {
    switch (source) {
      case ExpenseSource.sms:
        return sms;
      case ExpenseSource.email:
        return email;
      case ExpenseSource.manual:
        return manual;
      case ExpenseSource.recurring:
        return repeat;
    }
  }

  /// Get icon by name - returns IconData
  static IconData get(String name) {
    switch (name.toLowerCase()) {
      // Navigation
      case 'home':
        return home;
      case 'dashboard':
        return dashboard;
      case 'scan':
        return scan;
      case 'search':
        return search;
      case 'settings':
        return settings;
      // Actions
      case 'add':
      case 'plus':
        return add;
      case 'delete':
      case 'trash':
        return delete;
      case 'edit':
        return edit;
      case 'check':
        return check;
      case 'close':
      case 'x':
        return close;
      case 'menu':
        return menu;
      case 'filter':
        return filter;
      case 'refresh':
        return refresh;
      case 'save':
        return save;
      case 'share':
        return share;
      case 'download':
        return download;
      case 'upload':
        return upload;
      // Status
      case 'warning':
        return warning;
      case 'error':
        return error;
      case 'success':
        return success;
      case 'info':
        return info;
      case 'help':
        return help;
      // Navigation arrows
      case 'back':
        return back;
      case 'forward':
        return forward;
      case 'chevron_right':
        return chevronRight;
      case 'chevron_down':
        return chevronDown;
      // Finance
      case 'wallet':
        return wallet;
      case 'money':
        return money;
      case 'receipt':
        return receipt;
      case 'card':
        return card;
      case 'trending_up':
        return trendingUp;
      case 'trending_down':
        return trendingDown;
      case 'chart':
        return chart;
      case 'pie_chart':
        return pieChart;
      // Category
      case 'category':
      case 'tag':
        return category;
      // Source
      case 'sms':
        return PhosphorIcons.chatDots(PhosphorIconsStyle.regular);
      case 'message':
        return PhosphorIcons.chatDots(PhosphorIconsStyle.regular);
      case 'email':
      case 'mail':
        return email;
      case 'sync':
      case 'repeat':
        return repeat;
      // Time
      case 'calendar':
        return calendar;
      case 'clock':
        return clock;
      case 'schedule':
        return schedule;
      case 'history':
        return history;
      // User
      case 'user':
        return user;
      case 'profile':
        return profile;
      // Notification
      case 'notification':
      case 'bell':
        return notification;
      case 'cloud_done':
        return cloudDone;
      case 'cloud_off':
        return cloudOff;
      // Device
      case 'phone':
        return phone;
      case 'location':
      case 'map':
        return location;
      case 'image':
        return image;
      case 'link':
        return link;
      case 'wifi':
        return wifi;
      // Security
      case 'lock':
        return lock;
      case 'unlock':
        return unlock;
      case 'security':
      case 'shield':
        return security;
      case 'visibility':
        return visibility;
      case 'visibility_off':
        return visibilityOff;
      // Misc
      case 'empty':
      case 'inbox':
        return empty;
      case 'apps':
        return apps;
      case 'copy':
        return copy;
      case 'document':
      case 'file':
        return document;
      case 'folder':
        return folder;
      case 'star':
      case 'favorite':
        return star;
      case 'heart':
        return heart;
      case 'globe':
      case 'earth':
        return globe;
      case 'printer':
        return printer;
      default:
        return PhosphorIcons.question(PhosphorIconsStyle.regular);
    }
  }
}
