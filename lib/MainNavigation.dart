import 'package:flutter/material.dart';
import 'package:flutter_play_android/HomePage.dart';
import 'package:flutter_play_android/Knowledge.dart';
import 'package:flutter_play_android/Project.dart';
import 'package:flutter_play_android/PersonalCenter.dart';

class MainNavigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _NavigationState();
  }
}

class _NavigationState extends State<MainNavigation>  with SingleTickerProviderStateMixin{
  static const int TAB_COUNT = 4;
  //Tab页的控制器，可以用来定义Tab标签和内容页的坐标
  TabController tabController;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new TabBarView(
        controller: tabController,
        children: <Widget>[
          new HomePage(),
          new Knowledge(),
          new Project(),
          new PersonalCenter(),
        ],
      ),
      bottomNavigationBar: new Material(
        //底部栏整体颜色
        color: Colors.blueAccent,
        child: new TabBar(
          controller: tabController,
          tabs: <Widget>[
            new Tab(text: "首页",icon: new Icon(Icons.android)),
            new Tab(text: "知识体系",icon: new Icon(Icons.android)),
            new Tab(text: "项目",icon: new Icon(Icons.android)),
            new Tab(text: "个人中心",icon: new Icon(Icons.android)),
          ],
          //tab被选中时的颜色，设置之后选中的时候，icon和text都会变色
          labelColor: Colors.amber,
          //tab未被选中时的颜色，设置之后选中的时候，icon和text都会变色
          unselectedLabelColor: Colors.black,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = new TabController(
        length: TAB_COUNT,   //Tab页的个数
        vsync: this //动画效果的异步处理，默认格式
    );
  }

  //组件即将销毁时调用
  @override
  void dispose() {
    //释放内存，节省开销
    tabController.dispose();
    super.dispose();
  }
}
