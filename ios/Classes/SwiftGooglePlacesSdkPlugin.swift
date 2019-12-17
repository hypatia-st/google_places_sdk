import Flutter
import UIKit
import GooglePlaces

public class SwiftGooglePlacesSdkPlugin: NSObject, FlutterPlugin {
  var placesClient: GMSPlacesClient!
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "google_places_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftGooglePlacesSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getPlatformVersion") {
      result("iOS " + UIDevice.current.systemVersion)
    } else if (call.method == "initialize") {
      guard let args = call.arguments else {
        return
      }
      if let myArgs = args as? [String: Any],
        let iosApiKey = myArgs["iosApiKey"] as? String {
        placesClient = GMSPlacesClient.shared()
        GMSPlacesClient.provideAPIKey(iosApiKey)
        result(iosApiKey)
      } else {
        result(nil)
      }
    } else if (call.method == "getPlaceById") {
      guard let args = call.arguments else {
        return
      }
      if let myArgs = args as? [String: Any],
        let placeId = myArgs["placeId"] as? String {
       let fields: GMSPlaceField = GMSPlaceField(rawValue:
         UInt(GMSPlaceField.name.rawValue)
         | UInt(GMSPlaceField.placeID.rawValue)
         | UInt(GMSPlaceField.formattedAddress.rawValue)
         | UInt(GMSPlaceField.coordinate.rawValue))!
       placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: { ( place: GMSPlace?, error: Error?) in
         let placeDetails : Dictionary<String, Any> = [
           "id": place?.placeID as Any,
           "name": place?.name as Any,
           "address": place?.formattedAddress as Any,
           "latitude": place?.coordinate.latitude as Any,
           "longitude": place?.coordinate.longitude as Any
         ];
         result(placeDetails);
       })
      } else {
       result(nil)
      }
    }
  }
}
