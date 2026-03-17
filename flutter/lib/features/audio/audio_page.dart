import 'package:flutter/material.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Audio Module',
                key: Key('audio-module-page'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
