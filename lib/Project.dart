import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_play_android/entity/projectListEntity.dart';
import 'package:flutter_play_android/entity/projectListEntity.dart'
    as TabListEntity;
import 'package:flutter_play_android/entity/projectListItemEntity.dart'
    as ItemEntity;
import 'package:flutter_play_android/entity/projectListItemEntity.dart';
import 'package:flutter_play_android/utils/CommonUtil.dart';
import 'package:flutter_play_android/utils/NavigatorUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'http/Http.dart';
import 'http/api/Api.dart';

class Project extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ProjectState();
  }
}

class _ProjectState extends State<Project> {
  List<TabListEntity.Data> data = [];

  @override
  void initState() {
    super.initState();

    _getTabItemList();
  }

  Future _getTabItemList() async {
    var url = Api.PROJECT_TREE;
    var response = await HttpUtil().get(url);
    var item = ProjectListEntity.fromJson(response);
    setState(() {
      data = item.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return data.length == 0 ? _buildEmptyView() : _buildTabController();
  }

  Widget _buildEmptyView() {
    return SpinKitCircle(
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

  Widget _buildTabController() {
    return DefaultTabController(
        length: data.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("项目"),
            centerTitle: true,
            bottom: TabBar(
                isScrollable: true, //可以滑动
                tabs: data.map((item) {
                  return Tab(
                    text: item.name,
                  );
                }).toList()),
          ),
          body: TabBarView(
              children: data.map((item) {
            return TabListContent(item.id);
          }).toList()),
        ));
  }
}

class TabListContent extends StatefulWidget {
  final int cid;

  TabListContent(this.cid, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabListContentState(cid);
  }
}

class TabListContentState extends State<TabListContent>
    with AutomaticKeepAliveClientMixin {
  var pageSize = 15;
  var page = 0;

  //是否有更多数据
  bool isHasMore = false;
  List<ItemEntity.Datas> data;
  final int cid;

  TabListContentState(this.cid);

  final GlobalKey<RefreshIndicatorState> _refreshGlobalKey = GlobalKey();
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: false);

  @override
  void initState() {
    super.initState();
    _getListData(false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++;
        _getListData(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (null == data || data.length == 0) {
      return _buildEmptyView();
    } else {
      return _buildRefreshListView();
    }
  }

  Widget _buildEmptyView() {
    return SpinKitCircle(
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

  /**
   * 下拉刷新列表
   */
  Widget _buildRefreshListView() {
    return RefreshIndicator(
      color: Colors.green,
      child: _buildListView(),
      onRefresh: _refreshHelper,
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        key: _refreshGlobalKey,
        itemCount: data.length + 1,
        controller: _scrollController,
        itemBuilder: (context, index) {
          return buildItem(index);
        });
  }

  Widget buildItem(int index) {
    if (index == data.length) {
      if (isHasMore) {
        return _buildLoadMoreLoading();
      } else {
        return _buildNoMoreData();
      }
    } else {
      var item = data[index];
      var date =
          DateTime.fromMillisecondsSinceEpoch(item.publishTime, isUtc: true);
      return _buildCardItem(item, date, index);
    }
  }

  Widget _buildCardItem(ItemEntity.Datas item, DateTime date, int index) {
    return GestureDetector(
      onTap: () {
        NavigatorUtils.gotoDetail(context, item.link, item.title);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network(
                item.envelopePic,
                fit: BoxFit.cover,
                width: 85,
                height: 125,
              ),
              Container(
                height: 125,
                margin: EdgeInsets.only(left: 8.0),
                width: CommonUtil.getScreenWidth(context) - 130.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(item.title,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        maxLines: 2),
                    Text(item.desc,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        maxLines: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(item.author,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            maxLines: 1),
                        Text(
                            "${date.year}年${date.month}月${date.day}日${date.hour}:${date.minute}",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            maxLines: 1),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///创建 没有更多数据 view
  Widget _buildNoMoreData() {
    return Container(
        margin: EdgeInsets.only(top: 15, bottom: 15),
        alignment: Alignment.center,
        child: Text("没有更多数据了"));
  }

  ///创建 加载更多 view
  Widget _buildLoadMoreLoading() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitCircle(
              color: Colors.blue,
              size: 30,
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text("正在加载更多")
          ],
        ),
      ),
    );
  }

  _getListData(bool isLoadMore,[Completer completer]) async {
    var url = Api.PROJECT_LIST + "$page/json";
    var response = await HttpUtil().get(url, data: {"cid": cid});
    var item = ProjectListItemEntity.fromJson(response);

    completer?.complete();

    if (item.data.datas.length < pageSize) {
      isHasMore = false;
    } else {
      isHasMore = true;
    }
    if (isLoadMore) {
      data.addAll(item.data.datas);
      setState(() {});
    } else {
      setState(() {
        data = item.data.datas;
      });
    }
  }

  Future<Null> _refreshHelper() {
    final Completer<Null> completer = Completer<Null>();
    //清空数据
    data.clear();
    setState(() {

    });
    page = 0;
    _getListData(false,completer);
    return completer.future;
  }

  @override
  bool get wantKeepAlive => true;
}
