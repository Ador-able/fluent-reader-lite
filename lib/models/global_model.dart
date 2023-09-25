import 'dart:io';

import 'package:fluent_reader_lite/utils/store.dart';
import 'package:flutter/material.dart';

enum ThemeSetting { Default, Light, Dark }

// 在Dart中，with ChangeNotifier 表明 GlobalModel 类混合了 ChangeNotifier 类的功能。
// ChangeNotifier 是Flutter框架中的一个类，它是状态管理库provider的一部分，主要用于实现通知机制
// 当对象的状态发生变化时，它可以通知依赖它的观察者（通常是在Widget树中）。
// ChangeNotifier 提供了一些方法，如 notifyListeners()
// 当你调用这个方法时，所有订阅了这个ChangeNotifier实例的监听器都会接收到通知，从而触发它们的重建。
//
// 这在构建响应式的用户界面时非常有用，因为它允许你管理状态并自动更新关联的Widgets，而无需手动管理状态传递。
// 所以，当你看到 class GlobalModel with ChangeNotifier，这意味着 GlobalModel 类不仅定义了自己的状态和行为
// 还继承了 ChangeNotifier 类的所有属性和方法。
//
// 这样，GlobalModel 实例就可以作为状态容器，当其状态变化时，能够通知到使用它的Widgets进行刷新。
// 通常，这样的类会被用作Provider的类型，以便在Flutter应用中进行状态管理。
class GlobalModel with ChangeNotifier {
  ThemeSetting _theme = Store.getTheme();
  Locale _locale = Store.getLocale();
  int _keepItemsDays = Store.sp.getInt(StoreKeys.KEEP_ITEMS_DAYS) ?? 21;
  bool _syncOnStart = Store.sp.getBool(StoreKeys.SYNC_ON_START) ?? true;
  bool _inAppBrowser =
      Store.sp.getBool(StoreKeys.IN_APP_BROWSER) ?? Platform.isIOS;
  double _textScale = Store.sp.getDouble(StoreKeys.TEXT_SCALE);

  ThemeSetting get theme => _theme;

  set theme(ThemeSetting value) {
    if (value != _theme) {
      _theme = value;
      notifyListeners();
      Store.setTheme(value);
    }
  }

  Brightness getBrightness() {
    if (_theme == ThemeSetting.Default)
      return null;
    else
      return _theme == ThemeSetting.Light ? Brightness.light : Brightness.dark;
  }

  Locale get locale => _locale;

  set locale(Locale value) {
    if (value != _locale) {
      _locale = value;
      notifyListeners();
      Store.setLocale(value);
    }
  }

  int get keepItemsDays => _keepItemsDays;

  set keepItemsDays(int value) {
    _keepItemsDays = value;
    Store.sp.setInt(StoreKeys.KEEP_ITEMS_DAYS, value);
  }

  bool get syncOnStart => _syncOnStart;

  set syncOnStart(bool value) {
    _syncOnStart = value;
    Store.sp.setBool(StoreKeys.SYNC_ON_START, value);
  }

  bool get inAppBrowser => _inAppBrowser;

  set inAppBrowser(bool value) {
    _inAppBrowser = value;
    Store.sp.setBool(StoreKeys.IN_APP_BROWSER, value);
  }

  double get textScale => _textScale;

  set textScale(double value) {
    if (_textScale != value) {
      _textScale = value;
      notifyListeners();
      if (value == null) {
        Store.sp.remove(StoreKeys.TEXT_SCALE);
      } else {
        Store.sp.setDouble(StoreKeys.TEXT_SCALE, value);
      }
    }
  }
}
/**
    这段代码定义了一个GlobalModel类，它使用了ChangeNotifier来管理全局应用程序设置。该类提供了以下属性和方法：
    _theme：存储当前应用程序的主题设置，类型为ThemeSetting。通过theme属性进行获取和设置，设置新值时会触发notifyListeners()通知监听器。
    _locale：存储当前应用程序的地区设置，类型为Locale。通过locale属性进行获取和设置，设置新值时会触发notifyListeners()通知监听器。
    _keepItemsDays：存储保留项目的天数，类型为int。通过keepItemsDays属性进行获取和设置，设置新值时会保存到SharedPreferences中。
    _syncOnStart：存储应用程序启动时是否进行同步的设置，类型为bool。通过syncOnStart属性进行获取和设置，设置新值时会保存到SharedPreferences中。
    _inAppBrowser：存储是否在应用程序内使用浏览器的设置，类型为bool。通过inAppBrowser属性进行获取和设置，设置新值时会保存到SharedPreferences中。
    _textScale：存储文本缩放比例，类型为double。通过textScale属性进行获取和设置，设置新值时会触发notifyListeners()通知监听器，并保存到SharedPreferences中。
    此外，该类还提供了getBrightness()方法，根据当前主题设置返回相应的亮度值（Brightness.light或Brightness.dark），如果主题设置为默认值，则返回null。
    这个类的主要作用是管理应用程序的全局设置，提供获取和设置这些设置的方法，并在设置更改时通知监听器。这些设置包括主题、地区、保留项目天数、启动时同步、在应用程序内使用浏览器以及文本缩放比例
 */
