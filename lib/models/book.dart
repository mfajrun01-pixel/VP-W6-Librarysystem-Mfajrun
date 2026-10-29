class Book {
  final String id;
  final String title;
  final String author;
  final double replacementPrice;
  final bool isAvailable;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
    this.isAvailable = true,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      replacementPrice: (json['replacementPrice'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'replacementPrice': replacementPrice,
      'isAvailable': isAvailable,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    double? replacementPrice,
    bool? isAvailable,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      replacementPrice: replacementPrice ?? this.replacementPrice,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
