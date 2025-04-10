import 'package:flutter/material.dart';
import '../models/book_data.dart';
import '../widgets/book_list_item.dart';
import '../utils/permission_handler.dart';
import '../services/file_service.dart';
import 'epub_reader_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BookData> _books = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await PermissionsHandler.requestStoragePermission();
  }

  Future<void> _addBook() async {
    try {
      BookData? bookData = await FileService.pickEpubFile();

      if (bookData != null) {
        setState(() {
          _books.add(bookData);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ePub Reader'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 80,
                    color: AppTheme.primaryPurple.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your library is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add your first book',
                    style: TextStyle(
                      color: AppTheme.textBrown,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                return BookListItem(
                  book: _books[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EpubReaderScreen(book: _books[index]),
                      ),
                    ).then((_) {
                      // Refresh the UI when returning from reader screen
                      setState(() {});
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Add Book',
        child: const Icon(Icons.add),
        elevation: 4,
      ),
    );
  }
}
