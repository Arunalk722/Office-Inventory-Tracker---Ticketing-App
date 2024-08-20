import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dart/widgets/input_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TOCSVFile {
  Future<void> csv(
      List<List<String>> data, String name, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted) {
        Directory? downloadsDirectory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = downloadsDirectory!.path.split("/");
        for (int i = 1; i < paths.length; i++) {
          String path = paths[i];
          if (path != "Android") {
            newPath += "/" + path;
          } else {
            break;
          }
        }
        newPath = newPath + "/Download";
        downloadsDirectory = Directory(newPath);

        String filePath = '${downloadsDirectory.path}/${name}.csv';
        File file = File(filePath);

        String csvData = const ListToCsvConverter().convert(data);
        await file.writeAsString(csvData);
        ShowDialogs.showdialog(context,
            msg: 'you have successfully export ${name} data in ${filePath}',
            title: 'successfully export',
            icons: Icon(Icons.check),
            iconColors: Colors.green);
      } else {
        print('Permission denied');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
