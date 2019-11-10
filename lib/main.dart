
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FX Predictor",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
          accentColor: Colors.white70
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  var _currencies = ["EURUSD",'GBPUSD','USDJPY','USDCHF','AUDUSD']; // 1 2 3 10
  var _timeframes = ['M5','M15','M30','H1','D1'];

  var _dropdown_currency_item_selected = 'EURUSD';
  var _dropdown_timeframe_item_selected = 'D1';

  var signal_open = "";
  var signal_tp = "";

  final double  _minimumPadding = 5.0;

  bool swap = false;
  var swap_state = 0;

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  bool _isLoadingFX = false;

  predictFX(String fxpair, tf, token) async {

    var jsonResponse = null;
    var _server = "XXX.XXX.XXX.XXX";

    var response = await http.get(_server+"/api/predict?pair="+fxpair+"&tf="+tf+'&token='+token);
    print(response.body);
    if(response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoadingFX = false;
        });
        sharedPreferences.setString("prediction", jsonResponse['prediction']);
        // TODO ADD PROBABILITY HERE
        //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      }
    }
    else {
      setState(() {
        _isLoadingFX = false;
      });
      print(response.body);
    }
  }

  bool _isLoadingInv = false;

  predictInv(String fxpair, tf, token) async {

    var jsonResponse = null;
    var _server = "http://s2.efdev.ru";

    var response = await http.get(_server+"/api/invpredict?pair="+fxpair+"&tf="+tf+'&token='+token);
    print(response.body);
    if(response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoadingInv = false;
        });
        sharedPreferences.setString("recommend_inv", jsonResponse['recommendation']);
        sharedPreferences.setString("probability_inv", jsonResponse['probability']);

        // TODO ADD PROBABILITY HERE
        //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      }
    }
    else {
      setState(() {
        _isLoadingInv = false;
      });
      print(response.body);
    }
  }

  bool _isLoadingSig = false;

  check_signal(String fxpair, tf, token, entry, takeprofit) async {

    var jsonResponse = null;
    var _server = "http://s2.efdev.ru";

    var response = await http.get(_server+"/api/sigeval?pair="+fxpair+"&tf="+tf+'&token='+token+'&open='+entry+'&tp='+takeprofit);
    print(response.body);
    if(response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoadingSig = false;
        });
        sharedPreferences.setString("prediction_sig", jsonResponse['prediction']);
        sharedPreferences.setString("signalreccomend", jsonResponse['signalreccomend'].toString());
        sharedPreferences.setString("signal_probability", jsonResponse['signal_probability']);
        // TODO ADD PROBABILITY HERE
        //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      }
    }
    else {
      setState(() {
        _isLoadingSig = false;
      });
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {

    // -----

    //var OnebuttonText = 'Predict Trend';

    Widget swapWidget;
    if (swap) {
      if (swap_state == 1) {
        // IMAGE UP
        Random random = Random();

        var ArIcon;

        if (sharedPreferences.get('prediction') == 'UP') {
          ArIcon = Icons.arrow_upward;
        }
        else {
          ArIcon = Icons.arrow_downward;
        };

        swapWidget = new Container(
            margin: EdgeInsets.all(_minimumPadding * 2),
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Text('Result from neural network:\n',
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  Text('Currency pair:' + sharedPreferences.get('fxpair')),
                  Text('TimeFrame: ' + sharedPreferences.get('tf')),
                  Text('Prediction: ' + sharedPreferences.get('prediction')),
                  //Text('Probability: '+((75+random.nextInt(18))/100).toString()),
                  Icon(ArIcon),

                  Text('Result from investing:\n',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Trade recommendation: ' +
                      sharedPreferences.get('recommend_inv')),
                  Text('Trade signal strength: ' +
                      sharedPreferences.get('probability_inv')),


                  Text('\n'),
                  RaisedButton(
                      onPressed: () {
                        setState(() {
                          swap = !swap;
                        });
                      },
                      child: Text("Reset"))
                ]

            )
        );

        //swap = !swap;
        //OnebuttonText = 'Predict Trend';
      }
      else if (swap_state == 2) {
        Random random = Random();

        swapWidget = new Container(
            margin: EdgeInsets.all(_minimumPadding * 2),
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Text('Result from neural network:\n',
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  Text('Currency pair:' + sharedPreferences.get('fxpair')),
                  Text('TimeFrame: ' + sharedPreferences.get('tf')),
                  Text('Prediction: ' + sharedPreferences.get('prediction')),  // signalreccomend
                  //Text('Probability: '+((75+random.nextInt(18))/100).toString()),
                  //Icon(ArIcon),

                  Text('Signal:\n',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Open: ' + signal_open+' - TP: '+signal_tp),
                  Text('Signal recommendation: ' + sharedPreferences.get('signalreccomend'),style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Trade signal strength: ' + sharedPreferences.get('signal_probability')),


                  Text('\n'),
                  RaisedButton(
                      onPressed: () {
                        setState(() {
                          swap = !swap;
                        });
                      },
                      child: Text("Reset"))
                ]

            )
        );

      }

    } else {
      swapWidget = new Container(
          margin: EdgeInsets.all(_minimumPadding * 2),
          child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Icon(Icons.cloud_download),
                Center(
                  child: Text('\nPress Predict to start/restart')
                ),

              ]
          )
      );
    };


    var swapTile = new ListTile(
      title: swapWidget,
    );

    // -----

    final EntryController = TextEditingController();
    final TakeProfitController = TextEditingController();


    return Scaffold(
      appBar: AppBar(
        title: Text("Neuro FX Predictor", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(_minimumPadding * 2),
        child: ListView(
          children: <Widget>[

           // getImageAsset(),

            Padding(
                padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child: TextField(
                  controller: EntryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Buy target',
                      hintText: 'Enter your entry point',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                )),

            Padding(
                padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child: TextField(
                  controller: TakeProfitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Take Profit',
                      hintText: 'as price point',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                )),

            Padding(
                padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child: Row(
                  children: <Widget>[

                    Expanded(child: DropdownButton<String>(
                      items: _timeframes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),

                      value: this._dropdown_timeframe_item_selected,

                      onChanged: (String newValueSelected) {
                        sharedPreferences.setString("tf", newValueSelected);
                        setState(() {
                          this._dropdown_timeframe_item_selected = newValueSelected;
                        });

                      },

                    )),

                    Container(width: _minimumPadding * 5,),

                    Expanded(child: DropdownButton<String>(
                      items: _currencies.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),

                      value: this._dropdown_currency_item_selected,

                      onChanged: (String newValueSelected) {
                        sharedPreferences.setString("fxpair", newValueSelected);
                        // TODO selected value somehow
                        setState(() {
                          this._dropdown_currency_item_selected = newValueSelected;
                        });

                      },

                    ))


                  ],
                )),

            Padding(
                padding: EdgeInsets.only(bottom: _minimumPadding, top: _minimumPadding),
                child: Row(children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Predict Trend'),
                      onPressed: () {
                        predictFX(sharedPreferences.get('fxpair'), sharedPreferences.get('tf'), sharedPreferences.get('token'));
                        predictInv(sharedPreferences.get('fxpair'), sharedPreferences.get('tf'), sharedPreferences.get('token'));
                        setState((){
                          swap = !swap;
                          swap_state = 1;
                         // OnebuttonText = 'Reset';
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: RaisedButton(
                      child: Text('Evaluate Signal'),
                      onPressed: () {
                        signal_open = EntryController.text;
                        signal_tp = TakeProfitController.text;
                        check_signal(sharedPreferences.get('fxpair'), sharedPreferences.get('tf'), sharedPreferences.get('token'),EntryController.text,TakeProfitController.text);
                        setState((){
                          swap = !swap;
                          swap_state = 2;
                          // OnebuttonText = 'Reset';
                        });
                      },
                    ),
                  ),

                ],)),

            //Padding(
            //  padding: EdgeInsets.all(_minimumPadding * 2),
            //  child: Text('Prediction: '),
            //),

            swapTile

          ],
        ),
      ),

    );
  }


  //  body: Center(child: Text( sharedPreferences.getString("token") )),   //"Main Page")),
    //  drawer: Drawer(),
   // );
 // }

  Widget getImageAsset() {

    AssetImage assetImage = AssetImage('images/money.png');
    Image image = Image(image: assetImage, width: 125.0, height: 125.0,);

    return Container(child: image, margin: EdgeInsets.all(5.0 * 10),);
  }
}





/*
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodeversitas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}

 */
