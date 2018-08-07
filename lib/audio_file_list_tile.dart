import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';


import 'save_dialog.dart';
import 'audio_play_bar.dart';

class AudioFileListTile extends StatefulWidget {
  final FileSystemEntity file;
  AudioFileListTile({Key key, this.file}) : super(key: key);

  @override
  AudioFileListTileState createState() {
    return new AudioFileListTileState(file);
  }
}

class AudioFileListTileState extends State<AudioFileListTile> {
  FileSystemEntity file;
  String filePath;
  String fileName;




  @override
  AudioFileListTileState(FileSystemEntity file) {
    this.file = file;
    initFileAttributes();

  }



  initFileAttributes(){
    // Init some convenience variables
    this.filePath = file.path;
    this.fileName = this.filePath.split("/").last.split('.').first;
  }


  renameFile(newFile){
    // A callback for renaming the listtile

    // Rebuild
    //setState((){
    //  file=newFile;

    //});
    //initFileAttributes();

    print("Changed file to $this.file");
  }

  _deleteFile(File file) {
    // Delete a file and rebuild this widget parent!
    setState(() => file.deleteSync());
    print("Deleted file $fileName");
    Navigator.pop(context);
  }

  AlertDialog _openQueryDeleteDialog() {
    return AlertDialog(
        title: Text("Delete"),
        content: Text("$fileName ?"),
        actions: <Widget>[
          new FlatButton(
            child: const Text("YES"),
            onPressed: () => _deleteFile(this.file),
          ),
          new FlatButton(
            child: const Text("NO"),
            onPressed: () => Navigator.pop(context),
          )
        ]);
  }


  _showSaveDialog() async {
    
      // Note: SaveDialog should return a File or null when calling Navigator.pop()
      // Catch this return value and update the state of the ListTile if the File has been renamed
      // Useful info on making Dialogs that update parents: https://stackoverflow.com/questions/49706046/
        File newFile = await showDialog(
            context: context,
            builder: (context) => SaveDialog(defaultAudioFile: file,
            dialogText: "Rename $fileName",
            doLookupLargestIndex: false)
        );

        // Update the ListTile filename once the dialog is closed
        setState((){
          file=newFile;
          initFileAttributes();
        });

  }


  Row createTrailingButtons() {
    // Note: https://stackoverflow.com/questions/44656013
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        /*
        IconButton(
          icon: new Icon(Icons.delete),
          onPressed: (){
            showDialog(
              context: context,
              builder: (_) =>_openQueryDeleteDialog(),
            );
          }
        ),
        */
        PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                      value: 'Rename',
                      child: ListTile(
                        leading: Icon(Icons.redo),
                        title: Text('Rename'),
                        onTap: _showSaveDialog,
                      )),

                  PopupMenuDivider(), // ignore: list_element_type_not_assignable, https://github.com/flutter/flutter/issues/5771
                  PopupMenuItem<String>(
                      value: 'Delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => _openQueryDeleteDialog(),
                          );
                        },
                      ))
                ])
        /*
        IconButton(
          icon: new Icon(Icons.create),
          onPressed: null, //FIXME
        )
        */
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!file.existsSync()) {
      return Container(width: 0.0, height: 0.0); //Rebuild parent instead?
    }
    return new ListTile(
        title: new Text(fileName),
        dense: false,
        leading: Icon(Icons.play_circle_outline),
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        trailing: createTrailingButtons(),
        onTap: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return AudioPlayBar(file: file);
              });

        });
  }
}
