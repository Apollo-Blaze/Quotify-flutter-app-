import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Quote {
  late String text;
  late String source;

  Quote(this.text, this.source);

  Quote.fromJsonString(String jsonString) {
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    text = jsonMap['text'];
    source = jsonMap['source'];
  }

  String toJsonString() {
    Map<String, dynamic> jsonMap = {
      'text': text,
      'source': source,
    };
    return json.encode(jsonMap);
  }
}

List<Quote> quotes = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadQuotes();
  runApp(MaterialApp(home: Quotelist()));
}

Future<void> _loadQuotes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? quotesData = prefs.getStringList('quotes');

  // Load preset quotes if quotesData is null
  quotes = quotesData
          ?.map((quoteString) => Quote.fromJsonString(quoteString))
          .toList() ??
      [];

  if (quotesData == null) {
    List<Quote> presetQuotes = [
      Quote(
        'In the End, we will remember not the words of our enemies, but the silence of our friends.',
        'Martin Luther King Jr',
      ),
      Quote(
        'The only thing necessary for the triumph of evil is for good men to do nothing.',
        'Edmund Burke',
      ),
      Quote(
        'The truth is rarely pure and never simple.',
        'Oscar Wilde',
      ),
      // Add more preset quotes as needed
    ];

    quotesData = presetQuotes.map((quote) => quote.toJsonString()).toList();
    prefs.setStringList('quotes', quotesData);
  }
}

class Quotelist extends StatefulWidget {
  const Quotelist({Key? key}) : super(key: key);

  @override
  State<Quotelist> createState() => _QuotelistState();
}

class _QuotelistState extends State<Quotelist>
    with SingleTickerProviderStateMixin {
  List<Quote> quotes = [];
  TextEditingController quoteController = TextEditingController();
  TextEditingController sourceController = TextEditingController();
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    controller.forward();
  }

  Future<void> _loadQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? quotesData = prefs.getStringList('quotes');

    // Load preset quotes if quotesData is null
    quotes = quotesData
            ?.map((quoteString) => Quote.fromJsonString(quoteString))
            .toList() ??
        [];

    setState(() {});
  }

  void _saveQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> quotesData =
        quotes.map((quote) => quote.toJsonString()).toList();
    prefs.setStringList('quotes', quotesData);
  }

  void _addQuote() {
    String quoteText = quoteController.text;
    String source = sourceController.text;
    if (quoteText.isNotEmpty) {
      quotes.add(Quote(quoteText, source));
      quoteController.clear();
      sourceController.clear();
      _saveQuotes();
      setState(() {});
    }
  }

  void deleteQuote(int index) {
    quotes.removeAt(index);
    _saveQuotes();
    setState(() {});
  }

  void _showAddQuoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Colors.brown[50],
          title: Text(
            'New Quote',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: quoteController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20.0),
                    hintText: 'Quote',
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: sourceController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20.0),
                    hintText: 'Source',
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _addQuote();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.brown[800],
              ),
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget card(Quote quote, int index) {
    return Card(
      color: Colors.white.withOpacity(0.65),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                quote.text,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.brown[800],
                  fontFamily: 'Dancing',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "- " + quote.source,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.brown[900],
                    fontFamily: 'Caveat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8), // Add space between text and delete icon
                AnimatedDeleteButton(
                  onPressed: () => deleteQuote(index),
                  controller: controller,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: Text(
          'Quotify',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            fontFamily: 'Caveat',
          ),
        ),
        backgroundColor: Colors.brown[700],
        centerTitle: true,
        elevation: 6,
        actions: [
          IconButton(
            onPressed: () {
              _showAddQuoteDialog(context);
            },
            icon: Icon(Icons.add),
            color: Colors.brown[100],
            style: IconButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('assets/bgg.jpg'), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: quotes.length,
                    itemBuilder: (context, index) => card(quotes[index], index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedDeleteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final AnimationController controller;

  AnimatedDeleteButton({required this.onPressed, required this.controller});

  @override
  _AnimatedDeleteButtonState createState() => _AnimatedDeleteButtonState();
}

class _AnimatedDeleteButtonState extends State<AnimatedDeleteButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: widget.controller,
          curve: Curves.easeInOut,
        ),
      ),
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(-1, 0),
            end: Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: widget.controller,
              curve: Curves.easeInOut,
            ),
          ),
          child: IconButton(
            onPressed: widget.onPressed,
            icon: Icon(
              Icons.delete,
              color: Colors.red[800],
            ),
          ),
        );
      },
    );
  }
}
