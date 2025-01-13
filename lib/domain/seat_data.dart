class SeatData {
  SeatData({
    required this.id, required this.status,
  });
  final int id;
  String status;

  //JSONからオブジェクトを作成するファクトリメソッド
  factory SeatData.fromJson(dynamic json) {
    return SeatData(
      id: json['id'] as int,
      status: json['status'] as String,
    );
  }
}