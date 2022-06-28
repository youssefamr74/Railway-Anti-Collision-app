import 'package:flutter/material.dart';
import 'package:airasc/screens/login.dart';
import 'package:airasc/theme.dart';
import 'package:airasc/widgets/primary_button.dart';
import 'package:airasc/widgets/reset_form.dart';
import 'package:airasc/widgets/NavBar.dart';
import 'package:airasc/screens/TrainStatus.dart';
import 'package:airasc/screens/Map.dart';
import 'package:airasc/screens/MissionPlan.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage("images/railway-indian-india-sunset.jpg"), fit: BoxFit.cover)),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("A  I  R  A  C  S"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: NavBar(),
      body: Center(child: Column(children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 250),
          child: ElevatedButton(
            child: Text("Mission Plan",style: TextStyle(fontSize: 20)),
            onPressed: () => {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MissionPlanScreen()),
            )},
            style: ElevatedButton.styleFrom( // returns ButtonStyle
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20),
          child: ElevatedButton(
            child: Text("Train Status",style: TextStyle(fontSize: 20)),
            onPressed: () => { Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TrainStatusScreen()),
            )},
            style: ElevatedButton.styleFrom( // returns ButtonStyle
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
          )
        ),
        Container(
          margin: EdgeInsets.only(top: 20),
          child: ElevatedButton(
            child: Text("Location",style: TextStyle(fontSize: 20)),
            onPressed: () => {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            )},
            style: ElevatedButton.styleFrom(// returns ButtonStyle
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
          ),
        ),
      ],),),
    )
    );
  }
}
