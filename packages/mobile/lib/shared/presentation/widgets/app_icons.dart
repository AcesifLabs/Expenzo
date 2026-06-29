import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

class AppIcons {
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

  static const Map<String, IconData> _iconNameLookup = {
    'home': PiconsRegular.house,
    'dashboard': PiconsRegular.squaresFour,
    'scan': PiconsRegular.listMagnifyingGlass,
    'search': PiconsRegular.magnifyingGlass,
    'settings': PiconsRegular.faders,
    'add': PiconsRegular.plus,
    'plus': PiconsRegular.plus,
    'delete': PiconsRegular.trash,
    'trash': PiconsRegular.trash,
    'edit': PiconsRegular.pencilSimple,
    'check': PiconsRegular.check,
    'close': PiconsRegular.x,
    'x': PiconsRegular.x,
    'menu': PiconsRegular.list,
    'filter': PiconsRegular.funnel,
    'refresh': PiconsRegular.arrowsClockwise,
    'save': PiconsRegular.floppyDisk,
    'share': PiconsRegular.shareNetwork,
    'download': PiconsRegular.downloadSimple,
    'upload': PiconsRegular.uploadSimple,
    'warning': PiconsRegular.warning,
    'error': PiconsRegular.warningCircle,
    'success': PiconsRegular.checkCircle,
    'info': PiconsRegular.info,
    'help': PiconsRegular.question,
    'back': PiconsRegular.arrowLeft,
    'forward': PiconsRegular.arrowRight,
    'chevron_right': PiconsRegular.caretRight,
    'chevron_down': PiconsRegular.caretDown,
    'wallet': PiconsRegular.wallet,
    'money': PiconsRegular.currencyDollar,
    'receipt': PiconsRegular.invoice,
    'card': PiconsRegular.creditCard,
    'trending_up': PiconsRegular.trendUp,
    'trending_down': PiconsRegular.trendDown,
    'chart': PiconsRegular.chartBar,
    'pie_chart': PiconsRegular.chartPie,
    'category': PiconsRegular.tag,
    'tag': PiconsRegular.tag,
    'sms': PiconsRegular.chatDots,
    'message': PiconsRegular.chatDots,
    'email': PiconsRegular.envelope,
    'mail': PiconsRegular.envelope,
    'sync': PiconsRegular.arrowsClockwise,
    'repeat': PiconsRegular.arrowsClockwise,
    'calendar': PiconsRegular.calendar,
    'clock': PiconsRegular.clock,
    'schedule': PiconsRegular.calendarBlank,
    'history': PiconsRegular.clockCounterClockwise,
    'user': PiconsRegular.user,
    'profile': PiconsRegular.userCircle,
    'notification': PiconsRegular.bell,
    'bell': PiconsRegular.bell,
    'cloud_done': PiconsRegular.cloud,
    'cloud_off': PiconsRegular.cloudX,
    'phone': PiconsRegular.phone,
    'location': PiconsRegular.mapPin,
    'map': PiconsRegular.mapPin,
    'image': PiconsRegular.image,
    'link': PiconsRegular.link,
    'wifi': PiconsRegular.wifiHigh,
    'lock': PiconsRegular.lock,
    'unlock': PiconsRegular.lockOpen,
    'security': PiconsRegular.shield,
    'shield': PiconsRegular.shield,
    'visibility': PiconsRegular.eye,
    'visibility_off': PiconsRegular.eyeClosed,
    'empty': PiconsRegular.empty,
    'inbox': PiconsRegular.empty,
    'apps': PiconsRegular.squaresFour,
    'copy': PiconsRegular.copy,
    'document': PiconsRegular.fileText,
    'file': PiconsRegular.fileText,
    'folder': PiconsRegular.folder,
    'star': PiconsRegular.star,
    'favorite': PiconsRegular.star,
    'heart': PiconsRegular.heart,
    'globe': PiconsRegular.globe,
    'earth': PiconsRegular.globe,
    'printer': PiconsRegular.printer,
  };

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

  AppIcons._();

  static IconData getCategoryIcon(String iconName) {
    final iconData = _categoryIconMap[iconName];
    if (iconData != null) return iconData;

    return PiconsRegular.package;
  }

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
    final icon = _iconNameLookup[name.toLowerCase()];

    return icon ?? PiconsRegular.question;
  }
}
