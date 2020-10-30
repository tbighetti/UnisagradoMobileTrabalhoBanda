import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

void main() => runApp(AppBanda());

/// This is the main application widget.
class AppBanda extends StatelessWidget {
  static const String _title = 'Classificação de Bandas';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: BandaStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class BandaStatefulWidget extends StatefulWidget {
  BandaStatefulWidget({Key key}) : super(key: key);

  @override
  _BandaStatefulWidgetState createState() => _BandaStatefulWidgetState();
}

/// This is the private State class that goes with BandaStatefulWidget.
class _BandaStatefulWidgetState extends State<BandaStatefulWidget> {
  TextEditingController _controller;
  String _banda;
  double _pontuacao;

  void initState() {
    super.initState();
    _controller = TextEditingController();
    _banda = '';
    _pontuacao = 0;
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    onButtonPressLyrics() async {
      var url =
          'https://classification-lyrics-usc.herokuapp.com/api/v1/classification/band/lyrics';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json = '{"lyrics": "${_controller.value}"}';
      var response = await post(url, headers: headers, body: json);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      // Capturando Response
      String content = response.body;
      if (response.statusCode == 200) {
        print('Response body : ${content}');
        try {
          final parsed = jsonDecode(content).cast<String, dynamic>();
          setState(() {
            _banda = parsed['band'];
            _pontuacao = parsed['proba'];
          });
        } catch (Ex) {
          print("Erro ao decodificar JSON : $Ex");
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Classificação de Bandas'),
      ),
      body: Center(
          child: Column(children: <Widget>[
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Informe parte da letra da música',
          ),
        ),
        RaisedButton(
          onPressed: onButtonPressLyrics,
          child: const Text('Consultar', style: TextStyle(fontSize: 20)),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(this._banda),
          ),
        ),
        Card(
          child: ListTile(
            leading: CircularProgressIndicator(value: this._pontuacao),
            title: Text((this._pontuacao * 100).toStringAsFixed(0) + "%"),
          ),
        )
      ])),
    );
  }
}
