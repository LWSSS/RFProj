//
//  NetworkAssistent.h
//  RFProj
//
//  Created by liuwei on 2019/3/13.
//  Copyright © 2019年 com.LW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void(^RFUploadImageProgressBlock)(CGFloat progress);
typedef void(^RFUploadImagesuccessBlock)(id  _Nullable response, NSString * successInfo);
typedef void(^RFUploadImagefailBlock)(NSError * _Nonnull error);
typedef NS_ENUM(NSInteger, RequestMethod){
    GET,
    POST,
} ;

@interface NetworkAssistent : AFHTTPSessionManager

+(instancetype)sharedAssistent;

//AFN内部的请求方法
-(void)OriginRequestDataByMethod:(RequestMethod)requestMethod url:(NSString *)url showHud:(BOOL)showHud paragrams:(NSMutableDictionary *)params finishBlock:(void(^)(id responseObj,NSError * error))finishBlock;

-(void)RequestDataByMethod:(RequestMethod)requestMethod url:(NSString *)url showHud:(BOOL)showHud paragrams:(NSMutableDictionary *)params finishBlock:(void(^)(id responseObj, NSError * error))finishBlock;

-(void)uploadImageWithURL:(NSString *)url params:(NSDictionary *)params images:(NSArray<NSString *> *)images progress:(RFUploadImageProgressBlock)progressBlock success:(RFUploadImagesuccessBlock)successBlock fail:(RFUploadImagefailBlock)failBlock;
@end

