// Issues :-
// Reading preferences on startup doesnt refresh the screen and get the currencies correctly
// Manual data entry isnt working

//To do - list currencies
// Query currencies from site on startup
// Choose base currency
// Choose conversion currency


import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert' show utf8, json;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class HomeCurrencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Home Currency"),
        ),
        body:
        new ListView(
          children: <Widget>[
            new ListTile(
                title: new Text("AUD"),
                onTap: () {
    
                }
            )
          ],
        )
    );


  }
}

class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return new Scaffold(
    appBar: new AppBar(
        title: new Text("Settings"),
      ),
    body:
    new ListView(
            children: <Widget>[
              new ListTile(
                  leading: new Icon(Icons.attach_money),
                  title: new Text ("Home Currency"),
                onTap: ()
                  {
                     // Push currency list
                      Navigator.push(
                        context,
                        new MaterialPageRoute(builder: (context) => new HomeCurrencyPage()),
                      );
                    },

              ),
              new ListTile(
                  leading: new Icon(Icons.attach_money),
                  title: new Text ("Away Currency"),
                  onTap: ()
                  {
                    // Pick currency list
                  }
              ),
            ],
          ),
    );

  }
}


class MyAppState extends State<MyApp> {
  final _biggerFont = const TextStyle(fontSize: 24.0);
  double _exchangeRate = 1.0;
  var _fromCurrency = 'AUD' ;
  var _toCurrency  = 'AUD';

  var _lastUpdated = new DateTime.now();

  var amount1 = 1;
  var amount2 = 10;
  var amount3 = 20;
  var amount4 = 50;
  var amount5 = 100;

  //Future<Null>
  _readPrefs() async {
  // Open the shared preferences and find our currencies.
     SharedPreferences prefs = await SharedPreferences.getInstance();
    _fromCurrency = (prefs.getString('fromCurrency') ?? 'EUR');
    _toCurrency = (prefs.getString('toCurrency')?? 'AUD');
  }

  _savePrefs(var homeOrAway, var currency) async {
    // Save the preferences as required
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(homeOrAway, currency);
  }

  _getExchangeRate() async {
    // Get the exchange rate from free.currencyconverterapi.com
    // query = from_to . e.g AUD_USD
    // Returns a double value
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fromCurrency = (prefs.getString('fromCurrency') ?? 'EUR');
    _toCurrency = (prefs.getString('toCurrency')?? 'AUD');

    var fromToCurrency = _fromCurrency + "_" + _toCurrency;

    var url = 'https://free.currencyconverterapi.com/api/v5/convert?q=' +
        fromToCurrency;
    var httpClient = new HttpClient();

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var jsonString = await response.transform(utf8.decoder).join();
        print(jsonString);
        Map<String, dynamic> decodedMap = json.decode(jsonString);
        _exchangeRate = decodedMap['results'][fromToCurrency]['val'];
        print(decodedMap['results'][fromToCurrency]['val']);
        _lastUpdated = new DateTime.now();
      } else {
        print ('Error getting API data address:\nHttp status ${response.statusCode}');
      }
    } catch (exception) {
      print ('Failed getting API data');
      print (exception.toString());
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _exchangeRate = result;

    });
  }

  //Run this at app startup
  @override
  void initState(){
    super.initState();
    _readPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Travel Currency Cheatsheet'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: ()
              {
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new SettingsPage()),
                );
              },
            ),
          ],
      ),

      body: _buildScreen(),
    );
  }

  void _onPressed() {
    setState(() {
      _exchangeRate = double.parse(_controller.text);
      print(_exchangeRate);
      print ('Last updated is' + _lastUpdated.toString());
    }
    );
  }

  final TextEditingController _controller = new TextEditingController();

  Widget _buildScreen() {
    // Build the screen

    //Set the use of text themes
    final TextTheme textTheme = Theme.of(context).textTheme;
    //new Text('Display 3', style: textTheme.display3),
    //new Text('Display 2', style: textTheme.display2),
    //new Text('Display 1', style: textTheme.display1),
    //new Text('Headline', style: textTheme.headline),
    //new Text('Title', style: textTheme.title),
    //new Text('Subheading', style: textTheme.subhead),
    //new Text('Body 2', style: textTheme.body2),
    //new Text('Body 1', style: textTheme.body1),
    //new Text('Caption', style: textTheme.caption),
    //new Text('BUTTON', style: textTheme.button),

    return new Container(
      padding: new EdgeInsets.all(32.0),
      child: new Column(
        children: [

            new Row(
              // Header
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Text( _fromCurrency ,style: textTheme.headline),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new Text( _toCurrency , style: textTheme.headline),
                  ],
                )

              ],
            ),

            new Divider(height: 32.0, color: Colors.black),

            new Row(
              children: <Widget>[

                // This is broken! Not sure why. Needs debugging. This is the hook for the manual rate.

               // new TextField(
//                  controller: _controller,
  //                keyboardType: TextInputType.number,
                  //decoration: new InputDecoration(
              //      labelText: 'Exchange rate',
                  //),
    //            ),
              ],
            ),



            new Row(
              //Detail row 1
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                new Column(
                  children: <Widget>[
                    new Text(amount1.toString(),style:_biggerFont),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new Text((amount1 *_exchangeRate).toStringAsFixed(4), style:_biggerFont),
                  ],
                )

              ],

            ),


            new Row(
              // Last update text
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                new Text('Last updated: ' +
                    _lastUpdated.day.toString() + '/' +
                    _lastUpdated.month.toString() + '/' +
                    _lastUpdated.year.toString() + ' ' +
                    _lastUpdated.hour.toString() + ':' +
                    _lastUpdated.minute.toString() + ' ' +
                    _lastUpdated.timeZoneName.toString()
                    ,textScaleFactor: .8),

              ],
            ),


            new Divider(height: 32.0, color: Colors.black),

            new Row(
              //Detail row 2
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                new Column(
                  children: <Widget>[
                    new Text(amount2.toString(), style:_biggerFont),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new Text((amount2 *_exchangeRate).toStringAsFixed(2), style:_biggerFont),
                  ],
                )

              ],

            ),


            new Row(
              //Detail row 3
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                new Column(
                  children: <Widget>[
                    new Text(amount3.toString(),style:_biggerFont),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new Text((amount3 *_exchangeRate).toStringAsFixed(2), style:_biggerFont),
                  ],
                )

              ],

            ),

            new Row(
              //Detail row 4
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                new Column(
                  children: <Widget>[
                    new Text(amount4.toString(),style:_biggerFont),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new Text((amount4 *_exchangeRate).toStringAsFixed(2), style:_biggerFont),
                  ],
                )

              ],

            ),

            new Row(
              //Detail row 5
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                new Column(
                  children: <Widget>[
                    new Text(amount5.toString(),style:_biggerFont),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new Text((amount5 *_exchangeRate).toStringAsFixed(2), style:_biggerFont),
                  ],
                )

              ],

            ),

            new Divider(height: 32.0, color: Colors.black),

            new Row(
              //Total row
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                new Column(
                  children: <Widget>[
                    new RaisedButton(
                        child: new Text('Manual Rate'),

                        onPressed: (){_onPressed();}),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new RaisedButton(
                      child: new Text('Web Rate'),
                      onPressed: _getExchangeRate,),
                  ],
                )

              ],

            ),



        ],
      ),
    );
  } // Build screen
} // MyApp