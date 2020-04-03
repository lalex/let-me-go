import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:poly/poly.dart';

import 'package:letmego/location.dart';

class Postal {
  Postal();

  Future<String> postalCode() async {
    Position pos = await Location().getPosition();
    Point<double> p = Point(pos.latitude, pos.longitude);
    List<_Zone> index = await loadIndex();
    index.sort((_Zone a, _Zone b) {
      double da = p.distanceTo(a.point);
      double db = p.distanceTo(b.point);
      return da.compareTo(db);
    });

    // find exact polygon
    _Zone zone;
    await Future.forEach(index, (z) async {
      if (zone == null) {
        Polygon polygon = await loadPolygon(z.code);
        if (polygon.contains(p.x, p.y)) {
          zone = z;
        }
      }
    });
    if (zone == null) return '0000';

    return zone.code;
  }

  // load zones index file
  Future<List<_Zone>> loadIndex() async {
    String data = await rootBundle.loadString('data/index.csv');
    if (data == null) throw FlutterError('Unable to load index');
    List<_Zone> index = <_Zone>[];
    data.split(RegExp("\r?\n")).forEach((line) {
      List row = line.split(',');
      double x = double.parse(row[1]);
      double y = double.parse(row[2]);
      index.add(_Zone(row[0], Point(x, y)));
    });

    return index;
  }

  // load polygon
  Future<Polygon> loadPolygon(String code) async {
    String data = await rootBundle.loadString('data/polygon/' + code + '.csv');
    if (data == null) throw FlutterError('Unable to load polygon ' + code);
    List<Point> points = <Point>[];
    data.split(RegExp("\r?\n")).forEach((line) {
      List row = line.split(',');
      double x = double.parse(row[0]);
      double y = double.parse(row[1]);
      points.add(Point(x, y));
    });
    return Polygon(points);
  }
}

class _Zone {
  String code;
  Point<double> point;

  _Zone(this.code, this.point);
}
