import 'package:gestion_stock_server/model/operation.dart';
import 'package:gestion_stock_server/model/stock.dart';

import '../gestion_stock_server.dart';

class Store extends ManagedObject<_Store> implements _Store {
  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
  }
}

class _Store {
  @primaryKey
  int id;


  String title;
  String description;

  DateTime createdAt;
  ManagedSet<Stock> stocks;
  ManagedSet<Opperation> operations;
}
