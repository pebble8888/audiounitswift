//
//  MyAudioPlayer.swift
//  audiounitswift
//
//  Created by pebble8888 on 2015/11/30.
//  Copyright © 2015年 pebble8888. All rights reserved.
//

import Foundation
import AudioUnit
import AudioToolbox
import AVFoundation

class MyAudioPlayer
{
    var _audiounit: AudioUnit? = nil
    var _x: Float = 0
    let _sampleRate:Double = 44100
    init() {
#if os(iOS)
        let subtype = kAudioUnitSubType_RemoteIO
#else
        let subtype = kAudioUnitSubType_HALOutput 
#endif
        var acd = AudioComponentDescription(componentType: kAudioUnitType_Output, 
                                            componentSubType:subtype, 
                                            componentManufacturer: kAudioUnitManufacturer_Apple,
                                            componentFlags: 0, 
                                            componentFlagsMask: 0)
        
        let ac = AudioComponentFindNext(nil, &acd)
        AudioComponentInstanceNew(ac!, &_audiounit)
        AudioUnitInitialize(_audiounit!);
        // オーディオデータ供給を44100,ステレオ,標準フォーマット(Float32, Non-Interleave)に設定
        let audioformat:AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: _sampleRate, channels: 2)
        var asbd:AudioStreamBasicDescription = audioformat.streamDescription.pointee
        AudioUnitSetProperty(_audiounit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, UInt32(MemoryLayout.size(ofValue: asbd)))
    }
    let callback: AURenderCallback = {
        (inRefCon: UnsafeMutableRawPointer,
        ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, 
        inTimeStamp: UnsafePointer<AudioTimeStamp>, 
        inBusNumber: UInt32, 
        inNumberFrames: UInt32, 
        ioData: UnsafeMutablePointer<AudioBufferList>?)
        in
        // ポインタからMyAudioPlayerインスタンスに変換
        let myAudioPlayer:MyAudioPlayer = Unmanaged<MyAudioPlayer>.fromOpaque(inRefCon).takeUnretainedValue()
        myAudioPlayer.render(inNumberFrames, ioData:ioData)
        return noErr
    }
    func render(_ inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) {
        let delta:Float = Float(440 * 2 * M_PI / _sampleRate)
        guard let abl = UnsafeMutableAudioBufferListPointer(ioData) else {
            return
        }
        var x:Float = 0
        for buffer:AudioBuffer in abl {
            x = _x
            let cap = Int(buffer.mDataByteSize)/MemoryLayout<Float>.size
            assert(cap == Int(inNumberFrames))
            if let buf:UnsafeMutablePointer<Float> = buffer.mData?.bindMemory(to: Float.self, capacity: cap) {
                for i:Int in 0 ..< Int(inNumberFrames) {
                    buf[i] = sin(x)
                    x += delta
                }
            }
        }
        if abl.count > 0 {
            _x = x
        }
    }
    func play() {
        // MyAudioPlayerインスタンスをポインタに変換
        let ref: UnsafeMutableRawPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        var callbackstruct:AURenderCallbackStruct = AURenderCallbackStruct(inputProc: callback, inputProcRefCon: ref)
        AudioUnitSetProperty(_audiounit!, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackstruct, UInt32(MemoryLayout.size(ofValue: callbackstruct)))
        
        AudioOutputUnitStart(_audiounit!)
    }
}
