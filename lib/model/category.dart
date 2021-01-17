import 'package:gestion_stock_server/model/article.dart';

import '../gestion_stock_server.dart';

class Category extends ManagedObject<_Category> implements _Category {
  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
  @override
  Map<String, dynamic> asMap() {
    final map = super.asMap();
    if(map["parent"] != null){
      map["parentID"] = map["parent"]["id"];
    }
    return map;
  }
}

class _Category {
  @primaryKey
  int id;
  String title;
  String description;
  
  @Relate(#children, onDelete: DeleteRule.cascade)
  Category parent;
  DateTime createdAt;

  ManagedSet<Category> children;
  ManagedSet<Article> articles;
}
