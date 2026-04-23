import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Centralized icon helper for Lucide Icons integration
class AppIcons {
  AppIcons._();

  // ============ NAVIGATION ICONS ============
  static IconData get home => PhosphorIcons.house(PhosphorIconsStyle.regular);
  static IconData get dashboard => PhosphorIcons.squaresFour(PhosphorIconsStyle.regular);
  static IconData get scan => PhosphorIcons.listMagnifyingGlass(PhosphorIconsStyle.regular);
  static IconData get search => PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular);
  static IconData get settings => PhosphorIcons.faders(PhosphorIconsStyle.regular);

  // ============ ACTION ICONS ============
  static IconData get add => PhosphorIcons.plus(PhosphorIconsStyle.regular);
  static IconData get delete => PhosphorIcons.trash(PhosphorIconsStyle.regular);
  static IconData get edit => PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular);
  static IconData get check => PhosphorIcons.check(PhosphorIconsStyle.regular);
  static IconData get close => PhosphorIcons.x(PhosphorIconsStyle.regular);
  static IconData get menu => PhosphorIcons.list(PhosphorIconsStyle.regular);
  static IconData get filter => PhosphorIcons.funnel(PhosphorIconsStyle.regular);
  static IconData get refresh => PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.regular);
  static IconData get save => PhosphorIcons.floppyDisk(PhosphorIconsStyle.regular);
  static IconData get share => PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular);
  static IconData get download => PhosphorIcons.downloadSimple(PhosphorIconsStyle.regular);
  static IconData get upload => PhosphorIcons.uploadSimple(PhosphorIconsStyle.regular);

  // ============ STATUS ICONS ============
  static IconData get warning => PhosphorIcons.warning(PhosphorIconsStyle.regular);
  static IconData get error => PhosphorIcons.warningCircle(PhosphorIconsStyle.regular);
  static IconData get success => PhosphorIcons.checkCircle(PhosphorIconsStyle.regular);
  static IconData get info => PhosphorIcons.info(PhosphorIconsStyle.regular);
  static IconData get help => PhosphorIcons.question(PhosphorIconsStyle.regular);

  // ============ NAVIGATION ARROWS ============
  static IconData get back => PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular);
  static IconData get forward => PhosphorIcons.arrowRight(PhosphorIconsStyle.regular);
  static IconData get chevronRight => PhosphorIcons.caretRight(PhosphorIconsStyle.regular);
  static IconData get chevronDown => PhosphorIcons.caretDown(PhosphorIconsStyle.regular);

  // ============ FINANCE ICONS ============
  static IconData get wallet => PhosphorIcons.wallet(PhosphorIconsStyle.regular);
  static IconData get money => PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular);
  static IconData get receipt => PhosphorIcons.invoice(PhosphorIconsStyle.regular);
  static IconData get card => PhosphorIcons.creditCard(PhosphorIconsStyle.regular);
  static IconData get trendingUp => PhosphorIcons.trendUp(PhosphorIconsStyle.regular);
  static IconData get trendingDown => PhosphorIcons.trendDown(PhosphorIconsStyle.regular);
  static IconData get chart => PhosphorIcons.chartBar(PhosphorIconsStyle.regular);
  static IconData get pieChart => PhosphorIcons.chartPie(PhosphorIconsStyle.regular);

  // ============ CATEGORY ICONS ============
  static IconData get category => PhosphorIcons.tag(PhosphorIconsStyle.regular);
  static IconData get food => PhosphorIcons.forkKnife(PhosphorIconsStyle.regular);
  static IconData get grocery => PhosphorIcons.shoppingCart(PhosphorIconsStyle.regular);
  static IconData get shopping => PhosphorIcons.bag(PhosphorIconsStyle.regular);
  static IconData get transport => PhosphorIcons.car(PhosphorIconsStyle.regular);
  static IconData get entertainment => PhosphorIcons.ticket(PhosphorIconsStyle.regular);
  static IconData get health => PhosphorIcons.heartbeat(PhosphorIconsStyle.regular);
  static IconData get utilities => PhosphorIcons.lightning(PhosphorIconsStyle.regular);
  static IconData get education => PhosphorIcons.bookOpen(PhosphorIconsStyle.regular);
  static IconData get travel => PhosphorIcons.airplane(PhosphorIconsStyle.regular);
  static IconData get cafe => PhosphorIcons.coffee(PhosphorIconsStyle.regular);
  static IconData get gift => PhosphorIcons.gift(PhosphorIconsStyle.regular);
  static IconData get other => PhosphorIcons.tag(PhosphorIconsStyle.regular);

  // ============ SOURCE ICONS ============
  static IconData get sms => PhosphorIcons.chat(PhosphorIconsStyle.regular);
  static IconData get email => PhosphorIcons.envelope(PhosphorIconsStyle.regular);
  static IconData get manual => PhosphorIcons.pencilSimpleLine(PhosphorIconsStyle.regular);
  static IconData get sync => PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.regular);

  // ============ TIME ICONS ============
  static IconData get calendar => PhosphorIcons.calendar(PhosphorIconsStyle.regular);
  static IconData get clock => PhosphorIcons.clock(PhosphorIconsStyle.regular);
  static IconData get schedule => PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular);
  static IconData get history => PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular);
  static IconData get repeat => PhosphorIcons.arrowsCounterClockwise(PhosphorIconsStyle.regular);

  // ============ USER ICONS ============
  static IconData get user => PhosphorIcons.user(PhosphorIconsStyle.regular);
  static IconData get profile => PhosphorIcons.userCircle(PhosphorIconsStyle.regular);

  // ============ NOTIFICATION ICONS ============
  static IconData get notification => PhosphorIcons.bell(PhosphorIconsStyle.regular);
  static IconData get cloudDone => PhosphorIcons.cloud(PhosphorIconsStyle.regular);
  static IconData get cloudOff => PhosphorIcons.cloudX(PhosphorIconsStyle.regular);

  // ============ DEVICE/COMM ICONS ============
  static IconData get phone => PhosphorIcons.phone(PhosphorIconsStyle.regular);
  static IconData get location => PhosphorIcons.mapPin(PhosphorIconsStyle.regular);
  static IconData get image => PhosphorIcons.image(PhosphorIconsStyle.regular);
  static IconData get link => PhosphorIcons.link(PhosphorIconsStyle.regular);
  static IconData get wifi => PhosphorIcons.wifiHigh(PhosphorIconsStyle.regular);
  static IconData get printer => PhosphorIcons.printer(PhosphorIconsStyle.regular);

  // ============ SECURITY ICONS ============
  static IconData get lock => PhosphorIcons.lock(PhosphorIconsStyle.regular);
  static IconData get unlock => PhosphorIcons.lockOpen(PhosphorIconsStyle.regular);
  static IconData get security => PhosphorIcons.shield(PhosphorIconsStyle.regular);
  static IconData get visibility => PhosphorIcons.eye(PhosphorIconsStyle.regular);
  static IconData get visibilityOff => PhosphorIcons.eyeClosed(PhosphorIconsStyle.regular);

  // ============ MISC ICONS ============
  static IconData get empty => PhosphorIcons.empty(PhosphorIconsStyle.regular);
  static IconData get apps => PhosphorIcons.squaresFour(PhosphorIconsStyle.regular);
  static IconData get copy => PhosphorIcons.copy(PhosphorIconsStyle.regular);
  static IconData get document => PhosphorIcons.fileText(PhosphorIconsStyle.regular);
  static IconData get folder => PhosphorIcons.folder(PhosphorIconsStyle.regular);
  static IconData get star => PhosphorIcons.star(PhosphorIconsStyle.regular);
  static IconData get heart => PhosphorIcons.heart(PhosphorIconsStyle.regular);
  static IconData get globe => PhosphorIcons.globe(PhosphorIconsStyle.regular);

  // ============ CATEGORY EMOJI MAPPING ============
  /// Maps category names to icons
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return food;
      case 'grocery':
        return grocery;
      case 'shopping':
        return shopping;
      case 'transport':
      case 'transportation':
        return transport;
      case 'entertainment':
        return entertainment;
      case 'health':
      case 'medical':
        return health;
      case 'utilities':
      case 'bills':
        return utilities;
      case 'education':
      case 'learning':
        return education;
      case 'travel':
      case 'flight':
        return travel;
      case 'cafe':
      case 'coffee':
        return cafe;
      case 'gift':
      case 'gifts':
        return gift;
      case 'salary':
      case 'income':
        return money;
      case 'investment':
        return trendingUp;
      case 'other':
      case 'misc':
        return other;
      default:
        return other;
    }
  }

  /// Maps source names to icons
  static IconData getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'sms':
        return sms;
      case 'email':
        return email;
      case 'manual':
        return manual;
      case 'recurring':
        return repeat;
      default:
        return manual;
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
        return sms;
      case 'message':
        return sms;
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
        return Icons.help_outline;
    }
  }
}
