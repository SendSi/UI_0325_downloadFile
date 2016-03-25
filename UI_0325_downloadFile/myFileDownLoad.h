//
//  myFileDownLoad.h
//  UI_0325_downloadFile
//
//  Created by scuplt on 16-3-24.
//  Copyright (c) 2016年 itcast0413. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@interface myFileDownLoad : NSObject
-(void)downloadFilewithURL:(NSURL *)url andCompletion:(void(^)(UIImage *image) )completion;
@end
