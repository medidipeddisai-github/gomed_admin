// import 'package:flutter/material.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomBottomNavigationBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap, // Directly pass the onTap function
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.analytics),
//           label: 'Analysis',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'Profile',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.settings),
//           label: 'Settings',
//         ),
//       ],
//       type: BottomNavigationBarType.fixed,
//       backgroundColor: const Color(0xFF2A9D8F),
//       selectedItemColor: Colors.white,
//     );
//   }
// }





import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final double screenWidth;
  final VoidCallback onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.color,
    required this.screenWidth,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 50,
        width: screenWidth,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
