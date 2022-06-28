import 'package:flutter/material.dart';
import 'package:airasc/screens/TrainStatus.dart';
import 'package:airasc/screens/Map.dart';
import 'package:airasc/screens/MissionPlan.dart';
import 'package:airasc/screens/home.dart';
import 'package:airasc/screens/login.dart';
class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Name'),
            accountEmail: Text('name@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'images/blank-profile-picture.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                      'images/rw.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.train),
            title: Text('Train Status'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrainStatusScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.table_rows_sharp),
            title: Text('Mission Plan'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MissionPlanScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Location'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('About'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            title: Text('Exit'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogInScreen()),
            ),
          ),
        ],
      ),
    );
  }
}