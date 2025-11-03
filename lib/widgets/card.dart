import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MyCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black26,
        color: const Color.fromARGB(255, 130, 89, 200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 300,
          height: 200,
          child: Stack(
            children: [
              // Main column (image + title)
              Column(
                children: [
                  // Image section
                  Flexible(
                    flex: 7,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
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

                  // Title section
                  Flexible(
                    flex: 3,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 🔹 Trailing widget (top-right overlay)
              if (trailing != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: trailing,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
