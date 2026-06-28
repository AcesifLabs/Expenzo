import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

class AppIcons {
  AppIcons._();

  static IconData get home => PiconsRegular.house;
  static IconData get dashboard => PiconsRegular.squaresFour;
  static IconData get scan => PiconsRegular.listMagnifyingGlass;
  static IconData get search => PiconsRegular.magnifyingGlass;
  static IconData get settings => PiconsRegular.faders;

  static IconData get add => PiconsRegular.plus;
  static IconData get delete => PiconsRegular.trash;
  static IconData get edit => PiconsRegular.pencilSimple;
  static IconData get check => PiconsRegular.check;
  static IconData get close => PiconsRegular.x;
  static IconData get menu => PiconsRegular.list;
  static IconData get filter => PiconsRegular.funnel;
  static IconData get refresh => PiconsRegular.arrowsClockwise;
  static IconData get save => PiconsRegular.floppyDisk;
  static IconData get share => PiconsRegular.shareNetwork;
  static IconData get download => PiconsRegular.downloadSimple;
  static IconData get upload => PiconsRegular.uploadSimple;

  static IconData get warning => PiconsRegular.warning;
  static IconData get error => PiconsRegular.warningCircle;
  static IconData get success => PiconsRegular.checkCircle;
  static IconData get info => PiconsRegular.info;
  static IconData get help => PiconsRegular.question;

  static IconData get back => PiconsRegular.arrowLeft;
  static IconData get forward => PiconsRegular.arrowRight;
  static IconData get chevronRight => PiconsRegular.caretRight;
  static IconData get chevronDown => PiconsRegular.caretDown;

  static IconData get wallet => PiconsRegular.wallet;
  static IconData get money => PiconsRegular.currencyDollar;
  static IconData get receipt => PiconsRegular.invoice;
  static IconData get card => PiconsRegular.creditCard;
  static IconData get trendingUp => PiconsRegular.trendUp;
  static IconData get trendingDown => PiconsRegular.trendDown;
  static IconData get chart => PiconsRegular.chartBar;
  static IconData get pieChart => PiconsRegular.chartPie;

  static const Map<String, IconData> _categoryIconMap = {
    'package': PiconsRegular.package,
    'shoppingCart': PiconsRegular.shoppingCart,
    'forkKnife': PiconsRegular.forkKnife,
    'car': PiconsRegular.car,
    'house': PiconsRegular.house,
    'heartbeat': PiconsRegular.heartbeat,
    'gameController': PiconsRegular.gameController,
    'deviceMobile': PiconsRegular.deviceMobile,
    'airplane': PiconsRegular.airplane,
    'graduationCap': PiconsRegular.graduationCap,
    'currencyDollar': PiconsRegular.currencyDollar,
    'gift': PiconsRegular.gift,

    'briefcase': PiconsRegular.briefcase,
    'laptop': PiconsRegular.laptop,
    'chartLineUp': PiconsRegular.chartLineUp,
    'arrowULeftDown': PiconsRegular.arrowULeftDown,
  };

  static IconData getCategoryIcon(String iconName) {
    final iconData = _categoryIconMap[iconName];
    if (iconData != null) return iconData;
    return PiconsRegular.package;
  }

  static IconData get category => PiconsRegular.tag;
  static IconData get food => PiconsRegular.forkKnife;
  static IconData get grocery => PiconsRegular.shoppingCart;
  static IconData get shopping => PiconsRegular.bag;
  static IconData get transport => PiconsRegular.car;
  static IconData get entertainment => PiconsRegular.ticket;
  static IconData get health => PiconsRegular.heartbeat;
  static IconData get utilities => PiconsRegular.lightning;
  static IconData get education => PiconsRegular.bookOpen;
  static IconData get travel => PiconsRegular.airplane;
  static IconData get cafe => PiconsRegular.coffee;
  static IconData get gift => PiconsRegular.gift;
  static IconData get other => PiconsRegular.tag;
  static IconData get package => PiconsRegular.package;
  static IconData get house => PiconsRegular.house;
  static IconData get gameController => PiconsRegular.gameController;
  static IconData get deviceMobile => PiconsRegular.deviceMobile;
  static IconData get graduationCap => PiconsRegular.graduationCap;

  static IconData get sms => PiconsRegular.chatDots;
  static IconData get email => PiconsRegular.envelope;
  static IconData get manual => PiconsRegular.pencilSimpleLine;
  static IconData get repeat => PiconsRegular.arrowsClockwise;

  static IconData get calendar => PiconsRegular.calendar;
  static IconData get clock => PiconsRegular.clock;
  static IconData get schedule => PiconsRegular.calendarBlank;
  static IconData get history => PiconsRegular.clockCounterClockwise;

  static IconData get user => PiconsRegular.user;
  static IconData get profile => PiconsRegular.userCircle;

  static IconData get notification => PiconsRegular.bell;
  static IconData get cloudDone => PiconsRegular.cloud;
  static IconData get cloudOff => PiconsRegular.cloudX;

  static IconData get phone => PiconsRegular.phone;
  static IconData get location => PiconsRegular.mapPin;
  static IconData get image => PiconsRegular.image;
  static IconData get link => PiconsRegular.link;
  static IconData get wifi => PiconsRegular.wifiHigh;
  static IconData get printer => PiconsRegular.printer;

  static IconData get lock => PiconsRegular.lock;
  static IconData get unlock => PiconsRegular.lockOpen;
  static IconData get security => PiconsRegular.shield;
  static IconData get visibility => PiconsRegular.eye;
  static IconData get visibilityOff => PiconsRegular.eyeClosed;

  static IconData get empty => PiconsRegular.empty;
  static IconData get apps => PiconsRegular.squaresFour;
  static IconData get copy => PiconsRegular.copy;
  static IconData get document => PiconsRegular.fileText;
  static IconData get folder => PiconsRegular.folder;
  static IconData get star => PiconsRegular.star;
  static IconData get heart => PiconsRegular.heart;
  static IconData get globe => PiconsRegular.globe;

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

  static IconData get(String name) {
    switch (name.toLowerCase()) {
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

      case 'back':
        return back;
      case 'forward':
        return forward;
      case 'chevron_right':
        return chevronRight;
      case 'chevron_down':
        return chevronDown;

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

      case 'category':
      case 'tag':
        return category;

      case 'sms':
      case 'message':
        return sms;
      case 'email':
      case 'mail':
        return email;
      case 'sync':
      case 'repeat':
        return repeat;

      case 'calendar':
        return calendar;
      case 'clock':
        return clock;
      case 'schedule':
        return schedule;
      case 'history':
        return history;

      case 'user':
        return user;
      case 'profile':
        return profile;

      case 'notification':
      case 'bell':
        return notification;
      case 'cloud_done':
        return cloudDone;
      case 'cloud_off':
        return cloudOff;

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
        return PiconsRegular.question;
    }
  }
}
