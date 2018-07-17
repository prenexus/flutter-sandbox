// Issues :-
// Reading preferences on startup doesnt refresh the screen and get the currencies correctly
// Manual data entry isnt working

//To do - list currencies
// Query currencies from site on startup
// Choose base currency
// Choose conversion currency

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async' show Future;
//import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_search/material_search.dart';


String fromCurrency = 'USD';
String toCurrency = 'AUD';
var _exchangeRate;
var _lastUpdated;

const List _listOfCurrencies = [
{
    "currencyID": 'AUD',
    "currencyName": 'Australian Dollar',
    "currencySymbol": '\$'
},
{
    "currencySymbol": '\$',
    "currencyName": 'US Dollars',
    "currencyID": 'USD'
},
{
    "currencyName": 'Euro',
    "currencySymbol": 'E',
    "currencyID": 'EUR'
}

];

const _listValues = [1,10,20,50,100,250];

class CurrencyWidget extends StatelessWidget{
  final String currencyName;
  final String currencySymbol;
  final String currencyID;

  const CurrencyWidget({Key key, this.currencyName, this.currencySymbol, this.currencyID}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.grey), color: Colors.white70),
        margin: new EdgeInsets.symmetric(vertical: 1.0),
        child: new ListTile(
          leading: new Text(currencySymbol),
          title: new Text(currencyName),
          subtitle: new Text(currencyID),
          ),
    );
  }
}

//This class displays the drawer used on the main pages. This is our settings page
class DrawerOnly extends StatelessWidget{
  @override
  Widget build (BuildContext context) {
    return new Drawer(
      child: new ListView(
          children: <Widget>[
            new DrawerHeader(
              child: new Text('Settings'),
              decoration: new BoxDecoration(color: Colors.blue),
            ),

            new ListTile(
              title: new Text("Home Currency"),
              onTap: () {
                // Push currency list
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new HomeCurrencyPage()),
                );
              },
            ),

            new ListTile(
              title: new Text("Away Currency"),
              onTap: () {
                // Push currency list
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new AwayCurrencyPage()),
                );
              },
            )

          ]
      ),
    );
  }
}


// This routine returns a rate for a given currency pair from free.currencyconverterapi.com
_getExchangeRate() async {

  var fromToCurrency = fromCurrency + "_" + toCurrency;

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

}

// Main function
void main() async {
  // Retrieve list of currencies
  await _getExchangeRate();

  // Display the app
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
        //drawer: new DrawerOnly(),
        appBar: new AppBar(
          title: new Text("Home Currency"),
        ),
        body:
          new ListView.builder(itemBuilder: (BuildContext context, int index){
            return new CurrencyWidget(
              currencyID: _listOfCurrencies[index]['currencyID'],
              currencyName: _listOfCurrencies[index]['currencyName'],
              currencySymbol: _listOfCurrencies[index]['currencySymbol'],
            );
            },
            itemCount: _listOfCurrencies.length,
          )
    );
  }
}

// Display the settings pages
class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return new Scaffold(
      drawer: new DrawerOnly(),
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

  var amount1 = 1;
  var amount2 = 10;
  var amount3 = 20;
  var amount4 = 50;
  var amount5 = 100;

  //Run this at app startup
  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose(){

    super.dispose();
  }

  // Get the exchange rate from free.currencyconverterapi.com
  // query = from_to . e.g AUD_USD
  // Returns a double value

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      drawer: new DrawerOnly(),
      appBar: new AppBar(
        title: new Text('Currency Cheatsheet'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: ()
                {
                  //Need to refresh the widget?
                  //setState(_getExchangeRate());
                  _getExchangeRate();
                }
          ),

        ],
      ),

      body: _buildScreen(fromCurrency, toCurrency),
    );
  }

  //final TextEditingController _controller = new TextEditingController();

  Widget _buildScreen(String fromCurrency, String toCurrency) {
    // Build the screen
    print ("From Currency is currently:" + fromCurrency);
    print ("To currency is currently: " + toCurrency);
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
                    new Text( fromCurrency ,style: textTheme.headline),
                  ],
                ),

                new Column(
                  children: <Widget>[
                    new Text( toCurrency , style: textTheme.headline),
                  ],
                )

              ],
            ),

            new Divider(height: 32.0, color: Colors.black),

            new Row(
              children: <Widget>[


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



        ],
      ),
    );
  } // Build screen
} // MyApp