import 'dart:async';

import 'package:flutter/material.dart';
import 'package:banner_view/banner_view.dart';
import 'package:flutter_play_android/utils/CommonUtil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'entity/HomeArticleListEntityEntity.dart' as ArticleListEntity;
import 'entity/HomeBannerEntityEntity.dart' as BannerEntity;
import 'http/Http.dart';
import 'http/api/Api.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  ///这个key用来在不是手动下拉，而是点击某个button或其它操作时，代码直接触发下拉刷新
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorState =
      new GlobalKey<RefreshIndicatorState>();

  final ScrollController _scrollController =
      new ScrollController(keepScrollOffset: false);

  ///banner数据源
  List<ArticleListEntity.HomeArticleListEntityDataData> homeData = [];

  ///文章列表数据源
  List<BannerEntity.HomeBannerEntityData> bannerList = [];

  ///banner数量
  final int headerCount = 1;

  ///banner下标
  var bannerIndex = 0;

  ///列表一页的数量
  final int pageSize = 20;

  ///当前页数
  var page = 0;

  //是否在加载
  bool isLoading = false;

  //是否有更多数据
  bool isHasNoMore = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Material(
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("首页"),
          centerTitle: true,
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  //TODO
//              NavigatorUtils.gotoSearch(context);
                })
          ],
        ),
        body: new RefreshIndicator(
          color: Colors.green,
          child: _buildCustomListView(),
          onRefresh: _refreshHelper,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getBannerList();
    _getNewsListData(false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoading) {
          page++;
          _getNewsListData(true);
        }
      }
    });
  }

  Future<Null> _refreshHelper() {
    final Completer<Null> completer = new Completer<Null>();
    //清空数据
    homeData.clear();
    bannerList.clear();
    page = 0;
    _getBannerList(completer);
    _getNewsListData(false, completer);
    return completer.future;
  }

  ///请求banner数据
  _getBannerList([Completer completer]) async {
    var response = await HttpUtil().get(Api.BANNER_LIST);
    var item = new BannerEntity.Entity.fromJson(response);
    bannerList = item.data;
    setState(() {});
  }

  ///请求文章列表数据
  _getNewsListData(bool isLoadMore, [Completer completer]) async {
    if (isLoadMore) {
      setState(() => isLoading = true);
    }
    var response =
        await HttpUtil().get(Api.HOME_LIST + page.toString() + "/json");
    var item = new ArticleListEntity.HomeArticleListEntity.fromJson(response);
    completer?.complete();
    if (item.data.datas.length < pageSize) {
      isHasNoMore = true;
    } else {
      isHasNoMore = false;
    }
    if (isLoadMore) {
      isLoading = false;
      homeData.addAll(item.data.datas);
      setState(() {});
    } else {
      setState(() {
        homeData = item.data.datas;
      });
    }
  }

  _buildCustomListView() {
    return new ListView.builder(
      ///保持ListView任何情况都能滚动，解决在RefreshIndicator的兼容问题。
      physics: const AlwaysScrollableScrollPhysics(),
      key: _refreshIndicatorState,
      itemCount: homeData.length + headerCount + 1,
      controller: _scrollController,
      itemBuilder: (context, index) {
        if (0 == index) {
          return _buildBanner();
        } else {
          return _buildArticleItem(index - headerCount);
        }
      },
    );
  }

  ///创建banner
  _buildBanner() {
    return new Container(
      child: bannerList.length > 0
          ? new BannerView(
              bannerList.map((BannerEntity.HomeBannerEntityData item) {
                return new GestureDetector(
                    onTap: () {
                      //TODO
//                  NavigatorUtils.gotoDetail(context, item.url, item.title);
                    },
                    child: new Image.network(
                      item.imagePath,
                      fit: BoxFit.cover,
                    ));
              }).toList(),
              intervalDuration: Duration(seconds: 3),
//              animationDuration: Duration(milliseconds: 4000),
              cycleRolling: false,
              autoRolling: true,
              indicatorMargin: 8,
              indicatorNormal: _buildIndicatorItem(Colors.white),
              indicatorSelected:
                  _buildIndicatorItem(Colors.blue, isSelected: true),
              indicatorBuilder: (context, indicator) {
                return _buildIndicatorItemContainer(indicator);
              },
            )
          : new Container(),
      width: double.infinity,
      height: 250.0,
    );
  }

  ///创建banner的indicator
  Widget _buildIndicatorItem(Color color, {bool isSelected = false}) {
    double size = isSelected ? 10.0 : 6.0;
    return new Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.all(
          new Radius.circular(5.0),
        ),
      ),
    );
  }

  Widget _buildIndicatorItemContainer(Widget indicator) {
    var container = new Container(
      height: 40.0,
      child: new Stack(
        children: <Widget>[
          new Opacity(
            opacity: isLoading ? 1.0 : 0.7,
            child: new Container(
              color: Colors.grey[300],
            ),
          ),
          new Container(
            margin: EdgeInsets.only(right: 10.0),
            child: new Align(
              alignment: Alignment.centerRight,
              child: indicator,
            ),
          ),
          new Align(
            alignment: Alignment.centerLeft,
            child: new Container(
              margin: EdgeInsets.only(left: 15.0),
              child: new Text(bannerList[bannerIndex].title),
            ),
          )
        ],
      ),
    );

    return new Align(
      alignment: Alignment.bottomCenter,
      child: container,
    );
  }

  ///创建文章item
  _buildArticleItem(int index) {
    if (index == homeData.length) {
      if (isHasNoMore) {
        return _buildNoMoreData();
      } else {
        return _buildLoadMoreLoading();
      }
    } else {
      var item = homeData[index];
      var date =
          DateTime.fromMillisecondsSinceEpoch(item.publishTime, isUtc: true);
      return _buildCardItem(item, date, index);
    }
  }

  ///卡片式布局
  _buildCardItem(ArticleListEntity.HomeArticleListEntityDataData item,
      DateTime date, int index) {
    return new Card(
        child: new InkWell(
      onTap: () {
        var url = homeData[index].link;
        var title = homeData[index].title;
        //TODO
//            NavigatorUtils.gotoDetail(context, url, title);
      },
      child: new Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10.0),
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Container(
                  decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(3.0),
                      border: new Border.all(color: Colors.blue)),
                  child: new Text(
                    item.superChapterName,
                    style: new TextStyle(color: Colors.blue),
                  ),
                ),
                new Container(
                  margin: EdgeInsets.only(left: 5.0),
                  child: new Text(item.author),
                ),
                new Expanded(child: new Container()),
                new Text(
                  "${date.year}年${date.month}月${date.day}日 ${date.hour}:${date.minute}",
                  style: new TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Container(
                  height: 80.0,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        width: CommonUtil.getScreenWidth(context) - 100,
                        child: new Text(
                          item.title,
                          softWrap: true, //换行
                          maxLines: 2,
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        margin: EdgeInsets.only(top: 10.0),
                      ),
                      new Container(
                        child: new Text(
                          item.superChapterName + "/" + item.author,
                          style: new TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                item.envelopePic.isEmpty
                    ? new Container(
                        width: 60.0,
                        height: 60.0,
                      )
                    : new Image.network(
                        item.envelopePic,
                        width: 60.0,
                        height: 60.0,
                        fit: BoxFit.cover,
                      ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  ///没有更多数据
  Widget _buildNoMoreData() {
    return new Container(
      margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
      alignment: Alignment.center,
      child: new Text("没有更多数据了"),
    );
  }

  ///加载中
  Widget _buildLoadMoreLoading() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitFadingCircle(
                color: Colors.grey,
                size: 30.0,
              ),
              new Padding(padding: EdgeInsets.only(left: 10)),
              new Text("正在加载更多...")
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
