import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatScreen extends StatefulWidget {
  static const String id="chatscreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth=FirebaseAuth.instance;
  final _insertion=Firestore.instance;
  final textController=TextEditingController();
  String mess;
  FirebaseUser loggedinuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuser();
  }
  void getuser() async
  {
   final user=await _auth.currentUser();
   if(user!=Null)
     {
       loggedinuser=user;
       print(loggedinuser.email);
       print(user.email+"oi");
     }
  }
  void Stream() async
  {
    await for(var input in _insertion.collection('message').snapshots()){
      for (var messs in input.documents){
  print(messs.data);
  }
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                //Stream();
                Navigator.pushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _insertion.collection('message').snapshots(),
              // ignore: missing_return
              builder: (context,snapshot){
                if(snapshot.hasData) {
                  final message = snapshot.data.documents.reversed;
                  List<bubblemess> messagecontent = [];
                  for (var mess in message) {
                    final mestext = mess.data['text'];
                    final mesender = mess.data['sender'];
                    final log=mesender;

                    final messageWidget =bubblemess(text: mestext,sender: mesender,isme:loggedinuser.email==mesender?true:false,) ;
                    messagecontent.add(messageWidget);
                  }

                  return Expanded(
                    child: ListView(
                      reverse: false,
                      padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 10.0),
                        children: messagecontent
                    ),
                  );
                }
              }

            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                      mess=value;  //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      //Implement send functionality.
                      _insertion.collection('message').add({
                        'text':mess,
                        'sender':loggedinuser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class bubblemess extends StatelessWidget {
  final String text;
  final String sender;
  final bool isme;

  const bubblemess({Key key, this.text, this.sender,this.isme}) ;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isme?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(color: Colors.black45),),
          Material(
            color: isme? Colors.lightBlueAccent:Colors.white,
            elevation: 5.9,
            borderRadius: isme?BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)):BorderRadius.only(topRight:Radius.circular(30),topLeft: Radius.circular(0.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)),

            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(

                  "$text",style: TextStyle(fontSize: 15.0,color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
