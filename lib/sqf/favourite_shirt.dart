class FavouriteShirt {
  final int tId;
  final String shirtId;
  final String shirtImage;

  FavouriteShirt({required this.tId, required this.shirtId, required this.shirtImage});

  factory FavouriteShirt.fromMap(Map<String, dynamic> map) {
    return FavouriteShirt(
      tId: map['tId'],
      shirtId: map['shirtId'],
      shirtImage: map['shirtImage'],
    );
  }
}