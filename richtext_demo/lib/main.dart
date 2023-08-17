import 'package:flutter/material.dart';

import 'richtext/RichTextFieldController.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RichText Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'RichText Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RichTextEditingController controller = RichTextEditingController();
  FocusNode focusNode = FocusNode();
  TextStyle _style =
      TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.red);

  @override
  void initState() {
    super.initState();
    controller.setCurStyle(_style);
    // WidgetsBinding 它能监听到第一帧绘制完成，第一帧绘制完成标志着已经Build完成
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 8,
                decoration: InputDecoration(
                    isCollapsed: true, border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              color: Colors.grey[200],
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: GridView.count(
                  childAspectRatio: 1.5,
                  crossAxisCount: 6,
                  children: _buildTextStyleWidgets),
            )
          ],
        ));
  }

  List<Widget> get _buildTextStyleWidgets {
    return [
      TextButton(
          onPressed: () {
            onChangeFontStyle(FontStyle.italic);
          },
          child: Text("斜体", style: TextStyle(fontStyle: FontStyle.italic))),
      TextButton(
          onPressed: () {
            onChangeFontWeight();
          },
          child: Text("加粗", style: TextStyle(fontWeight: FontWeight.bold))),
      TextButton(
          onPressed: () {
            onChangeTextDecoration(TextDecoration.underline);
          },
          child: Text("下划线",
              style: TextStyle(decoration: TextDecoration.underline))),
      TextButton(
          onPressed: () {
            onChangeTextDecoration(TextDecoration.lineThrough);
          },
          child: Text("删除线",
              style: TextStyle(decoration: TextDecoration.lineThrough))),
      TextButton(
          onPressed: () {
            onChangeTextColor(Colors.red);
          },
          child: Text("红色", style: TextStyle(color: Colors.red))),
      TextButton(
          onPressed: () {
            onChangeTextColor(Colors.blue);
          },
          child: Text("蓝色", style: TextStyle(color: Colors.blue))),
      TextButton(
          onPressed: () {
            onChangeTextColor(Colors.green);
          },
          child: Text("绿色", style: TextStyle(color: Colors.green))),
      TextButton(
          onPressed: () {
            onChangeTextColor(Colors.yellow);
          },
          child: Text("黄色", style: TextStyle(color: Colors.yellow))),
      TextButton(
          onPressed: () {
            onChangeTextColor(Colors.purple);
          },
          child: Text("紫色", style: TextStyle(color: Colors.purple)))
    ];
  }

  void onChangeFontSize(double size) {
    onChangeStyle(size: (_style.fontSize ?? 16) + size);
  }

  void onChangeFontStyle(FontStyle fontStyle) {
    onChangeStyle(style: fontStyle);
  }

  void onChangeTextDecoration(TextDecoration textDecoration) {
    onChangeStyle(decoration: textDecoration);
  }

  void onChangeFontWeight() {
    FontWeight fontWeight = _style.fontWeight == FontWeight.bold
        ? FontWeight.normal
        : FontWeight.bold;
    onChangeStyle(weight: fontWeight);
  }

  void onChangeTextColor(Color color) {
    onChangeStyle(color: color);
  }

  void onChangeStyle(
      {FontWeight? weight,
      FontStyle? style,
      double? size,
      Color? color,
      TextDecoration? decoration}) {
    controller.changeTextStyle(
        weight: weight,
        style: style,
        size: size,
        color: color,
        decoration: decoration);
    setState(() {});
  }
}
