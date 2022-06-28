
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:airasc/widgets/NavBar.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
class TrainStatusScreen extends StatefulWidget {
  State<TrainStatusScreen> createState() => TrainStatusState();
}
class TrainStatusState extends State<TrainStatusScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    getTemperatue();
    getStatus();
    inputData();
  }
  User? user;
  bool isSwitched = false;
  String Switchstr = "";
  String Temp = "";
  String humidity = "";
  inputData(){
    user = auth.currentUser;
  }
   getTemperatue ()async{
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = FirebaseDatabase.instance.ref("Train_1");
    DatabaseReference Tempref= ref.child("Temperature");
    DatabaseReference Humref = ref.child("Humidity");
    DatabaseEvent event = await ref.once();
    var snapshot = await Tempref.get().whenComplete(() => setState(() {

    }));
    var snapshothum = await Humref.get().whenComplete(() => setState(() {

    }));
    Temp = snapshot.value.toString();
    humidity = snapshothum.value.toString();
  }
 getStatus()async{
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref("h").child("h");
  var snapshot = await ref.get().whenComplete(() => setState(() {

  }));
  var v = snapshot.value;
  if(v == 0){
    isSwitched = false;
    Switchstr = "closed";
  }
  else{
    isSwitched = true;
    Switchstr = "open";
  }
}
  @override
  Widget build(BuildContext context) {
    getTemperatue();
    getStatus();
    return Container(
    constraints: const BoxConstraints.expand(),
    decoration: const BoxDecoration(
    image: DecorationImage(
    image: AssetImage("images/railway-indian-india-sunset.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: Text("Train Status"),
    centerTitle: true,
    backgroundColor: Colors.deepPurple,
    ),
    drawer: NavBar(),
    body: Center(child: Column(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 200,left: 110),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 40,right: 120,left: 20),
              child: Switch(value: isSwitched,onChanged: null,  inactiveThumbColor: Colors.tealAccent,
                inactiveTrackColor: Colors.tealAccent.withOpacity(0.5),),

              //   child: RoundedBackgroundText(
              //     '   Train Speed',
              //     style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.deepPurple),
              //     backgroundColor: Colors.white60,
              //     innerRadius: 5.0,
              //     outerRadius: 20.0,
              //   ),

            ),
            Container(
              margin:EdgeInsets.only(top: 40,right: 30),
              child: Text(
                "Gate is ${Switchstr}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 150,left: 90),
        child: Stack(
          children: [
        Container(
          margin: EdgeInsets.only(top: 10,left: 50),
          child: RoundedBackgroundText(
            '   Temperature',
            style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.deepPurple),
            backgroundColor: Colors.white70,
            innerRadius: 5.0,
            outerRadius: 20.0,
          ),
        ), Container(
        margin:EdgeInsets.only(right: 220),
          child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 30,
                child:  Text("${Temp}°C",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),) ,

              ),
        ),
            Container(
              margin: EdgeInsets.only(top: 100,left: 50),
              child: RoundedBackgroundText(
                '   Humidity',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.deepPurple),
                backgroundColor: Colors.white70,
                innerRadius: 5.0,
                outerRadius: 20.0,
              ),
            ), Container(
              margin:EdgeInsets.only(right: 220,top: 90),
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 30,
                child: Text("${humidity}%",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),) ,
              ),
            ),
          ],
        ),
      ),
    ]
    ),
    ),
        )
    );
  }
}
