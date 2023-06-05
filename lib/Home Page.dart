import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Add & View.dart';
import 'dart:convert';
import 'Login_Register.dart';

class Home extends StatefulWidget {
  String name,contact,profile;
  int id;

  Home(this.name,this.contact,this.id,this.profile);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  TabController? tabcontroller ;
  int tabindex=0;
  Map loginuser={};

  SharedPreferences? prefs;
  pref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    pref();
    tabcontroller = TabController(initialIndex: tabindex,length: 2, vsync: this);
    loginuser=jsonDecode(widget.profile);
    String name = loginuser["name"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Card(margin: EdgeInsets.only(left: 10,right: 10,top: 50,bottom: 20),elevation: 5,
                  child: Container(width: double.infinity,height: 50,alignment: Alignment.center,
                      child: Text("${loginuser['name']}",style: TextStyle(fontSize: 20),))),

              Card(margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 50),elevation: 5,
                  child: Container(width: double.infinity,height: 50,alignment: Alignment.center,
                      child: Text("${loginuser['email']}",style: TextStyle(fontSize: 20),))),

              ElevatedButton(onPressed: () {
                prefs!.setBool('login', false);
                prefs!.setString('profile', "");
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return Login();},));
              }, child: Text("Logout"))
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Contacts Book"),
      ),
      body: Column(
        children: [
          TabBar(indicatorSize: TabBarIndicatorSize.label,
            controller: tabcontroller,labelPadding: EdgeInsets.all(5),
            onTap: (value) {
              tabindex=value;
              setState(() {});
            },
            tabs: [
              Tab( child: Text((widget.id==0) ? "Add" : "Update",style: TextStyle(color: Colors.black),)),
              Tab( child: Text("Contact",style: TextStyle(color: Colors.black))),
            ],
          ),
          Expanded(
            child: TabBarView(
                controller: tabcontroller,
                children: [
                  Add(widget.name, widget.contact, widget.id,widget.profile),
                  Contacts(widget.profile)
                ]),
          )
        ],
      ),
    );
  }
}
