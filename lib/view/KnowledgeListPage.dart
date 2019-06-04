import 'package:flutter/material.dart';
import 'package:flutter_play_android/entity/knowledgeItemEntity.dart'
    as KnowledgeItemEntity;
import 'package:flutter_play_android/entity/KnowledgeListEntity.dart'
    as KnowledgeListEntity;
import 'package:flutter_play_android/http/Http.dart';
import 'package:flutter_play_android/http/api/Api.dart';
import 'package:flutter_play_android/utils/NavigatorUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class KnowledgeListPage extends StatefulWidget {
  String name;

  KnowledgeListEntity.EntityData data;

  KnowledgeListPage({Key key, this.name, this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return KnowledgeListPageState(name, data);
  }
}

class KnowledgeListPageState extends State<KnowledgeListPage> {
  String name;

  KnowledgeListEntity.EntityData data;

  KnowledgeListPageState(this.name, this.data);

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: data.children.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
            bottom: TabBar(
                isScrollable: true,
                tabs: data.children.map((KnowledgeListEntity.Datachild child) {
                  return Tab(
                    text: child.name,
                  );
                }).toList()),
          ),
          body: TabBarView(
              children:
                  data.children.map((KnowledgeListEntity.Datachild child) {
            return ListPage(
              cid: child.id,
            );
          }).toList()),
        ));
  }
}

class ListPage extends StatefulWidget {
  final int cid;

  const ListPage({Key key, this.cid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListPageState(this.cid);
  }
}

class ListPageState extends State<ListPage> with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  final int cid;

  ListPageState(this.cid);

  List<KnowledgeItemEntity.KnowledgeItemDataData> data = [];

  @override
  Widget build(BuildContext context) {
    return isLoading ? _buildSpinKitCircle() : _buildListView();
  }

  Widget _buildSpinKitCircle() {
    return SpinKitCircle(
      itemBuilder: (_, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5.0),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return data.length > 0
        ? ListView(
            children: data.map((item) {
              var date = DateTime.fromMicrosecondsSinceEpoch(item.publishTime,
                  isUtc: true);
              return GestureDetector(
                onTap: () {
                  NavigatorUtils.gotoDetail(context, item.link, item.title);
                },
                child: new Card(
                  margin:
                      EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                  child: Container(
                    margin: EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              item.author,
                              style: new TextStyle(
                                  fontSize: 18.0, color: Colors.black87),
                            ),
                            new Text(
                              "${date.year}年${date.month}月${date.day}日 ${date.hour}:${date.minute}",
                              style: new TextStyle(
                                  fontSize: 12.0, color: Colors.grey),
                            ),
                          ],
                        ),
                        new Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text(
                            item.title,
                            style: new TextStyle(
                                color: Colors.black, fontSize: 18.0),
                          ),
                        ),
                        new Text(
                          "${item.author}/${item.chapterName}",
                          style:
                              new TextStyle(fontSize: 14.0, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        : new Container(
            child: Text(
              "没有更多数据！",
              style: TextStyle(fontSize: 20.0, color: Colors.black87),
            ),
          );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    _getPageData();
  }

  void _getPageData() async {
    var url = Api.KNOWLEDGE_LIST;
    var response = await HttpUtil().get(url, data: {"cid": cid});
    var item = new KnowledgeItemEntity.KnowledgeItemEntity.fromJson(response);
    setState(() {
      isLoading = false;
      data = item.data.datas;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
