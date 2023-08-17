import 'package:flutter/material.dart';
import 'TextSegment.dart';

extension TextStyleExtension on TextStyle {
  bool equalToStyle(TextStyle style) {
    return this.fontSize == style.fontSize &&
        this.fontWeight == style.fontWeight &&
        this.fontStyle == style.fontStyle &&
        this.color == style.color &&
        this.decoration == style.decoration;
  }
}

class TextSegments {
  List<TextSegment> replacements = [];
  String oldText = "";
  //上一次光标选中的区域
  TextRange? oldSelectRange;
  TextRange? oldEditingRange;

  //给某个range设置style
  void changeStyle(TextRange range,
      {FontWeight? weight,
      FontStyle? style,
      double? size,
      Color? color,
      TextDecoration? decoration}) {
    if (range.start == range.end) {
      return;
    }
    List<TextSegment> list = [];
    for (var i = 0; i < replacements.length; i++) {
      TextSegment element = replacements[i];
      TextStyle newStyle = element.style.copyWith(
          fontWeight: weight,
          fontStyle: style,
          fontSize: size,
          color: color,
          decoration: decoration);
      if (element.inRange(range) && !newStyle.equalToStyle(element.style)) {
        List<TextSegment> newList = element.changeRangeStyle(range, newStyle);
        list.addAll(newList);
      } else {
        list.add(element);
      }
    }
    replacements = list;
    _connect();
  }

  void config(
      {required TextRange selectRange,
      required TextRange editingRange,
      required String text,
      required TextStyle style}) {
    if (oldText == text) {
      oldSelectRange = selectRange;
      oldEditingRange = editingRange;
      return;
    }
    bool needContinue = handleOldSelectRange(selectRange, editingRange, text);
    if (needContinue == false) {
      return;
    }
    //删除
    if (text.length < oldText.length) {
      delete(selectRange, text);
    }
    //直接append到最后面
    else if (selectRange.start > oldText.length || replacements.length == 0) {
      append(selectRange, editingRange, text, style);
    }
    //从中间插入
    else {
      insert(selectRange, editingRange, text, style);
    }
    oldText = text;
    oldSelectRange = selectRange;
    oldEditingRange = editingRange;
  }

  //对光标选中的区域和正在编辑的区域进行处理
  bool handleOldSelectRange(
      TextRange selectRange, TextRange editingRange, String text) {
    //oldSelectRange光标选中多个，会走这个if，先吧光标之前选中的删除，再处理新文本
    if (oldSelectRange != null &&
        (oldSelectRange!.end != oldSelectRange!.start)) {
      delete(oldSelectRange!, oldText);
      oldText = replacements.map((e) => e.text).join();
    }
    //正在编辑的文字，还没点击确定（输入框中显示字母，点击确定之后才会选中文字）
    if (oldEditingRange != null &&
        !editingRange.isValid &&
        oldEditingRange?.isNormalized == true) {
      delete(oldEditingRange!, oldText);
      oldText = replacements.map((e) => e.text).join();
    }

    if (oldText == text) {
      oldSelectRange = selectRange;
      oldEditingRange = editingRange;
      return false;
    }
    return true;
  }

  void delete(TextRange range, String text) {
    if (range.start == -1 || range.end == -1) {
      return;
    }
    if (range.start == range.end) {
      int length = oldText.length - text.length;
      _deleteWithRange(
          TextRange(start: range.start + 1, end: range.start + length));
    }
    //删除多个
    else {
      _deleteWithRange(range);
    }
  }

  void _deleteWithRange(TextRange range) {
    List<TextSegment> segments = [];
    for (var i = 0; i < replacements.length; i++) {
      TextSegment element = replacements[i];
      element.removeWithRange(range);
      //更新位置
      if (i > 0) {
        element.start =
            replacements[i - 1].start + replacements[i - 1].text.length;
      }
      if (element.isEmpty() == false) {
        segments.add(element);
      }
    }
    replacements = segments;
  }

  void append(TextRange selectRange, TextRange editingRange, String text,
      TextStyle style) {
    if (replacements.length == 0) {
      replacements.add(TextSegment(start: 0, style: style, text: text));
    } else {
      TextSegment last = replacements.last;
      String rangeText = text.substring(oldText.length);
      if (last.style.equalToStyle(style)) {
        last.text = last.text + rangeText;
      } else {
        replacements.add(
            TextSegment(start: oldText.length, style: style, text: rangeText));
      }
    }
  }

  void insert(TextRange selectRange, TextRange editingRange, String text,
      TextStyle style) {
    int insertIndex = -1;
    List<TextSegment> list = replacements;
    //添加文字，selectRange是添加完之后的range，所以需要减去1
    int length = (text.length - oldText.length);
    selectRange = TextRange(
        start: selectRange.start - length, end: selectRange.end - length);

    //找到需要将添加的文字插入到replacements的某个元素中
    for (var i = 0; i < replacements.length; i++) {
      TextSegment element = replacements[i];
      if (element.inRange(selectRange)) {
        insertIndex = i;
        List newList = element.separateWithPos(selectRange.start);
        list[i] = newList.first;
        //如果加入到某个元素中，先将该元素分离成两个，后面将新元素加入到分离的两个元素中间
        if (list.length > i + 1) {
          list[i + 1] = newList.last;
          list.insert(i + 1, newList.last);
        } else {
          list.add(newList.last);
        }
        break;
      }
    }
    ////找到需要将添加的文字插入到replacements的某个元素后面
    if (insertIndex == -1) {
      for (var i = 0; i < replacements.length; i++) {
        TextSegment element = replacements[i];
        if (element.posIsNearRight(selectRange.start)) {
          insertIndex = i;
          break;
        }
      }
    }
    //都没找见，直接append到最后面
    if (insertIndex == -1) {
      print(
          "都没找见，直接append到最后面 selectRange = {${selectRange.start},${selectRange.end}}");
      append(selectRange, editingRange, text, style);
      return;
    }

    //将添加的文字加入进来
    int start = selectRange.start;
    TextSegment newT = TextSegment(
        start: selectRange.start,
        style: style,
        text: text.substring(start, start + length));
    list.insert(insertIndex + 1, newT);

    for (var i = insertIndex + 2; i < replacements.length; i++) {
      //插入的range后面的元素，range后移
      TextSegment element = replacements[i];
      element.start = element.start + length;
    }
    replacements = list;
    _connect();
  }

  //将style相同的连到一起，减少后面的for循环操作
  void _connect() {
    if (replacements.isEmpty) {
      return;
    }
    List<TextSegment> list = [replacements[0]];
    for (var i = 1; i < replacements.length; i++) {
      TextSegment element = replacements[i];
      TextSegment before = list.last;
      if (before.style.equalToStyle(element.style)) {
        before.text = before.text + element.text;
      } else {
        list.add(element);
      }
    }
    replacements = list;
  }
}
