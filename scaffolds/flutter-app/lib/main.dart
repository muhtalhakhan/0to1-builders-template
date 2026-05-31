import 'package:flutter/material.dart';

void main() {
  runApp(const PeopleApp());
}

class PeopleApp extends StatelessWidget {
  const PeopleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "it's for people, by the people",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0EA5E9)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int featureCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("it's for people, by the people")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'your flutter scaffold is ready with codex instructions.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text('features added: $featureCount'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() => featureCount += 1),
                child: const Text('add a feature'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
