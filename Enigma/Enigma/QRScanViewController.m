//
//  QRScanViewController.m
//  Enigma
//
//  Created by Bradley Slayter on 4/25/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

#import "QRScanViewController.h"

@interface AMScanViewController ()

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@end

@implementation AMScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if(![self isCameraAvailable]) {
		[self setupNoCameraView];
	}
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setNeedsStatusBarAppearanceUpdate];
	if([self isCameraAvailable]) {
		[self setupScanner];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle{
	return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)evt
{
	if(self.touchToFocusEnabled) {
		UITouch *touch=[touches anyObject];
		CGPoint pt= [touch locationInView:self.view];
		[self focus:pt];
	}
}

#pragma mark -
#pragma mark NoCamAvailable

- (void) setupNoCameraView
{
	UILabel *labelNoCam = [[UILabel alloc] init];
	labelNoCam.text = @"No Camera available";
	labelNoCam.textColor = [UIColor blackColor];
	[self.view addSubview:labelNoCam];
	[labelNoCam sizeToFit];
	labelNoCam.center = self.view.center;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setTitle:@"Cancel" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(8.0, [UIScreen mainScreen].bounds.size.height - 48.0, [UIScreen mainScreen].bounds.size.width - 16.0, 40.0);
	button.layer.cornerRadius = 6.0;
	button.layer.masksToBounds = true;
	button.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:170.0/255.0 blue:220.0/255.0 alpha:1.0];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.view addSubview:button];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
	return NO;//(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	/*if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
		AVCaptureConnection *con = self.preview.connection;
		con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
	} else {
		AVCaptureConnection *con = self.preview.connection;
		con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
	}*/
}

#pragma mark -
#pragma mark AVFoundationSetup

- (void) setupScanner
{
	
	dispatch_async(dispatch_get_main_queue(), ^{
		self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
		self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
	 
		self.session = [[AVCaptureSession alloc] init];
		
		self.output = [[AVCaptureMetadataOutput alloc] init];
		[self.session addOutput:self.output];
		[self.session addInput:self.input];
		
		[self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
		self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
		
		self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
		self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
		self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		
		AVCaptureConnection *con = self.preview.connection;
		
		con.videoOrientation = AVCaptureVideoOrientationPortrait;
		
		[self.view.layer insertSublayer:self.preview atIndex:0];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
		[button setTitle:@"Cancel" forState:UIControlStateNormal];
		[button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
		button.frame = CGRectMake(8.0, [UIScreen mainScreen].bounds.size.height - 48.0, [UIScreen mainScreen].bounds.size.width - 16.0, 40.0);
		button.layer.cornerRadius = 6.0;
		button.layer.masksToBounds = true;
		button.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:170.0/255.0 blue:220.0/255.0 alpha:1.0];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.view addSubview:button];

		[self.session startRunning];
	});
}

- (void)cancel
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Helper Methods

- (BOOL) isCameraAvailable
{
	NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	return [videoDevices count] > 0;
}

- (void)startScanning
{
	[self.session startRunning];
 
}

- (void) stopScanning
{
	[self.session stopRunning];
}

- (void) setTorch:(BOOL) aStatus
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[device lockForConfiguration:nil];
	if ( [device hasTorch] ) {
		if ( aStatus ) {
			[device setTorchMode:AVCaptureTorchModeOn];
		} else {
			[device setTorchMode:AVCaptureTorchModeOff];
		}
	}
	[device unlockForConfiguration];
}

- (void) focus:(CGPoint) aPoint
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if([device isFocusPointOfInterestSupported] &&
	   [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		double screenWidth = screenRect.size.width;
		double screenHeight = screenRect.size.height;
		double focus_x = aPoint.x/screenWidth;
		double focus_y = aPoint.y/screenHeight;
		if([device lockForConfiguration:nil]) {
			if([self.delegate respondsToSelector:@selector(scanViewController:didTapToFocusOnPoint:)]) {
				[self.delegate scanViewController:self didTapToFocusOnPoint:aPoint];
			}
			[device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
			[device setFocusMode:AVCaptureFocusModeAutoFocus];
			if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
				[device setExposureMode:AVCaptureExposureModeAutoExpose];
			}
			[device unlockForConfiguration];
		}
	}
}

#pragma mark -
#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
	   fromConnection:(AVCaptureConnection *)connection
{
	for(AVMetadataObject *current in metadataObjects) {
		if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
			if([self.delegate respondsToSelector:@selector(scanViewController:didSuccessfullyScan:)]) {
				NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
				[self.delegate scanViewController:self didSuccessfullyScan:scannedValue];
			}
		}
	}
}

@end
