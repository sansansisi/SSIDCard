//
//  SSTesseract.m
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import "SSTesseract.h"
#import "SSIDCard.h"
#import "baseapi.h"
#import "environ.h"
#import "pix.h"
#import "ocrclass.h"
#import "allheaders.h"
#import "genericvector.h"
#import "strngs.h"
#import "renderer.h"

@interface SSTesseract () {
	tesseract::TessBaseAPI *_tesseract;
}

@property (nonatomic, copy) NSString *dataPath;
@property (nonatomic, copy) NSString *language;

@end

@implementation SSTesseract

+ (void)initialize {
	if (self == [SSTesseract self]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didReceiveMemoryWarningNotification:)
													 name:UIApplicationDidReceiveMemoryWarningNotification
												   object:nil];
	}
}

+ (void)didReceiveMemoryWarningNotification:(NSNotification*)notification {
	tesseract::TessBaseAPI::ClearPersistentCache();
}

#pragma mark - Life Cycle

- (instancetype)init {
	return [self initWithLanguage:nil];
}

- (instancetype)initWithLanguage:(NSString*)language {
	if (self = [super init]) {
		
		if (language != nil) {
			self.language = language;
		} else {
			self.language = [@"IDCard" copy];
		}
		
		NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[SSIDCard class]] pathForResource:[NSString stringWithFormat:@"%@", [SSIDCard class]] ofType:@"bundle"]];
		self.dataPath = bundle.bundlePath;
		setenv("TESSDATA_PREFIX", [self.dataPath stringByAppendingString:@"/"].fileSystemRepresentation, 1);
		
		BOOL success = [self configTesseractEngine];
		if (!success) {
			return nil;
		}
	}
	return self;
}

- (void)dealloc {
	if (_tesseract != nullptr) {
		delete _tesseract;
		_tesseract = nullptr;
	}
}

#pragma mark - Interface
- (BOOL)recognize {
	if (!_tesseract) {
		NSLog(@"Error! Cannot recognize text because the Tesseract engine is not properly configured!");
		return NO;
	}
	
	int returnCode = 0;
	@try {
		returnCode = _tesseract->Recognize(NULL);
	}
	// LCOV_EXCL_START
	@catch (NSException *exception) {
		NSLog(@"Exception was raised while recognizing: %@", exception);
	}
	// LCOV_EXCL_STOP
	return returnCode == 0;
}

#pragma mark - Private Method
- (BOOL)configTesseractEngine {
	int initReturnCode = self.tesseract->Init(self.dataPath.UTF8String, self.language.UTF8String, tesseract::OEM_TESSERACT_ONLY);
	self.tesseract->SetVariable("tessedit_char_whitelist", "0123456789X");
	return initReturnCode == 0;
}

- (void)setEngineImage:(UIImage *)image {
	if (image.size.width <= 0 || image.size.height <= 0) {
		NSLog(@"ERROR: Image has invalid size!");
		return;
	}
	
	if (_tesseract != nullptr) {
		Pix *pix = [self pixForImage:image];
		
		@try {
			_tesseract->SetImage(pix);
		}
		//LCOV_EXCL_START
		@catch (NSException *exception) {
			NSLog(@"ERROR: Can't set image: %@", exception);
		}
		//LCOV_EXCL_STOP
		pixDestroy(&pix);
	}
	
	_image = image;
}

- (Pix *)pixForImage:(UIImage *)image
{
	int width = image.size.width;
	int height = image.size.height;
	
	CGImage *cgImage = image.CGImage;
	CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
	const UInt8 *pixels = CFDataGetBytePtr(imageData);
	
	size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
	size_t bytesPerPixel = bitsPerPixel / 8;
	size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
	
	int bpp = MAX(1, (int)bitsPerPixel);
	Pix *pix = pixCreate(width, height, bpp == 24 ? 32 : bpp);
	l_uint32 *data = pixGetData(pix);
	int wpl = pixGetWpl(pix);
	
	void (^copyBlock)(l_uint32 *toAddr, NSUInteger toOffset, const UInt8 *fromAddr, NSUInteger fromOffset) = nil;
	switch (bpp) {
			
#if 0 // BPP1 start. Uncomment this if UIImage can support 1bpp someday
			// Just a reference for the copyBlock
		case 1:
			for (int y = 0; y < height; ++y, data += wpl, pixels += bytesPerRow) {
				for (int x = 0; x < width; ++x) {
					if (pixels[x / 8] & (0x80 >> (x % 8))) {
						CLEAR_DATA_BIT(data, x);
					}
					else {
						SET_DATA_BIT(data, x);
					}
				}
			}
			break;
#endif // BPP1 end
			
		case 8: {
			copyBlock = ^(l_uint32 *toAddr, NSUInteger toOffset, const UInt8 *fromAddr, NSUInteger fromOffset) {
				SET_DATA_BYTE(toAddr, toOffset, fromAddr[fromOffset]);
			};
			break;
		}
			
#if 0 // BPP24 start. Uncomment this if UIImage can support 24bpp someday
			// Just a reference for the copyBlock
		case 24:
			// Put the colors in the correct places in the line buffer.
			for (int y = 0; y < height; ++y, pixels += bytesPerRow) {
				for (int x = 0; x < width; ++x, ++data) {
					SET_DATA_BYTE(data, COLOR_RED, pixels[3 * x]);
					SET_DATA_BYTE(data, COLOR_GREEN, pixels[3 * x + 1]);
					SET_DATA_BYTE(data, COLOR_BLUE, pixels[3 * x + 2]);
				}
			}
			break;
#endif // BPP24 end
			
		case 32: {
			copyBlock = ^(l_uint32 *toAddr, NSUInteger toOffset, const UInt8 *fromAddr, NSUInteger fromOffset) {
				toAddr[toOffset] = (fromAddr[fromOffset] << 24) | (fromAddr[fromOffset + 1] << 16) |
				(fromAddr[fromOffset + 2] << 8) | fromAddr[fromOffset + 3];
			};
			break;
		}
			
		default:
			NSLog(@"Cannot convert image to Pix with bpp = %d", bpp); // LCOV_EXCL_LINE
	}
	
	if (copyBlock) {
		switch (image.imageOrientation) {
			case UIImageOrientationUp:
				// Maintain byte order consistency across different endianness.
				for (int y = 0; y < height; ++y, pixels += bytesPerRow, data += wpl) {
					for (int x = 0; x < width; ++x) {
						copyBlock(data, x, pixels, x * bytesPerPixel);
					}
				}
				break;
				
			case UIImageOrientationUpMirrored:
				// Maintain byte order consistency across different endianness.
				for (int y = 0; y < height; ++y, pixels += bytesPerRow, data += wpl) {
					int maxX = width - 1;
					for (int x = maxX; x >= 0; --x) {
						copyBlock(data, maxX - x, pixels, x * bytesPerPixel);
					}
				}
				break;
				
			case UIImageOrientationDown:
				// Maintain byte order consistency across different endianness.
				pixels += (height - 1) * bytesPerRow;
				for (int y = height - 1; y >= 0; --y, pixels -= bytesPerRow, data += wpl) {
					int maxX = width - 1;
					for (int x = maxX; x >= 0; --x) {
						copyBlock(data, maxX - x, pixels, x * bytesPerPixel);
					}
				}
				break;
				
			case UIImageOrientationDownMirrored:
				// Maintain byte order consistency across different endianness.
				pixels += (height - 1) * bytesPerRow;
				for (int y = height - 1; y >= 0; --y, pixels -= bytesPerRow, data += wpl) {
					for (int x = 0; x < width; ++x) {
						copyBlock(data, x, pixels, x * bytesPerPixel);
					}
				}
				break;
				
			case UIImageOrientationLeft:
				// Maintain byte order consistency across different endianness.
				for (int x = 0; x < height; ++x, data += wpl) {
					int maxY = width - 1;
					for (int y = maxY; y >= 0; --y) {
						int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
						copyBlock(data, maxY - y, pixels, x0);
					}
				}
				break;
				
			case UIImageOrientationLeftMirrored:
				// Maintain byte order consistency across different endianness.
				for (int x = height - 1; x >= 0; --x, data += wpl) {
					int maxY = width - 1;
					for (int y = maxY; y >= 0; --y) {
						int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
						copyBlock(data, maxY - y, pixels, x0);
					}
				}
				break;
				
			case UIImageOrientationRight:
				// Maintain byte order consistency across different endianness.
				for (int x = height - 1; x >=0; --x, data += wpl) {
					for (int y = 0; y < width; ++y) {
						int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
						copyBlock(data, y, pixels, x0);
					}
				}
				break;
				
			case UIImageOrientationRightMirrored:
				// Maintain byte order consistency across different endianness.
				for (int x = 0; x < height; ++x, data += wpl) {
					for (int y = 0; y < width; ++y) {
						int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
						copyBlock(data, y, pixels, x0);
					}
				}
				break;
				
			default:
				break;  // LCOV_EXCL_LINE
		}
	}
	
	pixSetYRes(pix, (l_int32)72);
	
	CFRelease(imageData);
	
	return pix;
}

#pragma mark - Getters and Setters

- (NSString *)recognizedText
{
	if (!_tesseract) {
		NSLog(@"Error! Cannot get recognized text because the Tesseract engine is not properly configured!");
		return nil;
	}
	char *utf8Text = _tesseract->GetUTF8Text();
	if (utf8Text == NULL) {
		NSLog(@"No recognized text. Check that -[Tesseract setImage:] is passed an image bigger than 0x0.");
		return nil;
	}
	
	NSString *text = [NSString stringWithUTF8String:utf8Text];
	delete[] utf8Text;
	return text;
}

- (void)setImage:(UIImage *)image {
	if (_image != image) {
		[self setEngineImage:image];
	}
}

- (tesseract::TessBaseAPI *)tesseract {
	if (!_tesseract) {
		_tesseract = new tesseract::TessBaseAPI();
	}
	return _tesseract;
}

@end
