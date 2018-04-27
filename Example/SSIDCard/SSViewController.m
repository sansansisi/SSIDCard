//
//  SSViewController.m
//  SSIDCard
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import "SSViewController.h"
#import <SSIDCard/SSIDCard.h>

@interface SSViewController () <SSScanViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)scanBtnClicked {
	SSScanViewController *scanVC = [[SSScanViewController alloc] init];
	scanVC.delegate = self;
	
//	SSScanViewController *scanVC = [[SSScanViewController alloc] initWithBlock:^(NSString *result) {
//		self.resultLabel.text = result;
//	}];
	[self presentViewController:scanVC animated:YES completion:nil];
}

#pragma mark - <SSScanViewControllerDelegate>
- (void)ss_scanViewController:(SSScanViewController *)scanViewController didObtainedRecognizeResult:(NSString *)recognizeResult {
	self.resultLabel.text = recognizeResult;
}

@end
