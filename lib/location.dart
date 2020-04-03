@JS('navigator.geolocation') // navigator.geolocation namespace
library jslocation; // library name can be whatever you want

import 'dart:async';

import "package:js/js.dart";

@JS('getCurrentPosition') // Accessing method getCurrentPosition from Geolocation API
external void getCurrentPosition(Function success(GeolocationPosition pos), Function error(GeolocationPositionError err));

@JS()
@anonymous
class GeolocationCoordinates {
  external double get latitude;

  external double get longitude;

  external double get altitude;

  external double get accuracy;

  external double get altitudeAccuracy;

  external double get heading;

  external double get speed;

  external factory GeolocationCoordinates(
      {double latitude,
      double longitude,
      double altitude,
      double accuracy,
      double altitudeAccuracy,
      double heading,
      double speed});
}

@JS()
@anonymous
class GeolocationPosition {
  external GeolocationCoordinates get coords;

  external factory GeolocationPosition({GeolocationCoordinates coords});
}

@JS()
@anonymous
class GeolocationPositionError {
  external int get code;

  external String get message;
}

@JS()
@anonymous
class PositionOptions {
  external bool get enableHighAccuracy;

  external int get timeout;

  external int get maximumAge;
}

class Position {
  double latitude, longitude, accuracy;

  Position(this.latitude, this.longitude, this.accuracy);
}

class Location {
  Completer<Position> _completer = new Completer();

  _success(GeolocationPosition pos) {
    _completer.complete(new Position(
        pos.coords.latitude, pos.coords.longitude, pos.coords.accuracy));
  }

  _error(GeolocationPositionError err) {
    _completer.completeError(Error());
  }

  Future<Position> getPosition() {
    getCurrentPosition(allowInterop((pos) => _success(pos)), allowInterop((err) => _error(err)));
    return _completer.future;
  }

}
