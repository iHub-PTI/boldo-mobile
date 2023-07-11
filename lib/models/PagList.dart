class PagList<T> {
  int? total;
  List<T>? items;

  PagList({
    this.total,
    this.items,
  });

  PagList.fromJson(Map<String, dynamic> json, List<T> list) {
    total = json['total'];

    if (json['items'] != null) {
      items = [];
      items!.addAll(list);
    }
  }

}