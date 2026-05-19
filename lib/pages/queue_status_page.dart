import 'package:flutter/material.dart';

class QueueStatusPage extends StatelessWidget {
  const QueueStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Queue Status'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Position in Line',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              // Big bold number for the user's ticket
              const Text(
                '#108',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),
              const Text(
                'Now Serving:',
                style: TextStyle(fontSize: 18),
              ),
              const Text(
                '#105',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                'Estimated wait: 2 groups ahead of you',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}