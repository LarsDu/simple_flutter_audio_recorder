

import 'dart:io';
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
    int dur = audioPlayer.duration.inSeconds.toInt();
    print (dur);
    audioPlayer.seek(dur.toDouble()*0.8);
    setState( (){
      playerState = PlayerState.playing;
      duration = Duration(seconds: dur);
  
    });

  }

  Future fastRewind() async {
    int dur = audioPlayer.duration.inSeconds.toInt();
    audioPlayer.seek(dur.toDouble()*0.2);
    setState( (){
      playerState = PlayerState.playing;
      duration = Duration(seconds: dur);
  
    });

  }

movedSlider(double value){
  audioPlayer.seek((value/1000.0).roundToDouble()); 
  //int dur = audioPlayer.duration.inSeconds.toInt();
  //setState((){ 
  //    duration = Duration(seconds: dur);
  //  }
  //);
}

Widget build(BuildContext context){
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
            child: Column(
              children: [
                Container(height:70.0), //FIXME! Center these properly!
                Text(file.path.split('/').last.split('.').first),
                Container(height: 30.0,), // spacer
                position == null ?
                  Container() : Text(positionText)
                ,
                duration == null 
                ?  Container() :
                   Slider(
                  value: position?.inMilliseconds?.toDouble() ?? 0.0 , 
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: movedSlider,   
                ),
                ButtonBar(
                    mainAxisSize: MainAxisSize.min,
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new FloatingActionButton(
                        child: new Icon(Icons.fast_rewind),
                        onPressed: ()=>fastRewind(),
                        mini: true,
                      ),
                      new FloatingActionButton(
                        child: isPlaying
                            ? Icon(Icons.pause)
                            : Icon(Icons.play_arrow),
                        onPressed: isPlaying ? () => pause() : () => play(),
                      ),
                      new FloatingActionButton(
                        child: new Icon(Icons.fast_forward),
                        mini: true,
                        onPressed: () => fastForward(),
                      ),
                    ])
              ],
            )));
  }

}