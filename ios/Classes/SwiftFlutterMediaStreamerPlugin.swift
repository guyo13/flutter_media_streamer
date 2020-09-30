import Flutter
import UIKit
import Photos

public class SwiftFlutterMediaStreamerPlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate {
    var channel: FlutterMethodChannel
    var queryQueue: DispatchQueue
    var permissionsQueue: DispatchQueue
    var imageFetchResult: PHFetchResult<PHAsset>?
    let encoder: JSONEncoder
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_media_streamer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMediaStreamerPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.queryQueue = DispatchQueue(label: "net.guyor.flutter_media_streamer.cursor", qos: .utility)
        self.permissionsQueue = DispatchQueue(label: "net.guyor.flutter_media_streamer.permissions", qos: .userInitiated)
        self.imageFetchResult = nil
        self.encoder = JSONEncoder()
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
        case "haveStoragePermission":
            result(havePermissions())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getThumbnail(result: @escaping FlutterResult, uriString: String, width:Int = 640, height:Int = 400) {

    }
    private func getImage(result: @escaping FlutterResult, uriString: String, width:Int?, height:Int?) {

    }
    
    private func streamGalleryImages(result: @escaping FlutterResult, columns: [String], limit: Int = 10, offset: Int = 0) {
        //If cursor already available, continue serving results through it
        if self.imageFetchResult != nil {
            
        } else {
            // Check permissions on userInitiated queue
            self.permissionsQueue.async {
                if !self.havePermissions() {
                    // If no permissions granted, request and defer execution
                    // to when permissions are either granted or denied
                    self.requestPermissionsAndRegister { authStatus in
                        if (authStatus == PHAuthorizationStatus.authorized) {
                            // Execute query only if permissions were authorized
                            self.getGalleryImageCursor(columns: columns, limit: limit, offset: offset)
                        } else {
                            result(FlutterError(code: "ERR_PERMISSIONS",
                                                message: "Photo Gallery Permissions denied", details: nil))
                        }
                    }
                } else {
                    // Permissions available continue execution (on utility thread)
                    self.getGalleryImageCursor(columns: columns, limit: limit, offset: offset)
                }
            }
        }
    }
    
    private func getGalleryImageCursor(columns: [String], limit: Int = 10, offset: Int = 0) {
        self.queryQueue.async {
            let fetchOptions = PHFetchOptions()
            let sources: PHAssetSourceType = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
            fetchOptions.includeAssetSourceTypes = sources
            let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            DispatchQueue.main.sync {
                self.imageFetchResult = fetchResult
            }
        }
    }
    
    private func resumeImageCursor(result: @escaping FlutterResult, cursor: PHFetchResult<PHAsset>, limit: Int = 10, offset: Int = 0) {
        self.queryQueue.async {
            let start = offset
            let desiredEnd = offset + limit - 1
            let end = desiredEnd < cursor.count ? desiredEnd : (cursor.count - 1)
            let indexSet = IndexSet(start...end)
            let objects = cursor.objects(at: indexSet)
            var res = [String]()
            for item in objects {
                //TODO - serialize to json and add to res
                do {
                    let data = try self.encoder.encode(EncodableAsset.init(with: item))
                    let jsonString = String(data: data, encoding: .utf8)
                    if (jsonString != nil) {
                        res.append(jsonString!)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            print(res)
            result(res)
        }
    }
    
    private func havePermissions() -> Bool {
        let authStatus: PHAuthorizationStatus
        if #available(iOS 14.0, *) {
            authStatus = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite)
        } else {
            authStatus = PHPhotoLibrary.authorizationStatus()
        }
        return authStatus == PHAuthorizationStatus.authorized
    }
    
    private func requestPermissionsAndRegister(handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(handler)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        //TODO
    }
}
