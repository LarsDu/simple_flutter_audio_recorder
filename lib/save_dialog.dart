import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class SaveDialog extends StatefulWidget {
  final File defaultAudioFile;
  final String dialogText;
  final bool doLookupLargestIndex;


  SaveDialog({Key key,
             this.defaultAudioFile, 
              this.dialogText="Save file?",
              this.doLookupLargestIndex=true,
              }) : super(key: key);

  @override
  SaveDialogState createState() {   
    return SaveDialogState(defaultAudioFile,dialogText,doLookupLargestIndex);
  }
}

class SaveDialogState extends State<SaveDialog> {
  
  File defaultAudioFile;
  String dialogText;
  String newFilePath;
  TextEditingController _textController;
  bool doLookupLargestIndex;


  SaveDialogState(this.defaultAudioFile,this.dialogText,this.doLookupLargestIndex);

  @override
  initState(){
    super.initState();
    initTextController(true);
  }

  @override 
  dispose(){
    super.dispose();
    this._textController.dispose();
  }

  initTextController(bool doRebuildTextController){
    if (doLookupLargestIndex){
      initTextControllerWithLargestFileName(doRebuildTextController:doRebuildTextController);
    }else{
      initTextControllerWithCurrentFileName(doRebuildTextController:doRebuildTextController );
    }
  }

  Future<Null> initTextControllerWithCurrentFileName({bool doRebuildTextController=true}) async {
      setState( (){
        this.newFilePath = defaultAudioFile.path;
        String defaultFileName  = defaultAudioFile.path.split('/').last.split('.').first;
        if (doRebuildTextController){
          this._textController = TextEditingController(text: defaultFileName);
        }
      }
    );
  }

  Future<Null> initTextControllerWithLargestFileName({bool doRebuildTextController=true}) async {
    Directory directory = await getApplicationDocumentsDirectory();

    String fname = await _largestNumberedFilename();
    print ("new $fname");
    String fpath = p.join(directory.path,fname+'.m4a');
    setState( (){
        this.newFilePath = fpath;
        if (doRebuildTextController){
          this._textController = TextEditingController(text: fname);
        }
      }
    );
  }

  void _renameAudioFile() async {
    Navigator.pop(context);
    newFilePath  = p.join( p.dirname(defaultAudioFile.path), _textController.text + '.m4a');
    if (defaultAudioFile != null && newFilePath != null){
      try{
        print ("New file path $newFilePath");
        defaultAudioFile.rename(newFilePath); //FIXME!!!!
        //Reset the textController state
        initTextController(false);
       
      }catch(e){
        if (await defaultAudioFile.exists()){
          //FIXME: add file already exists warning
          print("File $defaultAudioFile already exists");
        }else{
          print ('Error renaming file');
        }
      }

    }else{
      print( "File $defaultAudioFile is null!");
    }
  }


  Future<String> _largestNumberedFilename(
    {String filenamePrefix:"Recording-", String delimiter: "-"}) async {

    // Get the largest numbered filename with a given [filenamePrefix] and [delimiter]
    // from the ApplicationDocumentsDirectory
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      int largestInt = 0;
    
      List<FileSystemEntity> entities = directory.listSync();
      for (FileSystemEntity entity in entities){
        String filePath = entity.path;
        if (filePath.endsWith('.m4a') && !(filePath.startsWith('Temp'))){
          String bname = p.basename(filePath);
              if (bname.startsWith(filenamePrefix)) {
                final String noExt = bname.split('.')[0];
                int curInt = int.parse(noExt.split(delimiter).last);
                largestInt = max(largestInt, curInt);
             }
        }
      }
      
  
      largestInt += 1;
      print ("Found largest index $largestInt");
      return filenamePrefix+largestInt.toString();

    } catch (e) {
      print("Error, failed to get documents directory and calculate largest numbered filename");
      return "1234";
    }
  }

  @override
  Widget build(BuildContext context) {
    //FIXME: This should be done with a SharedAudioFile context


    print ("Building");
    return AlertDialog(
        title: Text(dialogText),
        content: TextFormField(
         controller: _textController,
         decoration: InputDecoration(
          labelText: "Filename:",
          hintText: "Enter a filename with no extension.",
          ),
         validator: (value) {
          if (value.isEmpty) {
            return "Please enter a filename";
          }
      },),
      actions: <Widget>[
          new FlatButton(
            child: const Text("SAVE"),
            onPressed: () => _renameAudioFile(), //FIXME (change default audio file name to specified name)
          ),
          new FlatButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          )
        ]);
  }
}