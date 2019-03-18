//
//  RFDataManager.h
//  RFProj
//
//  Created by liuwei on 2019/3/15.
//  Copyright © 2019年 com.LW. All rights reserved.
//

#import "FMDatabase.h"

typedef enum : NSUInteger {
    OrderDESC = 0,
    OrderASC,
} DataOrderByType;

NS_ASSUME_NONNULL_BEGIN

@interface RFDataManager : FMDatabase

+(instancetype)sharedDataBase;
//判断表是否存在
-(BOOL)isHasTable:(NSString *)tableName;

// 创建表
-(BOOL)createTableWithName:(NSString *)tableName keys:(__kindof NSArray <NSString *> *)keys;

//插入数据
-(BOOL)insertDataToTable:(NSString *)tableName withKeys:(__kindof NSArray <NSString *> *)keys andValue:(__kindof NSArray <NSString *> *)values;


/**
 查找数据（模糊查询）
 
 @param tableName 表名字
 @param key 要查找的key
 @param keyword 要查找的key的值
 @param keysArray 要返回字典带的参数
 @return 返回字典数组
 */
- (NSArray *)queryFuzzysearchDataFromTable:(NSString *)tableName withKey:(NSString *)key andKeyWord:(NSString *)keyword getResultsWithKeys:(__kindof NSArray<NSString *> *)keysArray;

/**
 模糊查询+排序
 
 @param tableName 表名
 @param key 要查找的key
 @param keyword 要查找的key的值
 @param keysArray 要返回字典带的参数
 @param orderKey 要排序的key
 @param type 升序、降序
 @return 返回字典数组
 */
- (NSArray *)queryFuzzysearchDataFromTable:(NSString *)tableName withKey:(NSString *)key andKeyWord:(NSString *)keyword getResultsWithKeys:(__kindof NSArray<NSString *> *)keysArray orderByKey:(NSString *)orderKey andOrderByType:(DataOrderByType)type;

/**
 查找数据
 
 @param tableName 表名字
 @param key 要查找的key
 @param keyword 要查找的key的值
 @param keysArray 要返回字典带的参数
 @return 返回字典数组
 */
- (NSArray *)queryDataFromTable:(NSString *)tableName withKey:(NSString *)key andKeyWord:(NSString *)keyword getResultsWithKeys:(__kindof NSArray<NSString *> *)keysArray;

/**
 修改数据
 
 @param tableName 表名
 @param keys 修改对应的key
 @param values 要修改的值
 @param key 条件key
 @param value 条件值
 @return 是否修改成功
 */
- (BOOL)updateDataToTable:(NSString *)tableName withKeys:(__kindof NSArray<NSString *> *)keys andValue:(__kindof NSArray<NSString *> *)values whereKey:(NSString *)key equalTo:(NSString *)value;


/**
 删除数据
 
 @param tableName 表名
 @param key 条件key
 @param value 条件值
 @return 是否删除成功
 */
- (BOOL)deleteDataFromTable:(NSString *)tableName whereKey:(NSString *)key equalTo:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
