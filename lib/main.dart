import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?format=json&key=039f956e";

void main() async {
  runApp(MaterialApp(
      title: 'Conversor de moeda',
      theme: ThemeData(
        accentColor: Colors.amberAccent,
        hintColor: Colors.white,
        primaryColor: Colors.amber,
      ),
      home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    if (text == null || text.isEmpty) {
      dolarController.text = "";
      euroController.text = "";
    } else {
      double real = double.parse(text);
      dolarController.text = (real / dolar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsPrecision(2);
    }
  }

  void _dolarChanged(String text) {
    if (text == null || text.isEmpty) {
      realController.text = "";
      euroController.text = "";
    } else {
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    if (text == null || text.isEmpty) {
      realController.text = "";
      dolarController.text = "";
    } else {
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            "\$Conversor de moedas\$",
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.amberAccent,
          centerTitle: true,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
          ),
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Carregando Dados...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  );

                case ConnectionState.done:
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.attach_money,
                                  size: 150.0,
                                  color: Colors.amberAccent,
                                ),
                                Divider(
                                  color: Colors.transparent,
                                ),
                                buildTextField("Reais", "R\$", realController,
                                    _realChanged),
                                Divider(
                                  color: Colors.transparent,
                                ),
                                buildTextField("Doláres", "\$", dolarController,
                                    _dolarChanged),
                                Divider(
                                  color: Colors.transparent,
                                ),
                                buildTextField(
                                    "Euros", "€", euroController, _euroChanged)
                              ],
                            ),
                          )));

                default:
                  if (snapshot.hasError) {
                    print(snapshot);
                    return Center(
                      child: Text(
                        "Deu erro...",
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return Text("teste");
                  }
              }
            }));
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(String labelText, String prefixText,
    TextEditingController controller, Function onChanged) {
  return TextField(
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.amberAccent),
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16)),
      prefixIcon: Icon(Icons.attach_money),
      prefixText: prefixText,
    ),
    style: TextStyle(color: Colors.white),
    textAlignVertical: TextAlignVertical(y: 0),
    controller: controller,
    onChanged: onChanged,
    keyboardType: TextInputType.number,
  );
}
