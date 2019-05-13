import 'package:flutter/material.dart';

class Knowledge extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _KnowledgeState();
  }
}
class _KnowledgeState extends State<Knowledge>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      child: Center(child: new Text('知识体系', textDirection: TextDirection.ltr)),
    );
  }

}