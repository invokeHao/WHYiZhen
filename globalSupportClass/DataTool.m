//
//  LimitDataTool.m
//  iAppFree
//
//  Created by 尤锐 on 15/12/7.
//  Copyright (c) 2015年 尤锐. All rights reserved.
//

#import "DataTool.h"

@implementation DataTool

+ (DataTool *)shareInstance{
    static DataTool *tool = nil;
    if (tool == nil) {
        tool = [[DataTool alloc]init];
    }
    return tool;
}

- (id)init{
    if (self = [super init]) {
        
        // 创建当前的数据库
        _database = [[FMDatabase alloc]initWithPath:[self currentPath]];
 //       NSLog(@"%@",[self currentPath]);
        if ([_database open]) {
            
            YiZhenLog(@"数据库打开成功");
        }else{
            YiZhenLog(@"打开数据库失败");
        }
    }
    return self;
}

- (void)setTableName:(NSString *)tableName
{
    if ([_tableName isEqualToString:tableName])
    {
        return;
    }
    _tableName = tableName;
    [self createTable];
}


- (void)setTableStatu:(DataToolTableNameStatu)tableStatu
{
    if (_tableStatu == tableStatu) {
        return;
    }
    _tableStatu = tableStatu;
    switch (tableStatu) {
        case DataToolTableNameStatuliveList:
        { self.tableName = @"LiveList";
            break;
        }
        case DataToolTableNameStatuSport:
        {
            self.tableName = @"SportList";
            break;
        }
        case DataToolTableNameStatuCollect:
        {
            self.tableName = @"collectList";
            break;
        }
        case DataToolTableNameStatuUser:
        {
            self.tableName = @"UserList";
            break;
        }
        case DataToolTableNameStatuDownLoad:
        {
            self.tableName = @"DownLoadList";
            break;
        }
    }
    
}

// 封装了当前数据库路径(自动创建路径)
- (NSString *)currentPath{
    NSString *path = [NSString stringWithFormat:@"%@/Documents/YiZhen",NSHomeDirectory()];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/YiZhen.db",path];
}

- (void)createTable
{
    NSInteger tabelType=_tableStatu;
    switch (tabelType) {
        case 1:
        {
            NSString *createSql =[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,liveId varchar(128))",_tableName];
            [_database executeUpdate:createSql];
            NSLog(@"创建表%@成功",_tableName);
            break;
        }
        case 2:
        {
            NSString *createSql =[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,distance integer,step integer,runTime integer,calorie integer,bpm integer)",_tableName];
            [_database executeUpdate:createSql];
            NSLog(@"创建表%@成功",_tableName);
            break;
        }
        case 3:
        {
            NSString *createSql =[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,albumUrl varchar(256),name varchar(128),bpm varchar(128),author varchar(128),trackLength integer,collectNumber integer,IDS integer)",_tableName];
            [_database executeUpdate:createSql];
            NSLog(@"创建表%@成功",_tableName);
            break;
        }
        case 4:
        {
            NSString *createSql =[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,IDS integer,email varchar(128),password varchar(128))",_tableName];
            [_database executeUpdate:createSql];
            NSLog(@"创建表%@成功",_tableName);
            break;
        }
        case 5:
        {
            NSString *createSql =[NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,albumUrl varchar(256),name varchar(128),bpm varchar(128),author varchar(128),trackLength integer,collectNumber integer,IDS integer)",_tableName];
            [_database executeUpdate:createSql];
            NSLog(@"创建表%@成功",_tableName);
            break;
        }
    }
    
}

//- (NSArray *)selectAllModel{
//    
//    NSInteger tabelType=_tableStatu;
//    switch (tabelType) {
//        case 1:
//        {
//            NSString *selectSql =[NSString stringWithFormat:@"select * from %@",_tableName];
//            
//            // 搜索结果集
//            FMResultSet *result = [_database executeQuery:selectSql];
//            
//            NSMutableArray *array = [NSMutableArray array];
//            
//            while ([result next]) {
//                musicModel *model = [[musicModel alloc]init];
//                model.albumUrl = [result stringForColumn:@"albumUrl"];
//                model.name = [result stringForColumn:@"name"];
//                model.bpm = [result stringForColumn:@"bpm"];
//                model.author = [result stringForColumn:@"author"];
//                model.collectNumber=[[result stringForColumn:@"collectNumber"] integerValue];
//                model.trackLength=[[result stringForColumn:@"trackLength"] integerValue];
//                [array addObject:model];
//            }
//            return array;
//            break;
//        }
//        case 2:
//        {
//            NSString *selectSql =[NSString stringWithFormat:@"select * from %@",_tableName];
//            
//            // 搜索结果集
//            FMResultSet *result = [_database executeQuery:selectSql];
//            
//            NSMutableArray *array = [NSMutableArray array];
//            
//            while ([result next]) {
//                LastRunModel *model = [[LastRunModel alloc]init];
//                model.distance = [[result stringForColumn:@"distance"] integerValue];
//                model.step = [[result stringForColumn:@"step"] integerValue];
//                model.runTime = [[result stringForColumn:@"runTime"] integerValue];
//                model.calorie = [[result stringForColumn:@"calorie"] integerValue];
//                model.bpm=[[result stringForColumn:@"bpm"] integerValue];
//                [array addObject:model];
//            }
//            return array;
//            break;
//        }
//        case 3:
//        {
//            NSString *selectSql =[NSString stringWithFormat:@"select * from %@",_tableName];
//            
//            // 搜索结果集
//            FMResultSet *result = [_database executeQuery:selectSql];
//            
//            NSMutableArray *array = [NSMutableArray array];
//            
//            while ([result next]) {
//                musicModel *model = [[musicModel alloc]init];
//                model.albumUrl = [result stringForColumn:@"albumUrl"];
//                model.name = [result stringForColumn:@"name"];
//                model.bpm = [result stringForColumn:@"bpm"];
//                model.author = [result stringForColumn:@"author"];
//                model.collectNumber=[[result stringForColumn:@"collectNumber"] integerValue];
//                model.trackLength=[[result stringForColumn:@"trackLength"] integerValue];
//                model.IDS=[[result stringForColumn:@"IDS"]integerValue];
//                [array addObject:model];
//            }
//            return array;
//            break;
//        }
//        case 5:
//       {
//           NSString *selectSql =[NSString stringWithFormat:@"select * from %@",_tableName];
//           
//           // 搜索结果集
//           FMResultSet *result = [_database executeQuery:selectSql];
//           
//           NSMutableArray *array = [NSMutableArray array];
//           
//           while ([result next]) {
//               musicModel *model = [[musicModel alloc]init];
//               model.albumUrl = [result stringForColumn:@"albumUrl"];
//               model.name = [result stringForColumn:@"name"];
//               model.bpm = [result stringForColumn:@"bpm"];
//               model.author = [result stringForColumn:@"author"];
//               model.collectNumber=[[result stringForColumn:@"collectNumber"] integerValue];
//               model.trackLength=[[result stringForColumn:@"trackLength"] integerValue];
//               model.IDS=[[result stringForColumn:@"IDS"]integerValue];
//               [array addObject:model];
//           }
//           return array;
//           break;
//       }
//
//    }
//   
//    return nil;
//}

//账号密码的查询

-(NSMutableArray*)selectAllLive
{
    NSString *selectSql =[NSString stringWithFormat:@"select * from %@",_tableName];
    
    // 搜索结果集
    FMResultSet *result = [_database executeQuery:selectSql];
    
    NSMutableArray *array = [NSMutableArray array];
    while ([result next]) {
        NSString * liveID = [result stringForColumn:@"liveId"];
//        model.email = [result stringForColumn:@"email"];
//        model.password = [result stringForColumn:@"password"];
        [array addObject:liveID];
    }
    return array;
}

-(void)insertALive:(NSString*)liveId
{
    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(liveId)values(?)",_tableName];
    BOOL insert = [_database executeUpdate:insertSql,liveId];
    
    if (insert) {
        NSLog(@"插入成功");
    }else{
        NSLog(@"插入失败");
    }

}

//- (void)insertAnMusicModel:(musicModel *)model
//{
////    if ([self checkOutWithName:model.name]) {
////        return;
////    }
//    
//    NSString*collectNumber=[NSString stringWithFormat:@"%ld",model.collectNumber];
//    NSString*trackLength=[NSString stringWithFormat:@"%ld",model.trackLength];
//    
//    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(albumUrl,name,bpm,author,collectNumber,trackLength)values(?,?,?,?,?,?)",_tableName];
//    BOOL insert = [_database executeUpdate:insertSql,model.albumUrl,model.name,model.bpm,model.author,collectNumber,trackLength];
//    
//    if (insert) {
//        NSLog(@"插入成功");
//    }else{
//        NSLog(@"插入失败");
//    }
//}
//
//- (BOOL)checkOutWithName:(NSString *)name{
//    
//    NSInteger tabelType=_tableStatu;
//    
//    switch (tabelType) {
//        case 1:
//        {
//            NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where name = '%@'",_tableName,name];
//            BOOL flag = NO;
//            FMResultSet *result = [_database executeQuery:selectSql];
//            while ([result next]) {
//                flag = YES;
//                break;
//            }
//            return flag;
//            break;
//        }
//        case 4:
//        {
//            NSString *selectSql = [NSString stringWithFormat:@"select * from %@ where name = '%@'",_tableName,name];
//            BOOL flag = NO;
//            FMResultSet *result = [_database executeQuery:selectSql];
//            while ([result next]) {
//                flag = YES;
//                break;
//            }
//            return flag;
//            break;
//        }
//    }
//
//    return nil;
//}

//-(void)insertAnSportModel:(LastRunModel *)model
//{
//    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(distance,step,runTime,calorie,bpm)values(?,?,?,?,?)",_tableName];
//    NSString*distance=[NSString stringWithFormat:@"%ld",model.distance];
//    NSString*step=[NSString stringWithFormat:@"%ld",model.step];
//    NSString*runTime=[NSString stringWithFormat:@"%ld",model.runTime];
//    NSString*calorie=[NSString stringWithFormat:@"%ld",model.calorie];
//    NSString*bpm=[NSString stringWithFormat:@"%ld",model.bpm];
//    
//    BOOL insert = [_database executeUpdate:insertSql,distance,step,runTime,calorie,bpm];
//    
//    if (insert) {
//        NSLog(@"插入成功");
//    }else{
//        NSLog(@"插入失败");
//    }
//}
//
//-(void)insertAnCollectModel:(musicModel *)model
//{
//    if ([self checkOutWithName:model.name]) {
//            return;
//    }
//    
//    NSString*collectNumber=[NSString stringWithFormat:@"%ld",model.collectNumber];
//    NSString*trackLength=[NSString stringWithFormat:@"%ld",model.trackLength];
//    NSString*IDS=[NSString stringWithFormat:@"%ld",model.IDS];
//    
//    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(albumUrl,name,bpm,author,collectNumber,trackLength,IDS)values(?,?,?,?,?,?,?)",_tableName];
//    BOOL insert = [_database executeUpdate:insertSql,model.albumUrl,model.name,model.bpm,model.author,collectNumber,trackLength,IDS];
//    
//    if (insert) {
//        NSLog(@"插入成功");
//    }else{
//        NSLog(@"插入失败");
//    }
//}
//
//-(void)insertAnUserModel:(UserModel *)model
//{
//    if ([self checkOutWithName:model.name]) {
//        return;
//    }
//    
////    NSLog(@"%@-%@-%@-%ld",model.password,model.email,model.name,model.IDS);
//    
//   NSString*IDS=[NSString stringWithFormat:@"%ld",model.IDS];
//    
//    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(IDS,email,password)values(?,?,?)",_tableName];
//    BOOL insert = [_database executeUpdate:insertSql,IDS,model.email,model.password];
//    
//    if (insert) {
//        NSLog(@"插入成功");
//    }else{
//        NSLog(@"插入失败");
//    }
//}

- (void)removeTable{
    NSString *dropSql =[NSString stringWithFormat:@"drop table %@",_tableName];
    [_database executeUpdate:dropSql];
    NSLog(@"删除表%@成功",_tableName);
    [self createTable];
}

//-(void)removeModelFromTable:(musicModel *)model
//{
//    NSString*deleteSql=[NSString stringWithFormat:@"DELETE FROM %@ WHERE name = %@",_tableName,model.name];
//    [_database executeUpdate:deleteSql];
//    NSLog(@"移除%@",model.name);
//}


@end
