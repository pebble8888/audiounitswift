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
    var _audiounit: AudioUnit = nil
    var _x: Float = 0
    let _sampleRate:Double = 44100
    var _done:Bool = false
    init() {
#if os(iOS)
        let subtype = kAudioUnitSubType_RemoteIO
#else
        let subtype = kAudioUnitSubType_HALOutput 
#endif
        var acd = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType:subtype, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
        
        let ac = AudioComponentFindNext(nil, &acd)
        AudioComponentInstanceNew(ac, &_audiounit)
        AudioUnitInitialize(_audiounit);
        let audioformat:AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: _sampleRate, channels: 2)
        var asbd:AudioStreamBasicDescription = audioformat.streamDescription.memory
        AudioUnitSetProperty(_audiounit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, UInt32(sizeofValue(asbd)))
    }
    let callback: AURenderCallback = {
        (inRefCon: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>)
        in
        let myAudioPlayer:MyAudioPlayer = unsafeBitCast(inRefCon, MyAudioPlayer.self)
        myAudioPlayer.render(inNumberFrames, ioData:ioData)
        return noErr
    }
    func render(inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) {
        if !_done {
            getThreadPolicy()
            _done = true
        }
        let delta:Float = Float(440 * 2 * M_PI / _sampleRate)
        let abl = UnsafeMutableAudioBufferListPointer(ioData)
        var x:Float = 0
        for buffer:AudioBuffer in abl {
            x = _x
            let buf:UnsafeMutablePointer<Float> = unsafeBitCast(buffer.mData, UnsafeMutablePointer<Float>.self)
            for i:Int in 0 ..< Int(inNumberFrames) {
                buf[i] = sin(x)
                x += delta
            }
        }
        if abl.count > 0 {
            _x = x
        }
    }
    func play() {
        let ref: UnsafeMutablePointer<Void> = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        var callbackstruct:AURenderCallbackStruct = AURenderCallbackStruct(inputProc: callback, inputProcRefCon: ref)
        AudioUnitSetProperty(_audiounit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackstruct, UInt32(sizeofValue(callbackstruct)))
        
        AudioOutputUnitStart(_audiounit)
    }
}
