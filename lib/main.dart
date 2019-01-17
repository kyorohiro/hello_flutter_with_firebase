import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;

void main() => runApp(MyApp());

final dummySnapshot = [
  {"name": "Filip", "votes": 15},
  {"name": "Abraham", "votes": 14},
  {"name": "Richard", "votes": 11},
  {"name": "Ike", "votes": 10},
  {"name": "Justin", "votes": 1},
];


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boby Names',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Baby Names'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildBody(context)
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<fb.QuerySnapshot>(
      stream: fb.Firestore.instance.collection("baby").snapshots(),
      builder: (context, snapshot) {
        print(">> sb");
        if(!snapshot.hasData) {
          print(">> sb 1");
          return LinearProgressIndicator();
        } else {
          print(">> sb 2");
          return _buildListWithSnapshot(context, snapshot.data.documents);
        }
      },
    );

  }

  Widget _buildListWithMao(BuildContext, List<Map> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) {
        print(">> ${data}");
        _buildListItem(context, Record.fromMap(data));
      }).toList(),
    );
  }

  Widget _buildListWithSnapshot(BuildContext context, List<fb.DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, Record.fromSnapshot(data))).toList(),
    );
  }

  Widget _buildListItem(BuildContext context,Record record) {
    print(">>_bli");
    return Padding(
        key: ValueKey(record.name),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration:  BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(record.name),
            trailing: Text(record.votes.toString()),

            onTap: (){
              print(record);
              record.reference.updateData({'votes': record.votes + 1});
            }
            /*
            onTap:()=>
            fb.Firestore.instance.runTransaction((transaction) async {
              print("--1");
              fb.DocumentSnapshot fs = await transaction.get(record.reference);
              Record r = Record.fromSnapshot(fs);
              await transaction.update(r.reference, {'votes': r.votes + 1});
              print("--2");
            })*/,
          ),
        )
    );
  }

}


class Record {
  final String name;
  final int votes;
  final fb.DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : this.name = map["name"],
        this.votes = map["votes"];

  Record.fromSnapshot(fb.DocumentSnapshot snapshot)
  : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";

}