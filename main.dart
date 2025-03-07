import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BGNU',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'BGNU'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Adjust padding as needed
          child: Image.asset('assets/logo.jpg'), // Your logo asset
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align content at the top
          children: <Widget>[
            // Image inside the body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/uni.jpg'), // Your image asset
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "About Us: Baba Guru Nanak University BGNU Baba Guru Nanak University BGNU is a Public sector university located in District Nankana Sahib, in the Punjab region of Pakistan. It plans to facilitate between 10,000 to 15,000 students from all over the world at the university. The foundation stone of the university was laid on October 28, 2019 ahead of 550th of Guru Nanak Gurpurab by the Prime Minister of Pakistan. On July, 02, 2020 Government of Punjab has formally passed Baba Guru Nanak University Nankana Sahib Act 2020 X of 2020. The plan behind the establishment of this university to be modeled along the lines of world renowned universities with focus on languages and Punjab Studies offering faculties in Medicine, Pharmacy, Engineering, Computer science, Languages, Music and Social sciences. The initial cost Rupees 6 billion has already been allocated in the budget for this project to be spent in three phases on construction of Baba Guru Nanak University Nankana Sahib. The development work of Phase-I has already been started by Communication and Works Department of Government of Punjab.",
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blue, // Set your desired color
        padding: const EdgeInsets.all(10.0),
        child: const Text(
          'Bgnu.edu.pk',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
