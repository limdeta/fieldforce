// lib/features/shop/domain/entities/category.dart

class Category {
  final int id;
  final String name;
  final int lft;
  final int lvl;
  final int rgt;
  final String? description;
  final String? query;
  final int count;
  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.lft,
    required this.lvl,
    required this.rgt,
    this.description,
    this.query,
    required this.count,
    required this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      lft: json['lft'] as int,
      lvl: json['lvl'] as int,
      rgt: json['rgt'] as int,
      description: json['description'] as String?,
      query: json['query'] as String?,
      count: json['count'] as int,
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => Category.fromJson(child))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lft': lft,
      'lvl': lvl,
      'rgt': rgt,
      'description': description,
      'query': query,
      'count': count,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  // Вспомогательные методы для работы с nested set
  bool isLeaf() => children.isEmpty;

  bool isRoot() => lvl == 1;

  List<Category> getAllDescendants() {
    final descendants = <Category>[];
    for (final child in children) {
      descendants.add(child);
      descendants.addAll(child.getAllDescendants());
    }
    return descendants;
  }

  Category? findById(int categoryId) {
    if (id == categoryId) return this;
    for (final child in children) {
      final found = child.findById(categoryId);
      if (found != null) return found;
    }
    return null;
  }
}