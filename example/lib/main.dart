import 'package:example/src/my_symbols.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.purple,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Material Symbols'),
        ),
        body: ListView(
          children: MySymbols.all.entries.map((icon) {
            final name = icon.key;
            final data = icon.value;
            return ListTile(
              leading: Icon(data),
              title: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }
}
