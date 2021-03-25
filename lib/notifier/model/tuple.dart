class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  const Tuple2(this.item1, this.item2);

  factory Tuple2.fromList(List items) {
    if (items.length != 2) {
      throw ArgumentError('items must have length 2');
    }

    return Tuple2<T1, T2>(items[0] as T1, items[1] as T2);
  }

  @override
  String toString() => '[$item1, $item2]';

  @override
  bool operator ==(Object other) =>
      other is Tuple2 && other.item1 == item1 && other.item2 == item2;

  @override
  int get hashCode => item1.hashCode + item2.hashCode;
}