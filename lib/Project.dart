import 'package:flutter/material.dart';

class Project extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _ProjectState();
  }

}
class _ProjectState extends State<Project>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      child: Center(child: new Text('项目', textDirection: TextDirection.ltr)),
    );
  }

}