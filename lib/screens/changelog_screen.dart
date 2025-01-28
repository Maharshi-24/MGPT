import 'package:flutter/material.dart';
import '../utils/changelog_data.dart';

class ChangelogScreen extends StatelessWidget {
  final VoidCallback onDone;

  const ChangelogScreen({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      appBar: AppBar(
        backgroundColor: Colors.black, // Set AppBar background to black
        title: Text("What's New", style: TextStyle(color: Colors.white)), // Set text color to white
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: changelogData.length,
        itemBuilder: (context, index) {
          final changelog = changelogData[index];
          return Card(
            margin: EdgeInsets.all(12),
            elevation: 4,
            color: Colors.black, // Set card background to black
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Version ${changelog.version}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  SizedBox(height: 8),
                  ...changelog.highlights.map((highlight) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green), // Green check icon
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            highlight,
                            style: TextStyle(color: Colors.white), // Set highlight text color to white
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Set button background color
          ),
          child: Text("Continue", style: TextStyle(color: Colors.white)), // Set button text color to white
        ),
      ),
    );
  }
}
