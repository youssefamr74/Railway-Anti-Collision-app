import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:airasc/widgets/NavBar.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:airasc/lochelper.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:math';
import 'package:airasc/screens/MissionPlan.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:airasc/Location.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends StatefulWidget {
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  Timer? collisiontimer;
  Timer? timer;
  User? user;
  String? id;
  @override
  initState() {
    super.initState();
    inputData();
     getMycurrentlocation();
     getZones();
    collisiontimer = Timer.periodic(Duration(seconds: 10), (Timer t) => (
      collision()));
    collisiontimer = Timer.periodic(Duration(seconds: 3), (Timer t) => (
        geofence()));
  }
   static Position? position;
   Completer<GoogleMapController> _controller = Completer();
  Completer<GoogleMapController> _mapController = Completer();
  FloatingSearchBarController controller = FloatingSearchBarController();
  late final databaseRef = FirebaseDatabase.instance.ref();
  late DatabaseReference databaseReference;
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map <dynamic,dynamic> c = new Map<dynamic,dynamic>();
  List<dynamic> j = [] ;
  List<dynamic> z = [] ;
  List<dynamic> l = [] ;
  LinkedHashMap<String,dynamic> trainsList = new LinkedHashMap();
  int myzoneline = 0;
  String myzonename = "";
  Circle? myzone;
  Circle? nextzone;
  String collisionMessage = "";
  @override

  static final CameraPosition _mycurrenttlocationCameraPosition = CameraPosition(
  bearing: 0.0,
    target: LatLng(position!.latitude,position!.longitude),
    tilt: 0.0,
    zoom: 15
  );
  inputData(){
    user = auth.currentUser;
    id = user!.uid;
  }
  getDistance(Location location){
    getMycurrentlocation();
   double myLat = position!.latitude;
   double myLng = position!.longitude;
    var R = 6378137;
    double dLat = math.radians(location.lat! - myLat);
    double dLong = math.radians(location.lng! - myLng);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(math.radians(myLat)) *
                cos(math.radians(location.lat!)) *
                sin(dLong / 2) *
                sin(dLong / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    var d = R * c;
    return d; // returns the distance in meter
  }
  geofence()async{
    getmyzones();
    await inputData();
    var value =   FirebaseDatabase.instance.ref("trains").child("${id}");
    var valueline =  FirebaseDatabase.instance.ref("lines").child("lines");
    var valueh =  FirebaseDatabase.instance.ref("h");
    int lastline = 0;
    var snapshot = await FirebaseDatabase.instance.ref("trains").child("${id}").once();
    if (snapshot.snapshot.value != null) {
      await value.update({
        "lat": position!.latitude,
        "lng": position!.longitude,
      });
    }
    for(int i =0; i < z.length ; i++){
      double x = z[i]["lat"];
      double y = z[i]["lng"];
      Location loc = new Location(x, y);
      double d = getDistance(loc);
      if(d < z[i]["radius"]){
        print("train inside zone " + z[i]["name"]);
        myzone = new Circle(circleId: CircleId(z[i]["name"]),
            center: LatLng(z[i]["lat"],z[i]["lng"]));
        nextzone = new Circle(circleId: CircleId(j[i+1]["name"]),
            center: LatLng(z[i+1]["lat"],z[i+1]["lng"]));
        print("myzone" + myzone.toString());
        await value.update({
          "lat" : position!.latitude,
          "lng" : position!.longitude,
          "lastzone" : z[i]["name"],
          "nextzone" : z[i+1]["name"],
          "line" : z[i]["line"],
        });
        if(z[i]["type"] == "before"){
            await valueh.update({
              "h" : 1,
            });
        }
        else if (z[i]["type"] == "after"){
          await valueh.update({
            "h" : 0,
          });
        }
        myzoneline = z[i]["line"];
        myzonename = z[i]["name"];
        int cline = z[i]["line"];
        var getValue = await valueline.get().whenComplete(() => setState(() {  }));
        var a = jsonEncode(getValue.value);
        l = await json.decode(a.trim());
        print(l[cline]);
        if(cline != lastline){
          await valueline.update({
            (cline-1).toString() : l[cline] +1,
          });
        }
        if(lastline != 0 ){
          await valueline.update({
            (lastline - 1).toString() : l[lastline -1] -1,
          });
        }
        lastline = cline;
        print("lastline" + lastline.toString());
      };
      if (d > z[i]["radius"]) {
        print("train outside "+ z[i]["name"]);
      }

    }
  }
  collision()async{
    var collision = FirebaseDatabase.instance.ref("collision");
    var trains =  FirebaseDatabase.instance.ref("trains");
    Location location = new Location(0, 0);
    var getValue = await trains.get();
    var a = jsonEncode(getValue.value);
    bool yellow = false;
    bool red = false;
    trainsList = await json.decode(a.trim());
    var mytrain = trainsList[user!.uid];
    String othertrainName = "";
    trainsList.forEach((key, value) {
      if(key != user!.uid){
        print(value["nextzone"]);
        if(value["line"] == mytrain["line"]){
          yellow = true;
          location.lat = value["lat"];
          location.lng = value["lng"];
          othertrainName = value["trainnumber"];
          print("line conf");
          if(value["nextzone"] == mytrain["nextzone"]){
            collisionMessage = "Collision is expected between you and (${value["trainnumber"]}) at zone ${mytrain["nextzone"]}";
            collisionPopUp(context);
            location.lat = value["lat"];
            location.lng = value["lng"];
            othertrainName = value["trainnumber"];
            red = true;
          }
          if(value["nextzone"] == myzonename){
            collisionMessage = "Collision is expected between you and train (${value["trainnumber"]}) at zone ${myzonename}";
            collisionPopUp(context);
            location.lat = value["lat"];
            location.lng = value["lng"];
            othertrainName = value["trainnumber"];
            red = true;
          }
          else if(value["lastzone"] == mytrain["nextzone"]){
            collisionMessage = "Collision is expected between you and (${value["trainnumber"]}) at zone ${mytrain["nextzone"]}";
            collisionPopUp(context);
            location.lat = value["lat"];
            location.lng = value["lng"];
            othertrainName = value["trainnumber"];
            red = true;
          }
        }
      }
    });
    double distance = 0.0;
    if(yellow){
      distance =  getDistance(location);
      if(red){
      await collision.child(mytrain["trainnumber"]).update({
        "train1" : mytrain["trainnumber"],
        "train2" : othertrainName,
        "distance" : distance,
        "alarm" : "red"
      });
      }
      else{
        await collision.child(mytrain["trainnumber"]).update({
          "train1" : mytrain["trainnumber"],
          "train2" : othertrainName,
          "distance" : distance,
          "alarm" : "yellow"
        });
      }
    }
  }
  Future<void> getmyzones()async{
    if(MissionPlanState.mapMissionnum != null){
      var value =  FirebaseDatabase.instance.ref("missionplan").child("${MissionPlanState.mapMissionnum}").child("zone");
      var getValue = await value.get().whenComplete(() => setState(() {  }));
      var a = jsonEncode(getValue.value);
      z = await json.decode(a.trim());
    }

  }
  Future<void> getZones()async{
    var value = FirebaseDatabase.instance.ref("zones").child("circle");
    var getValue = await value.get().whenComplete(() => setState(() {  }));
    var a = jsonEncode(getValue.value);
    j = await json.decode(a.trim());
    //  j = json.decode(a);
  }
  updateDriverName()async{
    await databaseRef.child("missionplan").update({
      "${MissionPlanState.mapMissionnum}/drivername" : "Not selected",
    });
    await databaseRef.child("trains").child(user!.uid).remove();
  showPopUp(context);
  }
  showPopUp(context){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Hi! ${user!.email}"),
        content:  Text("Mission is Ended successfully"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  collisionPopUp(context){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Warning"),
        content:  Text(collisionMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  Set<Circle> getcircles(){
    return  Set.from(List<Circle>.generate(j.length, (index) => Circle(
      circleId: CircleId(j[index]["name"]),
      center:  LatLng(j[index]["lat"], j[index]["lng"]),
      radius: j[index]["radius"].toDouble(),
      fillColor: Colors.blue.withOpacity(0.3),
      strokeColor: Colors.blue,
      strokeWidth: 1,
    )));
  }
  Widget buildMap(){
     getZones();

    return SafeArea(
      child: GoogleMap(
        circles: getcircles(),
        mapType: MapType.normal,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: true,
        initialCameraPosition: _mycurrenttlocationCameraPosition,
        onMapCreated: (GoogleMapController controller){
          _controller.complete(controller);
        },
      ),
    );
  }

   Future<void> getMycurrentlocation()async{
     position = await LocationHelper.getCurrentLocation().whenComplete(() => setState(() {

     }));
   }
    Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Map"),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
          ),
          drawer: NavBar(),
          body :Scaffold(
       body: Stack(
         fit: StackFit.expand,
             children: [
               position != null && j!=null ?buildMap() : Center(child: Container(child: CircularProgressIndicator(
                 color: Colors.deepPurple,
               ),),),
             ],

      ),floatingActionButton:
          FloatingActionButton.extended(
            backgroundColor: Colors.deepPurple,
              onPressed: () {updateDriverName();},
        icon: Icon(Icons.cancel,color: Colors.white,),
        label: Text("End Mission"),
      ),
    ),),);
  }

}
