import 'dart:convert';

import 'package:gestion_stock_server/gestion_stock_server.dart';
import 'package:gestion_stock_server/model/article.dart';
import 'package:gestion_stock_server/model/stock.dart';
import 'package:gestion_stock_server/model/store.dart';
import 'package:mime/mime.dart';

class StoreController extends ResourceController {
  StoreController(this._context);

  final ManagedContext _context;

  Future<Response> getAllStores(Request request) async {
    final storesQuery = Query<Store>(_context)..join(set: (x) => x.stocks);
    final stores = await storesQuery.fetch();
    return Response.ok(stores);
  }

  Future<Response> getAllStock(Request request) async {
    final stocks = await Query<Stock>(_context).fetch();
    final extra = {"store": {}, "c1": {}, "c2": {}, "a": {}};
    for (var stock in stocks) {
      final article = await (Query<Article>(_context)
            ..where((x) => x.id).equalTo(stock.article.id)
            ..join(object: (e) => e.category))
          .fetchOne();
      if (article != null) {
        extra["a"][stock.article.id] ??= 0;
        extra["c1"][article.category.parent.id] ??= 0;
        extra["c2"][article.category.id] ??= 0;
        extra["store"][stock.store.id] ??= 0;
        extra["a"][stock.article.id] += stock.count;
        extra["c1"][article.category.parent.id] += stock.count;
        extra["c2"][article.category.id] += stock.count;
        extra["store"][stock.store.id] += stock.count;
      }
    }
    return Response.ok(extra);
  }

  Future<Response> addStore(Request request) async {
    final param = await forumParamOfMultiPart(request);
    if (param != null) {
      if (param['title'] == null || param['description'] == null) {
        return Response.badRequest();
      }
      final storeQuery = Query<Store>(_context)
        ..values.description = param['description'] as String
        ..values.title = param['title'] as String;

      return Response.ok(await storeQuery.insert());
    } else {
      return Response.badRequest();
    }
  }

  Future<Map<String, dynamic>> forumParamOfMultiPart(Request request) async {
    const acceptedKeys = [
      "title",
      "description",
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
          user[key] = utf8.decode(content[0]);
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

  FutureOr<RequestOrResponse> deleteStore(Request request) async {
    final parentID =
        int.tryParse(request.raw.uri.queryParameters["id"].toString());
    final pass = request.raw.uri.queryParameters["pass".toString()];
    if (parentID == null || pass == null)
      return Response.badRequest(
          body: "the query 'id' and 'pass' must not be empty");
    if (pass != GestionStockServerChannel.BAD_ACCESS_PASS)
      return Response.badRequest(body: "invalid password");
    final qry = Query<Store>(_context)..where((x) => x.id).equalTo(parentID);
    return Response.ok(await qry.delete());
  }
}
