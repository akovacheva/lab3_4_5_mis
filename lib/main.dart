import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Map<String, String>> exams = [
    {'subject': 'Kalkulus', 'date': '2023-08-10', 'time': '10:00 AM'},
    {'subject': 'Diskretni strukturi', 'date': '2023-08-12', 'time': '2:30 PM'},
    {'subject': 'Dizajn na interakcija covek-kompjuter', 'date': '2023-08-12', 'time': '2:30 PM'},
    {'subject': 'Formalni jazici i avtomati', 'date': '2023-08-12', 'time': '2:30 PM'},
    {'subject': 'Linearna algebra', 'date': '2023-08-12', 'time': '2:30 PM'},
  ];

  final List<Map<String, String>> predefinedUsers = [
    {'email': 'ana@kovacheva.com', 'password': 'admin'},
    {'email': 'user2@example.com', 'password': 'password2'},
    // ... more users ...
  ];

  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("User granted permission: ${settings.authorizationStatus}");
  }


  String? _loggedInUser;

  void _loginUser(String email, String password) {
    final user = predefinedUsers.firstWhere(
          (user) => user['email'] == email && user['password'] == password,
      orElse: () => {'email': '', 'password': ''}, // Return default values or an empty user
    );

    if (user['email'] != '') {
      setState(() {
        _loggedInUser = user['email'];
      });
    }
  }


  void _logoutUser() {
    setState(() {
      _loggedInUser = null;
    });
  }


  void _handleSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ExamList(exams: exams)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      home: _loggedInUser != null
          ? Scaffold(
        appBar: AppBar(
          title: const Text('Exam Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logoutUser,
            ),
          ],
        ),
        body: ExamList(exams: exams),
      )
          : Scaffold( // Add a Scaffold here
        body: LoginScreen(
          predefinedUsers: predefinedUsers,
          onLogin: _loginUser,
          onSkip: _handleSkip,
          exams: exams,
        ),
      ),
    );
  }

}


class ExamList extends StatefulWidget {
  final List<Map<String, String>> exams;

  const ExamList({Key? key, required this.exams}) : super(key: key);

  @override
  _ExamListState createState() => _ExamListState();
}

class _ExamListState extends State<ExamList> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Map<String, String>>> _events;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _events = _generateEvents(widget.exams);
  }

  Map<DateTime, List<Map<String, String>>> _generateEvents(List<Map<String, String>> exams) {
    Map<DateTime, List<Map<String, String>>> events = {};

    for (var exam in exams) {
      DateTime examDate = DateTime.parse(exam['date']!);
      if (events.containsKey(examDate)) {
        events[examDate]!.add(exam);
      } else {
        events[examDate] = [exam];
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
        appBar: AppBar(
        title: const Text('Exam List'),
    ),
      body: Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 01, 01),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: (day) => _events[day] ?? [], // Use the null-aware operator
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Update focused day to keep it in sync
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.exams.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(
                    widget.exams[index]['subject']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Date: ${widget.exams[index]['date']}, Time: ${widget.exams[index]['time']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
    ),
    );
  }
}
