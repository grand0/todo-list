import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ItemsStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/items');
  }

  Future<bool> get localFileExists async {
    final file = await _localFile;
    return file.exists();
  }

  void createLocalFile() async {
    final file = await _localFile;
    file.create();
  }

  void writeItems(List<String> items) async {
    String json = jsonEncode(items);
    final file = await _localFile;
    file.writeAsString(json);
  }

  Future<List<String>> readItems() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      if (contents.isEmpty) return <String>[];
      List<dynamic> dec = jsonDecode(contents);
      // converting dynamics to strings
      List<String> items = [];
      for (dynamic d in dec) {
        if (d is String) {
          // ensures that we can convert item
          items.add(d);
        }
      }
      return items;
    } catch (e) {
      print(e);
      return <String>[];
    }
  }
}
