import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'Home Page.dart';
import 'Login_Register.dart';

class Add extends StatefulWidget {
  String name,contact,profile;
  int id;
  Add(this.name,this.contact,this.id,this.profile);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {

  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  Map loginuser={};

  @override
  void initState() {
    super.initState();
    t1.text=widget.name;
    t2.text=widget.contact;
    loginuser=jsonDecode(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(margin: EdgeInsets.only(top: 30,left: 5,right: 5),
          child: TextFormField(controller: t1,
            decoration: InputDecoration(prefixIcon: Icon(Icons.person_add_alt_1_outlined),labelText: "Enter Name",border: OutlineInputBorder()),),
        ),
        Card(margin: EdgeInsets.only(top: 20,left: 5,right: 5,bottom: 30),
          child: TextFormField(controller: t2,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(prefixIcon: Icon(Icons.contact_page_outlined),labelText: "Enter Contact",border: OutlineInputBorder()),),
        ),

        ElevatedButton(onPressed: () {
          String name,contact,insert,update;
          int Lid =loginuser['id'];
          name=t1.text;
          contact=t2.text;
          if(widget.id==0)
          {
            if(t1.text.isEmpty)
              {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Name")));
              }
            else if(t2.text.isEmpty){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Contact")));
            }
            else
            {
              insert="INSERT INTO mycontacts VALUES(NULL,'$name','$contact','$Lid')";
              Login.database!.rawInsert(insert).then((value) => print("Contact : $value"));

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home("", "", 0,widget.profile),));
            }
          }
          else
          {
            update="update mycontacts set name='${t1.text}',contact='${t2.text}' where id='${widget.id}'";
            Login.database!.rawUpdate(update);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home("", "", 0,widget.profile),));
          }
          setState(() {});
        }, child: Text((widget.id==0) ? "Add" : "Update"))
      ],
    );
  }
}

//--------------- View Contacts---------->

class Contacts extends StatefulWidget {
  String profile;
  Contacts(this.profile);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  TextEditingController search = TextEditingController();
  List <Map> data=[];
  Map loginuser={};

  find_data() async {
    int Lid=loginuser['id'];
    String select="select * from mycontacts where LoginId='$Lid'";
    data = await Login.database!.rawQuery(select);
  }

  @override
  void initState() {
    super.initState();
    loginuser=jsonDecode(widget.profile);
    find_data();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card(margin: EdgeInsets.all(10),
        //   child: TextFormField(controller: search,
        //     decoration: InputDecoration(prefixIcon: Icon(Icons.search_rounded),labelText: "Search Contacts",contentPadding: EdgeInsets.all(5),
        //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),),
        // ),
        Divider(thickness: 2,color: Colors.grey.shade100,),
        Expanded(
            child: FutureBuilder(future: find_data(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  return (data.length==0) ? Center(child: Column(
                    children: const [
                      SizedBox(height: 50),
                      Icon(Icons.dangerous,size: 30,),
                      Text("No Contacts Available!",style: TextStyle(fontSize: 20),),
                    ],
                  ),)

                   :SlidableAutoCloseBehavior(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        int id=int.parse("${data[index]['id']}");
                        return Slidable(
                          startActionPane:
                          ActionPane(extentRatio: 0.21,
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                      return Home("${data[index]['name']}","${data[index]['contact']}",id,widget.profile);
                                    },));
                                  },
                                  backgroundColor: Color(0xFF0392CF),
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',borderRadius: BorderRadius.circular(20),
                                ),
                              ]
                          ),
                          endActionPane: ActionPane(extentRatio: 0.21,
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  String delete="delete from mycontacts where id=${data[index]['id']}";
                                  Login.database!.rawDelete(delete);
                                  setState(() {});
                                  final  snackBar = SnackBar(
                                    content: const Text('Delete'),
                                    backgroundColor: (Colors.black),behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'dismiss',
                                      onPressed: () {},
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',borderRadius: BorderRadius.circular(20),
                              ),
                            ],
                          ),
                          child: Card(shadowColor: Colors.grey.shade600,elevation: 5,
                            margin: EdgeInsets.all(5),
                            child: ListTile(
                              leading: CircleAvatar(radius: 20,child: Icon(Icons.person,size: 30),),
                              title: Text("${data[index]['name']}", style: TextStyle(fontSize: 18)),
                              subtitle: Text("${data[index]['contact']}", style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                else
                {
                  return CircularProgressIndicator();
                }
              },)
        ),
      ],
    );
  }
}

