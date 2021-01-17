import 'dart:convert' as cv;

import 'package:gestion_stock_server/gestion_stock_server.dart';
import 'package:gestion_stock_server/model/article.dart';
import 'package:gestion_stock_server/model/operation.dart';
import 'package:gestion_stock_server/model/stock.dart';
import 'package:gestion_stock_server/model/store.dart';
import 'package:mime/mime.dart';

class OperationController extends ResourceController {
  OperationController(this._context);

  final ManagedContext _context;

  Future<Response> getAllStock(Request request) async {
    final stocks = await Query<Stock>(_context).fetch();
    final extra = <String, Map>{}; // {storeid: {count: x, c1: {}, c2: {}, a: {}}}
    for (var stock in stocks) {
      final article = await (Query<Article>(_context)
            ..where((x) => x.id).equalTo(stock.article.id)
            ..join(object: (e) => e.category))
          .fetchOne();
      if (article != null) {
        extra[stock.store.id.toString()] ??= {"count": 0, "c1": {}, "c2": {}, "a": {}};
        extra[stock.store.id.toString()]["count"] += stock.count;
        extra[stock.store.id.toString()]["a"][stock.article.id.toString()] ??= 0;
        extra[stock.store.id.toString()]["c1"][article.category.parent.id.toString()] ??= 0;
        extra[stock.store.id.toString()]["c2"][article.category.id.toString()] ??= 0;
        extra[stock.store.id.toString()]["a"][stock.article.id.toString()] += stock.count;
        extra[stock.store.id.toString()]["c1"][article.category.parent.id.toString()] += stock.count;
        extra[stock.store.id.toString()]["c2"][article.category.id.toString()] += stock.count;
      }
    }
    return Response.ok(extra);
  }

  Future<Response> listOperation(Request request) async {
    final operations = await Query<Opperation>(_context).fetch();
    return Response.ok(operations);
  }

  Future<Response> addOperation(Request request) async {
    final param = await forumParamOfMultiPart(request);
    if (param != null) {
      if (param['action'] == null ||
          param['count'] == null ||
          param['date'] == null ||
          param['storeID'] == null ||
          param['articleID'] == null) {
        return Response.badRequest();
      }
      final storeQuery = Query<Opperation>(_context)
        ..values.action = int.tryParse(param['action'].toString())
        ..values.article = await (Query<Article>(_context)
              ..where((x) => x.id)
                  .equalTo(int.tryParse(param['articleID'].toString())))
            .fetchOne()
        ..values.store = await (Query<Store>(_context)
              ..where((x) => x.id)
                  .equalTo(int.tryParse(param['storeID'].toString())))
            .fetchOne()
        ..values.count = int.tryParse(param['count'].toString())
        ..values.date = DateTime.tryParse(param['date'].toString());
      final op = await storeQuery.insert();
      final stock = await (Query<Stock>(_context)
            ..where((x) => x.article.id).equalTo(op.article.id)
            ..where((x) => x.store.id).equalTo(op.store.id))
          .fetchOne();
      if (stock != null) {
        await (Query<Stock>(_context)
              ..values.count = stock.count + op.count * op.action
              ..where((x) => x.article.id).equalTo(op.article.id))
            .updateOne();
      } else {
        await (Query<Stock>(_context)
              ..values.count = op.count * op.action
              ..values.article.id = op.article.id
              ..values.store.id = op.store.id)
            .insert();
      }
      return Response.ok(op);
    } else {
      return Response.badRequest();
    }
  }

  Future<Map<String, dynamic>> forumParamOfMultiPart(Request request) async {
    const acceptedKeys = [
      "action",
      "articleID",
      "count",
      "date",
      "storeID",
    ];
    final bodyStream =
        Stream.fromIterable([await request.body.decode<List<int>>()]);
    final transformer = MimeMultipartTransformer(
        request.raw.headers.contentType.parameters["boundary"]);
    final parts = await transformer.bind(bodyStream).toList();
    final Map<String, dynamic> user = {};
    for (final part in parts) {
      final header = part.headers;
      final content = await part.toList();
      final allowedImageMineType = [
        'image/jpeg',
        'image/png',
      ];
      if ((header.keys.length == 1 ||
              header["content-type"].contains("text/plain")) &&
          header["content-disposition"] != null) {
        final String key = header["content-disposition"].split('"')[1];
        if (!acceptedKeys.contains(key)) {
          continue; // null;
        }
        try {
          user[key] = cv.utf8.decode(content[0]);
        } catch (e) {
          print(e);
          throw Exception();
        }
      } else if (header.keys.length == 2 &&
          header["content-disposition"] != null &&
          header["content-type"] != null &&
          allowedImageMineType.contains(header["content-type"])) {
        final name = header["content-disposition"].split('"')[3];
        final profileUrl = "${Directory.systemTemp.path}/$name";
        File file = File(profileUrl);
        file = await file.writeAsBytes(content[0]);
        user['file'] = file;
      } else {
        return null;
      }
    }
    return user;
  }
}
