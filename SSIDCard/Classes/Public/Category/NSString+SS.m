//
//  NSString+SS.m
//  SSIDCard
//
//  Created by 张家铭 on 2018/4/27.
//

#import "NSString+SS.h"

@implementation NSString (SS)

+ (NSString *)ss_removeSpaceAndNewline:(NSString *)str {
	if (str == nil) return str;
	NSString *tempStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
	tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	return tempStr;
}

@end
