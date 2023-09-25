import 'dart:io';

import 'package:fluent_reader_lite/models/service.dart';
import 'package:fluent_reader_lite/pages/article_page.dart';
import 'package:fluent_reader_lite/pages/error_log_page.dart';
import 'package:fluent_reader_lite/pages/settings/about_page.dart';
import 'package:fluent_reader_lite/pages/home_page.dart';
import 'package:fluent_reader_lite/pages/settings/feed_page.dart';
import 'package:fluent_reader_lite/pages/settings/general_page.dart';
import 'package:fluent_reader_lite/pages/settings/reading_page.dart';
import 'package:fluent_reader_lite/pages/settings/services/feedbin_page.dart';
import 'package:fluent_reader_lite/pages/settings/services/fever_page.dart';
import 'package:fluent_reader_lite/pages/settings/services/greader_page.dart';
import 'package:fluent_reader_lite/pages/settings/services/inoreader_page.dart';
import 'package:fluent_reader_lite/pages/settings/source_edit_page.dart';
import 'package:fluent_reader_lite/pages/settings/sources_page.dart';
import 'package:fluent_reader_lite/pages/settings_page.dart';
import 'package:fluent_reader_lite/utils/global.dart';
import 'package:fluent_reader_lite/utils/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'generated/l10n.dart';
import 'models/global_model.dart';

/**
 * 应用程序的主入口函数。
 * 该函数初始化Flutter的Widget绑定，确保SharedPreferences实例被初始化并创建全局配置。
 * 对于Android平台，还会调整状态栏样式并使用SurfaceAndroidWebView作为WebView平台。
 * 最后，运行应用程序的主要Widget树，并设置生命周期消息处理器以处理应用恢复事件。
 */
void main() async {
  // 初始化Flutter的Widget绑定
  WidgetsFlutterBinding.ensureInitialized();
  // 获取SharedPreferences的实例，并赋值给全局变量
  // SharedPreferences的实例在Dart（尤其是Flutter）中用于存储应用的轻量级持久化数据，通常是用户偏好设置、配置信息或其他小型数据。以下是一些使用SharedPreferences实例的常见用途：
  // 用户偏好设置：保存用户选择的语言、主题、音量设置等。
  // 应用配置：存储应用的配置信息，比如API密钥、默认值或用户首次启动应用的标志。
  // 临时数据：如果需要在应用会话之间保持一些临时数据，但不需要数据库级别的存储，可以使用SharedPreferences。
  // 登录状态：保存用户登录状态，以便在下次打开应用时自动登录（通常配合令牌或布尔值）。
  // 统计信息：记录用户的行为或应用的使用统计数据。
  // 以下是一个简单的Dart代码示例，展示了如何获取SharedPreferences实例以及如何使用它来存储和检索数据：
  Store.sp = await SharedPreferences.getInstance();
  // 进行全局初始化
  Global.init();
  // 如果是Android平台，则设置状态栏透明，并指定WebView使用SurfaceAndroidWebView
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    WebView.platform = SurfaceAndroidWebView();
  }
  // 运行应用的主Widget
  runApp(MyApp());
  // 设置系统生命周期通道的消息处理器
  SystemChannels.lifecycle.setMessageHandler((msg) {
    // 当应用从后台回到前台时，重启服务器并根据配置同步数据
    if (msg == AppLifecycleState.resumed.toString()) {
      if (Global.server != null) Global.server.restart();
      if (Global.globalModel.syncOnStart &&
          DateTime.now().difference(Global.syncModel.lastSynced).inMinutes >=
              10) {
        Global.syncModel.syncWithService();
      }
    }
    return null;
  });
}


class MyApp extends StatelessWidget {
  static final Map<String, Widget Function(BuildContext)> baseRoutes = {
    "/article": (context) => ArticlePage(),
    "/error-log": (context) => ErrorLogPage(),
    "/settings": (context) => SettingsPage(),
    "/settings/sources": (context) => SourcesPage(),
    "/settings/sources/edit": (context) => SourceEditPage(),
    "/settings/feed": (context) => FeedPage(),
    "/settings/reading": (context) => ReadingPage(),
    "/settings/general": (context) => GeneralPage(),
    "/settings/about": (context) => AboutPage(),
    "/settings/service/fever": (context) => FeverPage(),
    "/settings/service/feedbin": (context) => FeedbinPage(),
    "/settings/service/inoreader": (context) => InoreaderPage(),
    "/settings/service/greader": (context) => GReaderPage(),
    "/settings/service": (context) {
      var serviceType =
          SyncService.values[Store.sp.getInt(StoreKeys.SYNC_SERVICE) ?? 0];
      switch (serviceType) {
        case SyncService.None:
          break;
        case SyncService.Fever:
          return FeverPage();
        case SyncService.Feedbin:
          return FeedbinPage();
        case SyncService.GReader:
          return GReaderPage();
          break;
        case SyncService.Inoreader:
          return InoreaderPage();
          break;
      }
      return AboutPage();
    }
  };
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Global.globalModel),
        ChangeNotifierProvider.value(value: Global.sourcesModel),
        ChangeNotifierProvider.value(value: Global.itemsModel),
        ChangeNotifierProvider.value(value: Global.feedsModel),
        ChangeNotifierProvider.value(value: Global.groupsModel),
        ChangeNotifierProvider.value(value: Global.syncModel),
      ],
      child: Consumer<GlobalModel>(
        builder: (context, globalModel, child) => CupertinoApp(
          title: "Fluent Reader",
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: globalModel.locale,
          supportedLocales: [
            const Locale("de"),
            const Locale("en"),
            const Locale("es"),
            const Locale("zh"),
            const Locale("fr"),
            const Locale("uk"),
            const Locale("hr"),
            const Locale("pt"),
            const Locale("tr"),
          ],
          localeResolutionCallback: (_locale, supportedLocales) {
            _locale = Locale(_locale.languageCode);
            if (globalModel.locale != null)
              return globalModel.locale;
            else if (supportedLocales.contains(_locale))
              return _locale;
            else
              return Locale("en");
          },
          theme: CupertinoThemeData(
            primaryColor: CupertinoColors.systemBlue,
            brightness: globalModel.getBrightness(),
          ),
          routes: {
            "/": (context) => CupertinoScaffold(
                body: CupertinoTheme(
                    // For fixing the bug with modal_bottom_sheet overriding primary color
                    data: CupertinoThemeData(
                        primaryColor: CupertinoColors.activeBlue),
                    child: HomePage())),
            ...baseRoutes,
          },
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            if (Global.globalModel.textScale == null) return child;
            return MediaQuery(
                data: mediaQueryData.copyWith(
                    textScaleFactor: Global.globalModel.textScale),
                child: child);
          },
        ),
      ),
    );
  }
}
