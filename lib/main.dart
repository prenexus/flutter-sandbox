import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert' show utf8, json;

//To do - list currencies
// Query currencies from site
// Choose base currency
// Choose conversion currency

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  double _exchangeRate = 1.0;
  var _fromCurrency = 'AUD';
  var _toCurrency = 'USD';


  _getExchangeRate() async {

    // Get the exchange rate from free.currencyconverterapi.com
    // query = from_to . e.g AUD_USD
    // Returns a double value
    var fromToCurrecy = _fromCurrency + "_" + _toCurrency;

    var url = 'https://free.currencyconverterapi.com/api/v5/convert?q='+ fromToCurrecy;
    var httpClient = new HttpClient();

    var result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        print ('Status OK');
        var jsonString = await response.transform(utf8.decoder).join();
        print (jsonString);
        Map<String, dynamic> decodedMap = json.decode(jsonString);
        _exchangeRate = decodedMap['results'][fromToCurrecy]['val'];
        print (decodedMap['results'][fromToCurrecy]['val']);

      } else {
        result =
        'Error getting API data address:\nHttp status ${response.statusCode}';

      }
    } catch (exception) {
      result = 'Failed getting API data';
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    setState(() {
     // _exchangeRate = result;

    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Travel Currency Cheatsheet'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), ),//onPressed: null ),
        ],
      ),

      body: _buildScreen(),
    );  }

  double _rate = 0.00;
  double _usdamount = 100.00;

   void _onPressed()
  {
    setState(() {
      _exchangeRate = double.parse(_controller.text);
      print(_exchangeRate);
    }
    );
  }

    final TextEditingController _controller = new TextEditingController();

    Widget _buildScreen() {
      // Build the screen
      return new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
              children: <Widget>[
                new TextField(
                  controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      labelText: 'Exchange rate',
                    ),

                ),
                new RaisedButton(
                  child: new Text('Manual rate'),

                  onPressed: (){_onPressed();}),
                  //onPressed: _getExchangeRate,),

                new RaisedButton(
                    child: new Text('Web Rate'),

                    //onPressed: (){_onPressed();}),
                  onPressed: _getExchangeRate,),
                new Text('Exchange Rate = '+ _exchangeRate.toString()),
                new Text(_fromCurrency+ ' Amount = \$'+ _usdamount.toString()),
                new Text(_toCurrency +' Amount = \$' + ( _usdamount / _exchangeRate).toStringAsFixed(2)),
              //  new Text(_toCurrency +' Amount = \$' + ( _usdamount / _rate).toString()),

              ],
          )
        )
      );
    }
}