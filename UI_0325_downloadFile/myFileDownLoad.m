//
//  myFileDownLoad.m
//  UI_0325_downloadFile
//
//  Created by scuplt on 16-3-24.
//  Copyright (c) 2016年 itcast0413. All rights reserved.
//
#define  kTimeOut 2.0f
#define  kBytesPerTimes 20480
#import "myFileDownLoad.h"
#import <UIKit/UIImage.h>
#import "NSString+Password.h"

@interface myFileDownLoad()
/* cache 文件  */
@property (nonatomic,strong) NSString *cacheFile_allPath;
@property (nonatomic,strong) UIImage *cacheImage;

@end


@implementation myFileDownLoad

/* 路径  */
-(void)setCacheFile_allPath:(NSString *)cacheFile_allPath{
    NSString *cacheDir=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES)[0];
    cacheFile_allPath=[cacheFile_allPath MD5];//使用md5
    
    _cacheFile_allPath=[cacheDir stringByAppendingPathComponent:cacheFile_allPath];
}
/* 图片  */
-(UIImage *)cacheImage{
    if(_cacheImage==nil){
        _cacheImage=[UIImage imageWithContentsOfFile:self.cacheFile_allPath];
    }
    return _cacheImage;
}

/* url 字节们   下载 */
-(void)downloadFilewithURL:(NSURL *)url andCompletion:(void(^)(UIImage *image) )completion{
    
    //gdc 中的 串行队列 异步 方法
    dispatch_queue_t qt=dispatch_queue_create("cn.sendsi.com", DISPATCH_QUEUE_SERIAL);
    dispatch_async(qt, ^{
        NSLog(@"%@",[NSThread currentThread]);
        self.cacheFile_allPath=[url absoluteString ];// 把对URL进行MD5加密之后的结果当成文件名
        
        long long fileSize=[self fileSizeWithURL:url];   // 1. 从网络下载文件,需要知道这个文件的大小
        long long cacheFileSize=[self localFileSize];        // 计算本地缓存文件大小
        if(cacheFileSize ==fileSize){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self.cacheImage);
            });
            NSLog(@"文件已存在");
            return;
        }
        long long from_B=0;
        long long to_B=0;
        while (fileSize>kBytesPerTimes) {
            to_B=from_B+kBytesPerTimes-1;
            NSString *range=[NSString stringWithFormat:@"Bytes=%lld-%lld",from_B,to_B];
            NSLog(@"rang=%@",range);
            
            fileSize-=kBytesPerTimes;//减去原来的
            from_B+=kBytesPerTimes;//
        }
        [self downLoad_Data_withURL:url andFrom_B:from_B andTo_B:from_B+fileSize-1];//下载文件
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self.cacheImage);
        });
    });
}

/* 得到文件 大小   */
-(long long)fileSizeWithURL:(NSURL *)url{
    //request 头  response  response.expectedContentLength
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod=@"HEAD";
    NSURLResponse *response=nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    return response.expectedContentLength;
}
/* 下载文件 小范围 字节  */
-(void)downLoad_Data_withURL:(NSURL *)url andFrom_B:(long long)from_B andTo_B:(long long) to_B{
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeOut];//NSURLRequestReloadIgnoringCacheData忽略本机请求的缓存
    NSURLResponse *responese=nil;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&responese error:NULL];
    [self appendData:data];//追加 文件
}

#pragma mark -追加文件
-(void)appendData:(NSData *)data{
    NSFileHandle *fp=[NSFileHandle fileHandleForReadingAtPath:self.cacheFile_allPath];
    if(!fp){
        [data writeToFile:self.cacheFile_allPath atomically:YES];
    }else{//文件存在,追加文件
        [fp  seekToEndOfFile];//移动到文件末尾
        [fp writeData:data];//追加数据
        [fp closeFile];//关闭文件
    }
}

/* 计算 本地文件   */
-(long long) localFileSize{
    NSDictionary *dict=[[NSFileManager defaultManager] attributesOfItemAtPath:self.cacheFile_allPath error:NULL];
    NSLog(@"dict=%lld",[dict[NSFileSize ]longLongValue]);
    return [dict[NSFileSize] longLongValue];
}

@end




















