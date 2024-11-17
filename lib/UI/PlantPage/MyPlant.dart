import 'package:flutter/material.dart';
import 'dart:math';

class MyPlantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title and Icon in the same Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Cây trồng của tôi",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.grid_view, color: Colors.lightBlue.shade300),
          ],
        ),
        SizedBox(height: 10),

        // Full-width Container for the main content
        Container(
          width: double.infinity, // Makes the container span full width
          color: Color(0xFFE6F7FF), // Light blue background color
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              // Plant Carousel Section in a semi-circle layout
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < plantCards.length; i++)
                      Transform.translate(
                        offset: Offset(0, -sin(i * pi / (plantCards.length - 1)) * 10), // Adjust height based on sine wave
                        child: plantCards[i],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Main Plant Display
              Column(
                children: [
                  Image.asset(
                    "assets/senda.jpg",
                    width: 120, // Adjust the size of the image as needed
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sen đá",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Row for "Kỹ thuật canh tác" and "Sâu và bệnh hại" cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TechniqueCard(
                          icon: Icons.agriculture,
                          label: "Kỹ thuật canh tác"
                      ),
                      SizedBox(width: 50),
                      TechniqueCard(
                          icon: Icons.bug_report,
                          label: "Sâu và bệnh hại"
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// List of PlantCards arranged in semi-circle
List<Widget> plantCards = [
  PlantCard("assets/cachua.jpg", "Cà chua"),
  PlantCard("assets/lacai.jpg", "Xà lách"),
  PlantCard("assets/senda.jpg", "Sen đá", isMain: true),
  PlantCard("assets/saurieng.jpg", "Sầu riêng"),
  AddPlantButton(),
];

class PlantCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isMain;

  PlantCard(this.imagePath, this.name, {this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: isMain ? 50 : 40,
          backgroundColor: Color(0xFFD6EFFF),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(fontSize: isMain ? 16 : 14, fontWeight: isMain ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}

class TechniqueCard extends StatelessWidget {
  final IconData icon;
  final String label;

  TechniqueCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Container(
        width: 150, // Keep the width compact

        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // More padding for a larger card
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue, size: 40), // Larger icon size
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Larger font size
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AddPlantButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle new plant addition event
      },
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.lightBlue.shade100.withOpacity(0.5),
        child: Icon(Icons.add, color: Colors.lightBlue.shade400),
      ),
    );
  }
}
