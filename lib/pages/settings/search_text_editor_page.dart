import 'dart:async';
import 'package:fluent_reader_lite/utils/global.dart';
import 'package:fluent_reader_lite/components/list_tile_group.dart';
import 'package:fluent_reader_lite/components/my_list_tile.dart';
import 'package:fluent_reader_lite/generated/l10n.dart';
import 'package:fluent_reader_lite/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchTextEditorPage extends StatefulWidget {
  // 标题，用于文本输入界面的顶部或者相关提示信息中。
  final String title;

  // 确定按钮上显示的文本内容。
  final String saveText;

  // 文本输入框的初始值。
  final String initialValue;

  // 导航栏的颜色，用于自定义界面风格。
  final Color navigationBarColor;

  // 一个函数，用于验证用户输入的文本。接收一个字符串参数（用户输入），返回一个FutureOr<bool>类型的值（验证结果）。
  final FutureOr<bool> Function(String) validate;

  // 定义了文本输入的类型，例如电子邮件、电话号码等。这有助于定制键盘类型。
  final TextInputType inputType;

  // 指定是否自动纠正用户输入的文本。
  final bool autocorrect;

  SearchTextEditorPage(
    this.title,
    this.validate, {
    this.navigationBarColor,
    this.saveText,
    this.initialValue: "",
    this.inputType,
    this.autocorrect: false,
    Key key,
  }) : super(key: key);

  @override
  _SearchTextEditorPage createState() => _SearchTextEditorPage();
}

class _SearchTextEditorPage extends State<SearchTextEditorPage> {
  TextEditingController _controller;
  bool _validating = false;
  List<String> savedValues = []; // 用于保存值的列表

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {

    final List<Map<String, dynamic>> result = await Global.db.query('searchValues');
    setState(() {
      savedValues = result.map((e) => e['value'] as String).toList();
    });
  }

  void _onSave() async {
    setState(() {
      _validating = true;
    });
    var trimmed = _controller.text.trim();
    var valid = await widget.validate(trimmed);
    if (!mounted) return;
    setState(() {
      _validating = false;
    });
    if (valid) {
      Navigator.of(context).pop(trimmed);
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(S.of(context).invalidValue),
          actions: [
            CupertinoDialogAction(
              child: Text(S.of(context).close),
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _onFavoritePressed() async {
    final value = _controller.text;
    if (value.isNotEmpty && !savedValues.contains(value)) {
      setState(() {
        savedValues.add(value);
      });
      await _saveToDatabase(value);
    }
  }

  void _removeValue(String value) async {
    setState(() {
      savedValues.remove(value);
    });
    await _deleteFromDatabase(value);
  }

  Future<void> _saveToDatabase(String value) async {
    await Global.db.insert('searchValues', {'value': value});
  }

  Future<void> _deleteFromDatabase(String value) async {
    await Global.db
        .delete('searchValues', where: 'value = ?', whereArgs: [value]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: MyColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        backgroundColor: widget.navigationBarColor,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: _validating
              ? CupertinoActivityIndicator()
              : Text(widget.saveText ?? S.of(context).save),
          onPressed: _validating ? null : _onSave,
        ),
      ),
      child: ListView(children: [
        ListTileGroup([
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _controller,
                  decoration: null,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  readOnly: _validating,
                  autofocus: true,
                  obscureText:
                      widget.inputType == TextInputType.visiblePassword,
                  keyboardType: widget.inputType,
                  onSubmitted: (v) {
                    _onSave();
                  },
                  autocorrect: widget.autocorrect,
                  enableSuggestions: widget.autocorrect,
                ),
              ),
              GestureDetector(
                onTap: _onFavoritePressed,
                child: Row(
                  children: [
                    Icon(Icons.bookmark), // 添加收藏图标
                    SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ]),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'Custom Search',
            style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel.resolveFrom(context), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        if (savedValues != null)
          ...savedValues.map((s) {
            return MyListTile(
              title: Flexible(
                child: Text(
                  s,
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailingChevron: false,
              // background: Colors.grey[300],
              onTap: () {
                _controller.text = s;
              },
              trailing: GestureDetector(
                onTap: () {
                  _removeValue(s);
                },
                child: Icon(Icons.delete, color: Colors.red),
              ),
            );
          }),
      ]),
    );
  }
}
