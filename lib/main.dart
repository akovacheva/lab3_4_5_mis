import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
    localizationsDelegates: [
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      Locale('en', 'US'),
    ],
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

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  void _showAddSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String subject = subjectController.text;
                String date = dateController.text;
                String time = timeController.text;
                if (subject.isNotEmpty && date.isNotEmpty && time.isNotEmpty) {
                  // Add the subject with date and time to the list
                  setState(() {
                    exams.add({'subject': subject, 'date': date, 'time': time});
                  });
                  // Clear the controllers after adding
                  subjectController.clear();
                  dateController.clear();
                  timeController.clear();
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddSubjectDialog(context); // Pass the context to the method
            },
          ),
        ],
      ),
      body: ExamList(exams: exams),
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
    return Column(
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
    );
  }
}
