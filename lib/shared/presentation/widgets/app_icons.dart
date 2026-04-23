import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Centralized icon helper for Lucide Icons integration
class AppIcons {
  AppIcons._();

  // ============ NAVIGATION ICONS ============
  static IconData get home => LucideIcons.home;
  static IconData get dashboard => LucideIcons.layoutDashboard;
  static IconData get scan => LucideIcons.scan;
  static IconData get search => LucideIcons.search;
  static IconData get settings => LucideIcons.settings;

  // ============ ACTION ICONS ============
  static IconData get add => LucideIcons.plus;
  static IconData get delete => LucideIcons.trash2;
  static IconData get edit => LucideIcons.edit;
  static IconData get check => LucideIcons.check;
  static IconData get close => LucideIcons.x;
  static IconData get menu => LucideIcons.menu;
  static IconData get filter => LucideIcons.filter;
  static IconData get refresh => LucideIcons.refreshCcw;
  static IconData get save => LucideIcons.save;
  static IconData get share => LucideIcons.share;
  static IconData get download => LucideIcons.download;
  static IconData get upload => LucideIcons.upload;

  // ============ STATUS ICONS ============
  static IconData get warning => LucideIcons.alertTriangle;
  static IconData get error => LucideIcons.alertCircle;
  static IconData get success => LucideIcons.checkCircle;
  static IconData get info => LucideIcons.info;
  static IconData get help => LucideIcons.helpCircle;

  // ============ NAVIGATION ARROWS ============
  static IconData get back => LucideIcons.arrowLeft;
  static IconData get forward => LucideIcons.arrowRight;
  static IconData get chevronRight => LucideIcons.chevronRight;
  static IconData get chevronDown => LucideIcons.chevronDown;

  // ============ FINANCE ICONS ============
  static IconData get wallet => LucideIcons.wallet;
  static IconData get money => LucideIcons.dollarSign;
  static IconData get receipt => LucideIcons.receipt;
  static IconData get card => LucideIcons.creditCard;
  static IconData get trendingUp => LucideIcons.trendingUp;
  static IconData get trendingDown => LucideIcons.trendingDown;
  static IconData get chart => LucideIcons.barChart3;
  static IconData get pieChart => LucideIcons.pieChart;

  // ============ CATEGORY ICONS ============
  static IconData get category => LucideIcons.tag;
  static IconData get food => LucideIcons.utensils;
  static IconData get grocery => LucideIcons.shoppingCart;
  static IconData get shopping => LucideIcons.shoppingBag;
  static IconData get transport => LucideIcons.car;
  static IconData get entertainment => LucideIcons.ticket;
  static IconData get health => LucideIcons.heartPulse;
  static IconData get utilities => LucideIcons.zap;
  static IconData get education => LucideIcons.bookOpen;
  static IconData get travel => LucideIcons.rocket; // airplane alternative
  static IconData get cafe => LucideIcons.coffee;
  static IconData get gift => LucideIcons.gift;
  static IconData get other => LucideIcons.tag;

  // ============ SOURCE ICONS ============
  static IconData get sms => LucideIcons.messageSquare;
  static IconData get email => LucideIcons.mail;
  static IconData get manual => LucideIcons.edit3;
  static IconData get sync => LucideIcons.refreshCcw;

  // ============ TIME ICONS ============
  static IconData get calendar => LucideIcons.calendar;
  static IconData get clock => LucideIcons.clock;
  static IconData get schedule => LucideIcons.calendarClock;
  static IconData get history => LucideIcons.history;
  static IconData get repeat => LucideIcons.repeat;

  // ============ USER ICONS ============
  static IconData get user => LucideIcons.user;
  static IconData get profile => LucideIcons.userCircle;

  // ============ NOTIFICATION ICONS ============
  static IconData get notification => LucideIcons.bell;
  static IconData get cloudDone => LucideIcons.cloud;
  static IconData get cloudOff => LucideIcons.cloudOff;

  // ============ DEVICE/COMM ICONS ============
  static IconData get phone => LucideIcons.phone;
  static IconData get location => LucideIcons.mapPin;
  static IconData get image => LucideIcons.image;
  static IconData get link => LucideIcons.link;
  static IconData get wifi => LucideIcons.wifi;
  static IconData get printer => LucideIcons.printer;

  // ============ SECURITY ICONS ============
  static IconData get lock => LucideIcons.lock;
  static IconData get unlock => LucideIcons.unlock;
  static IconData get security => LucideIcons.shield;
  static IconData get visibility => LucideIcons.eye;
  static IconData get visibilityOff => LucideIcons.eyeOff;

  // ============ MISC ICONS ============
  static IconData get empty => LucideIcons.inbox;
  static IconData get apps => LucideIcons.layoutGrid;
  static IconData get copy => LucideIcons.copy;
  static IconData get document => LucideIcons.fileText;
  static IconData get folder => LucideIcons.folder;
  static IconData get star => LucideIcons.star;
  static IconData get heart => LucideIcons.heart;
  static IconData get globe => LucideIcons.globe;

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

/// Extension to convert Material Icons to Lucide Icons
extension MaterialToLucideIcon on IconData {
  IconData toLucide() {
    final iconName = toString().toLowerCase();

    // Map common Material icons to Lucide
    if (iconName.contains('home')) return AppIcons.home;
    if (iconName.contains('dashboard') || iconName.contains('layout'))
      return AppIcons.dashboard;
    if (iconName.contains('scan') || iconName.contains('qr'))
      return AppIcons.scan;
    if (iconName.contains('search')) return AppIcons.search;
    if (iconName.contains('settings')) return AppIcons.settings;
    if (iconName.contains('add') || iconName.contains('plus'))
      return AppIcons.add;
    if (iconName.contains('delete') || iconName.contains('trash'))
      return AppIcons.delete;
    if (iconName.contains('edit') || iconName.contains('pencil'))
      return AppIcons.edit;
    if (iconName.contains('check')) return AppIcons.check;
    if (iconName.contains('close') ||
        iconName.contains('cancel') ||
        iconName.contains('x'))
      return AppIcons.close;
    if (iconName.contains('menu')) return AppIcons.menu;
    if (iconName.contains('filter')) return AppIcons.filter;
    if (iconName.contains('refresh') || iconName.contains('sync'))
      return AppIcons.refresh;
    if (iconName.contains('save')) return AppIcons.save;
    if (iconName.contains('share')) return AppIcons.share;
    if (iconName.contains('download')) return AppIcons.download;
    if (iconName.contains('upload')) return AppIcons.upload;
    if (iconName.contains('warning') || iconName.contains('alert'))
      return AppIcons.warning;
    if (iconName.contains('error')) return AppIcons.error;
    if (iconName.contains('info')) return AppIcons.info;
    if (iconName.contains('arrow_left') || iconName.contains('back'))
      return AppIcons.back;
    if (iconName.contains('arrow_right') || iconName.contains('forward'))
      return AppIcons.forward;
    if (iconName.contains('chevron')) return AppIcons.chevronRight;
    if (iconName.contains('trending_up')) return AppIcons.trendingUp;
    if (iconName.contains('trending_down')) return AppIcons.trendingDown;
    if (iconName.contains('wallet') || iconName.contains('account_balance'))
      return AppIcons.wallet;
    if (iconName.contains('money') || iconName.contains('dollar'))
      return AppIcons.money;
    if (iconName.contains('receipt')) return AppIcons.receipt;
    if (iconName.contains('chart') || iconName.contains('pie'))
      return AppIcons.chart;
    if (iconName.contains('category') || iconName.contains('tag'))
      return AppIcons.category;
    if (iconName.contains('sms') || iconName.contains('message'))
      return AppIcons.sms;
    if (iconName.contains('email') || iconName.contains('mail'))
      return AppIcons.email;
    if (iconName.contains('calendar') || iconName.contains('date'))
      return AppIcons.calendar;
    if (iconName.contains('clock') ||
        iconName.contains('schedule') ||
        iconName.contains('time'))
      return AppIcons.clock;
    if (iconName.contains('history')) return AppIcons.history;
    if (iconName.contains('repeat')) return AppIcons.repeat;
    if (iconName.contains('person') || iconName.contains('user'))
      return AppIcons.user;
    if (iconName.contains('bell') || iconName.contains('notification'))
      return AppIcons.notification;
    if (iconName.contains('cloud')) return AppIcons.cloudDone;
    if (iconName.contains('phone')) return AppIcons.phone;
    if (iconName.contains('location') || iconName.contains('map'))
      return AppIcons.location;
    if (iconName.contains('image') || iconName.contains('photo'))
      return AppIcons.image;
    if (iconName.contains('link')) return AppIcons.link;
    if (iconName.contains('lock')) return AppIcons.lock;
    if (iconName.contains('unlock')) return AppIcons.unlock;
    if (iconName.contains('visibility') && !iconName.contains('off'))
      return AppIcons.visibility;
    if (iconName.contains('visibility_off')) return AppIcons.visibilityOff;
    if (iconName.contains('security') || iconName.contains('shield'))
      return AppIcons.security;
    if (iconName.contains('car') || iconName.contains('drive'))
      return AppIcons.transport;
    if (iconName.contains('hospital') ||
        iconName.contains('health') ||
        iconName.contains('heart'))
      return AppIcons.health;
    if (iconName.contains('book') || iconName.contains('school'))
      return AppIcons.education;
    if (iconName.contains('airplane') || iconName.contains('flight'))
      return AppIcons.travel;
    if (iconName.contains('shop') || iconName.contains('cart'))
      return AppIcons.shopping;
    if (iconName.contains('gift')) return AppIcons.gift;
    if (iconName.contains('ticket')) return AppIcons.entertainment;
    if (iconName.contains('flash') ||
        iconName.contains('electric') ||
        iconName.contains('zap'))
      return AppIcons.utilities;
    if (iconName.contains('star') || iconName.contains('favorite'))
      return AppIcons.star;
    if (iconName.contains('heart') && !iconName.contains('health'))
      return AppIcons.heart;
    if (iconName.contains('printer')) return AppIcons.printer;
    if (iconName.contains('globe') ||
        iconName.contains('earth') ||
        iconName.contains('world'))
      return AppIcons.globe;
    if (iconName.contains('copy')) return AppIcons.copy;
    if (iconName.contains('document') || iconName.contains('file'))
      return AppIcons.document;
    if (iconName.contains('folder')) return AppIcons.folder;
    if (iconName.contains('wifi') || iconName.contains('signal'))
      return AppIcons.wifi;
    if (iconName.contains('credit') || iconName.contains('card'))
      return AppIcons.card;
    if (iconName.contains('utensils') ||
        iconName.contains('food') ||
        iconName.contains('restaurant'))
      return AppIcons.food;
    if (iconName.contains('coffee') || iconName.contains('cafe'))
      return AppIcons.cafe;

    // Return original if no mapping found
    return this;
  }
}
