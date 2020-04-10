//
//  ViewController.m
//  指定view截图不失真
//
//  Created by macbook on 2020/4/10.
//  Copyright © 2020 制作贴纸. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}
/// 获取指定view的截图
-(UIImage *)doScreenShotWithImageView:(UIImageView *)imgV{
    CGRect imageRect = CGRectMake(imgV.frame.origin.x, imgV.frame.origin.y, imgV.frame.size.width, imgV.frame.size.height);
      // 获取该页面截图
//          UIGraphicsBeginImageContext(self.view.bounds.size);
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0); //后面的两个参数保证了不失真
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *imgeForSelfView = UIGraphicsGetImageFromCurrentImageContext(); // 截全屏，此时不失真
    // 获取图片框内用户看到图片
    CGFloat scale = imgeForSelfView.scale;
    imageRect.origin.x *= scale;
    imageRect.origin.y *= scale;
    imageRect.size.width *= scale;
    imageRect.size.height *= scale;
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imgeForSelfView.CGImage, imageRect);
//          UIImage * cutImage = [[UIImage alloc] initWithCGImage:imageRefRect]; // 这种也会失真，有可能是因为scale
    UIImage *cutImage = [UIImage imageWithCGImage:imageRefRect scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRefRect);
    
    return cutImage;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UIImage *myScreenShot = [self doScreenShotWithImageView:_imgV];
    // 保存到相册
    
    // 这种有人说会失真，但是我在真机上并没有看出来，
//    UIImageWriteToSavedPhotosAlbum(myScreenShot, NULL, NULL, NULL);
    
    // PHPhotoLibrary
    NSString *path = NSHomeDirectory();
    NSString *imgPath = [path stringByAppendingFormat:@"/Documents/cutImg.png"];
    [UIImagePNGRepresentation(myScreenShot) writeToFile:imgPath atomically:YES]; // 将图片data写进沙盒
    
    // 保存图片
    NSURL *imgUrl = [NSURL URLWithString:imgPath];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            PHPhotoLibrary *lib = [PHPhotoLibrary sharedPhotoLibrary];
            [lib performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:myScreenShot]; // 这种可以不写进沙盒
//                [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imgUrl];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    NSLog(@"成功");
                }
            }];
        }
    }];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"写进相册" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
