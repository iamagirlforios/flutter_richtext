import 'dart:math';

import 'package:flutter/material.dart';

class TextSegment {
  int start;
  TextStyle style;
  String text;
  TextSegment({required this.start, required this.style, required this.text});
  //自己在不在选择的区域中
  bool inRange(TextRange range) {
    if (text.length < 1 || !range.isNormalized) return false;
    if (range.start >= start + text.length || range.end <= start) {
      return false;
    }
    if (containPos(range.start) || containPos(range.end)) {
      return true;
    }
    if (range.start <= start && range.end >= start + 1) {
      return true;
    }

    return false;
  }

  //某个点是否在相邻的左边
  bool posIsNearLeft(int pos) {
    return pos == start;
  }

  //某个点是否在相邻的右边
  bool posIsNearRight(int pos) {
    return pos == (start + text.length);
  }

  //删除某个区域的文字
  void removeWithRange(TextRange delRange) {
    if (isEmpty()) {
      return;
    }

    if (delRange.start == delRange.end) {
      removeWithPos(delRange.start);
    } else if (inRange(delRange)) {
      for (var i = delRange.start;
          i < min(start + text.length, delRange.end);
          i++) {
        removeWithPos(i + 1);
      }
    }
    removeText();
    return;
  }

  void removeText() {
    if (deleteTextIdxs.length > 0) {
      int idx = deleteTextIdxs[0];
      int length = deleteTextIdxs.length;
      text = text.replaceRange(idx, idx + length, "");
      deleteTextIdxs = [];
    }
  }

  List<int> deleteTextIdxs = [];
  //删除
  bool removeWithPos(int pos) {
    //在区域内，删除,或者在最右边，删除
    if (containPos(pos) || posIsNearRight(pos)) {
      //长度只有1，直接删除
      if (text.length == 1) {
        deleteTextIdxs.add(0);
      }
      //删除最后一个
      else if (posIsNearRight(pos)) {
        deleteTextIdxs.add(text.length - 1);
      }
      //删除最前面一个
      else if (pos == start - 1) {
        deleteTextIdxs.add(0);
      }
      //删除中间的
      else {
        int idx = pos - start;
        deleteTextIdxs.add(idx - 1);
      }
      return true;
    }
    return false;
  }

  bool isEmpty() {
    return text.length == 0;
  }

  //是否包含某个点
  bool containPos(int pos) {
    int end = start + text.length;
    return pos > start && pos < end;
  }

  //通过inset的idx分割当前的EditRangeTextSpan成两个
  List<TextSegment> separateWithPos(int pos) {
    if (containPos(pos) == false) {
      return [this];
    }
    List<TextSegment> list = [];
    int idx = (pos - start);
    list.add(
        TextSegment(start: start, style: style, text: text.substring(0, idx)));

    list.add(TextSegment(
        start: start + idx, style: style, text: text.substring(idx)));
    print("separate two = ${list}");
    return list;
  }

  /*
  改变range对应的text的style
  range：改变范围
  newStyle：新样式
  return：改变之后被切割成了不同style的TextSegment数组
  */
  List<TextSegment> changeRangeStyle(TextRange range, TextStyle newStyle) {
    List<TextSegment> list = [];
    int leftIdx = 0;
    if (range.start > start) {
      leftIdx = range.start - start;
      list.add(TextSegment(
          start: start, style: style, text: text.substring(0, leftIdx)));
    }
    if (range.end >= start + text.length) {
      list.add(TextSegment(
          start: start + leftIdx,
          style: newStyle,
          text: text.substring(leftIdx)));
    } else {
      int rightIdx = range.end - start;
      list.add(TextSegment(
          start: start + leftIdx,
          style: newStyle,
          text: text.substring(leftIdx, rightIdx)));
      list.add(TextSegment(
          start: start + rightIdx,
          style: style,
          text: text.substring(rightIdx)));
    }
    return list;
  }

  @override
  String toString() {
    return "$text{${start},${start + text.length}}";
  }
}
