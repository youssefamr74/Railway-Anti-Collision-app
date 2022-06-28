import 'package:flutter/material.dart';
import 'package:airasc/widgets/NavBar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:airasc/lochelper.dart';
import 'package:geolocator/geolocator.dart';
class MissionPlanScreen extends StatefulWidget {
  State<MissionPlanScreen> createState() => MissionPlanState();
}
class MissionPlanState extends State<MissionPlanScreen> {

  @override
  initState() {
    super.initState();
    getData();
    inputData();
    getMycurrentlocation();

  }
  List<dynamic> z = [] ;
  String? email;
  Position? position;
  static int? mapMissionnum;
  bool isSelected = false;
  static int missionNum = 0;
  List<dynamic> d = [] ;
  Map <dynamic,dynamic> c = new Map<dynamic,dynamic>();
  late final databaseRef = FirebaseDatabase.instance.ref("missionplan");
  late DatabaseReference databaseReference;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String alert = "";
   inputData(){
     user = auth.currentUser;
     email = user!.email;
  }
  Future<void> getMycurrentlocation()async{
    position = await LocationHelper.getCurrentLocation().whenComplete(() => setState(() {

    }));
  }
  updateDriverName(int i)async{
     print(d);
    List <dynamic> v = [];
    for(int j =0; j < d.length;j++){
      print(d[j]["missionnumber"]);
      if(d[j]["missionnumber"]!= null){
        if(int.parse(d[j]["missionnumber"])==i){

          v.add(d[j]);
          MissionPlanState.missionNum = j;
        }
      }

    }
    MissionPlanState.mapMissionnum = int.parse(v[0]["missionnumber"]);
      if(v[0]["drivername"] == user!.email){
       alert = "[ERROR] You are already assigned to this mission";
     }
    else if(v[0]["drivername"] != "Not selected"){
    alert = "[ERROR] This mission is already assigned to another driver";
    }
     else if (v[0]["drivername"] == "Not selected"){
       print("aywa");
       bool result = d.every((element) {
         return element["drivername"] != user!.email;
       });
       print(result);
       if(result) {
         alert = "You are assigned to this mission successfully";
         await databaseRef.update({
           "${(i).toString()}/drivername": user!.email,
         });
       }
       else{
         alert = "[ERROR] You are already assigned to another mission.";
       }
     }
     showPopUp(context);
     print(alert);
  }
  Future<void> getmyzones()async{
    if(MissionPlanState.mapMissionnum != null){
      var value =  FirebaseDatabase.instance.ref("missionplan").child("${MissionPlanState.mapMissionnum}").child("zone");
      var getValue = await value.get().whenComplete(() => setState(() {  }));
      var a = jsonEncode(getValue.value);
      z = await json.decode(a.trim());
    }

  }
  updatetrains()async{
     await getmyzones();
    late final dbRef = FirebaseDatabase.instance.ref("trains");
    await dbRef.child("${user!.uid}").set({
        "driveremail" : this.email,
        "lastzone" : d[MissionPlanState.missionNum]["endzone"],
        "lat" : position!.latitude,
        "lng" : position!.longitude,
        "lastzone" : z[0]["name"],
        "nextzone" : z[1]["name"],
        "line" : z[0]["line"],
        "trainnumber" : d[MissionPlanState.missionNum]["trainnumber"],

    });
  }
  Future<void> getData()async{
    var value = FirebaseDatabase.instance.ref("missionplan");
    var getValue = await value.get().whenComplete(() => setState(() {  }));
    var a = await jsonEncode(getValue.value);

    c  = await json.decode(a.trim());
  //  print(c);
    d.clear();
    d.addAll(c.values);
        d.removeWhere((element) => element == null,);

  }
  showPopUp(context){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Hi! ${user!.email}"),
        content:  Text(alert),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
 Widget buildDataTable() {
    int selectedIndex = -1;
    getData();
    final columns = ['Mission Name','Mission Number','Driver Name'
     , 'Duration', 'line','Train Number','Start Time','End Time','Start Zone','End Zone'];
    return  InteractiveViewer (
      constrained: false,
      child: DataTable(
          showCheckboxColumn: false,
          headingRowColor:
          MaterialStateColor.resolveWith((states) => Colors.deepPurple.withOpacity(0.7)),
          dataRowColor:MaterialStateColor.resolveWith((states) => Colors.black.withOpacity(0.3)) ,
          columnSpacing: 30,
          dataTextStyle: TextStyle(fontSize: 17,color: Colors.white,fontWeight: FontWeight.bold),
          showBottomBorder: true ,
          columns: getColumns(columns),
          rows: List<DataRow>.generate(
          d.indexOf(d.last)+1,
          (index) => DataRow(selected:false,onSelectChanged: (selected) {updateDriverName(int.parse(d[index]["missionnumber"]));updatetrains();},
              cells: [
            DataCell(Text(d[index]!=null?  d[index]["missionname"]!=null?d[index]["missionname"]:" ":" ",)
            ),
            DataCell(Text(d[index]!=null? d[index]["missionnumber"]!=null?d[index]["missionnumber"]:" ":" ",)),
            DataCell(Text(d[index]!=null ?d[index]["drivername"]!=null?d[index]["drivername"]:" ":" ")),
            DataCell(Text(d[index]!=null ?d[index]["duration"]!=null?d[index]["duration"]:" ":" ")),
            DataCell(Text(d[index]!=null ?d[index]["line"]!=null?d[index]["line"]:" ":" ")),
            DataCell(Text(d[index] !=null?d[index]["trainnumber"]!=null?d[index]["trainnumber"]:" ":" ")),
            DataCell(Text(d[index] !=null?d[index]["starttime"]!=null?d[index]["starttime"]:" ":" ")),
            DataCell(Text(d[index] !=null?d[index]["endtime"]!=null?d[index]["endtime"]:" ":" ")),
            DataCell(Text(d[index] !=null?d[index]["startzone"]!=null?d[index]["startzone"]:" ":" ")),
            DataCell(Text(d[index] !=null?d[index]["endzone"]!=null?d[index]["endzone"]:" ":" ")),
          ])
      )
      ),
    );

  }
  List<DataColumn> getColumns(List<String> columns) =>
      columns.map((String column) => DataColumn2(label: Text(column,style: TextStyle(color: Colors.white),),size: ColumnSize.S,)
      ).toList();
  @override
  Widget build(BuildContext context) {
getData();
    return Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/railway-indian-india-sunset.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Mission Plan"),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
          ),
          drawer: NavBar(),
          body: d.isEmpty? Center(child: Container(
            child: CircularProgressIndicator(color: Colors.deepPurple,),
          ),):buildDataTable(),
        ),
    );
  }
}
