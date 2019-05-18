import 'package:flutter/material.dart';
import 'package:flutter_play_android/entity/KnowledgeListEntity.dart' as Data;
import 'package:flutter_play_android/utils/NavigatorUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'entity/KnowledgeListEntity.dart';
import 'http/Http.dart';
import 'http/api/Api.dart';

class Knowledge extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _KnowledgeState();
  }
}

class _KnowledgeState extends State<Knowledge>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  List<Data.EntityData> dataList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    _getNetData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("知识体系"),
          centerTitle: true,
        ),
        body: isLoading
            ? _buildSpinKitCircle()
            : _showData()
    );
  }

  ///创建loading框
  Widget _buildSpinKitCircle() {
    return SpinKitCircle(
      size: 60.0,
      itemBuilder: (_, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.blue,
          ),
        );
      },
    );
  }

  ///显示数据
  Widget _showData() {
    return dataList.length > 0
        ? _buildListView()
        : Container(
      child: Text(
        "没有更多数据哦",
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    )
    ,
  }

  ///创建listView
  Widget _buildListView() {
    return ListView(
      children: dataList.map((data) {
        return GestureDetector(
          onTap: () {
            NavigatorUtils.gotoKnowledgeList(context, data.name, data);
          },
          child: Card(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          data.name,
                          style: TextStyle(fontSize: 20, color: Colors.black87),
                        ),
                        margin: EdgeInsets.all(10.0),
                      ),
                      Wrap(
                        spacing: 1.0,
                        direction: Axis.horizontal,
                        children: data.children.map((itemData) {
                          return Container(
                            margin: EdgeInsets.all(10.0),
                            child: Text(
                              itemData.name,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.navigate_next),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  ///获取知识体系列表的数据
  Future _getNetData() async {
    var url = Api.KNOWLEDGE_TREE;
    var response = await HttpUtil().get(url);
    var item = new KnowledgeListEntity.fromJson(response);
    setState(() {
      dataList = item.data;
      isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
