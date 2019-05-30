//
//  QRScanReader.m
//  Bitcoin
//
//  Created by lewin on 2018/3/14.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "QRScanReader.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@implementation QRScanReader
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(readerQR:(NSString *)fileUrl success:(RCTPromiseResolveBlock)success failure:(RCTResponseErrorBlock)failure){
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        //從相簿
        if ([fileUrl containsString:@"assets-library:"]) {
            [self readerQRFromAssets:fileUrl completion:^(NSString *result) {
                if(result){
                    success(result);
                } else {
                    NSString *domain = @"ed.liao";
                    NSString *desc = @"取得相片失敗";
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
                    NSError *error = [NSError errorWithDomain:domain
                                                         code:404
                                                     userInfo:userInfo];
                    failure(error);
                }
            }];
        } else {
            NSString *result = [self readerQRFromFile:fileUrl];
            if(result){
                success(result);
            }else{
                NSString *domain = @"yitang.xiao";
                NSString *desc = NSLocalizedString(@"没有相關二維碼", @"");
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
                NSError *error = [NSError errorWithDomain:domain
                                                     code:404
                                                 userInfo:userInfo];
                failure(error);
            }
        }
    });
}

-(void)readerQRFromAssets:(NSString*)fileUrl completion:(void(^)(NSString* result))completion{
    NSURL* url = [NSURL URLWithString:fileUrl];
    PHFetchResult* result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    [[PHImageManager defaultManager] requestImageDataForAsset:result.firstObject options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        CIImage *ciImagee = [CIImage imageWithData:imageData];
        CIContext *context = [CIContext contextWithOptions:nil];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        NSArray *features = [detector featuresInImage:ciImagee];
        if(!features || features.count==0){
            completion(nil);
            return;
        }
        //3. 获取扫描结果
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        
        completion(scannedResult);
    }];
}

-(NSString*)readerQRFromFile:(NSString*)fileUrl {
    fileUrl = [fileUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:fileUrl];
    CIImage *ciImage = [CIImage imageWithData:fileData];
    NSArray *features = [detector featuresInImage:ciImage];
    if(!features || features.count==0){
        return nil;
    }
    //3. 获取扫描结果
    CIQRCodeFeature *feature = [features objectAtIndex:0];
    NSString *scannedResult = feature.messageString;
    return scannedResult;
}

@end
