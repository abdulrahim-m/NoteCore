import 'package:flutter/foundation.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';

abstract class FilterableListController implements Listenable {
  List<TagDto> get tags;
  Set<int> get filterTagIds;
  DateTime? get createdAfter;
  DateTime? get createdBefore;
  int get activeFilterCount;
  
  void toggleFilterTag(int id);
  void setCreatedAfter(DateTime? value);
  void setCreatedBefore(DateTime? value);
  void clearFilters();
  
  Future<TagDto?> createTag(String name);
  Future<void> deleteTag(int id);
}