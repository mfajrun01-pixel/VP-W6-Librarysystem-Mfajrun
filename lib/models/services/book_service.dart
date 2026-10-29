import 'dart:convert';
import 'package:flutter/services.dart';
import '/models/book.dart';

class BookService {
  final String jsonPath;

  BookService({this.jsonPath = 'books.json'});

  Future<List<Book>> loadBooksFromAsset() async {
    try {
      final String jsonString = await rootBundle.loadString(jsonPath);
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback default books if asset fails to load
      return const [
        Book(
          id: 'B001',
          title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
          author: 'Robert C. Martin',
          replacementPrice: 150000.0,
          isAvailable: true,
        ),
        Book(
          id: 'B002',
          title: 'Design Patterns',
          author: 'Erich Gamma et al.',
          replacementPrice: 200000.0,
          isAvailable: true,
        ),
      ];
    }
  }
}
