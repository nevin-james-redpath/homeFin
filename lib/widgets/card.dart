import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String imagePath;
  final String title;

  const MyCard({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 20,
        shadowColor: Colors.black,
        color: const Color.fromARGB(255, 130, 89, 200),
        child: SizedBox(
          width: 300,
          height: 200,
          child: Column(
            children: [
              // Image section (20%)
              Flexible(
                flex: 7,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                    bottom: Radius.circular(4),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.fill,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),

              // Text section (80%)
              Flexible(
                flex: 3,
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
