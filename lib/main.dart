
import 'package:flutter/material.dart';
//import 'package:glob/glob.dart'; //BROKEN!
import 'package:simple_permissions/simple_permissions.dart';
import 'file_recorder_page.dart';
import 'audio_recorder_page.dart';
import 'package:flutter/services.dart';



// Run the app
void main() {
  //ref: https://medium.com/@kr1uz/how-to-restrict-device-orientation-in-flutter-65431cd35113
  //runApp(new OminousApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
   .then((_) {
      runApp(new UmmLikeApp());
  });
}

class _Page {
  const _Page({this.icon, this.text});
  final IconData icon;
  final String text;
}

//Set up list of pages for tab navigation
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
    //Stop any ongoing recording

  }

  requestPermissions() async {
    bool audioRes =
        await SimplePermissions.requestPermission(Permission.RecordAudio) == PermissionStatus.authorized;
    bool readRes = await SimplePermissions
        .requestPermission(Permission.ReadExternalStorage) == PermissionStatus.authorized;
    bool writeRes = await SimplePermissions
        .requestPermission(Permission.WriteExternalStorage) == PermissionStatus.authorized;
    return (audioRes && readRes && writeRes);
  }
}












