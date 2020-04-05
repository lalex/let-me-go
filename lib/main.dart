import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:letmego/localization.dart';
import 'package:letmego/postal.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLocalizationsDelegate _appLocalizationsDelegate;

  @override
  void initState() {
    super.initState();
    _appLocalizationsDelegate = AppLocalizationsDelegate(Locale('en'));
  }

  onLocaleChange(Locale locale) {
    setState(() {
      _appLocalizationsDelegate = AppLocalizationsDelegate(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('en'), Locale('el'), Locale('ru')],
      localizationsDelegates: [
        _appLocalizationsDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      title: 'Let me go',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        localeChangeCallback: onLocaleChange,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.localeChangeCallback}) : super(key: key);

  LocaleChangeCallback localeChangeCallback;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _shortNumber = '8998';
  List<String> _purposes = <String>['1', '2', '3', '4', '5', '6', '7', '8'];
  Map<String, String> _languages = <String, String>{
    'en': 'En',
    'el': 'Ελ',
    'ru': 'Ру'
  };

  TextEditingController _controllerPostalCode, _controllerIdPassport;
  String _postalCode = '';
  String _id = '';
  String _purpose = '';
  String _language = 'en';

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
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
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
          title: Text(
            AppLocalizations.of(context).translate("privacy_policy"),
          ),
          content: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Container(
                  child: Text(
                      AppLocalizations.of(context).translate('privacy_data')),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                      AppLocalizations.of(context).translate('privacy_source')),
                ),
              ])),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPosition() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<String>(
              future: Postal().postalCode(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                List<Widget> actions = <Widget>[];

                if (snapshot.hasData) {
                  // found
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
                      child: Text(
                          AppLocalizations.of(context).translate('geo_no')),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                          AppLocalizations.of(context).translate('geo_yes')),
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
                  // error
                  children = <Widget>[
                    Text(
                        AppLocalizations.of(context).translate('geo_not_found'))
                  ];
                  actions = <Widget>[
                    FlatButton(
                      child:
                          Text(MaterialLocalizations.of(context).okButtonLabel),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ];
                } else {
                  // in progress
                  children = <Widget>[
                    SizedBox(
                      child: CircularProgressIndicator(),
                      width: 30,
                      height: 30,
                    ),
                  ];
                  actions = <Widget>[
                    FlatButton(
                      child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ];
                }
                return AlertDialog(
                  title: Center(
                      child: Text(AppLocalizations.of(context)
                          .translate('geo_your_postal_code'))),
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
        title: Text(AppLocalizations.of(context).translate("title"),
            style: TextStyle(
              fontSize: 14,
            )),
        actions: <Widget>[
          Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _language,
                iconSize: 24,
                iconEnabledColor:
                    DefaultTextStyle.of(context).style.decorationColor,
                elevation: 16,
                onChanged: (String newValue) {
                  widget.localeChangeCallback(Locale(newValue));
                  setState(() {
                    _language = newValue;
                  });
                },
                items: _languages
                    .map<String, DropdownMenuItem<String>>(
                        (String lang, String title) {
                      return MapEntry<String, DropdownMenuItem<String>>(
                          lang,
                          DropdownMenuItem<String>(
                            value: lang,
                            child: Text(title),
                          ));
                    })
                    .values
                    .toList(),
                selectedItemBuilder: (BuildContext context) {
                  return _languages
                      .map<String, DropdownMenuItem<String>>(
                          (String lang, String title) {
                        return MapEntry<String, DropdownMenuItem<String>>(
                            lang,
                            DropdownMenuItem<String>(
                              value: lang,
                              child: Text(
                                title,
                                style: DefaultTextStyle.of(context).style,
                              ),
                            ));
                      })
                      .values
                      .toList();
                },
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 65,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)
                  .translate("official_guidelines")),
              trailing: Icon(Icons.open_in_new),
              onTap: () async {
                const url = 'https://covid19.cy/index_en.html';
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context).translate("privacy_policy"),
              ),
              onTap: () {
                _showPrivacyPolicy();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 640),
            child: Column(
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
                      labelText: AppLocalizations.of(context).translate("id"),
                      suffixIcon: Visibility(
                          visible: _id.isNotEmpty,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => setState(() {
                              _controllerIdPassport.text = '';
                              _id = '';
                            }),
                          )),
                    ),
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
                    //value: _purpose,
                    isExpanded: true,
                    iconSize: 24,
                    icon: IconButton(
                      icon: Icon(Icons.keyboard_arrow_down),
                    ),
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
                Visibility(
                  visible: _postalCode.isNotEmpty &&
                      _id.isNotEmpty &&
                      _purpose.isNotEmpty,
                  child: Column(children: [
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
                                            fontSizeFactor:
                                                MediaQuery.of(context)
                                                        .devicePixelRatio *
                                                    1.5),
                                  ),
                                ),
                                subtitle: Text(AppLocalizations.of(context)
                                        .translate("to") +
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
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      child: Text(
                        AppLocalizations.of(context).translate("warning"),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FlatButton(
        child: Text(
          AppLocalizations.of(context).translate("privacy_policy"),
          textAlign: TextAlign.center,
        ),
        onPressed: _showPrivacyPolicy,
      ),
    );
  }
}
