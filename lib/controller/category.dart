import 'dart:convert';

import 'package:gestion_stock_server/gestion_stock_server.dart';
import 'package:gestion_stock_server/model/category.dart';
import 'package:mime/mime.dart';

class CategoryController extends ResourceController {
  CategoryController(this._context);

  final ManagedContext _context;

  @Operation.get()
  Future<Response> getAllCategory(Request request) async {
    final coursesQuery = Query<Category>(_context)
      ..where((x) => x.parent).isNull()
      ..join(set: (x) => x.children);
    final courses = await coursesQuery.fetch();
    return Response.ok(courses);
  }

  @Operation.post()
  Future<Response> addCategory(Request request) async {
    final param = await forumParamOfMultiPart(request);
    if (param != null) {
      if (param['title'] == null || param['description'] == null) {
        return Response.badRequest();
      }
      final storeQuery = Query<Category>(_context)
        ..values.description = param['description'] as String
        ..values.title = param['title'] as String;
      if (param['parentID'] != null) {
        storeQuery.values.parent = await (Query<Category>(_context)
              ..where((x) => x.id)
                  .equalTo(int.tryParse(param['parentID'].toString())))
            .fetchOne();
      }
      return Response.ok(await storeQuery.insert());
    } else {
      return Response.badRequest();
    }
  }

  Future<Map<String, dynamic>> forumParamOfMultiPart(Request request) async {
    const acceptedKeys = [
      "title",
      "description",
      "parentID",
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
}
