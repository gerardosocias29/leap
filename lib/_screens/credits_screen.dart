import 'package:flutter/material.dart';

import '../api.dart';
import '../app_theme.dart';

class CreditsScreen extends StatefulWidget {
  @override
  _CreditsScreenState createState() => _CreditsScreenState();
}
class GridCardItem {
  final String name;
  final String imagePath;

  GridCardItem({required this.name, required this.imagePath});
}

class ListCardItem {
  final String authors;
  final String bookTitle;
  final String bookDescription;
  final String publishYear;
  final String publisher;
  final String isbn;

  ListCardItem({
    required this.authors,
    required this.bookTitle,
    required this.bookDescription,
    required this.publishYear,
    required this.publisher,
    required this.isbn,
  });

}

class _CreditsScreenState extends State<CreditsScreen>{

  final List<GridCardItem> items = [
    GridCardItem(
      name: 'Joana Marie B. Mejias',
      imagePath: 'assets/speech_icon.png',
    ),
    GridCardItem(
      name: 'Christian Nikko P. Torremocha',
      imagePath: 'assets/speech_icon.png',
    ),
    GridCardItem(
      name: 'Ydelle T. Logroño',
      imagePath: 'assets/speech_icon.png',
    ),
    GridCardItem(
      name: 'Jenel S. Bautista',
      imagePath: 'assets/speech_icon.png',
    ),
  ];
  late final List<ListCardItem> listItems = [];


  _initRetrieval() async {
    var urls = [
      'get_references'
    ];
    var datas = await Api().multipleGetRequest(urls);
    setState(() {
      var data = datas[0];
      for(var x=0; x<data.length; x++){
        var item = data[x];
        listItems.add(ListCardItem(authors: item['authors'], bookTitle: item['book_title'], bookDescription: item['book_description'], publishYear: item['publish_year'], publisher: item['publisher'], isbn: item['isbn']));
      }
    });

  }

  @override
  void initState() {
    _initRetrieval();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beige,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Credits',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
        backgroundColor: AppTheme.beige,
        shadowColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('The Developers'),
            SizedBox(height: 20,),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8, // Adjust this value for desired aspect ratio
                  crossAxisSpacing: 8.0, // Gap between columns
                  mainAxisSpacing: 8.0, // Gap between rows
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GridCardWidget(
                    item: items[index],
                  );
                },
              ),
            ),
            SizedBox(height: 20,),
            Text('References'),
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                itemCount: listItems.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.book),
                      title: Text(
                        listItems[index].bookTitle,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.0),
                          Text(
                            'Author(s): ${listItems[index].authors}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            '${listItems[index].bookDescription}, ${listItems[index].publishYear}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Published and Distributed by: ${listItems[index].publisher}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'ISBN: ${listItems[index].isbn}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4.0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GridCardWidget extends StatelessWidget {
  final GridCardItem item;

  const GridCardWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}