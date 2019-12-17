import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GooglePlace {
  final double latitude;
  final double longitude;
  final String id;
  final String name;
  final String address;

  GooglePlace({
    @required this.latitude, 
    @required this.longitude, 
    @required this.id, 
    @required this.name, 
    @required this.address
  });
}

class GooglePlacesClient {
  final MethodChannel _channel;
  GooglePlacesClient(this._channel);
  Future<GooglePlace> getPlaceById(String placeId) async {
    final Map map = await _channel.invokeMethod('getPlaceById', {"placeId": placeId});
    return _mapToPlace(map);
  }

  static GooglePlace _mapToPlace(Map placeMap) {
    if (placeMap["latitude"] is double) {
      return new GooglePlace(
        name: placeMap["name"],
        id: placeMap["id"],
        address: placeMap["address"],
        latitude: placeMap["latitude"],
        longitude: placeMap["longitude"]
      );
    } else {
      return new GooglePlace(
        name: placeMap["name"],
        id: placeMap["id"],
        address: placeMap["address"],
        latitude: double.parse(placeMap["latitude"]),
        longitude: double.parse(placeMap["longitude"])
      );
    }
  }
}

class GooglePlacesSdk {
  static const MethodChannel _channel =
      const MethodChannel('google_places_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<GooglePlacesClient> initialize({String androidApiKey, String iosApiKey}) async {
    await _channel.invokeMethod('initialize', {"androidApiKey": androidApiKey, "iosApiKey": iosApiKey});
    return GooglePlacesClient(_channel);
  }
}
