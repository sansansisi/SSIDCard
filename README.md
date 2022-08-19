# SSIDCard

[![Version](https://img.shields.io/cocoapods/v/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
[![License](https://img.shields.io/cocoapods/l/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
[![Platform](https://img.shields.io/cocoapods/p/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
![图片](https://github.com/sansansisi/publicImages/blob/main/RPReplay_Final1660896205.gif)
## 介绍
扫描识别**姓名**和**身份证号**，完美支持`bitcode`,姓名和身份证号都是自己训练的模型，因为中文字符庞大，只训练了简单的常用字符，所以姓名识别并不是很准确。

## demo报错
执行pod install 后运行dmeo报错，请增加下图红框中信息
![](https://cdn.jsdelivr.net/gh/sansansisi/publicImages/article/Foxmail20220819171836.png)

## 使用
- `Podfile`中`pod 'SSIDCard'`
- `info.plist`文件中增加`Privacy - Camera Usage Description`描述
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
