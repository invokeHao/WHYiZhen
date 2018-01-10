#import <Foundation/Foundation.h>
#import "FMDatabase.h"

typedef enum {
    DataToolTableNameStatuliveList = 1,//直播列表
    DataToolTableNameStatuSport,
    DataToolTableNameStatuCollect,
    DataToolTableNameStatuUser,
    DataToolTableNameStatuDownLoad,
}DataToolTableNameStatu;

@interface DataTool : NSObject

@property (strong, nonatomic) FMDatabase *database;

@property (strong, nonatomic) NSString *tableName;

@property (assign, nonatomic) DataToolTableNameStatu tableStatu;


+ (DataTool *)shareInstance;

//- (NSArray *)selectAllModel;

-(NSMutableArray*)selectAllLive;

//- (void)insertAnMusicModel:(musicModel *)model;
//
//-(void)insertAnSportModel:(LastRunModel *)model;
//
//-(void)insertAnCollectModel:(musicModel *)model;
//
//-(void)insertAnUserModel:(UserModel*)model;
-(void)insertALive:(NSString*)liveId;

- (void)removeTable;

//-(void)removeModelFromTable:(musicModel*)model;

@end
