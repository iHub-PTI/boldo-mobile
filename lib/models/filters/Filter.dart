abstract class Filter {

  bool get ifFiltered;

  Map<String, dynamic> toJson();

  Future<void> clearFilter();

}