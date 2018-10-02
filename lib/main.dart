
// TODO: Manual data entry isnt working
// TODO: Create a 'switch' button to reverse currencies

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/rendering.dart';

import 'package:shared_preferences/shared_preferences.dart';

var listValues = ['1','11','20','50','100','250'];

String fromCurrency = 'USD';
String toCurrency = 'AUD';
var _denoms;
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
    "currencyName": 'Euro Dollars',
    "currencySymbol": 'E',
    "currencyID": 'EUR'
},
{
  "currencyName": 'Japanese Yen',
  "currencySymbol": 'Y',
  "currencyID": 'JPY'
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

// Denoms should have been loaded from prefs - if it hasnt, initialise a basic set
  if (_denoms == null){
    print ('Denoms is null after preferences read');
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
    _readPreferences();
  }

  @override
  void dispose(){
    super.dispose();
  }

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
                setState(() {
                  _getExchangeRate();
                });
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
                new Text( fromCurrency ,style: textTheme.headline,
                    textAlign: TextAlign.right),
              ),

              new Container(
                width: 130.0,
                child:
                new Text( toCurrency , style: textTheme.headline, textAlign: TextAlign.right),

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
          new Expanded(
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
              )
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('AwayCurrency', currencyID);
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
            ),

            new ListTile(
              title: new Text("Denominations"),
              onTap: () {
                // Push currency list
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new DenominationsPage()),
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

  if (fromCurrency == null){
    fromCurrency = 'USD';
  }

  if (toCurrency == null) {
    toCurrency = 'AUD';
  }

  //print ("From: " + fromCurrency);
  //print ("To: " + toCurrency);

  var fromToCurrency = fromCurrency + "_" + toCurrency;
  var url = 'https://free.currencyconverterapi.com/api/v5/convert?q=' +
      fromToCurrency;
  var httpClient = new HttpClient();

  try {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      var jsonString = await response.transform(utf8.decoder).join();
      //print(jsonString);
      Map<String, dynamic> decodedMap = json.decode(jsonString);
      _exchangeRate = decodedMap['results'][fromToCurrency]['val'];
     // print("Exchange Rate is " + decodedMap['results'][fromToCurrency]['val']);
      _lastUpdated = new DateTime.now();
    } else {
      print ('Error getting API data address:\nHttp status ${response.statusCode}');
    }
  } catch (exception) {
    print ('Failed getting API data');
    print (exception.toString());
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
          title: new Text("Home Currency"),
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
          title: new Text("Away Currency"),
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
          title: new Text("Denominations"),
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
                        print ('Removed from list' + items.toString());
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
            )
        )
    ],
        )
    );
  }
}

