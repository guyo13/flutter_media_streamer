//
//  ImageAssetModel.swift
//  flutter_media_streamer
//
//  Created by Guy O on 30/09/2020.
//

import Foundation
import Photos

class EncodeableLocation: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let floor: Int?
    let horizontalAccuracy: Double?
    let verticalAccuracy: Double?
    let speedAccuracy: Double?
    let courseAccuracy: Double?
    let timestamp: Double
    let speed: Double?
    let course: Double?
    
    
    init(with location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.floor = location.floor?.level
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        if #available(iOS 10.0, *) {
            self.speedAccuracy = location.speedAccuracy
        } else {
            // Fallback on earlier versions
            self.speedAccuracy = nil
        }
        if #available(iOS 13.4, *) {
            self.courseAccuracy = location.courseAccuracy
        } else {
            // Fallback on earlier versions
            self.courseAccuracy = nil
        }
        self.timestamp = location.timestamp.timeIntervalSince1970
        self.speed = location.speed
        self.course = location.course
    }
}

class EncodableAsset: Codable {
    let localIdentifier: String
    let mediaType: String
    let mediaSubtypes: [String]
    let sourceType: String
    let pixelWidth: Int
    let pixelHeight: Int
    let creationDate: Double?
    let modificationDate: Double?
    let location: EncodeableLocation?
    let duration: Double
    let isFavorite: Bool
    let isHidden: Bool
    let playbackStyle: String?
    let representsBurst: Bool
    let burstIdentifier: String?
    let burstSelectionTypes: [String]?
    
        
    init(with asset: PHAsset) {
        self.localIdentifier = asset.localIdentifier
        self.mediaType = EncodableAsset.getMediaTypeString(type: asset.mediaType)
        self.mediaSubtypes = EncodableAsset.getMediaSubtypes(subtypes: asset.mediaSubtypes)
        self.sourceType = EncodableAsset.getSourceType(source: asset.sourceType)
        self.pixelWidth = asset.pixelWidth
        self.pixelHeight = asset.pixelHeight
        self.creationDate = asset.creationDate?.timeIntervalSince1970
        self.modificationDate = asset.modificationDate?.timeIntervalSince1970
        self.duration = asset.duration
        self.isFavorite = asset.isFavorite
        self.isHidden = asset.isHidden
        if #available(iOS 11, *) {
            self.playbackStyle = EncodableAsset.getPlaybackStyle(style: asset.playbackStyle)
        } else {
            // Fallback on earlier versions
            self.playbackStyle = nil
        }
        self.location = asset.location != nil ? EncodeableLocation.init(with: asset.location!) : nil
        self.representsBurst = asset.representsBurst
        self.burstIdentifier = asset.burstIdentifier
        self.burstSelectionTypes = self.representsBurst ? EncodableAsset.getBurstSelectionTypes(types: asset.burstSelectionTypes) : nil
    }
    
    public static func getMediaTypeString(type: PHAssetMediaType) -> String {
        switch type {
        case .image:
            return "image"
        case .audio:
            return "audio"
        case .video:
            return "video"
        case .unknown:
            return "unknown"
        default:
            return "unknown"
        }
    }
    
    public static func getSourceType(source: PHAssetSourceType) -> String {
        switch source {
        case .typeCloudShared:
            return "cloudShared"
        case .typeUserLibrary:
            return "userLibrary"
        case .typeiTunesSynced:
            return "iTunesSynced"
        default:
            return "unknown"
        }
    }
    
    @available(iOS 11, *)
    public static func getPlaybackStyle(style: PHAsset.PlaybackStyle) -> String {
        switch style {
        case .image:
            return "image"
        case .imageAnimated:
            return "imageAnimated"
        case .livePhoto:
            return "livePhoto"
        case .video:
            return "video"
        case .videoLooping:
            return "videoLooping"
        default:
            return "unsupported"
        }
    }
    
    public static func getBurstSelectionTypes(types: PHAssetBurstSelectionType) -> [String] {
        var res = [String]()
        if types.rawValue & PHAssetBurstSelectionType.autoPick.rawValue != 0 {
            res.append("autoPick")
        }
        if types.rawValue & PHAssetBurstSelectionType.userPick.rawValue != 0 {
            res.append("userPick")
        }
        return res
    }
    
    public static func getMediaSubtypes(subtypes: PHAssetMediaSubtype) -> [String] {
        var res = [String]()
        if (PHAssetMediaSubtype.photoPanorama.rawValue & subtypes.rawValue) != 0 {
            res.append("photoPanorama")
        }
        if (PHAssetMediaSubtype.photoHDR.rawValue & subtypes.rawValue) != 0 {
            res.append("photoHDR")
        }
        if (PHAssetMediaSubtype.photoScreenshot.rawValue & subtypes.rawValue) != 0 {
            res.append("photoScreenshot")
        }
        if #available(iOS 9.1, *) {
            if (PHAssetMediaSubtype.photoLive.rawValue & subtypes.rawValue) != 0 {
                res.append("photoLive")
            }
        }
        if #available(iOS 10.2, *) {
            if (PHAssetMediaSubtype.photoDepthEffect.rawValue & subtypes.rawValue) != 0 {
                res.append("photoDepthEffect")
            }
        }
        if (PHAssetMediaSubtype.videoStreamed.rawValue & subtypes.rawValue) != 0 {
            res.append("videoStreamed")
        }
        if (PHAssetMediaSubtype.videoHighFrameRate.rawValue & subtypes.rawValue) != 0 {
            res.append("videoHighFrameRate")
        }
        if (PHAssetMediaSubtype.videoTimelapse.rawValue & subtypes.rawValue) != 0 {
            res.append("videoTimelapse")
        }
        return res
    }
}
