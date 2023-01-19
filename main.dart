import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Books'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca un libro',
              ),
            ),
          ),
          ElevatedButton(
            child: Text('Cerca'),
            onPressed: () {
              searchBooks(_searchController.text);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_books[index].title),
                  subtitle: Text(_books[index].author),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookPage(_books[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void searchBooks(String query) async {
    final response =
        await http.get('https://www.googleapis.com/books/v1/volumes?q=$query');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _books =
            data['items'].map<Book>((book) => Book.fromJson(book)).toList();
      });
    }
  }
}

class BookPage extends StatelessWidget {
  final Book book;

  BookPage(this.book);
  TextStyle drip = const TextStyle(fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(book.title),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(book.thumbnail),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(book.title, style: drip),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(book.author, style: drip),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(book.synopsis, style: drip),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(book.price, style: drip),
              ),
            ],
          ),
        )));
  }
}

class Book {
  final String title;
  final String author;
  final String synopsis;
  final String price;
  final String thumbnail;

  Book({
    required this.title,
    required this.author,
    required this.synopsis,
    required this.price,
    required this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final price = json['saleInfo']['listPrice'] != null
        ? '€' + json['saleInfo']['listPrice']['amount'].toStringAsFixed(2)
        : 'Prezzo non disponibile';
    final thumbnail = json['volumeInfo']['imageLinks'] != null
        ? json['volumeInfo']['imageLinks']['thumbnail']
        : 'https://www.fcpindustriale.it/wp-content/uploads/2017/07/noimage.jpg';
    final title = json['volumeInfo']['title'].toString();
    final author = json['volumeInfo']['authors'][0] != null
        ? json['volumeInfo']['authors'][0].toString()
        : 'Autore non disponibile';
    final synopsis = json['volumeInfo']['description'] != null
        ? json['volumeInfo']['description'].toString()
        : 'Sintesi non disponibile';
    return Book(
      title: title,
      author: author,
      synopsis: synopsis,
      price: price,
      thumbnail: thumbnail,
    );
  }
}
