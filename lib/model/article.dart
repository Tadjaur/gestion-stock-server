import 'package:gestion_stock_server/model/operation.dart';
import 'package:gestion_stock_server/model/stock.dart';

import '../gestion_stock_server.dart';
import 'category.dart';

class Article extends ManagedObject<_Article> implements _Article {
  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
   @override
  Map<String, dynamic> asMap() {
    final map = super.asMap();
    if(map["category"] != null){
      map["categoryID"] = map["category"]["id"];
    }
    return map;
  }
}

class _Article {
  @primaryKey
  int id;

  String mark;
  @Column(nullable: true)
  String image;
  String description;
  String title;

  @Relate(#articles, onDelete: DeleteRule.cascade)
  Category category;

  DateTime createdAt;
  ManagedSet<Stock> stocks;
  ManagedSet<Opperation> operations;
}
