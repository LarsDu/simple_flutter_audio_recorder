import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class FileStorage {
  // A class for saving and retrieving files from the apps Documents directory.
  Future<Directory> get docDir async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory;
    } catch (e) {
      // Return 0 if error encountered.
      print("Error, failed to get documents directory");
      return null;
    }
  }

  
}






/*
class FileStorageContext extends InheritedWidget{
  final FileStorage storage = FileStorage();
  FileStorageContext(child): super(child: child);

  @override
  bool updateShouldNotify(FileStorageContext old){
    // Notify flutter that the storage object has changed
    return old.storage != storage;
  }

  static FileStorageContext of(BuildContext context){
    return (context.inheritFromWidgetOfExactType(FileStorageContext) as FileStorageContext);
  } 


}
*/
