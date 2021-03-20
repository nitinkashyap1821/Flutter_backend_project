import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';


class Json{

  save(String x) async {
    final directory = await getApplicationDocumentsDirectory();
    print("path = "+directory.path);
    final file = File('${directory.path}/myfile.txt');
    await file.writeAsString(x+"\n",mode: FileMode.append);
  }







}

