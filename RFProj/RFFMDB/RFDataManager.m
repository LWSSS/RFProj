//
//  RFDataManager.m
//  RFProj
//
//  Created by liuwei on 2019/3/15.
//  Copyright © 2019年 com.LW. All rights reserved.
//

#import "RFDataManager.h"

@implementation RFDataManager

+(instancetype)sharedDataBase{
    static RFDataManager * dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[RFDataManager alloc] init];
    });
    return dataManager;
}

//判断是否存在表
-(BOOL)isHasTable:(NSString *)tableName{
    FMResultSet * result = [self executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?",tableName];
    while ([result next]) {
        NSInteger count = [result intForColumn:@"count"];
        if (count == 0) {
            return  NO;
        }else{
            return YES;
        }
    }
    return NO;
}

//创建表
-(BOOL)createTableWithName:(NSString *)tableName keys:(__kindof NSArray <NSString *> *)keys{
    if (self.open) {
        NSString * dbLanguage = @"";
        for (int i = 0; i < keys.count; i++) {
            NSString * type = @"text";
            NSString * tableLanguage;
            if (i != 0) {
                tableLanguage = [NSString stringWithFormat:@", %@ %@ NOT NULL",keys[i],type];
            }else{
                tableLanguage = [NSString stringWithFormat:@" %@ %@ NOT NULL",keys[i],type];
            }
            dbLanguage = [dbLanguage stringByAppendingString:tableLanguage];
        }
        NSString * createTableDBString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer PRIMARY KEY AUTOINCREMENT, %@);", tableName,dbLanguage];
        BOOL result = [self executeUpdate:createTableDBString];
        return result;
    }else{
        return NO;
    }
}

//插入数据
-(BOOL)insertDataToTable:(NSString *)tableName withKeys:(__kindof NSArray <NSString *> *)keys andValue:(__kindof NSArray <NSString *> *)values{
    if (keys.count != values.count) {
        NSLog(@"键值数量不对应...");
        return NO;
    }
    NSString * keysString = @"";
    NSString * valuesString = @"";
    for (int i = 0; i < keys.count; i++) {
        NSString * keyTempString;
        NSString * valueTempString;
        if (i != 0) {
            keyTempString = [NSString stringWithFormat:@", %@",keys[i]];
            valueTempString = [NSString stringWithFormat:@", \"%@\"",values[i]];
        }else{
            keyTempString = [NSString stringWithFormat:@" %@",keys[i]];
            valueTempString = [NSString stringWithFormat:@" \"%@\"",values[i]];
        }
        keysString = [keysString stringByAppendingString:keyTempString];
        valuesString = [valuesString stringByAppendingString:valueTempString];
    }
    return [self executeQuery:[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);",tableName,keysString,valuesString]];
}

/**
 查找数据（模糊查询）
 
 @param tableName 表名字
 @param key 要查找的key
 @param keyword 要查找的key的值
 @param keysArray 要返回字典带的参数
 @return 返回字典数组
 */
- (NSArray *)queryFuzzysearchDataFromTable:(NSString *)tableName withKey:(NSString *)key andKeyWord:(NSString *)keyword getResultsWithKeys:(__kindof NSArray<NSString *> *)keysArray
{
    NSString *seletedString = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    if (key != nil && keyword != nil) {
        NSString *fuzzysearchKeyword = [NSString stringWithFormat:@"%@%@%@",@"%",keyword,@"%"];
        seletedString = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ like \'%@\'",tableName,key,fuzzysearchKeyword];
    }
    FMResultSet *resultSet = [self executeQuery:seletedString];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while ([resultSet next]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *keyString in keysArray) {
            dic[keyString] = [resultSet stringForColumn:keyString];
        }
        [resultArray addObject:dic];
    }
    return [resultArray copy];
}

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
- (NSArray *)queryFuzzysearchDataFromTable:(NSString *)tableName withKey:(NSString *)key andKeyWord:(NSString *)keyword getResultsWithKeys:(__kindof NSArray<NSString *> *)keysArray orderByKey:(NSString *)orderKey andOrderByType:(DataOrderByType)type{
    NSString *seletedString = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    if (key != nil && keyword != nil) {
        NSString *fuzzysearchKeyword = [NSString stringWithFormat:@"%@%@%@",@"%",keyword,@"%"];
        seletedString = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ like \'%@\'",tableName,key,fuzzysearchKeyword];
        seletedString = [NSString stringWithFormat:@"%@ order by %@ %@",seletedString, orderKey, type==OrderDESC ? @"desc":@"asc"];
    }
    FMResultSet *resultSet = [self executeQuery:seletedString];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while ([resultSet next]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *keyString in keysArray) {
            dic[keyString] = [resultSet stringForColumn:keyString];
        }
        [resultArray addObject:dic];
    }
    return [resultArray copy];
}


/**
 查找数据
 
 @param tableName 表名字
 @param key 要查找的key
 @param keyword 要查找的key的值
 @param keysArray 要返回字典带的参数
 @return 返回字典数组
 */
- (NSArray *)queryDataFromTable:(NSString *)tableName withKey:(NSString *)key andKeyWord:(NSString *)keyword getResultsWithKeys:(__kindof NSArray<NSString *> *)keysArray
{
    NSString *seletedString = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    if (key != nil && keyword != nil) {
        seletedString = [NSString stringWithFormat:@"SELECT * FROM %@ where %@=\'%@\'",tableName,key,keyword];
    }
    FMResultSet *resultSet = [self executeQuery:seletedString];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while ([resultSet next]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *keyString in keysArray) {
            dic[keyString] = [resultSet stringForColumn:keyString];
        }
        [resultArray addObject:dic];
    }
    return [resultArray copy];
}

/**
 修改数据
 
 @param tableName 表名
 @param keys 修改对应的key
 @param values 要修改的值
 @param key 条件key
 @param value 条件值
 @return 是否修改成功
 */
- (BOOL)updateDataToTable:(NSString *)tableName withKeys:(__kindof NSArray<NSString *> *)keys andValue:(__kindof NSArray<NSString *> *)values whereKey:(NSString *)key equalTo:(NSString *)value
{
    if (keys.count != values.count) {
        NSLog(@"keys的数量和values数量不对应......");
        return NO;
    }
    NSString *setString = @"";
    for (int i = 0; i < keys.count; i++) {
        NSString *tempString;
        
        if (i != 0) {
            tempString = [NSString stringWithFormat:@", %@=\'%@\'",keys[i],values[i]];
            
        } else {
            tempString = [NSString stringWithFormat:@" %@=\'%@\'",keys[i],values[i]];
        }
        setString = [setString stringByAppendingString:tempString];
    }
    NSString *str = [NSString stringWithFormat:@"update %@ set %@ where %@ = \'%@\'",tableName,setString,key,value];
    
    return [self executeUpdate:str];
}

/**
 删除数据
 
 @param tableName 表名
 @param key 条件key
 @param value 条件值
 @return 是否删除成功
 */
- (BOOL)deleteDataFromTable:(NSString *)tableName whereKey:(NSString *)key equalTo:(NSString *)value
{
    NSString *str = [NSString stringWithFormat:@"delete from %@ where %@ = \'%@\'",tableName,key,value];
    return [self executeUpdate:str];
}
@end
