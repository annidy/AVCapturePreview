//
//  ViewController.m
//  AVCapturePreview
//
//  Created by annidyfeng on 16/4/8.
//  Copyright © 2016年 annidyfeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()
@property (weak) IBOutlet NSLevelIndicator *volumeLevelIndicator;
@property (assign) NSTimer *audioLevelTimer;
@end

@implementation ViewController
{
    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_captureLayer;
    AVCaptureAudioPreviewOutput *_caputreAudioPreview;
    AVCaptureStillImageOutput *_captureStillImageOutput;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer:YES];
    // Do any additional setup after loading the view.
    

}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self initCaptureSession];
    [self setupPreviewLayer];
    [self setupAuidoPreview];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)startSession:(id)sender {
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
}
- (IBAction)stopSession:(id)sender {
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
    }
}

- (IBAction)captureImage:(id)sender {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _captureStillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    __weak typeof(self) weakSelf = self;
    [_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        NSImage *image = [[NSImage alloc] initWithData:imageData];
        
        [weakSelf.stillImageView setImage:image];
    }];
}

- (void)initCaptureSession
{
    _captureSession = [[AVCaptureSession alloc] init];
    
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    AVCaptureDevice *captureDevice = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *dev in devices) {
        NSLog(@"%@", [dev localizedName]);
        
        if (dev.position == AVCaptureDevicePositionFront){
            captureDevice = dev;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if (!captureDevice) {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (input) {
        if ([_captureSession canAddInput:input]) {
            [_captureSession addInput:input];
        }
    }
    
    
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    input = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (input) {
        if ([_captureSession canAddInput:input]) {
            [_captureSession addInput:input];
        }
    }
}

- (void)setupPreviewLayer
{
    _captureLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    [_captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    _captureLayer.frame = (NSRect){.origin=CGPointZero, .size=self.cameraView.frame.size};
    
    [self.cameraView.layer addSublayer:_captureLayer];
    
    
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [_captureStillImageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
}

- (void)setupAuidoPreview
{
    _caputreAudioPreview = [[AVCaptureAudioPreviewOutput alloc] init];
    [_caputreAudioPreview setVolume:0]; // no playback
    
    if ([_captureSession canAddOutput:_caputreAudioPreview]) {
        [_captureSession addOutput:_caputreAudioPreview];
    }
    
    [self setAudioLevelTimer:[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateAudioLevels:) userInfo:nil repeats:YES]];
}

- (void)updateAudioLevels:(NSTimer *)timer
{
    NSInteger channelCount = 0;
    float decibels = 0.f;
    
    // Sum all of the average power levels and divide by the number of channels
    for (AVCaptureConnection *connection in _caputreAudioPreview.connections) {
        for (AVCaptureAudioChannel *audioChannel in [connection audioChannels]) {
            decibels += [audioChannel averagePowerLevel];
            channelCount += 1;
        }
    }
    
    decibels /= channelCount;
    
    [[self volumeLevelIndicator] setFloatValue:(pow(10.f, 0.05f * decibels) * 20.0f)];
}
@end
