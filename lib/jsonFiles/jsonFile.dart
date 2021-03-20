import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';


class Json{
  

  save(String key1,dynamic value1,String key2, dynamic value2) async {
    final directory = await getApplicationDocumentsDirectory();
    print("path = "+directory.path);
    final file = File('${directory.path}/myfile.json');
    Map<String,dynamic> content1 = {key1: value1};
    Map<String,dynamic> content2 = {key2: value2};
    await file.writeAsString(jsonEncode(content1),mode: FileMode.append);
    await file.writeAsString(jsonEncode(content2),mode: FileMode.append);
  }







}

