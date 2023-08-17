import 'package:flutter/material.dart';
import 'TextSegments.dart';
import 'TextSegment.dart';

class RichTextEditingController extends TextEditingController {
  TextStyle _curStyle = TextStyle();

  void setCurStyle(TextStyle style) {
    _curStyle = style;
  }

  void changeTextStyle(
      {FontWeight? weight,
      FontStyle? style,
      double? size,
      Color? color,
      TextDecoration? decoration}) {
    _curStyle = _curStyle.copyWith(
        fontWeight: weight,
        fontStyle: style,
        fontSize: size,
        color: color,
        decoration: decoration);
    if (!selectRange.isCollapsed) {
      configs.changeStyle(selectRange,
          weight: weight,
          style: style,
          size: size,
          color: color,
          decoration: decoration);
    }
  }

  TextRange selectRange = TextRange.empty;
  TextSegments configs = TextSegments();

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    assert(!value.composing.isValid ||
        !withComposing ||
        value.isComposingRangeValid);
    //给TextSegments配置数据更新replacements
    this.selectRange = value.selection;
    configs.config(
        selectRange: value.selection,
        editingRange: value.composing,
        text: value.text,
        style: _curStyle);

    List<InlineSpan> children = [];
    print(
        "text = ${text}, replacements = ${configs.replacements.map((e) => e.toString())}");
    //拼接
    for (TextSegment element in configs.replacements) {
      TextSpan span = TextSpan(text: element.text, style: element.style);
      children.add(span);
    }
    return TextSpan(children: children);
  }
}
