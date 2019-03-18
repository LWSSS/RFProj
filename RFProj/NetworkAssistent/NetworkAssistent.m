//
//  NetworkAssistent.m
//  RFProj
//
//  Created by liuwei on 2019/3/13.
//  Copyright © 2019年 com.LW. All rights reserved.
//

#import "NetworkAssistent.h"
#import <MBProgressHUD/MBProgressHUD.h>


@protocol NetWorkProxy <NSObject>

@optional
/******AFN 内部的数据访问方法*******/
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end

@interface NetworkAssistent()<NSURLSessionDelegate,NetWorkProxy>

@end

@implementation NetworkAssistent



+(instancetype)sharedAssistent{
    static NetworkAssistent * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    });
    
    return instance;
}

-(instancetype)initWithBaseURL:(NSURL *)baseUrl{
    self = [super initWithBaseURL:baseUrl];
    if (self) {
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable) {
//                [MBProgressHUD showWithTitle:@"当前无网络连接"];
            }
        }];
        [self.reachabilityManager startMonitoring];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 20;
        [self.requestSerializer setValue:[NSString stringWithFormat:@"%@",[UIDevice currentDevice].identifierForVendor] forHTTPHeaderField:@"APP-UDID"];
        
        //设置请求头
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@""];
        
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",nil];
    }
    return self;
}

//AFN内部的请求方法
-(void)OriginRequestDataByMethod:(RequestMethod)requestMethod url:(NSString *)url showHud:(BOOL)showHud paragrams:(NSMutableDictionary *)params finishBlock:(void(^)(id responseObj,NSError * error))finishBlock{
    [self requestDataByMethod:requestMethod url:url params:params hud:showHud finishBlock:finishBlock];
    
}

-(void)requestDataByMethod:(RequestMethod)requestMethod url:(NSString *)url params:(NSDictionary *)params hud:(BOOL)hud finishBlock:(void (^)(id responseObj, NSError * error))finishBlock{
    if (!url.length) {
        NSLog(@"url is nil");
        finishBlock(nil,nil);
        return;
    }
    
    if (hud) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    NSString * method = @"";
    switch (requestMethod) {
        case GET:
            method = @"GET";
            break;
        case POST:
            method = @"POST";
            break;
        default:
            break;
    }
    
    [self dataTaskWithHTTPMethod:method URLString:url parameters:params uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSInteger  code = [[dict objectForKey:@"code"] integerValue];
        NSDictionary * data = [dict objectForKey:@"result"];
        if (code == 200) {
            //请求成功
            finishBlock(data,nil);
        }else if (code == 403){
            NSDictionary * dataCode = @{@"code" : [NSString stringWithFormat:@"%ld",(long)code]};
            finishBlock(dataCode,nil);
        }
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
//        [MBProgressHUD showWithTitle:@"request failed"];
        finishBlock(nil, error);
    }];
}

//普通请求方法
-(void)RequestDataByMethod:(RequestMethod)requestMethod url:(NSString *)url showHud:(BOOL)showHud paragrams:(NSMutableDictionary *)params finishBlock:(void(^)(id responseObj, NSError * error))finishBlock{
    if (!url.length) {
        finishBlock(nil,nil);
        NSLog(@"缺少网络接口");
        return;
    }
    
    if (showHud) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    
    NSString * requestType = @"";
    switch (requestMethod) {
        case GET:
            requestType = @"GET";
            break;
        case POST:
            requestType = @"POST";
        default:
            break;
    }
    
    AFHTTPSessionManager * requestManager = [AFHTTPSessionManager manager];
    if ([requestType  isEqualToString:@"GET"]) {
        [requestManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"网络请求成功");
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [[dict objectForKey:@"code"] integerValue];
            NSDictionary * data = [dict objectForKey:@"result"];
            if (code == 200) {
                finishBlock(data,nil);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"网络请求失败：%@",error.debugDescription);
            finishBlock(nil,error);
        }];
    }else if ([requestType isEqualToString:@"POST"]){
        [requestManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"网络请求失败");
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [[dict objectForKey:@"code"] integerValue];
            NSDictionary * data = [dict objectForKey:@"result"];
            if (code == 200) {
                finishBlock(data,nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"网络请求失败：%@",error.debugDescription);
        }];
    }
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

-(void)uploadImageWithURL:(NSString *)url params:(NSDictionary *)params images:(NSArray<NSString *> *)images progress:(RFUploadImageProgressBlock)progressBlock success:(RFUploadImagesuccessBlock)successBlock fail:(RFUploadImagefailBlock)failBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString * image in images) {
            NSData * data=UIImageJPEGRepresentation([UIImage imageNamed:image], 0.7);
            [formData appendPartWithFileData:data name:image fileName:[NSString stringWithFormat:@"%@.jpg",image] mimeType:@"jpg/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        CGFloat pro = 100.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"%f", pro);
        progressBlock(pro);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject, @"uploadSuccess");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock(error);
    }];
}


#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        //客户端证书认证,https进行配置
        //提交证书*****
        NSString *path = [[NSBundle mainBundle]pathForResource:@""ofType:@"cer"];
        NSData *p12data = [NSData dataWithContentsOfFile:path];
        CFDataRef inP12data = (__bridge CFDataRef)p12data;
        SecIdentityRef myIdentity;
        OSStatus status = [self extractIdentity:inP12data toIdentity:&myIdentity];
        if (status != 0) {
            return;
        }
        SecCertificateRef myCertificate;
        SecIdentityCopyCertificate(myIdentity, &myCertificate);
        const void *certs[] = { myCertificate };
        CFArrayRef certsArray =CFArrayCreate(NULL, certs,1,NULL);
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:myIdentity certificates:(__bridge NSArray*)certsArray persistence:NSURLCredentialPersistencePermanent];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

-(OSStatus)extractIdentity:(CFDataRef)inP12Data toIdentity:(SecIdentityRef*)identity {
    OSStatus securityError = errSecSuccess;
    //输入证书密码*****
    CFStringRef password = CFSTR("");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12Data, options, &items);
    if (securityError == 0)
    {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }
    else
    {
        NSLog(@".cer error!");
    }
    
    if (options) {
        CFRelease(options);
    }
    return securityError;
}

@end
