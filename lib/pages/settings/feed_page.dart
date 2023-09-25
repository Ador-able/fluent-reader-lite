import 'package:fluent_reader_lite/components/list_tile_group.dart';
import 'package:fluent_reader_lite/components/my_list_tile.dart';
import 'package:fluent_reader_lite/generated/l10n.dart';
import 'package:fluent_reader_lite/models/feeds_model.dart';
import 'package:fluent_reader_lite/models/groups_model.dart';
import 'package:fluent_reader_lite/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class FeedPage extends StatelessWidget {

  /*
    该函数是一个Dart函数，用于打开一个手势选项页面。函数接受两个参数：context和isToRight。
    context是构建上下文，用于访问当前的UI上下文信息；
    isToRight是一个布尔值，表示手势是从右向左滑动还是从左向右滑动。

    函数内部使用Navigator.of(context).push()来导航到一个新的页面。
    这个新页面是一个CupertinoPageRoute，使用CupertinoPageScaffold作为页面的基本框架。
    CupertinoPageScaffold有
    一个背景颜色属性backgroundColor，设置为MyColors.background；
    一个navigationBar属性，用于设置导航栏，其中middle属性是一个Text，显示根据isToRight参数决定的文本；一个child属性，用于设置页面的主要内容。
    页面的主要内容是一个Consumer<FeedsModel>，用于监听FeedsModel的改变并构建UI。

    Consumer<FeedsModel>的builder属性是一个函数，接受三个参数：context、feedsModel和child。
    在这个函数内部，定义了一个swipeOptons列表，包含了手势选项的文本和对应的操作。
    然后使用ListView来展示这些选项，每个选项都是一个ListTileGroup，通过ListTileGroup.fromOptions()方法从swipeOptons列表中创建。
    ListTileGroup.fromOptions()方法接受三个参数：选项列表、当前选中的选项和一个回调函数。
    当用户选择一个选项时，回调函数会被调用，并更新FeedsModel中的swipeR或swipeL属性，具体取决于isToRight参数的值
   */
  void _openGestureOptions(BuildContext context, bool isToRight) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => CupertinoPageScaffold(
        backgroundColor: MyColors.background,
        navigationBar: CupertinoNavigationBar(
          middle: Text(isToRight ? S.of(context).swipeRight : S.of(context).swipeLeft),
        ),
        child: Consumer<FeedsModel>(
          builder: (context, feedsModel, child) {
            final swipeOptons = [
              Tuple2(S.of(context).toggleRead, ItemSwipeOption.ToggleRead),
              Tuple2(S.of(context).toggleStar, ItemSwipeOption.ToggleStar),
              Tuple2(S.of(context).share, ItemSwipeOption.Share),
              Tuple2(S.of(context).openExternal, ItemSwipeOption.OpenExternal),
              Tuple2(S.of(context).openMenu, ItemSwipeOption.OpenMenu),
            ];
            return ListView(children: [
              ListTileGroup.fromOptions(
                swipeOptons,
                isToRight ? feedsModel.swipeR : feedsModel.swipeL,
                (v) { 
                  if (isToRight) feedsModel.swipeR = v;
                  else feedsModel.swipeL = v;
                },
              ),
            ]);
          },
        ),
      ),
    ));
  }

  @override
  // Flutter中Widget的生命周期方法，用于生成UI。它接收一个BuildContext参数，用于获取当前构建上下文信息
  Widget build(BuildContext context) {
    // CupertinoPageScaffold：这是一个iOS风格的页面框架，提供了导航栏和背景颜色等功能
    return CupertinoPageScaffold(
      backgroundColor: MyColors.background,
      // navigationBar：定义了导航栏，其中middle属性设置了导航栏中间的文本。
      navigationBar: CupertinoNavigationBar(
        middle: Text(S.of(context).feed),
      ),
      child: Consumer<FeedsModel>(
        // Consumer<FeedsModel>：这是一个依赖注入Widget，用于监听FeedsModel的改变并实时更新UI。builder方法接收context，feedsModel和child参数，返回一个Widget。
        builder: (context, feedsModel, child) {
          final swipeOptons = {
            ItemSwipeOption.ToggleRead: S.of(context).toggleRead,
            ItemSwipeOption.ToggleStar: S.of(context).toggleStar,
            ItemSwipeOption.Share: S.of(context).share,
            ItemSwipeOption.OpenExternal: S.of(context).openExternal,
            ItemSwipeOption.OpenMenu: S.of(context).openMenu,
          };
          final preferences = ListTileGroup([
            MyListTile(
              title: Text(S.of(context).showThumb),
              trailing: CupertinoSwitch(
                value: feedsModel.showThumb,
                onChanged: (v) { feedsModel.showThumb = v; },
              ),
              trailingChevron: false,
            ),
            MyListTile(
              title: Text(S.of(context).showSnippet),
              trailing: CupertinoSwitch(
                value: feedsModel.showSnippet,
                onChanged: (v) { feedsModel.showSnippet = v; },
              ),
              trailingChevron: false,
            ),
            MyListTile(
              title: Text(S.of(context).dimRead),
              trailing: CupertinoSwitch(
                value: feedsModel.dimRead,
                onChanged: (v) { feedsModel.dimRead = v; },
              ),
              trailingChevron: false,
              withDivider: false,
            ),
          ], title: S.of(context).preferences);
          final groups = ListTileGroup([
            Consumer<GroupsModel>(
              builder: (context, groupsModel, child) {
                return MyListTile(
                  title: Text(S.of(context).showUncategorized),
                  trailing: CupertinoSwitch(
                    value: groupsModel.showUncategorized,
                    onChanged: (v) { groupsModel.showUncategorized = v; },
                  ),
                  trailingChevron: false,
                  withDivider: false,
                );
              },
            ),
          ], title: S.of(context).groups);
          return ListView(
            children: [
              preferences,
              groups,
              ListTileGroup([
                MyListTile(
                  title: Text(S.of(context).swipeRight),
                  trailing: Text(swipeOptons[feedsModel.swipeR]),
                  onTap: () { _openGestureOptions(context, true); },
                ),
                MyListTile(
                  title: Text(S.of(context).swipeLeft),
                  trailing: Text(swipeOptons[feedsModel.swipeL]),
                  onTap: () { _openGestureOptions(context, false); },
                  withDivider: false,
                ),
              ], title: S.of(context).gestures),
            ],
          );
        },
      ),
    );
  }
}