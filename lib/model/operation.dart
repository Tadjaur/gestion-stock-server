import '../gestion_stock_server.dart';
import 'article.dart';
import 'store.dart';

class Opperation extends ManagedObject<_Opperation> implements _Opperation {
  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}

class _Opperation {
  @primaryKey
  int id;
  int count;
  int action;

  @Relate(#operations)
  Store store;
  @Relate(#operations)
  Article article;

  DateTime createdAt;
  DateTime date;
}
