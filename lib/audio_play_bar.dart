import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';

enum PlayerState { stopped, playing, paused }


class AudioPlayBar extends StatefulWidget{
  
  final FileSystemEntity file;
  AudioPlayBar({Key key, this.file}) : super(key: key);

  @override
  AudioPlayBarState createState(){
    return new AudioPlayBarState(file);
  }
}



class AudioPlayBarState extends State<AudioPlayBar>{
  File file;
  AudioPlayer audioPlayer;
  Duration duration; // full duration of file
  Duration position; 

  PlayerState playerState = PlayerState.stopped;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;



  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;



  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  @override 
  AudioPlayBarState(this.file);

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }



  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        print(msg);
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  void onComplete() {
    setState(
      () => playerState = PlayerState.stopped
    );
  }

  Future play() async {
    await audioPlayer.play(file.path);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    print ("Pressed pause");
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future fastForward() async {     
    try{
      int dur = audioPlayer.duration.inSeconds;
      audioPlayer.seek(dur.toDouble()*0.8);
      setState( (){
       playerState = PlayerState.playing;
       duration = Duration(seconds: dur.toInt());  
      });
    } catch(e){
      print( "Error attempting to fast forward");
    }
  }

  Future fastRewind() async {
    
    try{
      int dur = audioPlayer.duration.inSeconds;
      audioPlayer.seek(dur.toDouble()*0.2);
      setState( (){
       playerState = PlayerState.playing;
       duration = Duration(seconds: dur);  
     });
    }catch(e){
      print( "Error attempting to fast rewind");
    }
  }

void movedSlider(double value){
  // Update the slider image
  //value is in milliseconds
  if(value.toInt()%100 == 0){
    setState((){    
      position = new Duration(milliseconds: value.toInt() );
   });
  }
}

void finishedMovedSlider(double value){
  value = max(0, value);
  audioPlayer.pause();
  try{
    audioPlayer.seek( (value/1000.0).roundToDouble() ); 
  }catch(e){
    print("Error attempting to seek to time");
  }
  setState((){
    position = new Duration(milliseconds: value.toInt());
    playerState = PlayerState.paused;
  }); 
}

Widget build(BuildContext context){
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
            child: Column(
              children: [
                Spacer(flex:1),
                // Display the filename
                Text(
                  file.path.split('/').last.split('.').first, 
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.5,
                  ),
                Container(height:12.0),
                // Display the audio position (time)
                position == null ?
                  Container() : Text(positionText,textScaleFactor: 1.2,),
                // Display the slider
                duration == null 
                ?  Container() :
                   Slider(
                  value: position?.inMilliseconds?.toDouble() ?? 0.01 , 
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble()+10.0,
                  divisions: 20,
                  onChanged: movedSlider,
                  onChangeEnd: finishedMovedSlider,   
                ),
                Container(height:20.0),
                // Display the audio control buttons
                ButtonBar(
                    mainAxisSize: MainAxisSize.min,
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //new FloatingActionButton(
                      //  child: new Icon(Icons.fast_rewind),
                      //  onPressed: ()=>fastRewind(),
                      //  mini: true,
                      //),
                      new FloatingActionButton(
                        child: isPlaying
                            ? Icon(Icons.pause)
                            : Icon(Icons.play_arrow),
                        onPressed: isPlaying ? () => pause() : () => play(),
                      ),
                      //new FloatingActionButton(
                      //  child: new Icon(Icons.fast_forward),
                      // mini: true,
                      //  onPressed: () => fastForward(),
                      //),
                    ]),
                    Spacer(),
              ],
            )));
  }

}