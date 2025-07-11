// lib/models/field.dart
class Field {
  final String id;
  final String name;
  final String type; // Contoh: "Rumput Sintetis", "Karpet Vinyl", "Profesional"
  final String description;
  final double pricePerHour; // Harga per jam
  final String? imageUrl;

  Field({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.pricePerHour,
    this.imageUrl,
  });

  // Konversi objek Field ke Map untuk penyimpanan SQLite
  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'pricePerHour': pricePerHour,
      'imageUrl': imageUrl,
    };
  }

  // Buat objek Field dari Map yang dibaca dari SQLite
  factory Field.fromSqliteMap(Map<String, dynamic> map) {
    return Field(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      pricePerHour: (map['pricePerHour'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
