import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _HomePageState();
  }
}
class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      child: Center(child: new Text('首页', textDirection: TextDirection.ltr)),
    );
  }

}