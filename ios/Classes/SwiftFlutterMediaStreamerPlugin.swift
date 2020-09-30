import Flutter
import UIKit

public class SwiftFlutterMediaStreamerPlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate {
    var channel: FlutterMethodChannel

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_media_streamer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMediaStreamerPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public func handle( _ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
            NSLog("Inavlid arguments passed via method channel")
            result(FlutterError(code: "Invalid_Arguments", message: nil, details: nil))
            return
        }
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getThumbnail":
            let w: Int = (args["width"] as? NSNumber)?.intValue ?? 640
            let h: Int = (args["height"] as? NSNumber)?.intValue ?? 400
            let contentUriString: String = args["height"] as! String
            getThumbnail(result: result, uriString: contentUriString, width: w, height: h)
        case "getImage":
            let w: Int? = (args["width"] as? NSNumber)?.intValue
            let h: Int? = (args["height"] as? NSNumber)?.intValue
            let contentUriString: String = args["height"] as! String
            getImage(result: result, uriString: contentUriString, width: w, height: h)
        case "streamGalleryImages":
            let columns = args["columns"] as! [String]
            let limit = (args["limit"] as? NSNumber)?.intValue ?? 10
            let offset = (args["offset"] as? NSNumber)?.intValue ?? 0
            streamGalleryImages(result: result, columns: columns, limit: limit, offset: offset)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getThumbnail(result: FlutterResult, uriString: String, width:Int = 640, height:Int = 400) {

    }
    private func getImage(result: FlutterResult, uriString: String, width:Int?, height:Int?) {

    }
    private func streamGalleryImages(result: FlutterResult, columns: [String], limit: Int = 10, offset: Int = 0) {

    }


    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        //TODO
    }
}
