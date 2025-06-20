// lib/models/field.dart (Diperbarui)
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'pricePerHour': pricePerHour,
      'imageUrl': imageUrl,
    };
  }

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
