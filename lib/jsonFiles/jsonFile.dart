import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';


class Json{

  File jsonFile;
  Directory dir;
  String fileName = "myJSONFile.json";

  writeToFile(dynamic value1, dynamic value2) async {
    final directory = await getApplicationDocumentsDirectory();
    print("path = "+directory.path);
    Map<String,dynamic> content1 = {'LAT': value1};
    Map<String,dynamic> content2 = {'LNG': value2};
    final jsonFile = File('${directory.path}/$fileName');
    if(jsonFile != null){
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content1);
      jsonFileContent.addAll(content2);
      await jsonFile.writeAsString(jsonEncode(content1));
      await jsonFile.writeAsString(jsonEncode(content2));
    }
  }
}

