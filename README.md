# SSIDCard

[![Version](https://img.shields.io/cocoapods/v/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
[![License](https://img.shields.io/cocoapods/l/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
[![Platform](https://img.shields.io/cocoapods/p/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
![图片](http://oarzzvu0u.bkt.clouddn.com/ssidcard_github.gif)
## 介绍
扫描识别**姓名**和**身份证号**，完美支持`bitcode`。依赖`OpenCV`，这个库比较大，`pod install`时需要多等一会😜

## 使用
- `Podfile`中`pod 'SSIDCard'`
- `info.plist`文件中增加`Privacy - Camera Usage Description`描述，否则崩溃
- 导入头文件`<SSIDCard/SSIDCard.h>`
- 两种调用方式：
	- block:
	```
	OC:
	SSScanViewController *scanVC = [[SSScanViewController alloc] initWithBlock:^(SSIDCard *idcard) {
		self.nameLbale.text = [NSString stringWithFormat:@"姓名：%@", idcard.idName];
		self.numberLabel.text = [NSString stringWithFormat:@"身份证号：%@", idcard.idNumber];
	}];
	[self presentViewController:scanVC animated:YES completion:nil];
   ```
   ```
	Swift:
	let vc = SSScanViewController.init { (idcard) in
			print(idcard.idName ?? "")
		}
	self.present(vc!, animated: true, completion: nil)
	```
	- delegate
	```
	SSScanViewController *scanVC = [[SSScanViewController alloc] init];
	scanVC.delegate = self;
	实现代理方法：- (void)ss_scanViewController:(SSScanViewController *)scanViewController didObtainedRecognizeResult:(SSIDCard *)idcard
	```

## License

SSIDCard is available under the MIT license. See the LICENSE file for more info.
