import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:banner_view/banner_view.dart';
import 'package:flutter_play_android/utils/CommonUtil.dart';
import 'package:flutter_play_android/utils/NavigatorUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'entity/HomeArticleListEntity.dart' as ArticleListEntity;
import 'entity/HomeBannerEntity.dart' as BannerEntity;
import 'http/Http.dart';
import 'http/api/Api.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  ///这个key用来在不是手动下拉，而是点击某个button或其它操作时，代码直接触发下拉刷新
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorState =
      GlobalKey<RefreshIndicatorState>();

  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: false);

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
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("首页"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  //TODO
//              NavigatorUtils.gotoSearch(context);
                })
          ],
        ),
        body: RefreshIndicator(
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
    final Completer<Null> completer = Completer<Null>();
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
    var item = BannerEntity.Entity.fromJson(response);
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
    var item = ArticleListEntity.HomeArticleListEntity.fromJson(response);
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
    return ListView.builder(
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
    return Container(
      child: bannerList.length > 0
          ? BannerView(
              bannerList.map((BannerEntity.HomeBannerEntityData item) {
                return GestureDetector(
                    onTap: () {
                      NavigatorUtils.gotoDetail(context, item.url, item.title);
                    },
                    child: Image.network(
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
          : Container(),
      width: double.infinity,
      height: 250.0,
    );
  }

  ///创建banner的indicator
  Widget _buildIndicatorItem(Color color, {bool isSelected = false}) {
    double size = isSelected ? 10.0 : 6.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
    );
  }

  Widget _buildIndicatorItemContainer(Widget indicator) {
    var container = Container(
      height: 40.0,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: isLoading ? 1.0 : 0.7,
            child: Container(
              color: Colors.grey[300],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: indicator,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 15.0),
              child: Text(bannerList[bannerIndex].title),
            ),
          )
        ],
      ),
    );

    return Align(
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
    return Card(
        margin: EdgeInsets.only(left: 5, top: 2.5, right: 5, bottom: 2.5),
        child: InkWell(
          onTap: () {
            var url = homeData[index].link;
            var title = homeData[index].title;
            NavigatorUtils.gotoDetail(context, url, title);
          },
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          border: Border.all(color: Colors.blue)),
                      child: Text(
                        item.superChapterName,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0),
                      child: Text(item.author),
                    ),
                    Expanded(child: Container()),
                    Text(
                      "${date.year}年${date.month}月${date.day}日 ${date.hour}:${date.minute}",
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 80.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: CommonUtil.getScreenWidth(context) - 100,
                            child: Text(
                              item.title,
                              softWrap: true, //换行
                              maxLines: 2,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            margin: EdgeInsets.only(top: 10.0),
                          ),
                          Container(
                            child: Text(
                              item.superChapterName + "/" + item.author,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    item.envelopePic.isEmpty
                        ? Container(
                            width: 60.0,
                            height: 60.0,
                          )
                        : Image.network(
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
    return Container(
      margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
      alignment: Alignment.center,
      child: Text("没有更多数据了"),
    );
  }

  ///加载中
  Widget _buildLoadMoreLoading() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitFadingCircle(
                color: Colors.grey,
                size: 30.0,
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Text("正在加载更多...")
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
