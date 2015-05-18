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
#define kRGB(c) [UIColor colorWithRed : ((c >> 16) & 0xFF) / 255.0 green : ((c >> 8) & 0xFF) / 255.0 blue : (c & 0xFF) / 255.0 alpha : 1.0]
#define kRGBA(c) [UIColor colorWithRed : ((c >> 24) & 0xFF) / 255.0 green : ((c >> 16) & 0xFF) / 255.0 blue : ((c >> 8) & 0xFF) / 255.0 alpha : ((c) & 0xFF) / 255.0]
#import <UIKit/UIKit.h>

/**
 * Overlay over the camera view to display the area (a square) where to scan the
 * code.
 * @since 2.0.0
 */
@interface QRCodeReaderView : UIView

@end
