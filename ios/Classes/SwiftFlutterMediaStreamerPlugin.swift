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
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getThumbnail":
            if !checkDictionaryArgs(call: call) {
                result(FlutterError(code: "Invalid_Arguments", message: nil, details: nil))
            }
            let args = call.arguments as! Dictionary<String, Any>
            let w: Int = (args["width"] as? NSNumber)?.intValue ?? 640
            let h: Int = (args["height"] as? NSNumber)?.intValue ?? 400
            let contentUriString: String = args["height"] as! String
            getThumbnail(result: result, uriString: contentUriString, width: w, height: h)
        case "getImage":
            if !checkDictionaryArgs(call: call) {
                result(FlutterError(code: "Invalid_Arguments", message: nil, details: nil))
            }
            let args = call.arguments as! Dictionary<String, Any>
            let w: Int? = (args["width"] as? NSNumber)?.intValue
            let h: Int? = (args["height"] as? NSNumber)?.intValue
            let contentUriString: String = args["height"] as! String
            getImage(result: result, uriString: contentUriString, width: w, height: h)
        case "imageMetadataStream":
            if !checkDictionaryArgs(call: call) {
                result(FlutterError(code: "Invalid_Arguments", message: nil, details: nil))
            }
            let args = call.arguments as! Dictionary<String, Any>
            let columns = args["columns"] as! [String]
            let limit = (args["limit"] as? NSNumber)?.intValue ?? 10
            let offset = (args["offset"] as? NSNumber)?.intValue ?? 0
            streamImageMetadata(result: result, columns: columns, limit: limit, offset: offset)
        case "havePermissions":
            result(havePermissions())
        case "requestPermissions":
            requestPermissionsAndRegister(handler: {authResults in result(authResults == .authorized)})
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func checkDictionaryArgs(call: FlutterMethodCall) -> Bool {
        guard (call.arguments as? Dictionary<String, Any>) != nil else {
            NSLog("Inavlid arguments passed via method channel")
            return false
        }
        return true
    }
    
    private func getThumbnail(result: @escaping FlutterResult, uriString: String, width:Int = 640, height:Int = 400) {
        
    }
    private func getImage(result: @escaping FlutterResult, uriString: String, width:Int?, height:Int?) {
        
    }
    
    private func streamImageMetadata(result: @escaping FlutterResult, columns: [String], limit: Int = 10, offset: Int = 0) {
        //If cursor already available, continue serving results through it
        if self.imageFetchResult != nil {
            self.queryQueue.async {
                self.resumeImageCursor(result: result, cursor: self.imageFetchResult!, limit: limit, offset: offset)
            }
        } else {
            weak var weakSelf: SwiftFlutterMediaStreamerPlugin? = self
            let handler = { (authStatus: PHAuthorizationStatus) in
                if (authStatus == PHAuthorizationStatus.authorized) {
                    // Execute query only if permissions were authorized
                    weakSelf?.queryQueue.async {
                        weakSelf?.getGalleryImageCursor(columns: columns, limit: limit, offset: offset)
                        weakSelf?.resumeImageCursor(result: result, cursor: (weakSelf?.imageFetchResult)!, limit: limit, offset: offset)
                    }
                } else {
                    result(FlutterError(code: "ERR_PERMISSIONS",
                                        message: "Photo Gallery Permissions denied", details: nil))
                }
            }
            self.executeWithGalleryPermissions(handler: handler)
        }
    }
    
    // Run only from worker thread
    private func getGalleryImageCursor(columns: [String], limit: Int = 10, offset: Int = 0) {
        let fetchOptions = PHFetchOptions()
        let sources: PHAssetSourceType = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        fetchOptions.includeAssetSourceTypes = sources
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        DispatchQueue.main.sync {
            self.imageFetchResult = fetchResult
        }
    }
    
    // Run only from worker thread
    private func resumeImageCursor(result: @escaping FlutterResult, cursor: PHFetchResult<PHAsset>, limit: Int = 10, offset: Int = 0) {
        var res = [String]()
        if offset < cursor.count {
            let start = offset
            let desiredEnd = offset + limit - 1
            let end = desiredEnd < cursor.count ? desiredEnd : (cursor.count - 1)
            let indexSet = IndexSet(start...end)
            let objects = cursor.objects(at: indexSet)
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
        }
        print("Sent \(res.count) items!")
        result(res)
        // When we reach to the end of the PHFetchResult set it to null
        if res.count == 0 {
            DispatchQueue.main.sync {
                self.imageFetchResult = nil
            }
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
    
    private func executeWithGalleryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void) {
        // Check permissions on userInitiated queue
        self.permissionsQueue.async {
            if !self.havePermissions() {
                // If no permissions granted, request and defer execution
                // to when permissions are either granted or denied
                self.requestPermissionsAndRegister(handler: handler)
            } else {
                // Permissions available continue execution
                handler(PHAuthorizationStatus.authorized)
            }
        }
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        //TODO
    }
}
