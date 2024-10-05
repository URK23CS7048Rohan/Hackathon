import 'dart:async';
import 'dart:convert'; // Required for base64 encoding
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For location fetching
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MyHomePage(title: 'SafeSense'),
    );
  }
}

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void setupNotification() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received notification: ${message.notification!.title}');
      });
    }
  }
  class ReminderService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleReminder(String title, String body, DateTime time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      time,
      const NotificationDetails(
        android: AndroidNotificationDetails('channel_id', 'channel_name'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
ReminderService _reminderService = ReminderService();
_reminderService.initialize();
_reminderService.scheduleReminder("Medication Reminder", "It's time to take your medication", DateTime.now().add(Duration(minutes: 5)));
FallDetectionService _fallDetectionService = FallDetectionService();
_fallDetectionService.startMonitoring();
LocationService _locationService = LocationService();
_locationService.monitorSafeZone(Position(latitude: 12.9716, longitude: 77.5946), 1000); // Radius 1000 meters



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const countdownDuration = Duration(seconds: 30);
  var seconds = 30;
  Duration duration = const Duration(seconds: 30);
  Timer? timer;
  bool hasFallen = false;
  bool isCountDown = true;
  bool contactAuthorities = false;
  late final AudioCache _audioCache;

  @override
  void initState() {
    super.initState();
    _audioCache = AudioCache(
      prefix: 'assets/audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }

  // Function to fetch the user's location coordinates
  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  // Function to send SMS using Twilio, including the location coordinates
  Future<void> sendSMS() async {
    const String accountSid = 'AC64bbe98186c2d4c58e4431b443feb923';
    const String authToken = 'e97e86be0df5a86716f9f878a521baf0';
    const String twilioNumber = '+1 707 414 3139';
    const String recipientNumber = '+917484907592'; // Indian number

    // Get the user's location
    Position position;
    try {
      position = await _getUserLocation();
    } catch (e) {
      print('Error fetching location: $e');
      return;
    }

    // Format the message with the user's location
    String locationMessage =
        'A fall has been detected. Help is on the way! Coordinates: Latitude ${position.latitude}, Longitude ${position.longitude}';

    final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': twilioNumber,
        'To': recipientNumber,
        'Body': locationMessage,
      },
    );

    if (response.statusCode == 201) {
      print('Message sent successfully.');
    } else {
      print('Failed to send message: ${response.body}');
    }
  }

  void startTimer() {
    setState(() {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => decrement());
    });
  }

  void decrement() {
    setState(() {
      if (isCountDown) {
        seconds = duration.inSeconds - 1;
        print('Duration: $seconds');
        if (seconds < 0) {
          confirmedFall();
        } else {
          duration = Duration(seconds: seconds);
        }
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    duration = countdownDuration;
  }

  void resetApp() {
    setState(() {
      hasFallen = false;
      isCountDown = true;
      contactAuthorities = false;
      resetTimer();
      _audioCache.play("alarm.mp3", volume: 0);
    });
  }

  void fallTrigger() {
    setState(() {
      hasFallen = true;
      startTimer();
    });
  }

  void confirmedFall() {
    setState(() {
      contactAuthorities = true;
      isCountDown = false;
      hasFallen = true;
      resetTimer();
    });
    sendSMS(); // Call sendSMS function when fall is confirmed
  }

  void makeNoise() {
    _audioCache.play('alarm.mp3', volume: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                  child: const Text("No fall detected \n Enjoy yourself!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                  visible: !hasFallen),
              Visibility(
                child: const Text('Fall detected \n Are you OK?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                visible: (hasFallen & !contactAuthorities),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      child: ElevatedButton(
                          child: const Text("Yes",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50)),
                          onPressed: resetApp,
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.green),
                              shadowColor: WidgetStateProperty.all<Color>(
                                Colors.green.withOpacity(0.5),
                              ),
                              fixedSize: WidgetStateProperty.all<Size>(
                                  const Size(180, 400)))),
                      visible: (hasFallen & !contactAuthorities)),
                  const SizedBox(
                    width: 9,
                  ),
                  Visibility(
                    child: ElevatedButton(
                        child: const Text("No",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 50)),
                        onPressed: confirmedFall,
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.red),
                            shadowColor: WidgetStateProperty.all<Color>(
                                Colors.red.withOpacity(0.5)),
                            fixedSize: WidgetStateProperty.all<Size>(
                                const Size(180, 400)))),
                    visible: (hasFallen & !contactAuthorities),
                  )
                ],
              ),
              Visibility(
                  child: const Text(
                    'Contacting help in...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  visible: (hasFallen & !contactAuthorities)),
              Visibility(
                  child: buildTime(),
                  visible: (hasFallen & !contactAuthorities)),
              Visibility(
                  child: const Text('Help is on the way',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  visible: contactAuthorities),
              Visibility(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      child: ElevatedButton(
                          child: const Text("Noise",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50)),
                          onPressed: makeNoise,
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.blue),
                              shadowColor: WidgetStateProperty.all<Color>(
                                Colors.green.withOpacity(0.5),
                              ),
                              fixedSize: WidgetStateProperty.all<Size>(
                                  const Size(180, 400)))),
                      visible: (contactAuthorities)),
                  const SizedBox(
                    width: 9,
                  ),
                  Visibility(
                    child: ElevatedButton(
                        child: const Text("Reset",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                            )),
                        onPressed: resetApp,
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.red),
                            shadowColor: WidgetStateProperty.all<Color>(
                                Colors.red.withOpacity(0.5)),
                            fixedSize: WidgetStateProperty.all<Size>(
                                const Size(180, 400)))),
                    visible: (contactAuthorities),
                  )
                ],
              )),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (!contactAuthorities & !hasFallen) {
                  fallTrigger();
                } else {
                  print("RESET APP REQUIRED");
                }
              },
              tooltip: 'Trigger Fall',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: resetApp,
              tooltip: 'Reset',
              child: const Icon(Icons.loop),
            )
          ],
        ));
  }

  Widget buildTime() {
    return Text('${duration.inSeconds}', style: const TextStyle(fontSize: 40));
  }
}
