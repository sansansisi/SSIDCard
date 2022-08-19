# SSIDCard

[![Version](https://img.shields.io/cocoapods/v/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
[![License](https://img.shields.io/cocoapods/l/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
[![Platform](https://img.shields.io/cocoapods/p/SSIDCard.svg?style=flat)](https://cocoapods.org/pods/SSIDCard)
![图片](https://github.com/sansansisi/publicImages/blob/main/RPReplay_Final1660896205.gif)
## 介绍
扫描识别**姓名**和**身份证号**，完美支持`bitcode`

## 运行示例程序
### 克隆方式
- git clone https://github.com/sansansisi/SSIDCard.git
- cd SSIDCard
- git lfs pull (请先安装[Git LFS](https://git-lfs.github.com/),如果克隆下来时，/SSIDCard/Frameworks/opencv2.framework/Versions/A 路径下存在opencv文件(245M大小)，就跳过这一步)
- cd Example
- pod install

### 直接下载压缩包方式
直接下载的zip解压运行，会缺少opencv文件，请去[opencv](https://github.com/opencv/opencv/releases) 下载3.4.1版本的opencv2.framework替换掉本工程的/SSIDCard/Frameworks/opencv2.framework文件,然后执行pod install就可以正确执行示例程序。

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
