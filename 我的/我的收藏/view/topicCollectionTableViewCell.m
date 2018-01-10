//
//  topicCollectionTableViewCell.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "topicCollectionTableViewCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "linkButton.h"


@implementation topicCollectionTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI
{
    self.contentView.backgroundColor=[UIColor whiteColor];
    _iconButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_iconButton addTarget:self action:@selector(GotoAddFriend:) forControlEvents:UIControlEventTouchUpInside];
    _iconButton.layer.cornerRadius=17.5;
    _iconButton.layer.masksToBounds=YES;
    [self.contentView addSubview:_iconButton];
    
    _nameLabel=[[UILabel alloc]init];
    _nameLabel.font=[UIFont systemFontOfSize:15.0];
    _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16.0];
    [self.contentView addSubview:_nameLabel];
    
    _TimeLabel=[[UILabel alloc]init];
    _TimeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13.0];
    _TimeLabel.textColor=darkTitleColor;
    [self.contentView addSubview:_TimeLabel];
    
    _contentLabel=[[UILabel alloc]init];
    _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15.0];
    _contentLabel.textColor=blackTitleColor;
    _contentLabel.numberOfLines=5;
    [self.contentView addSubview:_contentLabel];
    
    _OcrView=[[UIView alloc]init];
    _OcrView.backgroundColor=[UIColor clearColor];
    _OcrView.userInteractionEnabled=YES;
    [self.contentView addSubview:_OcrView];
    
    _tagView=[[UIView alloc]init];
    _tagView.backgroundColor=[UIColor clearColor];
    _tagView.userInteractionEnabled=YES;
    [self.contentView addSubview:_tagView];
    
    _lineView=[[UIView alloc]init];
    _lineView.backgroundColor=grayBackColor;
    [self.contentView addSubview:_lineView];
    
    _helpBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_helpBtn setTitle:@"求助" forState:UIControlStateNormal];
    [_helpBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [_helpBtn.titleLabel setFont:YiZhenFont13];
    [_helpBtn setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    [_helpBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [_helpBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 33)];
    [_helpBtn addTarget:self action:@selector(pressGoToHelpList:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_helpBtn];
    
    _replayLabel=[[UILabel alloc]init];
    _replayLabel.textColor=darkTitleColor;
    _replayLabel.font=YiZhenFont12;
    [self.contentView addSubview:_replayLabel];
    
    UIImageView*replyImage=[[UIImageView alloc]init];
    replyImage.image=[UIImage imageNamed:@"replies"];
    replyImage.contentMode=UIViewContentModeCenter;
    [self.contentView addSubview:replyImage];
    
    //适配屏幕
    [_iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@15);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconButton.mas_right).with.offset(10);
        make.top.equalTo(@21);
        make.height.equalTo(@22);
    }];
    
    [_TimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@15);
        make.right.equalTo(@-15);
    }];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_nameLabel.mas_bottom).with.offset(4);
        make.left.mas_equalTo(_iconButton.mas_right).with.offset(10);
        make.right.equalTo(@-15);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-40);
        make.left.equalTo(@60);
        make.height.equalTo(@0.5);
        make.right.equalTo(@-15);
    }];
    
    [_replayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@17);
        make.right.equalTo(@-15);
        make.bottom.equalTo(@-11);
    }];
    [replyImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-12);
        make.right.mas_equalTo(_replayLabel.mas_left).with.offset(-7);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    [_helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-10);
        make.left.equalTo(@60);
        make.size.mas_equalTo(CGSizeMake(55, 22));
    }];
    
    [_OcrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentLabel);
        make.bottom.mas_equalTo(_lineView.mas_top).with.offset(-14);
        make.size.mas_equalTo(CGSizeMake(250, 80));
    }];
    
    [_tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentLabel);
        make.bottom.mas_equalTo(_lineView.mas_top).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(245, 22));
    }];
}
- (void)setModel:(topicModel *)model
{
    _model = model;
    
    [_iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:_model.creatorAvatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    _nameLabel.text=model.creatorName;
    _TimeLabel.text=[model create_time:model.updateTime];
    _contentLabel.text=_model.content;
    
    _helpBtn.hidden=NO;
    if (model.tagsArray.count<1) {
        _helpBtn.hidden=YES;
    }
    _replayLabel.text=[NSString stringWithFormat:@"%ld",model.replyAmount];
    //判断是否有图片
    NSInteger i=0;
    NSInteger j=0;
    _photoArray=[[NSMutableArray alloc]initWithCapacity:0];
    _photoUrlArray=[[NSMutableArray alloc]initWithCapacity:0];
    _OcrView.hidden=YES;
    _tagView.hidden=YES;
    
    if (model.attachmentList.count>0) {
        //复用前删除缓存的图片，防止图片因为没有数据而被缓存的图片复用
        [_OcrView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [_tagView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        
        for (attachmentListModel*attachModel in model.attachmentList) {
            //0为图片
            if(attachModel.type==0)
            {
                _OcrView.hidden=NO;
                UIImageView*photo=[[UIImageView alloc]initWithFrame:CGRectMake((80+7)*i, 0, 80, 80)];
                [photo sd_setImageWithURL:[NSURL URLWithString:attachModel.url] placeholderImage:[UIImage imageNamed:@"yulantu_3"]];
                photo.tag=500+i;
                photo.userInteractionEnabled = YES;
                [photo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPhotoTap:)]];
                NSArray*strArr=[attachModel.url componentsSeparatedByString:@"@"];
                NSString*photoUrl=strArr[0];
                [_photoUrlArray addObject:photoUrl];
                [_photoArray addObject:photo];
                [_OcrView addSubview:photo];
                i++;
                if (i>2) {
                    break;
                }
            }
            else {
                _tagView.hidden=NO;
                webUrl=attachModel.url;
                linkButton*linkBtn=[[linkButton alloc]initWithFrame:CGRectMake((22+30)*j, 0, 22, 22) andType:attachModel.type];
                [linkBtn addTarget:self action:@selector(GotoOcrWebView) forControlEvents:UIControlEventTouchUpInside];
                [_tagView addSubview:linkBtn];
                if (!_OcrView.hidden) {
                    [_tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(_contentLabel);
                        make.bottom.mas_equalTo(_OcrView.mas_top).with.offset(-10);
                        make.size.mas_equalTo(CGSizeMake(245, 22));
                        
                    }];
                }
                else{
                    [_tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(_contentLabel);
                        make.bottom.mas_equalTo(_lineView.mas_top).with.offset(-10);
                        make.size.mas_equalTo(CGSizeMake(245, 22));
                    }];
                }
                
                j++;
            }
        }
    }
    else
    {
        _OcrView.hidden=YES;
        _tagView.hidden=YES;
    }
    
    //    NSLog(@"_contentLabel.y==%lf",_contentLabel.frame.origin.y);
    //    NSLog(@"_moduleBtn.y==%lf",_moduleBtn.frame.origin.y);
    //    NSLog(@"_replayLabel.y==%lf",_replayLabel.frame.origin.y);
    //    NSLog(@"contentView.height==%lf",self.contentView.height);
}

#pragma mark-cell上buton的点击事件
-(void)pressGoToHelpList:(UIButton*)button
{
    _tagB(1);
}

-(void)GotoAddFriend:(UIButton*)button
{
    _personB(_model.creatorAvatar);
}

-(void)GotoOcrWebView
{
    _webB(webUrl);
}



#pragma mark-图片的点击事件
- (void)addPhotoTap:(UITapGestureRecognizer *)recognizer
{
    NSInteger count = _photoArray.count;
    
    // 1.封装图片数据
    NSMutableArray *myphotos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 一个MJPhoto对应一张显示的图片
        MJPhoto *mjphoto = [[MJPhoto alloc] init];
        
        mjphoto.srcImageView = _OcrView.subviews[i]; // 来源于哪个UIImageView
        mjphoto.url = [NSURL URLWithString:_photoUrlArray[i]]; // 图片路径
        
        [myphotos addObject:mjphoto];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = recognizer.view.tag-500; // 弹出相册时显示的第一张图片是？
    browser.photos = myphotos; // 设置所有的图片
    [browser show];
}

@end
