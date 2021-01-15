import '../gestion_stock_server.dart';
import 'article.dart';
import 'store.dart';

class Stock extends ManagedObject<_Stock> implements _Stock {
  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}

class _Stock {
  @primaryKey
  int id;
  int count;

  @Relate(#stocks)
  Store store;
  @Relate(#stocks)
  Article article;

  DateTime createdAt;
}
