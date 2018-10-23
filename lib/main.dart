// TODO: Make the fonts nicer to look at - use Table layout to get a better layout
// TODO: Help pages on startup
// TODO: Manual rate entry
// TODO: Move _getExchange rate (or another function) inside the widget to see if that fixes refresh bugs (Stateful widget stuff)

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

var listValues = ['1','10','20','50','100','250'];

String fromCurrency = 'USD';
String toCurrency = 'AUD';
var _denoms;
var _exchangeRate;
var _lastUpdated;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


const List _listOfCurrencies = [
{
    "currencyID": 'AUD',
    "currencyName": 'Australian Dollar',
    "currencySymbol": '\$'
},
{
  "currencySymbol": '\$',
  "currencyName": 'US Dollar',
  "currencyID": 'USD'
},
{
  "currencySymbol": '\$',
  "currencyName": 'Canadian Dollar',
  "currencyID": 'CAD'
},

{
  "currencyName": 'Euro Dollar',
  "currencySymbol": '\€',
  "currencyID": 'EUR'
},

{
  "currencyID": 'GBP',
  "currencyName": 'Great British Pound',
  "currencySymbol": '\£'
},

{
  "currencyID": 'NZD',
  "currencyName": 'New Zealand Dollar',
  "currencySymbol": '\$'
},

{
  "currencyID": 'CNY',
  "currencyName": 'Chinese Yuan',
  "currencySymbol": '\¥'
},

{
  "currencyName": 'Japanese Yen',
  "currencySymbol": '\¥',
  "currencyID": 'JPY'
},

{
  "currencyID": 'INR',
  "currencyName": 'Indian Rupee',
  "currencySymbol": '\₹'
},

{
  "currencyID": 'MXN',
  "currencyName": 'Mexican Peso',
  "currencySymbol": '\$'
},

{
  "currencyName": 'Rawandan Franc',
  "currencySymbol": 'F',
  "currencyID": 'RWF'
},

{
  "currencyName": 'Ugandan Shilling',
  "currencySymbol": 'S',
  "currencyID": 'UGX'
}

];


// Main function
void main() async {
  // Retrieve list of currencies
  await _readPreferences();
  await _getExchangeRate();

// Denoms should have been loaded from prefs - if it hasn't, initialise a basic set
  if (_denoms == null){
    _denoms = listValues;
  }

  // Display the app
  debugPaintSizeEnabled=false;
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp>  {
  final _biggerFont = const TextStyle(fontSize: 24.0);

  //Run this at app startup
  @override
  void initState(){
    super.initState();

    setState(() {
      _readPreferences();
      _handleRefresh();
    });

  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 1));
    setState(() {_getExchangeRate();});
    return null;
  }

  void _switchCurrencies(){
    var switchHome = fromCurrency;
    var switchAway = toCurrency;

    fromCurrency = switchAway;
    toCurrency = switchHome;

    setState(() {_getExchangeRate();});

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      key: _scaffoldKey,
      drawer: new DrawerOnly(),
      appBar: new AppBar(
        title: new Text('Currency Cheatsheet'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: ()
              {
                setState(() {_getExchangeRate();});
              }
          ),
        ],
      ),
      body: _buildScreen(fromCurrency, toCurrency),
    );
  }

  Widget _buildScreen(String fromCurrency, String toCurrency)  {
    // Build the screen

    //Set the use of text themes
    final TextTheme textTheme = Theme.of(context).textTheme;

    return new Container(
      padding: new EdgeInsets.all(32.0),
      child: new Column(
        children: [

          new Row(
            // Header
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Container(
                width: 100.0,
                child:
                    new GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                          new MaterialPageRoute(
                              builder: (context) => new HomeCurrencyPage()),
                        );
                      },
                      child:
                        new Text(fromCurrency ?? '',style: textTheme.headline, textAlign: TextAlign.right),
                    ),
              ),

              new Container(
                width: 50.0,
                child: new IconButton (onPressed: _switchCurrencies,
                  icon: Icon(Icons.compare_arrows),
                )
              ),


              new Container(
                width: 50.0,
                child:
                  new GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                        new MaterialPageRoute(builder: (context) => new AwayCurrencyPage()),
                      );
                    },
                    child:
                      new Text( toCurrency ?? '', style: textTheme.headline, textAlign: TextAlign.right),
                  ),
              ),

            ],
          ),


          new Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Container(
                  width: 100.0,
                  child:
                    new Text("Local", textAlign: TextAlign.right),
                ),

                new Container(
                  width:50.0,
                ),

                new Container(
                  width: 50.0,
                  child:
                    new Text("Home", textAlign: TextAlign.right),
                ),
            ],
          ),

          new Divider(height: 32.0, color: Colors.black),

          new Row(
            //Detail row
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[

              new Container(
                width: 100.0,
                child:
                new Text("1.0000",style:_biggerFont, textAlign: TextAlign.right,),
              ),

              new Container(
                width : 130.0,
                child:
                new Text( (_exchangeRate).toStringAsFixed(4), style:_biggerFont, textAlign: TextAlign.right,),
              )
            ],
          ),

          new Divider(height: 32.0, color: Colors.black),

          // List the denominations from preferences
          new Expanded(child:
            new RefreshIndicator(
              child : new ListView.builder(
                  padding: EdgeInsets.only(bottom: 8.0),
                  itemBuilder: (BuildContext context, int index)
                  {
                    return new DenomsWidget(
                      denomsAmount: _denoms[index],
                      exchangeRate: _exchangeRate.toString(),
                    );
                  },
                  itemCount: _denoms.length
              ),
              onRefresh: _handleRefresh,
            ),
          ),

          new Divider(height: 32.0, color: Colors.black),

          new Row(
            // Last updated text
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Text('Last updated: ' + DateFormat('dd-MMM-yyyy - kk:mm').format(_lastUpdated),textScaleFactor: .8),
            ],
          ),
        ],
      ),
    );
  } // Build screen
} // MyApp

class DenomsWidget extends StatefulWidget {

  final String denomsAmount;
  final String exchangeRate;

  DenomsWidget({Key key, this.denomsAmount, this.exchangeRate}) : super (key: key);

  @override
  DenomsWidgetState createState() =>
        DenomsWidgetState();
}

class DenomsWidgetState extends State<DenomsWidget>{

  @override
  Widget build(BuildContext context) {
    return Row (
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        Container(
            width: 100.0,
            child:
            new Text(widget.denomsAmount,
                textAlign: TextAlign.right,
                style: new TextStyle(
                    fontSize: 25.0))

        ),
        Container(
          width: 130.0,
          child:
          new Text( (double.parse(widget.denomsAmount) *
              double.parse(widget.exchangeRate)).toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: new TextStyle(
                  fontSize: 25.0)),
        )
      ],
    );
 }
}

class AwayCurrencyWidget extends StatefulWidget {

  final String currencyName;
  final String currencySymbol;
  final String currencyID;

  AwayCurrencyWidget({Key key, this.currencyName, this.currencySymbol, this.currencyID}) : super (key: key);

  @override
  AwayCurrencyWidgetState createState() =>
      AwayCurrencyWidgetState();
}

class AwayCurrencyWidgetState extends State<AwayCurrencyWidget>{

  var _isSelected = false;

  tappedItem(String currencyID) async{
    _isSelected = true;

    //Set the exchange rate to 0 so we dont get a false read
    //_exchangeRate = 0.0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('AwayCurrency', currencyID);
    toCurrency = currencyID;
    await _getExchangeRate();

  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        new Container(
            decoration: new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.grey), color: Colors.white70),
            margin: new EdgeInsets.symmetric(vertical: 1.0),
            child: new ListTile(
                leading: new Text(widget.currencyID),
                title: new Text(widget.currencyName),
                subtitle: new Text(widget.currencySymbol),
                trailing: new Icon (_isSelected ? Icons.check : null),

                onTap: () {
                  setState(() {
                    tappedItem(widget.currencyID);
                    Navigator.pop(context);
                  });
                }
            )
        ),
      ],
    );
  }
}

class CurrencyWidget extends StatefulWidget {

  final String currencyName;
  final String currencySymbol;
  final String currencyID;

  CurrencyWidget({Key key, this.currencyName, this.currencySymbol, this.currencyID}) : super (key: key);

  @override
  CurrencyWidgetState createState() =>
      CurrencyWidgetState();
}

class CurrencyWidgetState extends State<CurrencyWidget>{

  var _isSelected = false;
  var checkCurrency = 'USD';

  tappedItem(String currencyID) async{
     _isSelected = true;

     SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.setString('HomeCurrency', currencyID);

     //Set the exchange rate to 0 so we dont get a false read
     //_exchangeRate = 0.0;
     await _readPreferences();
     await _getExchangeRate();

  }

  @override
  Widget build(BuildContext context) {

    return Column(
    children: [
        new Container(
        decoration: new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.grey), color: Colors.white70),
        margin: new EdgeInsets.symmetric(vertical: 1.0),
        child: new ListTile(
          leading: new Text(widget.currencyID),
          title: new Text(widget.currencyName),
          subtitle: new Text(widget.currencySymbol),
          trailing: new Icon (_isSelected ? Icons.check : null),

          onTap: () {
            setState(() {
                tappedItem(widget.currencyID);
                Navigator.pop(context);
            });
          }
         )
        ),
    ],
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
            new Container(height: 100.0, child:
            new DrawerHeader(
              padding: EdgeInsets.only(left: 10.0, top: 50.0),
              child: new Text('Settings',
                  style: new TextStyle(fontSize: 23.0),
              ),
              decoration: new BoxDecoration(color: Colors.blue),
            ),
            ),
         new ListTile(
              title: new Text("Local Currency", style: new TextStyle(fontSize: 16.0),),
              leading: const Icon(Icons.airplanemode_active),
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
              title: new Text("Home Currency", style: new TextStyle(fontSize: 16.0),),
              leading: const Icon(Icons.home),
              onTap: () {
                // Push currency list
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new AwayCurrencyPage()),
                );
              },
            ),

            new ListTile(
              title: new Text("Currency List", style: new TextStyle(fontSize: 16.0),),
              leading: const Icon(Icons.monetization_on),
              onTap: () {
                // Push currency list
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new DenominationsPage()),
                );
              },
            ),

            new ListTile(
              title: new Text("Help", style: new TextStyle(fontSize: 16.0),),
              leading: const Icon(Icons.help),
              onTap: () {
                // Push currency list
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new HelpPage()),
                );
              },
            )

        ]
      ),
    );
  }
}

_readPreferences() async{

  SharedPreferences prefs = await SharedPreferences.getInstance();

  fromCurrency = prefs.getString('HomeCurrency');
  toCurrency = prefs.getString('AwayCurrency');
  _denoms = prefs.getStringList('Denominations');

  if (_denoms == null)
    {
      _denoms = listValues;
    }

}

// This routine returns a rate for a given currency pair from free.currencyconverterapi.com
_getExchangeRate() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (fromCurrency == null){
    fromCurrency = 'USD';
  }

  if (toCurrency == null) {
    toCurrency = 'AUD';
  }

  var fromToCurrency = fromCurrency + "_" + toCurrency;
  var url = 'https://free.currencyconverterapi.com/api/v5/convert?q=' +
      fromToCurrency;
  var httpClient = new HttpClient();

  try {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      var jsonString = await response.transform(utf8.decoder).join();

      Map<String, dynamic> decodedMap = json.decode(jsonString);
      _exchangeRate = decodedMap['results'][fromToCurrency]['val'];
      _lastUpdated = new DateTime.now();

      print ('Exchange rate is ' + _exchangeRate.toString());
      print ('Currency pair is ' + fromToCurrency);

      //Save the keypair exchange rate and last updated date
      prefs.setDouble(fromToCurrency, _exchangeRate);
      prefs.setString(fromToCurrency + 'date', _lastUpdated.toString() );

      //_scaffoldKey.currentState.initState();

    } else {
      //print ('Error getting API data address:\nHttp status ${response.statusCode}');
      // Assume no connection to web service
      // Read rates from saved prefs
      _exchangeRate = prefs.getDouble(fromCurrency + "_" + toCurrency) ?? 0.0;

      // Can only store strings, so read last updated date into a string
      var _lastUpdatedString = prefs.getString(fromCurrency + "_" + toCurrency + "date") ?? new DateTime.now().toString();
      // Parse last updated back to a date/time object
      _lastUpdated = DateTime.parse(_lastUpdatedString);
    }
  } catch (exception) {
    print ('Failed getting API data');
    print (exception.toString());

    _scaffoldKey.currentState.showSnackBar(SnackBar(content: new Text('Error. Returning last known rates'),duration: new Duration(seconds: 5),));
    _exchangeRate = prefs.getDouble(fromCurrency + "_" + toCurrency) ?? 0.0;

    // Can only store strings, so read last updated date into a string
   var _lastUpdatedString = prefs.getString(fromCurrency + "_" + toCurrency + "date") ?? new DateTime.now().toString();
    // Parse last updated back to a date/time object
    _lastUpdated = DateTime.parse(_lastUpdatedString);

  }

}


class HomeCurrencyPage extends StatefulWidget {
  // This class displays the list of denominations for selected currency
  // Users can add or remove the denominations they need

  @override
  HomeCurrencyPageWidgetState createState() =>
      HomeCurrencyPageWidgetState();
}

class HomeCurrencyPageWidgetState extends State<HomeCurrencyPage>{

  //class HomeCurrencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        appBar: new AppBar(
          title: new Text("Local Currency"),
        ),
        body:
          new ListView.builder(itemBuilder: (BuildContext context, int index){
            return new CurrencyWidget(
              currencyName: _listOfCurrencies[index]['currencyName'],
              currencyID: _listOfCurrencies[index]['currencyID'],
              currencySymbol: _listOfCurrencies[index]['currencySymbol'],
                );
            },
            itemCount: _listOfCurrencies.length,
          )
    );
   }
}

class AwayCurrencyPage extends StatefulWidget {
  // This class displays the list of denominations for selected currency
  // Users can add or remove the denominations they need

  @override
  AwayCurrencyPageWidgetState createState() =>
      AwayCurrencyPageWidgetState();
}

class AwayCurrencyPageWidgetState extends State<AwayCurrencyPage>{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        appBar: new AppBar(
          title: new Text("Home Currency"),
        ),
        body:
        new ListView.builder(itemBuilder: (BuildContext context, int index){
          return new AwayCurrencyWidget(
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


class HelpPage extends StatefulWidget {
  // This class displays the list of denominations for selected currency
  // Users can add or remove the denominations they need

  @override
  HelpPageWidgetState createState() =>
      HelpPageWidgetState();
}

class HelpPageWidgetState extends State<HelpPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Help"),
      ),
      body:
      new Container(
        padding: new EdgeInsets.all(32.0),
        child: 
          new Column(

            children: <Widget>[
              new RichText(text: TextSpan(style: new TextStyle(fontSize: 16.0, color:Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: 'Currency Cheatsheet\n\n', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    TextSpan(text: 'A simple currency converter designed to show common denominations at a glance.'),
                    TextSpan(text: '\n\n', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Usage\n\n', style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Select the currency where you are currently located. \n\mNext, choose the currency of the country you are from.\n\n'),
                    TextSpan(text: 'Modify the currency list to show your common conversions. You might like to pick the cost of a coffee or a burger\n\n'),
                    TextSpan(text: 'Refresh to get the latest conversion rate'),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class DenominationsPage extends StatefulWidget {
  // This class displays the list of denominations for selected currency
  // Users can add or remove the denominations they need

  @override
  _DenominationsPageWidgetState createState() =>
      _DenominationsPageWidgetState();
}

class _DenominationsPageWidgetState extends State<DenominationsPage>{

  var items = _denoms;

  // Save the list of denominations to the preferences file
  _saveList() async{

    List<int> intList = new List();

    //Extract string list and parse to int list
    for (var i=0; i < items.length; i++)
      {
        intList.add(int.parse(items[i]));
      }

      //Sort the new list
      intList.sort();

    //Build the array ready to repopulate
    List<String> strList = new List();

    // Pop it back into string format so we can save it
    for (var q=0; q < intList.length; q++){
      strList.add(intList[q].toString());
    }

    //Set items to the newly built strList
    items = strList;

    //Save it to disk
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('Denominations', items);
    await _readPreferences();

  }

  final TextEditingController eCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //drawer: new DrawerOnly(),
        appBar: new AppBar(
          title: new Text("Currency List"),
        ),

        body:
        new Column(
        children: <Widget>[
          new TextField(
            controller: eCtrl,
            decoration: InputDecoration(
                //border: InputBorder.none,
                labelText: 'Add new value'
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (text) {
              items.add(text);
              eCtrl.clear();
              setState(() {_saveList();});
            },
        ),
        new Expanded(child:
       // new RefreshIndicator(child:
            new ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index)
              {
                final item = items[index];

                return Dismissible(
                  key: Key(item),
                  onDismissed: (direction) {
                    setState(() {
                        items.removeAt(index);
  //                      print ('Removed from list' + items.toString());
                        _saveList();

                    });
                    Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("$item removed")));
                  },
                  background: Container(
                      color: Colors.red,
                      alignment: FractionalOffset.centerRight,
                      child: new IconButton(
                          icon: Icon(Icons.delete),
                        color: Colors.black,
                      )

                  ),
                  child: ListTile(title: new Text(
                    '$item',
                    style: new TextStyle(
                        fontSize: 20.0 ),
                  )
                  ),
                );
            },
            ),
      )
    ],
        )
    );
  }

}