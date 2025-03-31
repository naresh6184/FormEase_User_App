import 'package:flutter/material.dart';
import 'themed_scaffold.dart';
import 'leave_form_PG.dart';
import 'leave_form_UG.dart';
import 'animated_button.dart'; // Import the AnimatedButton file

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("FormEase",style: TextStyle(fontSize: 40 , fontWeight: FontWeight.w800 , color: Colors.white54.withOpacity(0.7) ,),),),
            const SizedBox(height: 150,),
            AnimatedButton(
              text: "Leave Application Form For UG Students",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveApplicationFormUG()));
              },
            ),
            const SizedBox(height: 50),
            AnimatedButton(
              text: "Leave Application Form For PG Students",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveApplicationFormPG()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
