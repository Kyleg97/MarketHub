import 'package:MarketHub/providers/reddit_provider.dart';
import 'package:MarketHub/providers/robinhood_provider.dart';
import 'package:MarketHub/providers/stocktwits_provider.dart';
import 'package:MarketHub/widgets/stocktwits_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:MarketHub/services/trading_apps.dart';

class PopularPage extends StatefulWidget {
  PopularPage() : super();

  @override
  PopularPageState createState() => PopularPageState();
}

class PopularPageState extends State<PopularPage> {
  ScrollController _scrollController = new ScrollController();

  int _currentSource = 0; // 0 stocktwits, 1 reddit, 2 robinhood

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(50, 20),
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 5, 10),
            child: FlatButton(
              onPressed: () {
                setState(() {
                  _currentSource = 0;
                });
              },
              child: Text(
                "Stocktwits",
                style: TextStyle(
                    color: _currentSource == 0 ? Colors.teal : Colors.white),
              ),
              color: _currentSource == 0
                  ? Theme.of(context).selectedRowColor
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 5, 10),
            child: FlatButton(
              onPressed: () {
                setState(() {
                  _currentSource = 1;
                });
              },
              child: Text(
                "Reddit",
                style: TextStyle(
                    color: _currentSource == 1 ? Colors.teal : Colors.white),
              ),
              color: _currentSource == 1
                  ? Theme.of(context).selectedRowColor
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 5, 10),
            child: FlatButton(
              onPressed: () {
                setState(() {
                  _currentSource = 2;
                });
              },
              child: Text(
                "Robinhood",
                style: TextStyle(
                    color: _currentSource == 2 ? Colors.teal : Colors.white),
              ),
              color: _currentSource == 2
                  ? Theme.of(context).selectedRowColor
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
      body: Container(
        //bottom: false,
        /*decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Colors.teal[100], Colors.teal],
              begin: const FractionalOffset(0.0, 0.5),
              end: const FractionalOffset(0.5, 0.0),
              //radius: 1.5,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),*/
        child: _currentSource == 0
            ? StocktwitsPage(scrollController: _scrollController)
            : _currentSource == 1
                ? RedditPage(scrollController: _scrollController)
                : RobinhoodPage(scrollController: _scrollController),
      ),
    );
  }
}

// Stocktwits Page
class StocktwitsPage extends StatelessWidget {
  const StocktwitsPage({
    Key key,
    @required ScrollController scrollController,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: StocktwitsProvider(),
      child: Consumer<StocktwitsProvider>(
        builder: (context, provider, child) {
          return provider.isFetching
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(5),
                    itemCount: provider.getItems.length,
                    itemBuilder: (context, i) => StocktwitsCard(
                        provider.getItems[i].symbol,
                        provider.getItems[i].title,
                        provider.getItems[i].watchlistCount),
                  ),
                );
        },
      ),
    );
  }
}

// Reddit Page
class RedditPage extends StatelessWidget {
  const RedditPage({
    Key key,
    @required ScrollController scrollController,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;

  void leavingAppDialog(String ticker, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text("Do you want to view $ticker on Robinhood?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                TradingApps.launchURL(ticker);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: RedditProvider(),
      child: Consumer<RedditProvider>(
        builder: (context, provider, child) {
          return provider.isFetching
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(5),
                    itemCount: provider.getItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 5,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () {
                                TradingApps.installedApps.forEach((element) {
                                  if (element["app_name"] == "Robinhood") {
                                    leavingAppDialog(
                                        provider.getItems[index].ticker,
                                        context);
                                    return;
                                  }
                                });
                              },
                              title: Text(provider.getItems[index].ticker),
                              subtitle: Text(provider.getItems[index].company),
                              trailing: Text(
                                "Mentions:\n" +
                                    provider.getItems[index].count.toString(),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}

// Robinhood Page
class RobinhoodPage extends StatelessWidget {
  const RobinhoodPage({
    Key key,
    @required ScrollController scrollController,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;

  void leavingAppDialog(String ticker, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text("Do you want to view $ticker on Robinhood?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                TradingApps.launchURL(ticker);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: RobinhoodProvider(),
      child: Consumer<RobinhoodProvider>(
        builder: (context, provider, child) {
          return provider.isFetching
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(5),
                    itemCount: provider.getItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 5,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () {
                                TradingApps.installedApps.forEach((element) {
                                  if (element["app_name"] == "Robinhood") {
                                    leavingAppDialog(
                                        provider.getItems[index].ticker,
                                        context);
                                    return;
                                  }
                                });
                              },
                              title: Text(provider.getItems[index].ticker),
                              subtitle: Text(provider.getItems[index].company),
                              trailing: Text(
                                "Volume:\n" +
                                    provider.getItems[index].volume.toString(),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
