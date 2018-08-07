import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
//import 'package:glob/glob.dart'; //BROKEN!
import 'package:simple_permissions/simple_permissions.dart';

// Files used by this package
import 'audio_file_list_tile.dart';
import 'save_dialog.dart';
import 'package:path_provider/path_provider.dart';




void main() => runApp(new UmmLikeApp());

//Replace each of these pages with the actual widgets you want.
class _Page {
  const _Page({this.icon, this.text});
  final IconData icon;
  final String text;
}

const List<_Page> _allPages = const <_Page>[
  const _Page(icon: Icons.mic, text: 'RECORD'),
  const _Page(icon: Icons.folder, text: 'FILES'),
];


class UmmLikeApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SimpleFlutterAudioRecorder',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new UmmLikeHomePage(
        title: 'Simple Flutter Audio Recorder',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UmmLikeHomePage extends StatefulWidget {
  //HomePage constructor

  final String title;
  UmmLikeHomePage({Key key, this.title})
      : super(key: key);
  UmmLikeHomePageState createState() => new UmmLikeHomePageState();
}

class UmmLikeHomePageState extends State<UmmLikeHomePage>
    with SingleTickerProviderStateMixin {
  SnackBar errorSnackBar = new SnackBar(content: Text("Tapped button"));
  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    //
    Scaffold scaffold = Scaffold(
        appBar: new AppBar(
            // Set AppBar title
            title: new Text(widget.title),
            bottom: new TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const UnderlineTabIndicator(),
              tabs: _allPages.map((_Page page) {
                return new Tab(text: page.text, icon: new Icon(page.icon));
              }).toList(),
            )),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            new SafeArea(
                top: false,
                bottom: false,
                child: AudioRecorderPage()),
            new SafeArea(
                top: false,
                bottom: false,
                child: FileBrowserPage())
          ],
        ));


        return scaffold;
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _allPages.length);
    _tabController.addListener(_onTabChange);
    requestPermissions();
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange(){
    //FIXME: Rebuild AudioRecorderPage here
  }

  requestPermissions() async {
    bool audioRes =
        await SimplePermissions.requestPermission(Permission.RecordAudio);
    bool readRes = await SimplePermissions
        .requestPermission(Permission.ReadExternalStorage);
    bool writeRes = await SimplePermissions
        .requestPermission(Permission.WriteExternalStorage);
    return (audioRes && readRes && writeRes);
  }
}

class AudioRecorderPage extends StatefulWidget {
  AudioRecorderPage({Key key}) : super(key: key);

  @override
  AudioRecorderPageState createState() {
    return new AudioRecorderPageState();
  }
}

class AudioRecorderPageState extends State<AudioRecorderPage> {
  // The AudioRecorderPageState holds info based on
  // whether the app is currently
  Recording _recording;
  bool _isRecording = false;
  bool _doQuerySave = false; //Activates save or delete buttons

  String tempFilename = "TempRecording"; //Filename without path or extension
  File defaultAudioFile;



  _stopRecording() async {
    // Await return of Recording object
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;

    //final storage = SharedAudioContext.of(context).storage;
    //Directory docDir = await storage.docDir;
    Directory docDir = await getApplicationDocumentsDirectory();



    setState(() {
      //Tells flutter to rerun the build method
      _isRecording = isRecording;
      _doQuerySave = true;
      defaultAudioFile = File(p.join(docDir.path, this.tempFilename+'.m4a'));
    });
  }



  _startRecording() async {
    try {
      //final storage = SharedAudioContext.of(context).storage;
      //Directory docDir = await storage.docDir;
      Directory docDir = await getApplicationDocumentsDirectory();
      String newFilePath = p.join(docDir.path, this.tempFilename);
      File tempAudioFile = File(newFilePath+'.m4a');
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text("Recording."),
                                     duration: Duration(milliseconds: 1400), ));
      if (await tempAudioFile.exists()){
        await tempAudioFile.delete();
      }
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.AAC);
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Error! Audio recorder lacks permissions.")));
      }
      bool isRecording = await AudioRecorder.isRecording;
      setState(() {
        //Tells flutter to rerun the build method
        _recording = new Recording(duration: new Duration(), path: newFilePath);
        _isRecording = isRecording;
        defaultAudioFile = tempAudioFile;
      });
    } catch (e) {
      print(e);
    }
  }

  _deleteCurrentFile() async {
    //Clear the default audio file and reset query save and recording buttons
    if (defaultAudioFile != null){
        setState(() {
        //Tells flutter to rerun the build method
        _isRecording = false;
        _doQuerySave = false;
        defaultAudioFile.delete();
      });
    }else{
      print ("Error! defaultAudioFile is $defaultAudioFile");
    } 
    Navigator.pop(context);
  
  }

  AlertDialog _deleteFileDialogBuilder(){
    return AlertDialog(
      title: Text("Delete current recording?"),
      actions: <Widget>[
          new FlatButton(
            child: const Text("YES"),
            onPressed: () => _deleteCurrentFile(), //
          ),
          new FlatButton(
            child: const Text("NO"),
            onPressed: () => Navigator.pop(context),
          )
        ]
    
    );

  }


  _showSaveDialog() {
      // Note: SaveDialog should return a File or null when calling Navigator.pop()
      // Catch this return value and update the state of the ListTile if the File has been renamed
        showDialog(
            context: context,
            builder: (context) => SaveDialog(defaultAudioFile: defaultAudioFile,)
        );
  }
  @override
  Widget build(BuildContext context) {

    return new Card(
      child: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(height:70.0),
            Container( 
              width: 120.0,
              height: 120.0,
              child:
                 CircularProgressIndicator(
                   strokeWidth: 14.0,
                   value: _isRecording ? null : 0.0,
            )),
            Container(height:100.0),//spacer
            _isRecording
                ? new Text(
                    'Pause',
                    textScaleFactor: 1.5,
                  )
                : new Text('Record', textScaleFactor: 1.5),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                new FloatingActionButton(
                  child: _doQuerySave ? new Icon(Icons.cancel) : null,
                  backgroundColor:
                      _doQuerySave ? Colors.blueAccent : Colors.transparent,
                  onPressed: _doQuerySave ? (() => showDialog(
                    context: context,
                    builder: (context) => _deleteFileDialogBuilder(),
                  )): null,
                  mini: true,
                ),
                new FloatingActionButton(
                  child: _isRecording
                      ? new Icon(Icons.pause, size: 36.0)
                      : new Icon(Icons.mic, size: 36.0),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
                new FloatingActionButton(
                  child: _doQuerySave ? new Icon(Icons.check_circle) : null,
                  backgroundColor:
                      _doQuerySave ? Colors.blueAccent : Colors.transparent,
                  mini: true,
                  onPressed: _doQuerySave ? _showSaveDialog : null, 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FileBrowserPage extends StatefulWidget {
  FileBrowserPage({Key key}) : super(key: key);

  @override
  FileBrowserState createState() {
    return FileBrowserState();
  }
}




class FileBrowserState extends State<FileBrowserPage> {

  FileBrowserState();



  ListView createFileListView(BuildContext context, AsyncSnapshot snapshot) {
    Directory docDir = snapshot.data;

    //Filter out all m4a files
    // create ListTile for each file
    List<FileSystemEntity> dirFiles = docDir.listSync();
  
    // Glob audio files that are not the temp file.
    List<FileSystemEntity> m4aFiles =
        dirFiles.where((file) => (file.path.endsWith('.m4a') && file.path.split('/').last != 'TempRecording.m4a' )).toList();

    //Glob has a bug!!!
    //final audioFilesGlob = new Glob(p.join(docDir,"*"));
    //print (audioFilesGlob.list());
    //var audioFiles = audioFilesGlob.listSync();
    //print("${audioFiles}");

    List<Widget> audioFileTiles = new List();

    for (FileSystemEntity file in m4aFiles) {
   
      //String nameroot = pathStr.split('/').last;
      
      if (file.path.endsWith('.m4a')) {
        audioFileTiles.add(new AudioFileListTile(file: file));
      }
    }
    
    return ListView(children:audioFileTiles);
  }


  @override
  Widget build(BuildContext context) {
    // Retrieve list of files in directory
    var futureBuilder = new FutureBuilder(
      future: getApplicationDocumentsDirectory(),//SharedAudioContext.of(context).storage.docDir,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text('Loading...',textScaleFactor: 2.0);
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createFileListView(context, snapshot);
              //return createFileBrowserColumn(context, snapshot);
        }
      },
    );
    return futureBuilder;
  }
}

