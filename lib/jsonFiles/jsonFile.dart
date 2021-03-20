import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:x/services/geolocator_service.dart';

class Json{

  File testFile;
  Directory dir;
  String fileName = "myFile.txt";
  bool fileExists = false;
  Map<String, dynamic> fileContent;

  void getDir() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
    });

  }

  void createFile(dynamic contents,Directory dir, String filename){

    testFile = new File(dir.path + "/" + fileName);
    fileExists = testFile.existsSync();
    testFile.createSync();
    fileExists = true;
    testFile.writeAsStringSync(contents);
  }

  void writeToFile(contents) {
    if (fileExists) {
      print("File exists");
      dynamic testFileContent = testFile.readAsStringSync();
      testFileContent.addAll(contents);
      testFile.writeAsStringSync(testFileContent);
    } else {
      print("File does not exist!");
      createFile(contents, dir, fileName);
    }
  }








}

