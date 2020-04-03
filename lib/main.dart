import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:letmego/localization.dart';
import 'package:letmego/postal.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [Locale('en'), Locale('el'), Locale('ru')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      title: 'Let me go',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Let me go'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _shortNumber = '8998';
  List<String> _purposes = <String>['1', '2', '3', '4', '5', '6', '7', '8'];

  TextEditingController _controllerPostalCode, _controllerIdPassport;
  String _postalCode = '';
  String _id = '';
  String _purpose = '1';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _controllerPostalCode = TextEditingController(text: _postalCode);
    _controllerIdPassport = TextEditingController(text: _id);
  }

  String _messageText() {
    return "${_purpose} ${_id} ${_postalCode}";
  }

  void _sendSMS() {
    if (window.navigator.userAgent.contains('iPhone')) {
      window.open(
          "sms:" +
              _shortNumber +
              "&body=" +
              Uri.encodeComponent(_messageText()),
          'sms');
    } else if (window.navigator.userAgent.contains('Android')) {
      window.open(
          "sms:" +
              _shortNumber +
              "?body=" +
              Uri.encodeComponent(_messageText()),
          'sms');
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text(AppLocalizations.of(context).translate('on_your_mobile')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('send_message')),
                  Text.rich(TextSpan(
                    text: _messageText(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .apply(fontSizeFactor: 2.0),
                  )),
                  Text(AppLocalizations.of(context)
                      .translate('to_short_number')),
                  Text.rich(TextSpan(
                    text: _shortNumber,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .apply(fontSizeFactor: 1.7),
                  )),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Container(
                  child:
                      Text("This application is made for your convinience only "
                          "and it doesn't store any data or messages "
                          "outside of your device."),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text("This application is open source."),
                ),
              ])),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showPosition() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<String>(
              future: Postal().postalCode(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                List<Widget> actions = <Widget>[];

                if (snapshot.hasData) {
                  String postalCode = snapshot.data;
                  children = <Widget>[
                    Text(
                      postalCode,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .apply(fontSizeFactor: 2.0),
                    )
                  ];
                  actions = <Widget>[
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Yes'),
                      onPressed: () {
                        setState(() {
                          _controllerPostalCode.text = postalCode;
                          _postalCode = postalCode;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ];
                } else if (snapshot.hasError) {
                  children = <Widget>[Text('Location failed')];
                  actions = <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ];
                } else {
                  children = <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 30,
                      height: 30,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("getting..."),
                    )
                  ];
                  actions = <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ];
                }
                return AlertDialog(
                  title: Center(child: Text('Your postal code')),
                  content: SingleChildScrollView(
                    child: Column(
                      children: children,
                    ),
                  ),
                  actions: actions,
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
//        actions: <Widget>[
//          DropdownButton<String>(
//            value: _locale,
//            iconSize: 24,
//            elevation: 16,
//            onChanged: (String newValue) {
//              setState(() {
//                _locale = newValue;
//              });
//            },
//            items: <String>["ru", "en", "el"]
//                .map<DropdownMenuItem<String>>((String lang) {
//              return DropdownMenuItem<String>(
//                value: lang,
//                child: Text(lang.toUpperCase()),
//              );
//            }).toList(),
//          ),
//        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 65,
              child: DrawerHeader(
                child: Text(''),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            ListTile(
              title: Text('Official Guidelines'),
              onTap: () async {
                const url = 'https://covid19.cy/index_en.html';
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              onTap: () {
                _showPrivacyPolicy();
              },
            ),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          constraints: BoxConstraints(maxWidth: 640),
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.local_post_office, size: 36.0),
                title: TextField(
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).translate("post_code"),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: () => _showPosition(),
                      )),
                  controller: _controllerPostalCode,
                  onChanged: (String value) => setState(() {
                    _postalCode = value;
                  }),
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.perm_identity, size: 36.0),
                title: TextField(
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate("id")),
                  controller: _controllerIdPassport,
                  onChanged: (String value) => setState(() {
                    _id = value;
                  }),
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.question_answer, size: 36.0),
                title: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).translate("purpose")),
                  value: _purpose,
                  isExpanded: true,
                  iconSize: 24,
                  onChanged: (String newValue) {
                    setState(() {
                      _purpose = newValue;
                    });
                  },
                  items: _purposes.map<DropdownMenuItem<String>>((String r) {
                    return DropdownMenuItem<String>(
                      value: r,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: "[${r}] ",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context)
                                .translate("purpose_${r}"),
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ])),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return _purposes.map<Widget>((String r) {
                      return Text(
                        "[${r}] " +
                            AppLocalizations.of(context)
                                .translate("purpose_${r}"),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      );
                    }).toList();
                  },
                ),
              ),
              Divider(),
              Container(
                width: 490,
                child: Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                          leading: Icon(Icons.message, size: 36.0),
                          title: RichText(
                            text: TextSpan(
                              text: _messageText(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .apply(
                                      fontSizeFactor: MediaQuery.of(context)
                                              .devicePixelRatio *
                                          1.5),
                            ),
                          ),
                          subtitle: Text(
                              AppLocalizations.of(context).translate("to") +
                                  " " +
                                  _shortNumber),
                          trailing: Ink(
                            decoration: ShapeDecoration(
                              color: Theme.of(context).accentColor,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white),
                              onPressed: () {
                                _sendSMS();
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                child: Text(
                  AppLocalizations.of(context).translate("warning"),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
