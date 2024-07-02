import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'LocationScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MyApp());
    hideStatusBar();
  });
}

void hideStatusBar() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Control Car',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  int speed = 0;
  int turnDirection = 0;
  int dumpState = 0;
  int hornState = 0;
  String currentImageData = '';
  Image? backgroundImage;
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    databaseReference.child('kamera').child('mobil').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        updateImageFrames(snapshot.value.toString());
      }
    });
  }

  void sendCommandToFirebase() {
    if (speed == 0 && turnDirection == 0) {
      databaseReference.child("car").set({
        "speed": 0,
        "turnDirection": 0,
        "Dump": dumpState,
        "horn": hornState,
      });
    } else {
      databaseReference.child("car").set({
        "speed": speed,
        "turnDirection": turnDirection,
        "Dump": dumpState,
        "horn": hornState,
      });
    }
  }

  void updateImageFrames(String base64String) {
    if (base64String != currentImageData) {
      currentImageData = base64String;
      Uint8List bytes = base64Decode(base64String);
      setState(() {
        backgroundImage = Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      });
    }
  }

  void setSpeed(int newSpeed) {
    setState(() {
      speed = newSpeed;
    });
    sendCommandToFirebase();
  }

  void setTurnDirection(int newTurnDirection) {
    setState(() {
      turnDirection = newTurnDirection;
    });
    sendCommandToFirebase();
  }

  void setDumpState(int newDumpState) {
    setState(() {
      dumpState = newDumpState;
    });
    sendCommandToFirebase();
  }

  void setDumpDownState(int newDumpState) {
    setState(() {
      dumpState = newDumpState;
    });
    sendCommandToFirebase();
  }

  void setHornState(int newHornState) {
    setState(() {
      hornState = newHornState;
    });
    sendCommandToFirebase();
  }

  void navigateToLocationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Remote Control Car',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _backgroundKey,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: backgroundImage ?? Container(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTapDown: (_) {
                            setTurnDirection(-1);
                          },
                          onTapUp: (_) {
                            setTurnDirection(0);
                          },
                          child: CircleAvatar(
                            backgroundColor: turnDirection == -1
                                ? Colors.lightBlue[100]
                                : Colors.blue,
                            radius: 40,
                            child: Icon(Icons.arrow_back, size: 40, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTapDown: (_) {
                            setTurnDirection(1);
                          },
                          onTapUp: (_) {
                            setTurnDirection(0);
                          },
                          child: CircleAvatar(
                            backgroundColor: turnDirection == 1
                                ? Colors.lightBlue[100]
                                : Colors.blue,
                            radius: 40,
                            child: Icon(Icons.arrow_forward, size: 40, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTapDown: (_) {
                            setSpeed(1);
                          },
                          onTapUp: (_) {
                            setSpeed(0);
                          },
                          child: CircleAvatar(
                            backgroundColor: speed == 1 ? Colors.lightBlue[100] : Colors.blue,
                            radius: 40,
                            child: Icon(Icons.arrow_upward, size: 40, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTapDown: (_) {
                            setSpeed(-1);
                          },
                          onTapUp: (_) {
                            setSpeed(0);
                          },
                          child: CircleAvatar(
                            backgroundColor: speed == -1 ? Colors.lightBlue[100] : Colors.blue,
                            radius: 40,
                            child: Icon(Icons.arrow_downward, size: 40, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTapDown: (_) {
                        setHornState(1);
                      },
                      onTapUp: (_) {
                        setHornState(0);
                      },
                      onTapCancel: () {
                        setHornState(0);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 40,
                        child: Icon(Icons.volume_up, size: 40, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setDumpState(dumpState == 0 ? 1 : 0);
                      },
                      child: Text('Dump Up'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setDumpDownState(dumpState == 0 ? -1 : 0);
                      },
                      child: Text('Dump Down'),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        navigateToLocationScreen(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 40,
                        child: Text(
                          '📍',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
