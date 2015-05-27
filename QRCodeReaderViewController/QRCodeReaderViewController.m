/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderViewController.h"
//#import "QRCameraSwitchButton.h"
#import "QRCodeReaderView.h"

@interface QRCodeReaderViewController ()
//@property (strong, nonatomic) QRCameraSwitchButton *switchCameraButton;
@property (strong, nonatomic) UIView *navigationBarView;
@property (strong, nonatomic) QRCodeReaderView     *cameraView;
@property (strong, nonatomic) UIButton             *cancelButton;
@property (strong, nonatomic) UIButton             *helpButton;
@property (strong, nonatomic) UILabel             *titleLabel;
@property (strong, nonatomic) QRCodeReader         *codeReader;
@property (strong, nonatomic) UIImageView         *imgShadow;
@property (copy, nonatomic) void (^completionBlock) (NSString *);

@end

@implementation QRCodeReaderViewController

- (void)dealloc
{
  [_codeReader stopScanning];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
  return [self initWithCancelButtonTitle:nil];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle
{
  return [self initWithCancelButtonTitle:cancelTitle metadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
}

- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
  return [self initWithCancelButtonTitle:nil metadataObjectTypes:metadataObjectTypes];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
  QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:metadataObjectTypes];
  
  return [self initWithCancelButtonTitle:cancelTitle codeReader:reader];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader
{
  if ((self = [super init])) {
    self.view.backgroundColor = [UIColor blackColor];
    self.codeReader           = codeReader;
    
    if (cancelTitle == nil) {
      cancelTitle = NSLocalizedString(@"C", @"C");
    }
    
    [self setupUIComponentsWithCancelButtonTitle:cancelTitle];
    [self setupAutoLayoutConstraints];
    
    [_cameraView.layer insertSublayer:_codeReader.previewLayer atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    __weak typeof(self) weakSelf = self;
    
    [codeReader setCompletionWithBlock:^(NSString *resultAsString) {
      if (weakSelf.completionBlock != nil) {
        weakSelf.completionBlock(resultAsString);
      }

      if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(reader:didScanResult:)]) {
        [weakSelf.delegate reader:weakSelf didScanResult:resultAsString];
      }
    }];
  }
  return self;
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle];
}

+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
  return [[self alloc] initWithMetadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle metadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [_codeReader startScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [_codeReader stopScanning];
  
  [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  _codeReader.previewLayer.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate
{
  return YES;
}

#pragma mark - Managing the Orientation

- (void)orientationChanged:(NSNotification *)notification
{
  [_cameraView setNeedsDisplay];
  
  if (_codeReader.previewLayer.connection.isVideoOrientationSupported) {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    _codeReader.previewLayer.connection.videoOrientation = [QRCodeReader videoOrientationFromInterfaceOrientation:
                                                            orientation];
  }
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
  self.completionBlock = completionBlock;
}

#pragma mark - Initializing the AV Components

- (void)setupUIComponentsWithCancelButtonTitle:(NSString *)cancelButtonTitle
{
  self.cameraView                                       = [[QRCodeReaderView alloc] init];
  _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
  _cameraView.clipsToBounds                             = YES;
  [self.view addSubview:_cameraView];
  
  [_codeReader.previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  
  if ([_codeReader.previewLayer.connection isVideoOrientationSupported]) {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    _codeReader.previewLayer.connection.videoOrientation = [QRCodeReader videoOrientationFromInterfaceOrientation:orientation];
  }
  
//  if ([_codeReader hasFrontDevice]) {
//    _switchCameraButton = [[QRCameraSwitchButton alloc] init];
//    [_switchCameraButton setTranslatesAutoresizingMaskIntoConstraints:false];
//    [_switchCameraButton addTarget:self action:@selector(switchCameraAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_switchCameraButton];
//  }

    self.cancelButton = [[UIButton alloc] init];
    self.helpButton = [[UIButton alloc] init];
    
    self.navigationBarView = [[UIView alloc] init];
    self.navigationBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.navigationBarView setBackgroundColor:kRGB(0x2A2A2A)];
    [self.view addSubview:_navigationBarView];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setText:@"Scan QRcode"];
    [self.titleLabel setFont:[UIFont fontWithName : @"DINPro" size : 22]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_navigationBarView addSubview:_titleLabel];
    
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    UIFont *fontCancel = [UIFont fontWithName:@"EUMIcons-App-Regular" size:50];
    [_cancelButton.titleLabel setFont:fontCancel];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [_navigationBarView addSubview:_cancelButton];
    
    _helpButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_helpButton setTitle:@"" forState:UIControlStateNormal];
    [_helpButton setImage:[UIImage imageNamed:@"icn-learn"] forState:UIControlStateNormal];
    UIFont *fontHelp = [UIFont fontWithName : @"DINPro" size : 22];
    [_helpButton.titleLabel setFont:fontHelp];
    [_helpButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_helpButton addTarget:self action:@selector(helpAction:) forControlEvents:UIControlEventTouchUpInside];
    [_navigationBarView addSubview:_helpButton];
    
    _imgShadow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top-bar-shadow"]];
    _imgShadow.translatesAutoresizingMaskIntoConstraints = NO;
    [_imgShadow setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_imgShadow];
}

- (void)setupAutoLayoutConstraints{
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_navigationBarView, _cameraView, _cancelButton,_titleLabel,_imgShadow,_helpButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[_navigationBarView(64)]-(0)-[_imgShadow(9)]-(-9)-[_cameraView]-(0)-|" options:0 metrics:nil views:views]];
    [self.navigationBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_cancelButton(64)]" options:0 metrics:nil views:views]];
    [self.navigationBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_cancelButton(60)]" options:0 metrics:nil views:views]];
    
    [self.navigationBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_helpButton(64)]" options:0 metrics:nil views:views]];
    [self.navigationBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_helpButton(60)]-0-|" options:0 metrics:nil views:views]];
    
    [self.navigationBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_titleLabel]|" options:0 metrics:nil views:views]];
    [self.navigationBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]|" options:0 metrics:nil views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_navigationBarView]|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imgShadow]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:nil views:views]];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cancelButton]-|" options:0 metrics:nil views:views]];
  
//  if (_switchCameraButton) {
//    NSDictionary *switchViews = NSDictionaryOfVariableBindings(_switchCameraButton);
//    
//    [self.view addConstraints:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_switchCameraButton(50)]" options:0 metrics:nil views:switchViews]];
//    [self.view addConstraints:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_switchCameraButton(70)]|" options:0 metrics:nil views:switchViews]];
//  }
}


//- (void)switchDeviceInput
//{
//  [_codeReader switchDeviceInput];
//}

#pragma mark - Catching Button Events

- (void)cancelAction:(UIButton *)button
{
  [_codeReader stopScanning];
  
  if (_completionBlock) {
    _completionBlock(nil);
  }
  
  if (_delegate && [_delegate respondsToSelector:@selector(readerDidCancel:)]) {
    [_delegate readerDidCancel:self];
  }
}

- (void)helpAction:(UIButton*)button{
    if (_delegate && [_delegate respondsToSelector:@selector(readerDidTapHelpButton:)]) {
        [_delegate readerDidTapHelpButton:self];
    }
}
//- (void)switchCameraAction:(UIButton *)button
//{
//  [self switchDeviceInput];
//}

@end
