import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'Home Page.dart';
import 'package:path/path.dart';

class Login extends StatefulWidget {
  static Database? database;
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _email =TextEditingController();
  TextEditingController _password =TextEditingController();
  List <Map> row=[];
  int cnt=0;
  bool tp=false,login=false, pw = false;
  String profile='';
  SharedPreferences? prefs;

  data() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'contact.db');

     const MyRegister = """
        CREATE TABLE  registers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, pass TEXT
      );""";

    const MyContact = """
        CREATE TABLE  mycontacts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, contact TEXT,LoginId INTEGER
      );""";


  Login.database= await openDatabase(path, version: 2, onCreate: (Database db, int version) async {
      await db.execute(MyRegister);
      await db.execute(MyContact);
    },);

   /* Login.database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE registers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, pass TEXT)');
    });
    Login.database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE mycontacts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, contact TEXT)');
    });
*/
     prefs = await SharedPreferences.getInstance();
    login = prefs!.getBool('login') ?? false;
    profile = prefs!.getString('profile') ?? "";

    String select = "select * from registers";
    Login.database!.rawQuery(select).then((value) {
      row=value;
    });

    if(login==true)
      {
       Navigator.push(context as BuildContext ,MaterialPageRoute(builder: (context) {
         return Home('', '', 0, profile);
       },));
      }
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
      data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Column(
        children: [
          Card(margin: const EdgeInsets.only(top: 30,left: 5,right: 5),
            child: TextFormField(controller: _email,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.email),labelText: "Enter Email",border: OutlineInputBorder()),),
          ),
          Card(margin: const EdgeInsets.only(top: 20,left: 5,right: 5,bottom: 30),
            child: TextFormField(controller: _password,
              obscureText: pw,
              decoration: InputDecoration(prefixIcon: Icon(Icons.key),
                  suffixIcon: IconButton(onPressed: () {
                    pw =!pw;
                    setState(() {});
                  }, icon:(pw) ? Icon(Icons.remove_red_eye_outlined) : Icon(Icons.remove_red_eye)),
                  labelText: "Enter Password",border: const OutlineInputBorder()),),
          ),

          ElevatedButton(onPressed: () {
            String email,pass;
            email=_email.text;
            pass=_password.text;

            for (int i=0;i<row.length;i++) {
              if (email==row[i]['email'] && pass==row[i]['pass'])
              {
                cnt=1;
                profile = jsonEncode(row[i]);
                break;
              }
            }
            if(cnt==1)
              {
                prefs!.setBool('login', true);
                prefs!.setString('profile', profile);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return Home("","",0,profile);},));
              }
            else
            {
              final snackBar =  SnackBar(padding: EdgeInsets.all(10),
                  content: const Text('Wrong UserName Or Password'),
                  backgroundColor: (Colors.black),
                  action: SnackBarAction(
                    label: 'dismiss',
                    onPressed: () {},
                  ));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }, child: Text("Login")),

          Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Register();
                },));
              }, child: Text("New User / Sign Up?"))
            ],
          ),

          (row.length==0) ? Text(" ${row.length} Data") :
          Expanded(child: ListView.builder(
            itemCount: row.length,
            itemBuilder: (context, index) {
            return ListTile(
              title: Text("${row[index]['name']}"),
              subtitle: Text("${row[index]['email']} | ${row[index]['pass']}"),
            );
          },))
        ],
      ),
    );
  }
}


//--------------------------Register----------------------------------


class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _name =TextEditingController();
  TextEditingController _email =TextEditingController();
  TextEditingController _password =TextEditingController();
  bool pw = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Page"),
      ),
      body: Column(
        children: [
          Card(margin: const EdgeInsets.only(top: 30,left: 5,right: 5),
            child: TextFormField(controller: _name,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person),labelText: "Enter Name",border: OutlineInputBorder()),),
          ),
          Card(margin: const EdgeInsets.only(top: 10,left: 5,right: 5),
            child: TextFormField(controller: _email,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.email),labelText: "Enter Email",border: OutlineInputBorder()),),
          ),
          Card(margin: const EdgeInsets.only(top: 10,left: 5,right: 5,bottom: 30),
            child: TextFormField(controller: _password,
              obscureText: pw,
              decoration: InputDecoration(prefixIcon: Icon(Icons.key),
                  suffixIcon: IconButton(onPressed: () {
                    pw =!pw;
                    setState(() {});
                  }, icon:(pw) ? Icon(Icons.remove_red_eye_outlined) : Icon(Icons.remove_red_eye)),
                  labelText: "Enter Password",border: const OutlineInputBorder()),),
          ),
          ElevatedButton(onPressed: () {
            String name,email,pass,insert;
            name=_name.text;
            email=_email.text;
            pass=_password.text;

            insert = "INSERT INTO registers VALUES(NULL,'$name','$email','$pass')";
            Login.database!.rawInsert(insert);
            print("Inserted");
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Login();
            },));
          }, child: Text("Register")),
        ],
      ),
    );
  }
}
