//
//  DeviceProfileDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

struct DeviceProfileDTO: Encodable {

    // MARK: - Nested

    struct DirectPlayProfile: Encodable {
        let container: String
        let type: String
        let videoCodec: String
        let audioCodec: String
    }

    struct TranscodingProfile: Encodable {
        let container: String
        let type: String
        let videoCodec: String
        let audioCodec: String
        let `protocol`: String
        let context: String
        let maxAudioChannels: String
        let minSegments: Int
        let breakOnNonKeyFrames: Bool
    }

    struct ProfileCondition: Encodable {
        let condition: String
        let property: String
        let value: String
        let isRequired: Bool
    }

    struct CodecProfile: Encodable {
        let type: String
        let codec: String
        let conditions: [ProfileCondition]
    }

    struct SubtitleProfile: Encodable {
        let format: String
        let method: String
    }

    // MARK: - Fields

    let maxStreamingBitrate: Int
    let directPlayProfiles: [DirectPlayProfile]
    let transcodingProfiles: [TranscodingProfile]
    let codecProfiles: [CodecProfile]
    let subtitleProfiles: [SubtitleProfile]
}

// MARK: - jellyOS profile

extension DeviceProfileDTO {
    static let maxBitrate = 120_000_000

    static let appleHLS = DeviceProfileDTO(
        maxStreamingBitrate: maxBitrate,
        directPlayProfiles: [
            DirectPlayProfile(container: "mp4,m4v,mov", type: "Video", videoCodec: "h264,hevc", audioCodec: "aac,ac3,eac3,flac,alac,mp3")
        ],
        transcodingProfiles: [
            TranscodingProfile(
                container: "mp4",
                type: "Video",
                videoCodec: "hevc,h264",
                audioCodec: "aac,ac3,eac3",
                protocol: "hls",
                context: "Streaming",
                maxAudioChannels: "6",
                minSegments: 2,
                breakOnNonKeyFrames: true
            )
        ],
        codecProfiles: [
            CodecProfile(type: "Video", codec: "hevc", conditions: [
                ProfileCondition(condition: "EqualsAny", property: "VideoCodecTag", value: "hvc1|dvh1", isRequired: true),
                ProfileCondition(condition: "LessThanEqual", property: "VideoFramerate", value: "60", isRequired: true),
                ProfileCondition(
                    condition: "EqualsAny",
                    property: "VideoRangeType",
                    value: "SDR|HDR10|HDR10Plus|HLG|DOVIWithHDR10|DOVIWithHLG|DOVIWithSDR|DOVIWithEL",
                    isRequired: false
                )
            ])
        ],
        subtitleProfiles: [
            SubtitleProfile(format: "vtt", method: "Hls"),
            SubtitleProfile(format: "pgssub", method: "Encode"),
            SubtitleProfile(format: "ass", method: "Encode"),
            SubtitleProfile(format: "ssa", method: "Encode")
        ]
    )
}
