class WatchlistModel {
  final String id;
  String name;
  List<String> symbols;

  WatchlistModel({required this.id, required this.name, List<String>? symbols})
      : symbols = symbols ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbols': symbols,
      };

  factory WatchlistModel.fromJson(Map<String, dynamic> json) => WatchlistModel(
        id: json['id'] as String,
        name: json['name'] as String,
        symbols: (json['symbols'] as List).map((e) => e as String).toList(),
      );
}
