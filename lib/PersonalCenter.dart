import 'package:flutter/material.dart';

class PersonalCenter extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _PersonalCenterState();
  }

}
class _PersonalCenterState extends State<PersonalCenter>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      child: Center(child: new Text('个人中心', textDirection: TextDirection.ltr)),
    );
  }

}