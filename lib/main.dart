import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        title: "the qouto day",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String _url = "https://api.quotable.io/random";
  late String _imageUrl = "https://source.unsplash.com/random/";
  late StreamController _streamController;
  late Stream _stream;
  late Response response;
  int counter = 0;

  getQuotes() async {
    _newImage();
    _streamController.add("waiting");
    response = await get(Uri.parse(_url));
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    final _streamController = StreamController();
    final _stream = _streamController.stream;
    getQuotes();
  }

  void _newImage() {
    setState(() {
      _imageUrl = 'https://source.unsplash.com/random/$counter';
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return Scaffold(
        backgroundColor: Colors.brown,
        appBar: AppBar(
          title: Center(child: Text(widget.title)),
        ),
        body: Center(
          child: StreamBuilder(
              stream: _stream,
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                if (snapshot.data == "waiting") {
                  return Center(child: Text("Waiting of the Quotes....."));
                }
                return GestureDetector(
                  onDoubleTap: () {
                    getQuotes();
                  },
                  child: Stack(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5), BlendMode.darken),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/loading.gif',
                          image: _imageUrl,
                          fit: BoxFit.fitHeight,
                          width: double.maxFinite,
                          height: double.maxFinite,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Center(
                            child: Text(
                          snapshot.data['content'].toString().toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 0.8,
                              fontSize: 25.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 50.0),
                            child: Center(
                                child: Text(
                              "-" +
                                  snapshot.data['author']
                                      .toString()
                                      .toUpperCase(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  letterSpacing: 0.8,
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
        ));
  }
}
