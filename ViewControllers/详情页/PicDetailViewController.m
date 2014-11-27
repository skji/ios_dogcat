//
//  PicDetailViewController.m
//  MyPetty
//
//  Created by miaocuilin on 14-8-22.
//  Copyright (c) 2014年 AidiGame. All rights reserved.
//

#import "PicDetailViewController.h"
#import "PresentDetailViewController.h"
#import "IQKeyboardManager.h"
#import "PetInfoModel.h"
#import "ToolTipsViewController.h"
#import "PetInfoViewController.h"
#import "MassWatchViewController.h"
#import "QuickGiftViewController.h"
#import "SendGiftViewController.h"

#define Alpha 0.4
//礼物条、评论、头像之间的间隔
#define Space 6
@interface PicDetailViewController ()

@end

@implementation PicDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
//    self.sv.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
//    NSLog(@"%@", self.usr_id);
    //注册完之后更新按钮头像
    if (isLoaded) {
//        NSLog(@"%@", self.usr_id);
        [self loadCountryList];
        //更新头像
        NSLog(@"%@", [USER objectForKey:@"petInfoDict"]);
        BOOL a = [[USER objectForKey:@"petInfoDict"] isKindOfClass:[NSDictionary class]];
        if (a) {
            if (!([[[USER objectForKey:@"petInfoDict"] objectForKey:@"tx"] isKindOfClass:[NSNull class]] || [[[USER objectForKey:@"petInfoDict"] objectForKey:@"tx"] length]==0)) {
                NSString * docDir = DOCDIR;
                NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[USER objectForKey:@"petInfoDict"] objectForKey:@"tx"]]];
                //        NSLog(@"--%@--%@", txFilePath, self.headImageURL);
                UIImage * image = [UIImage imageWithContentsOfFile:txFilePath];
                if (image) {
                    [self.headButton setBackgroundImage:image forState:UIControlStateNormal];
                    //            headImageView.image = image;
                }else{
                    //下载头像
                    NSString * url = [NSString stringWithFormat:@"%@%@", PETTXURL, [[USER objectForKey:@"petInfoDict"] objectForKey:@"tx"]];
                    NSLog(@"%@", url);
                    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
                        if (isFinish) {
                            [self.headButton setBackgroundImage:load.dataImage forState:UIControlStateNormal];
                            //                    headImageView.image = load.dataImage;
                            NSString * docDir = DOCDIR;
                            NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[USER objectForKey:@"petInfoDict"] objectForKey:@"tx"]]];
                            [load.data writeToFile:txFilePath atomically:YES];
                        }else{
                            NSLog(@"头像下载失败");
                        }
                    }];
                    [request release];
                }
            }
        }
    }
    
}
#pragma mark -
-(void)loadCountryList
{
    NSString * code = [NSString stringWithFormat:@"is_simple=1&usr_id=%@dog&cat", [USER objectForKey:@"usr_id"]];
    NSString * url = [NSString stringWithFormat:@"%@%d&usr_id=%@&sig=%@&SID=%@", USERPETLISTAPI, 1, [USER objectForKey:@"usr_id"], [MyMD5 md5:code], [ControllerManager getSID]];
    NSLog(@"%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            NSLog(@"%@", load.dataDict);
//            [self.userPetListArray removeAllObjects];
            NSArray * array = [load.dataDict objectForKey:@"data"];
            for(int i=0;i<array.count;i++){
                if ([[array[i] objectForKey:@"aid"] isEqualToString:self.aid]) {
                    self.label1.text = @"摇一摇";
                    [self.btn1 setBackgroundImage:[UIImage imageNamed:@"shake.png"] forState:UIControlStateNormal];
                    break;
                }else if(i == array.count-1){
                    self.label1.text = @"捣捣乱";
                    [self.btn1 setBackgroundImage:[UIImage imageNamed:@"rock2.png"] forState:UIControlStateNormal];
                }
            }
//            for (NSDictionary * dict in array) {
//                UserPetListModel * model = [[UserPetListModel alloc] init];
//                [model setValuesForKeysWithDictionary:dict];
//                [self.userPetListArray addObject:model];
//                [model release];
//            }
//            self.refreshData();
        }else{
            
        }
    }];
    [request release];
}
-(void)viewDidAppear:(BOOL)animated
{
    isLoaded = YES;
    isInThisController = YES;
//    NSLog(@"%f--%f--%f", commentTextView.frame.origin.x, commentBgView.frame.origin.x, commentBgView.frame.origin.y);
}
-(void)viewDidDisappear:(BOOL)animated
{
    isInThisController = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MobClick event:@"photopage"];
    
//    NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:0];
//    NSLog(@"%@--%d", tempArray, tempArray.count);
//    for (int i=0; i<100; i++) {
//        [tempArray addObject:@""];
//    }
//    [tempArray insertObject:@"reply_name" atIndex:8];
//    
//    NSLog(@"%@--%d", tempArray, tempArray.count);
    
    
    // Do any additional setup after loading the view from its nib.
    self.usrIdArray = [NSMutableArray arrayWithCapacity:0];
    self.nameArray = [NSMutableArray arrayWithCapacity:0];
    self.bodyArray = [NSMutableArray arrayWithCapacity:0];
    self.createTimeArray = [NSMutableArray arrayWithCapacity:0];
//    self.petInfoArray = [NSMutableArray arrayWithCapacity:0];
    self.likerTxArray = [NSMutableArray arrayWithCapacity:0];
    self.senderTxArray = [NSMutableArray arrayWithCapacity:0];
    self.txTotalArray = [NSMutableArray arrayWithCapacity:0];
    self.txTypeTotalArray = [NSMutableArray arrayWithCapacity:0];
    
//    [self createIQ];
    [self loadData];
    [self createBg];
    [self.view bringSubviewToFront:self.sv];
    [self.view bringSubviewToFront:self.headerBgView];
    [self createFakeNavigation];
    [self createHeader];
    
//    [self createUI];
//    [self createComment];
}
//- (void)createIQ
//{
//    //Enabling keyboard manager
//    [[IQKeyboardManager sharedManager] setEnable:NO];
//    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:15];
//	//Enabling autoToolbar behaviour. If It is set to NO. You have to manually create UIToolbar for keyboard.
//	[[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
//    
//	//Setting toolbar behavious to IQAutoToolbarBySubviews. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
//	[[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarBySubviews];
//    
//    //Resign textField if touched outside of UITextField/UITextView.
//    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:NO];
//}
#pragma mark - 关系API


- (void)loadAttentionAPI
{
    StartLoading;
    NSLog(@"aid:%@",self.aid);
    NSString *sig = [MyMD5 md5:[NSString stringWithFormat:@"aid=%@dog&cat",self.aid]];
    NSString *attentionString = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@",RELATIONAPI,self.aid,sig,[ControllerManager getSID]];
    NSLog(@"%@",attentionString);
    httpDownloadBlock *request = [[httpDownloadBlock alloc] initWithUrlStr:attentionString Block:^(BOOL isFinish, httpDownloadBlock *load) {
        if (isFinish) {
            [load.dataDict objectForKey:@"data"];
//            isFollow = [[[load.dataDict objectForKey:@"data"] objectForKey:@"is_follow"] intValue];
            NSLog(@"%d",[[[load.dataDict objectForKey:@"data"] objectForKey:@"is_fan"] intValue]);
            if (![[[load.dataDict objectForKey:@"data"] objectForKey:@"is_fan"] intValue]) {
                super.label1.text =@"捣捣乱";
                [self.btn1 setBackgroundImage:[UIImage imageNamed:@"rock2.png"] forState:UIControlStateNormal];
            }
            LoadingSuccess;
        }
    }];
    [request release];
}
#pragma mark -照片数据加载
-(void)loadData
{
    //Loading界面开始启动
    StartLoading;
    if (![ControllerManager getIsSuccess]) {
        [USER setObject:@"" forKey:@"usr_id"];
    }
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"img_id=%@&usr_id=%@dog&cat", self.img_id, [USER objectForKey:@"usr_id"]]];
    NSString * url = [NSString stringWithFormat:@"%@%@&usr_id=%@&sig=%@&SID=%@", IMAGEINFOAPI, self.img_id, [USER objectForKey:@"usr_id"], sig, [ControllerManager getSID]];
    NSLog(@"imageInfoAPI:%@", url);
    
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            if ([[load.dataDict objectForKey:@"confVersion"] isEqualToString:@"1.0"]) {
                isTest = YES;
            }
            
            NSLog(@"imageInfo:%@", load.dataDict);
            self.is_follow = [[[load.dataDict objectForKey:@"data"] objectForKey:@"is_follow"] intValue];
//            if (self.is_follow) {
//                self.attentionBtn.selected = YES;
//            }
            NSDictionary * dict = [[load.dataDict objectForKey:@"data"] objectForKey:@"image"];
            self.aid = [dict objectForKey:@"aid"];
            //四个动作是摇一摇还是捣捣乱
//            if ([ControllerManager getIsSuccess]) {
//                [self loadAttentionAPI];
//            }
            self.shares = [dict objectForKey:@"shares"];
//            NSLog(@"%@", [dict objectForKey:@"shares"]);
            self.gifts = [dict objectForKey:@"gifts"];
            self.cmt = [dict objectForKey:@"cmt"];
            if ([self.cmt isEqualToString:@" "]) {
                self.cmt = @"";
            }
            self.num = [dict objectForKey:@"likes"];
            self.imageURL = [dict objectForKey:@"url"];
            self.usr_id = [dict objectForKey:@"usr_id"];
            self.likers = [dict objectForKey:@"likers"];
            self.senders = [dict objectForKey:@"senders"];
            self.comments = [dict objectForKey:@"comments"];
            self.topic_name = [dict objectForKey:@"topic_name"];
            self.relates = [dict objectForKey:@"relates"];
            
            if (![[[load.dataDict objectForKey:@"data"] objectForKey:@"liker_tx"] isKindOfClass:[NSNull class]]) {
                self.likerTxArray = [[load.dataDict objectForKey:@"data"] objectForKey:@"liker_tx"];
            }
            
            if (![[[load.dataDict objectForKey:@"data"] objectForKey:@"sender_tx"] isKindOfClass:[NSNull class]]) {
                self.senderTxArray = [[load.dataDict objectForKey:@"data"] objectForKey:@"sender_tx"];
            }
            
            self.createTime = [dict objectForKey:@"create_time"];
            self.timeLabel.text = [MyControl timeFromTimeStamp:self.createTime];
            
            //解析数据
            if (![self.likers isKindOfClass:[NSNull class]]) {
                self.likersArray = [self.likers componentsSeparatedByString:@","];
                NSLog(@"self.lisersArray:%@--", self.likersArray);
                for(NSString * str in self.likersArray){
                    if (![str isEqualToString:@""] && str != nil && [str isEqualToString:[USER objectForKey:@"usr_id"]]) {
                        isLike = YES;
                        break;
                    }
                }
            }
            
            //
            [self loadPetData];
            //
            [self downloadBigImage];
            //分析评论字符串
            [self analyseComments];
        }else{
            LoadingFailed;
            NSLog(@"数据加载失败");
        }
    }];
    [request release];
}
-(void)analyseComments
{
    if (!([self.comments isKindOfClass:[NSNull class]] || self.comments.length == 0)) {
        NSArray * arr1 = [self.comments componentsSeparatedByString:@";usr"];
        
        //以前这里i从1开始，起初好像是为了实时回复
        for(int i=0;i<arr1.count;i++){
            if (i == 0 && [arr1[i] length] == 0) {
                continue;
            }
//            NSLog(@"%@", arr1[i]);
            NSString * usrId = [[[[arr1[i] componentsSeparatedByString:@",name"] objectAtIndex:0] componentsSeparatedByString:@"_id:"] objectAtIndex:1];
            [self.usrIdArray addObject:usrId];
            //            [usrId release];
            
            //
            if ([arr1[i] rangeOfString:@"reply_id"].location == NSNotFound) {
                NSString * name = [[[[arr1[i] componentsSeparatedByString:@",body"] objectAtIndex:0] componentsSeparatedByString:@"name:"] objectAtIndex:1];
                [self.nameArray addObject:name];
                //            [name release];
            }else{
                NSString * name = [[[[arr1[i] componentsSeparatedByString:@",reply_id"] objectAtIndex:0] componentsSeparatedByString:@",name:"] objectAtIndex:1];
                NSString * reply_name = [[[[arr1[i] componentsSeparatedByString:@",body"] objectAtIndex:0] componentsSeparatedByString:@",reply_name:"] objectAtIndex:1];
                NSLog(@"%@", reply_name);
                NSString * str = [NSString stringWithFormat:@"%@&%@", name, reply_name];
                [self.nameArray addObject:str];
            }
            
            
            NSString * body = [[[[arr1[i] componentsSeparatedByString:@",create_time"] objectAtIndex:0] componentsSeparatedByString:@"body:"] objectAtIndex:1];
            [self.bodyArray addObject:body];
            //            [body release];
            
            NSString * createTime = [[arr1[i] componentsSeparatedByString:@",create_time:"] objectAtIndex:1];
            [self.createTimeArray addObject:createTime];
            //            [createTime release];
        }
//        NSLog(@"评论分析结果:%@\n%@\n%@\n%@", self.usrIdArray, self.nameArray, self.bodyArray, self.createTimeArray);
//        if (++prepareCreateUINum == 2) {
//            [self createUI];
//        }
    }
    
//    NSLog(@"%@--self.bodyArray:%@", self.comments, self.bodyArray);
//    if (++prepareCreateUINum == 2) {
//        [self createUI];
//    }
}
-(void)loadPetData
{
    StartLoading;
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"aid=%@dog&cat", self.aid]];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", PETINFOAPI, self.aid, sig, [ControllerManager getSID]];
    NSLog(@"PetInfoAPI:%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
//            NSLog(@"照片详情页宠物信息：%@", load.dataDict);
//            PetInfoModel * model = [[PetInfoModel alloc] init];
//            [model setValuesForKeysWithDictionary:load.dataDict];
//            [self.petInfoArray addObject:model];
            NSDictionary * dic = [load.dataDict objectForKey:@"data"];
//            NSLog(@"%@", [dic objectForKey:@"aid"]);
            self.pet_aid = [dic objectForKey:@"aid"];
            self.pet_name = [dic objectForKey:@"name"];
            self.pet_tx = [dic objectForKey:@"tx"];
            //父类的宠物信息字典
//            masterID = [dic objectForKey:@"master_id"];
            //
//            NSArray * array = [USER objectForKey:@"petAidArray"];
            [self loadCountryList];
//            for (int i=0; i<array.count; i++) {
//                if ([array[i] isEqualToString:[dic objectForKey:@"aid"]]) {
//                    self.label1.text = @"摇一摇";
//                    [self.btn1 setBackgroundImage:[UIImage imageNamed:@"shake.png"] forState:UIControlStateNormal];
//                    break;
//                }else if(i == array.count-1){
//                    self.label1.text = @"捣捣乱";
//                    [self.btn1 setBackgroundImage:[UIImage imageNamed:@"rock2.png"] forState:UIControlStateNormal];
//                }
//            }
            if ([[dic objectForKey:@"master_id"] isEqualToString:[USER objectForKey:@"usr_id"]]) {
                self.label3.text = @"萌叫叫";
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
            }else{
                self.label3.text = @"萌印象";
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"touch.png"] forState:UIControlStateNormal];
            }
            
//            super.shakeInfoDict = dic;
//            self.pet_aid = [dic objectForKey:@"aid"];
//            [super viewDidLoad];
            
            //改变header数据
            self.name.text = [dic objectForKey:@"name"];
            if ([[dic objectForKey:@"gender"] intValue] == 2) {
                self.sex.image = [UIImage imageNamed:@"woman.png"];
            }else{
                self.sex.image = [UIImage imageNamed:@"man.png"];
            }
            
            if ([[dic objectForKey:@"type"] intValue]/100 == 1) {
                isMi = YES;
            }
            self.cateName = [ControllerManager returnCateNameWithType:[dic objectForKey:@"type"]];
            NSLog(@"%@--%@", [dic objectForKey:@"type"], [ControllerManager returnCateNameWithType:[dic objectForKey:@"type"]]);
            self.headImageURL = [dic objectForKey:@"tx"];
            //
            [self downloadHeadImage];
            
            self.cate.text = [NSString stringWithFormat:@"%@ | %@", self.cateName, [MyControl returnAgeStringWithCountOfMonth:[dic objectForKey:@"age"]]];
            
            /********************/
            if (++prepareCreateUINum == 2) {
                LoadingSuccess;
                [self createUI];
            }
        }else{
            LoadingFailed;
            NSLog(@"请求宠物数据失败");
        }
    }];
    [request release];
}
//-(void)loadUserData
//{
//    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"usr_id=%@dog&cat", self.usr_id]];
//    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", USERINFOAPI, self.usr_id, sig, [ControllerManager getSID]];
//    NSLog(@"UserInfoAPI:%@", url);
//    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
//        if (isFinish) {
//            LoadingSuccess;
//            
//            NSLog(@"用户信息：%@", load.dataDict);
//            NSDictionary * dict = [[load.dataDict objectForKey:@"data"] objectForKey:@"user"];
//            self.petName = [dict objectForKey:@"a_name"];
//            if ([[dict objectForKey:@"type"] intValue]/100 == 1) {
//                self.cateName = [[[USER objectForKey:@"CateNameList"] objectForKey:@"1"] objectForKey:[dict objectForKey:@"type"]];
//            }else if([[dict objectForKey:@"type"] intValue]/100 == 2){
//                self.cateName = [[[USER objectForKey:@"CateNameList"] objectForKey:@"2"] objectForKey:[dict objectForKey:@"type"]];
//            }else if([[dict objectForKey:@"type"] intValue]/100 == 3){
//                self.cateName = [[[USER objectForKey:@"CateNameList"] objectForKey:@"3"] objectForKey:[dict objectForKey:@"type"]];
//            }else{
//                self.cateName = @"苏格兰折耳猫";
//            }
//            //
//            NSLog(@"%@", [dict objectForKey:@"tx"]);
//            self.headImageURL = [dict objectForKey:@"tx"];
//            
//            [self downloadHeadImage];
//            self.name.text = self.petName;
//            if ([[dict objectForKey:@"gender"] intValue] == 1) {
//                self.sex.image = [UIImage imageNamed:@"woman.png"];
//            }
//            self.cate.text = [NSString stringWithFormat:@"%@ | %@岁", self.cateName, [dict objectForKey:@"age"]];
//            if ([[load.dataDict objectForKey:@"isFriend"] intValue] == 1) {
//                [self.attentionBtn setImage:[UIImage imageNamed:@"didAttention.png"] forState:UIControlStateNormal];
//            }
//        }else{
//            LoadingFailed;
//            NSLog(@"用户信息数据加载失败");
//        }
//    }];
//    [request release];
//}


//下载头像及图像
-(void)downloadHeadImage
{
    
    if ([self.headImageURL isKindOfClass:[NSNull class]] || self.headImageURL.length==0) {
        [self.headBtn setBackgroundImage:[UIImage imageNamed:@"defaultPetHead.png"] forState:UIControlStateNormal];
    }else{
        NSString * docDir = DOCDIR;
        NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.headImageURL]];
//        NSLog(@"--%@--%@", txFilePath, self.headImageURL);
        UIImage * image = [UIImage imageWithContentsOfFile:txFilePath];
        if (image) {
            [self.headBtn setBackgroundImage:image forState:UIControlStateNormal];
        }else{
            //下载头像
            httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:[NSString stringWithFormat:@"%@%@", PETTXURL, self.headImageURL] Block:^(BOOL isFinish, httpDownloadBlock * load) {
                if (isFinish) {
                    [self.headBtn setBackgroundImage:load.dataImage forState:UIControlStateNormal];
                    NSString * docDir = DOCDIR;
                    NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.headImageURL]];
                    [load.data writeToFile:txFilePath atomically:YES];
                }else{
                    NSLog(@"头像下载失败");
                }
            }];
            [request release];
        }
    }
}
-(void)downloadBigImage
{
    //先初始化bigImageView
    bigImageView = [[ClickImage alloc] initWithFrame:CGRectMake(0, 64+44, 320, 200)];
    
    NSString * docDir = DOCDIR;
    NSString * filePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.imageURL]];
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
    if (image) {
        //图片已经存在，直接调整大小
        bigImageView.image = image;
        [self adjustedImage:bigImageView];
        if (++prepareCreateUINum == 2) {
            LoadingSuccess;
            [self createUI];
        }
    }else{
        //图片不存在，下载之后调整大小
        NSString * url = [NSString stringWithFormat:@"%@%@", IMAGEURL, self.imageURL];
        NSLog(@"%@", url);
        httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:[NSString stringWithFormat:@"%@%@", IMAGEURL, self.imageURL] Block:^(BOOL isFinish, httpDownloadBlock * load) {
//            NSLog(@"%@", load.data);
            if (isFinish) {
                bigImageView.image = load.dataImage;
                [self adjustedImage:bigImageView];
                if (++prepareCreateUINum == 2) {
                    LoadingSuccess;
                    [self createUI];
                    
                }
            }else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"图片加载失败" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
                [alert release];
            }
        }];
        [request release];
    }
}
//调整图片大小
-(void)adjustedImage:(UIImageView *)imageView
{
    float width = imageView.image.size.width;
    float height = imageView.image.size.height;
    NSLog(@"图片大小:%f--%f", width, height);
    if (width>320) {
        float w = 320/width;
        width *= w;
        height *= w;
    }
    if (height>568) {
        float h = 568/height;
        width *= h;
        height *= h;
    }
    if (width<320) {
        float s = 320/width;
        width *= s;
        height *= s;
    }
//    bigImageViewWidth = width;
//    bigImageViewHeight = height;
    imageView.frame = CGRectMake(0, 64+44, width, height);
//    if(height<=self.view.frame.size.height){
//        imageView.frame = CGRectMake(self.view.center.x-width/2, self.view.center.y-height/2, width, height);
//        imageView.center = self.view.center;
//    }else{
//        imageView.frame = CGRectMake(0, 0, width, height);
//        imageView.center = CGPointMake(self.view.frame.size.width/2, height/2);
//    }
}

-(void)createBg
{
    self.bgImageView = [MyControl createImageViewWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height) ImageName:@""];
    [self.view addSubview:self.bgImageView];

//    NSString * docDir = DOCDIR;
    NSString * filePath = BLURBG;
    NSLog(@"%@", filePath);
    NSData * data = [NSData dataWithContentsOfFile:filePath];

    UIImage * image = [UIImage imageWithData:data];
    self.bgImageView.image = image;

    UIView * tempView = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    tempView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    [self.view addSubview:tempView];
}

-(void)createFakeNavigation
{
    navView = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, 64)];
    [self.view addSubview:navView];
    
    UIView * alphaView = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, 64)];
    alphaView.alpha = 0.85;
    alphaView.backgroundColor = BGCOLOR;
    [navView addSubview:alphaView];
    
    UIImageView * backImageView = [MyControl createImageViewWithFrame:CGRectMake(17, 32, 10, 17) ImageName:@"leftArrow.png"];
    [navView addSubview:backImageView];
    
    UIButton * backBtn = [MyControl createButtonWithFrame:CGRectMake(10, 25, 40, 30) ImageName:@"" Target:self Action:@selector(backBtnClick) Title:nil];
    backBtn.showsTouchWhenHighlighted = YES;
    [navView addSubview:backBtn];
    
    UILabel * titleLabel = [MyControl createLabelWithFrame:CGRectMake(60, 64-20-15, 200, 20) Font:17 Text:@"照片详情"];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    
    UIImageView * threePoint = [MyControl createImageViewWithFrame:CGRectMake(self.view.frame.size.width-36, 32+17/2.0-9/4.0, 47/2.0, 9/2.0) ImageName:@"threePoint.png"];
    [navView addSubview:threePoint];
    
    UIButton * threePBtn = [MyControl createButtonWithFrame:CGRectMake(self.view.frame.size.width-42, 25, 25+8+4, 32) ImageName:@"" Target:self Action:@selector(threePBtnClick) Title:nil];
    threePBtn.showsTouchWhenHighlighted = YES;
    
    [navView addSubview:threePBtn];
}

#pragma mark - 点击右上角三个点
-(void)threePBtnClick
{
    if (!isAlertCreated) {
        [self createBottomAlert];
    }
    alphaBtn.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        alphaBtn.alpha = 0.5;
        CGRect rect = moreView2.frame;
        rect.origin.y = self.view.frame.size.height-rect.size.height;
        moreView2.frame = rect;
    }];
    
}
#pragma mark - 创建举报和分享底部view
-(void)createBottomAlert
{
    alphaBtn = [MyControl createButtonWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ImageName:@"" Target:self Action:@selector(cancelBtnClick2) Title:nil];
    alphaBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:alphaBtn];
    alphaBtn.alpha = 0;
    alphaBtn.hidden = YES;
    
    // 318*234
    moreView2 = [MyControl createViewWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 234)];
    moreView2.backgroundColor = [ControllerManager colorWithHexString:@"efefef"];
    //    [self.view bringSubviewToFront:moreView];
    [self.view addSubview:moreView2];
    
    //orange line
    UIView * orangeLine = [MyControl createViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
    orangeLine.backgroundColor = [ControllerManager colorWithHexString:@"fc7b51"];
    [moreView2 addSubview:orangeLine];
    
    //label
    UILabel * shareLabel = [MyControl createLabelWithFrame:CGRectMake(15, 10, 80, 15) Font:13 Text:@"分享到"];
    shareLabel.textColor = [UIColor blackColor];
    [moreView2 addSubview:shareLabel];
    //3个按钮
    NSArray * arr = @[@"more_weixin.png", @"more_friend.png", @"more_sina.png"];
    NSArray * arr2 = @[@"微信好友", @"朋友圈", @"微博"];
    for(int i=0;i<3;i++){
        UIButton * button = [MyControl createButtonWithFrame:CGRectMake(40+i*92, 33, 42, 42) ImageName:arr[i] Target:self Action:@selector(shareClick:) Title:nil];
        button.tag = 200+i;
        [moreView2 addSubview:button];
        
        CGRect rect = button.frame;
        UILabel * label = [MyControl createLabelWithFrame:CGRectMake(rect.origin.x-10, rect.origin.y+rect.size.height+5, rect.size.width+20, 15) Font:12 Text:arr2[i]];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        //        label.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [moreView2 addSubview:label];
    }
    //grayLine1
    UIView * grayLine1 = [MyControl createViewWithFrame:CGRectMake(0, 105, 320, 2)];
    grayLine1.backgroundColor = [ControllerManager colorWithHexString:@"e3e3e3"];
    [moreView2 addSubview:grayLine1];
    
    UIButton * reportBtn = [MyControl createButtonWithFrame:CGRectMake(55/2, 127, self.view.frame.size.width-55, 76/2) ImageName:@"" Target:self Action:@selector(reportBtnClick) Title:@"举报此照"];
    reportBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    reportBtn.layer.cornerRadius = 7;
    reportBtn.layer.masksToBounds = YES;
    reportBtn.backgroundColor = [UIColor lightGrayColor];
    reportBtn.showsTouchWhenHighlighted = YES;
    [moreView2 addSubview:reportBtn];
    
    //grayLine2
    UIView * grayLine2 = [MyControl createViewWithFrame:CGRectMake(0, 180, self.view.frame.size.width, 4)];
    grayLine2.backgroundColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1];
//    grayLine2.backgroundColor = [UIColor redColor];
    [moreView2 addSubview:grayLine2];
    
    UIButton * cancelBtn2 = [MyControl createButtonWithFrame:CGRectMake(0, 188, self.view.frame.size.width, 90/2) ImageName:@"" Target:self Action:@selector(cancelBtnClick2) Title:@"取消"];
    cancelBtn2.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelBtn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moreView2 addSubview:cancelBtn2];
}
-(void)reportBtnClick
{
    ReportAlertView * report = [[ReportAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    report.AlertType = 4;
    [report makeUI];
    [self.view addSubview:report];
    [UIView animateWithDuration:0.2 animations:^{
        report.alpha = 1;
    }];
    report.confirmClick = ^(){
        [self reportImage];
        [self cancelBtnClick2];
    };
}
-(void)cancelBtnClick2
{
    [UIView animateWithDuration:0.3 animations:^{
        alphaBtn.alpha = 0.0;
        CGRect rect = moreView2.frame;
        rect.origin.y = self.view.frame.size.height;
        moreView2.frame = rect;
    } completion:^(BOOL finished) {
        alphaBtn.hidden = YES;
    }];

}
-(void)createHeader
{
    [self.headBtn setBackgroundImage:[UIImage imageNamed:@"defaultPetHead.jpg"] forState:UIControlStateNormal];
    self.headBtn.layer.cornerRadius = self.headBtn.frame.size.height/2;
    self.headBtn.layer.masksToBounds = YES;
    
//    [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"didAttention.png"] forState:UIControlStateSelected];
}
-(void)createUI
{
    self.sv.contentSize = CGSizeMake(320, 800);
    
    //大图
//    UIImage * image = [UIImage imageNamed:@"cat2.jpg"];
//    float height = 320/image.size.width*image.size.height;
//    CGRectMake(0, 64+44, 320, height)
//    bigImageView = [[ClickImage alloc] initWithFrame:CGRectMake(0, 64+44, bigImageViewWidth, bigImageViewHeight)];
//    bigImageView.image = image;
    bigImageView.canClick = YES;
    [self.sv addSubview:bigImageView];
    [bigImageView release];
    
    //点赞
    UIImageView * zanBgView = [MyControl createImageViewWithFrame:CGRectMake(10, bigImageView.frame.size.height-10-20, 50, 20) ImageName:@"zanBg.png"];
    [bigImageView addSubview:zanBgView];
    
    zanLabel = [MyControl createLabelWithFrame:CGRectMake(20-3, 0, 30, 20) Font:12 Text:self.num];
    zanLabel.textAlignment = NSTextAlignmentRight;
    [zanBgView addSubview:zanLabel];
    
    fish = [MyControl createImageViewWithFrame:CGRectMake(3, 0, 30, 20) ImageName:@""];
    if (isMi) {
        //53*34
//        fish.frame = CGRectMake(3, 3, 30, 14);
        fish.image = [UIImage imageNamed:@"fish.png"];
    }else{
        //53*34
//        fish.frame = CGRectMake(8, 3, 20, 16);
        fish.image = [UIImage imageNamed:@"bone.png"];
    }
    [zanBgView addSubview:fish];
    
    UIButton * zanBtn = [MyControl createButtonWithFrame:CGRectMake(0, 0, 50, 20) ImageName:@"" Target:self Action:@selector(zanBtnClick:) Title:nil];
    [zanBgView addSubview:zanBtn];
    
    if (isLike) {
        if (isMi) {
            fish.image = [UIImage imageNamed:@"fish1.png"];
        }else{
            fish.image = [UIImage imageNamed:@"bone1.png"];
        }
        zanBtn.selected = YES;
        zanLabel.textColor = BGCOLOR;
    }
    
    //礼物盒、工具条
    UIView * giftBgAlphaView = [MyControl createViewWithFrame:CGRectMake(0, bigImageView.frame.origin.y+bigImageView.frame.size.height, self.view.frame.size.width, 44)];
    giftBgAlphaView.backgroundColor = [UIColor whiteColor];
    giftBgAlphaView.alpha = Alpha;
    [self.sv addSubview:giftBgAlphaView];
    
    UIView * giftBgView = [MyControl createViewWithFrame:CGRectMake(0, bigImageView.frame.origin.y+bigImageView.frame.size.height, self.view.frame.size.width, 44)];
    [self.sv addSubview:giftBgView];
    
    
    UIButton * sendGift = [MyControl createButtonWithFrame:CGRectMake(20, 9, 25, 26) ImageName:@"detail_gift.png" Target:self Action:@selector(sendGiftClick) Title:nil];
    sendGift.showsTouchWhenHighlighted = YES;
    [giftBgView addSubview:sendGift];
    
    UIView * vLine = [MyControl createViewWithFrame:CGRectMake(60, 4, 1, 36)];
    vLine.backgroundColor = LineGray;
    [giftBgView addSubview:vLine];
    
    giftNum = [MyControl createLabelWithFrame:CGRectMake(65, 12, 150, 20) Font:14 Text:nil];
    giftNum.textColor = [UIColor blackColor];
//    NSLog(@"%@", self.gifts);
    if ([self.gifts intValue]) {
        NSString * str = [NSString stringWithFormat:@"已经收到了 %@ 件礼物", self.gifts];
        NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:str];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 6)];
        [attString addAttribute:NSForegroundColorAttributeName value:BGCOLOR range:NSMakeRange(6, self.gifts.length)];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(6+self.gifts.length, 4)];
        giftNum.attributedText = attString;
        
    }else{
        giftNum.text = @"木有收到礼物~";
    }
    
    [giftBgView addSubview:giftNum];
    
    //评论和分享
    UIImageView * commentImageView = [MyControl createImageViewWithFrame:CGRectMake(435/2, (44-25/44.0*41)/2, 25, 25/44.0*41) ImageName:@"detail_comment.png"];
    [giftBgView addSubview:commentImageView];
    
    commentNum = [MyControl createLabelWithFrame:CGRectMake(commentImageView.frame.origin.x+commentImageView.frame.size.width, 12, 30, 20) Font:10 Text:[NSString stringWithFormat:@"%d", self.nameArray.count]];
    commentNum.textAlignment = NSTextAlignmentCenter;
    commentNum.textColor = [UIColor lightGrayColor];
    [giftBgView addSubview:commentNum];
    
    UIButton * comment = [MyControl createButtonWithFrame:CGRectMake(435/2, 0, 45, 44) ImageName:@"" Target:self Action:@selector(commentClick) Title:nil];
//    comment.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [giftBgView addSubview:comment];
    /*******************************/
    UIImageView * shareImageView = [MyControl createImageViewWithFrame:CGRectMake(546/2, (44-37*(25/43.0))/2, 25, 37*(25/43.0)) ImageName:@"detail_share.png"];
    [giftBgView addSubview:shareImageView];
    
    shareNum = [MyControl createLabelWithFrame:CGRectMake(shareImageView.frame.origin.x+shareImageView.frame.size.width, 12, 20, 20) Font:10 Text:nil];
    if (self.shares) {
        shareNum.text = [NSString stringWithFormat:@"%@", self.shares];
    }else{
        shareNum.text = @"0";
    }
    shareNum.textAlignment = NSTextAlignmentCenter;
    shareNum.textColor = [UIColor lightGrayColor];
    [giftBgView addSubview:shareNum];
    
    UIButton * share = [MyControl createButtonWithFrame:CGRectMake(546/2, 0, 45, 44) ImageName:@"" Target:self Action:@selector(shareClick) Title:nil];
//    share.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [giftBgView addSubview:share];
    
    UIView * line = [MyControl createViewWithFrame:CGRectMake(0, giftBgView.frame.size.height-1, self.view.frame.size.width, 1)];
    line.backgroundColor = LineGray;
    [giftBgView addSubview:line];
    
    //白背景
    whiteBgView = [MyControl createViewWithFrame:CGRectMake(0, giftBgView.frame.origin.y+giftBgView.frame.size.height, self.view.frame.size.width, 0)];
    whiteBgView.backgroundColor = [UIColor whiteColor];
    whiteBgView.alpha = Alpha;
    [self.sv addSubview:whiteBgView];
    
    
    //话题
    UILabel * topic = [MyControl createLabelWithFrame:CGRectMake(15, giftBgView.frame.origin.y+giftBgView.frame.size.height+Space, 200, 20) Font:14 Text:@""];
    if (self.topic_name.length != 0) {
        topic.text = [NSString stringWithFormat:@"#%@#", self.topic_name];
    }else{
        CGRect rect = topic.frame;
        rect.size.height = 0;
        topic.frame = rect;
    }
    topic.textColor = BGCOLOR;
//    topic.backgroundColor = [UIColor whiteColor];
    [self.sv addSubview:topic];
    
//    NSString * string = @"她渐渐的让我明白了感情的戏，戏总归是戏，再美也是暂时的假象，无论投入多深多真，结局总是如此。";
    NSString * string = self.cmt;
    CGSize topicSize = [string sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(290, 100) lineBreakMode:1];
    
//    (15, topic.frame.origin.y+topic.frame.size.height+10, 290, topicSize.height)
    topicDetail = [MyControl createLabelWithFrame:CGRectMake(15, topic.frame.origin.y+topic.frame.size.height + Space, 290, topicSize.height) Font:14 Text:string];
    topicDetail.textColor = [UIColor darkGrayColor];
//    topicDetail.backgroundColor = [UIColor whiteColor];
    [self.sv addSubview:topicDetail];
//    if ([self.cmt isKindOfClass:[NSNull class]] || self.cmt.length == 0) {
//        CGRect rect = topicDetail.frame;
//        rect.origin.
//    }

    topicUser = [MyControl createLabelWithFrame:CGRectMake(15, topicDetail.frame.origin.y+topicDetail.frame.size.height + Space, 200, 20) Font:14 Text:@""];
    topicUser.textColor = BGCOLOR;
//    topicUser.backgroundColor = [UIColor whiteColor];
    if (self.relates.length != 0 && ![self.relates isEqualToString:@"点击@小伙伴"]) {
        topicUser.text = self.relates;
    }else{
        CGRect rect = topicUser.frame;
        rect.size.height = 0;
        topicUser.frame = rect;
    }
    [self.sv addSubview:topicUser];
    
    //定下白色背景的高度
    CGRect rect = whiteBgView.frame;
    BOOL t = [self.topic_name isKindOfClass:[NSNull class]] || self.topic_name.length == 0;
    BOOL c = [self.cmt isKindOfClass:[NSNull class]] || self.cmt.length == 0;
    BOOL r = [self.relates isKindOfClass:[NSNull class]] || self.relates.length == 0 || [self.relates isEqualToString:@"点击@小伙伴"];
    if (t && c && r) {
        /*???????????????????????*/
//        if ([self.relates isEqualToString:@"点击@小伙伴"]) {
//            rect.size.height = topic.frame.origin.y+topic.frame.size.height-rect.origin.y+Space;
//        }else{
//            rect.size.height = topicUser.frame.origin.y+topicUser.frame.size.height-rect.origin.y+Space;
//        }
        //都为0，白色背景高度设为0.
        rect.size.height = 0;
//        whiteBgView.frame = rect;
    }else{
        rect.size.height = topicUser.frame.origin.y+topicUser.frame.size.height-rect.origin.y+Space;
    }
    
    NSLog(@"%f", rect.size.height);
    whiteBgView.frame = rect;
    
//    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[self.createTime intValue]];
//    NSDateFormatter * format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
//    UILabel * topicTime = [MyControl createLabelWithFrame:CGRectMake(320-10-150, topicUser.frame.origin.y+3, 150, 15) Font:12 Text:[format stringFromDate:date]];
//    topicTime.textAlignment = NSTextAlignmentRight;
//    topicTime.textColor = [UIColor lightGrayColor];
//    [self.sv addSubview:topicTime];
//    [format release];
    
//    NSLog(@"%@--%@", self.likerTxArray, self.senderTxArray);
//    if ((![self.likerTxArray isKindOfClass:[NSNull class]] && self.likerTxArray.count > 0) || (![self.senderTxArray isKindOfClass:[NSNull class]] && self.senderTxArray.count > 0)) {
        [self createUsersTx];
//    }
    
    
    [self createCmt];
    
    //创建评论框
    [self createComment];
    
    self.menuBgView.frame = CGRectMake(50, self.view.frame.size.height-40, 220, 80);
    [self.view bringSubviewToFront:self.menuBgBtn];
    [self.view bringSubviewToFront:self.menuBgView];
}
-(void)createUsersTx
{
    usersBgView = [MyControl createViewWithFrame:CGRectMake(0, whiteBgView.frame.origin.y+whiteBgView.frame.size.height, self.view.frame.size.width, 44)];
    [self.sv addSubview:usersBgView];
    
    UIView * usersBgAlphaView = [MyControl createViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    usersBgAlphaView.backgroundColor = [UIColor whiteColor];
    usersBgAlphaView.alpha = Alpha;
    [usersBgView addSubview:usersBgAlphaView];
    
    //用户头像
//    (0, topicUser.frame.origin.y+topicUser.frame.size.height+10, 320, 50)
    
//    NSLog(@"%f--%@", topicDetail.frame.size.height, self.cmt);
//    if ([self.cmt isKindOfClass:[NSNull class]] || self.cmt.length == 0) {
//        usersBgView.frame = CGRectMake(0, topicDetail.frame.origin.y-Space*2, self.view.frame.size.width, 44);
//        usersBgAlphaView.frame = usersBgView.frame;
//    }else{
//        UIView * line = [MyControl createViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
//        line.backgroundColor = LineGray;
//        [usersBgView addSubview:line];
//    }
    
    
    
    /*
     设置一个总的数组用来存储头像，送礼在前，点赞在后，详情页只能容下8个头像。
     再开一个数组存储这些人的行为是送礼还是点赞，与前面数组对应。
     当我新点赞或送礼之后，我的头像出现在下方最前端。也就是添加在数组的最前端--
     但是退出再近排布顺序还是送礼在前，点赞在后。所以我点赞之后退出再进第一个可能不是我。
     */
//    NSLog(@"%@---%@--%@", self.senderTxArray, self.likerTxArray, self.txTypeTotalArray);
    if (![self.senderTxArray isKindOfClass:[NSNull class]]) {
        [self.txTotalArray addObjectsFromArray:self.senderTxArray];
        for (int i=0; i<self.senderTxArray.count; i++) {
            [self.txTypeTotalArray addObject:@"sender"];
        }
    }
    if (![self.likerTxArray isKindOfClass:[NSNull class]]) {
        [self.txTotalArray addObjectsFromArray:self.likerTxArray];
        for (int i=0; i<self.likerTxArray.count; i++) {
            [self.txTypeTotalArray addObject:@"liker"];
        }
    }
//    NSLog(@"%@", self.txTypeTotalArray);
    //txCount最大限制为7
    if (self.txTotalArray.count > 7) {
        txCount = 7;
    }else{
        txCount = self.txTotalArray.count;
    }
    
    //
//    if ([self.cmt isKindOfClass:[NSNull class]] || self.cmt.length == 0) {
//        if (([self.topic_name isKindOfClass:[NSNull class]] || self.topic_name.length == 0) && ([self.relates isEqualToString:@""] || [self.relates isEqualToString:@"点击@小伙伴"])) {
//            usersBgView.frame = CGRectMake(0, topicUser.frame.origin.y+topicUser.frame.size.height, self.view.frame.size.width, 44);
//            usersBgAlphaView.frame = usersBgView.frame;
//        }else{
//            usersBgView.frame = CGRectMake(0, usersBgAlphaView.frame.origin.y, self.view.frame.size.width, 44);
//        }
//        
////        usersBgAlphaView.frame = usersBgView.frame;
//    }else{
        if (txCount) {
            if (whiteBgView.frame.size.height != 0) {
                UIView * line = [MyControl createViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                line.backgroundColor = LineGray;
                [usersBgView addSubview:line];
            }
        }else{
            CGRect rect = usersBgView.frame;
            rect.size.height = 0;
            usersBgView.frame = rect;
            usersBgAlphaView.frame = CGRectZero;
        }
        
//    }
    
    //
    for (int i=0; i<txCount; i++) {
        UIImageView * header = [MyControl createImageViewWithFrame:CGRectMake(15+i*(76/2), 7, 30, 30) ImageName:@""];
        header.layer.cornerRadius = 15;
        header.layer.masksToBounds = YES;
        [usersBgView addSubview:header];
        NSLog(@"self.txTotalArray:%@", self.txTotalArray);
        if ([self.txTotalArray[i] isEqualToString:@""]) {
            header.image = [UIImage imageNamed:@"defaultUserHead.png"];
        }else{
            //下载头像图片
            NSString * docDir = DOCDIR;
            NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.txTotalArray[i]]];
            UIImage * image = [UIImage imageWithContentsOfFile:txFilePath];
            if (image) {
                header.image = image;
            }else{
                //下载头像
                httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:[NSString stringWithFormat:@"%@%@", USERTXURL, self.txTotalArray[i]] Block:^(BOOL isFinish, httpDownloadBlock * load) {
                    if (isFinish) {
                        header.image = load.dataImage;
                        NSString * docDir = DOCDIR;
                        NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.txTotalArray[i]]];
                        [load.data writeToFile:txFilePath atomically:YES];
                    }else{
                        NSLog(@"头像下载失败");
                    }
                }];
                [request release];
            }
        }
        
        UIImageView * giftSymbol = [MyControl createImageViewWithFrame:CGRectMake(header.frame.origin.x+18, header.frame.origin.y+20, 14, 14) ImageName:@"detail_symbol_fish.png"];
        if ([self.txTypeTotalArray[i] isEqualToString:@"sender"]) {
            giftSymbol.image = [UIImage imageNamed:@"zan_gift.png"];
        }else{
            if (isMi) {
                giftSymbol.image = [UIImage imageNamed:@"zan_fish.png"];
            }else{
                giftSymbol.image = [UIImage imageNamed:@"zan_bone.png"];
            }
        }
        [usersBgView addSubview:giftSymbol];
    }
    UIImageView * arrow = [MyControl createImageViewWithFrame:CGRectMake(320-20-10, 12, 20, 20) ImageName:@"arrow_right.png"];
    [usersBgView addSubview:arrow];
    
    UIButton * usersBtn = [MyControl createButtonWithFrame:CGRectMake(0, 0, 320, 44) ImageName:nil Target:self Action:@selector(usersBtnClick) Title:nil];
    [usersBgView addSubview:usersBtn];
    

}
-(void)createCmt
{
    int height = 0;
    usersBgView.hidden = YES;
    if (txCount) {
        height = usersBgView.frame.size.height;
        usersBgView.hidden = NO;
    }
    //创建评论
    commentsBgView = [MyControl createViewWithFrame:CGRectMake(0, usersBgView.frame.origin.y+height, 320, 100)];
    [self.sv addSubview:commentsBgView];
    
    int commentsBgViewHeight = 0;
    for(int i=0;i<self.usrIdArray.count;i++){
        UILabel * cmtUserName = [MyControl createLabelWithFrame:CGRectMake(15, 10+commentsBgViewHeight, 230, 20) Font:15 Text:nil];
        if ([self.nameArray[i] rangeOfString:@"&"].location == NSNotFound) {
            cmtUserName.text = self.nameArray[i];
            cmtUserName.textColor = BGCOLOR;
        }else{
            NSString * name = [[self.nameArray[i] componentsSeparatedByString:@"&"] objectAtIndex:0];
            NSString * reply_name = [[self.nameArray[i] componentsSeparatedByString:@"&"] objectAtIndex:1];
            if([reply_name rangeOfString:@"@"].location != NSNotFound){
                reply_name = [[reply_name componentsSeparatedByString:@"@"] objectAtIndex:1];
            }
                
            NSString * str = [NSString stringWithFormat:@"%@ 回复 %@", name, reply_name];
            NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:str];
            [attString addAttribute:NSForegroundColorAttributeName value:BGCOLOR range:NSMakeRange(0, name.length)];
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(name.length, 4)];
            [attString addAttribute:NSForegroundColorAttributeName value:BGCOLOR range:NSMakeRange(name.length+4, reply_name.length)];
            cmtUserName.attributedText = attString;
        }
        
        [commentsBgView addSubview:cmtUserName];
        
        UILabel * timeStamp = [MyControl createLabelWithFrame:CGRectMake(320-10-100, cmtUserName.frame.origin.y+3, 100, 15) Font:12 Text:[MyControl timeFromTimeStamp:self.createTimeArray[i]]];
        timeStamp.textAlignment = NSTextAlignmentRight;
        timeStamp.textColor = [UIColor lightGrayColor];
        [commentsBgView addSubview:timeStamp];
        
        CGSize size = [self.bodyArray[i] sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(290, 100) lineBreakMode:1];
        
        UILabel * cmtLabel = [MyControl createLabelWithFrame:CGRectMake(15, cmtUserName.frame.origin.y+cmtUserName.frame.size.height+10, 290, size.height) Font:15 Text:self.bodyArray[i]];
        cmtLabel.textColor = [UIColor blackColor];
        [commentsBgView addSubview:cmtLabel];
        
        UIView * line = [MyControl createViewWithFrame:CGRectMake(0, cmtLabel.frame.origin.y+cmtLabel.frame.size.height+size.height, 320, 1)];
        line.backgroundColor = LineGray;
        [commentsBgView addSubview:line];
        
        UIButton * btn = [MyControl createButtonWithFrame:CGRectMake(0, cmtUserName.frame.origin.y, self.view.frame.size.width, line.frame.origin.y+line.frame.size.height-cmtUserName.frame.origin.y) ImageName:@"" Target:self Action:@selector(replyBtnClick:) Title:nil];
//        btn.backgroundColor = [UIColor colorWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:0.3];
        btn.tag = 1000 + i;
        [commentsBgView addSubview:btn];
        
        if (isTest) {
            UIButton * reportCmtBtn = [MyControl createButtonWithFrame:CGRectMake(self.view.frame.size.width-40, timeStamp.frame.origin.y+25, 31/1.5, 26/1.5) ImageName:@"grayAlert.png" Target:self Action:@selector(reportCmtBtnClick:) Title:@""];
            reportCmtBtn.tag = 2000+i;
            [commentsBgView addSubview:reportCmtBtn];
        }
        
        commentsBgViewHeight = line.frame.origin.y+1;
    }
    commentsBgView.frame = CGRectMake(0, commentsBgView.frame.origin.y, 320, commentsBgViewHeight);
    //54为menu按钮的露出高度
    self.sv.contentSize = CGSizeMake(320, usersBgView.frame.origin.y+usersBgView.frame.size.height+commentsBgViewHeight+54);
//    NSLog(@"%f--%f--%d", usersBgView.frame.origin.y, usersBgView.frame.size.height, commentsBgViewHeight);
}
-(void)reportCmtBtnClick:(UIButton *)btn
{
//    btn.tag == 2000+i;
    NSLog(@"%d", btn.tag);
    ReportAlertView * report = [[ReportAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    report.AlertType = 2;
    [report makeUI];
    [self.view addSubview:report];
    [UIView animateWithDuration:0.2 animations:^{
        report.alpha = 1;
    }];
    report.confirmClick = ^(){
        [self reportImage];
    };
}
-(void)reportImage
{
    StartLoading;
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"img_id=%@dog&cat", self.img_id]];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", REPORTIMAGEAPI, self.img_id, sig, [ControllerManager getSID]];
    NSLog(@"%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            NSLog(@"%@", load.dataDict);
            [MyControl loadingSuccessWithContent:@"举报成功" afterDelay:0.5];
        }else{
            LoadingFailed;
        }
    }];
    [request release];
}

-(void)createComment
{
    bgButton = [MyControl createButtonWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-64) ImageName:nil Target:self Action:@selector(bgButtonClick) Title:nil];
    bgButton.backgroundColor = [UIColor blackColor];
    bgButton.alpha = 0.3;
    bgButton.hidden = YES;
    [self.view addSubview:bgButton];
    
    commentBgView = [MyControl createViewWithFrame:CGRectMake(-self.view.frame.size.width, self.view.frame.size.height-216-40, 320, 40)];
    commentBgView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    [self.view addSubview:commentBgView];
    
//    commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 250, 30)];
    commentTextView = [MyControl createTextFieldWithFrame:CGRectMake(5, 5, 250, 30) placeholder:@"写个评论呗" passWord:NO leftImageView:nil rightImageView:nil Font:15];
//    commentTextView.textColor = [UIColor lightGrayColor];
//    commentTextView.text = @"写个评论呗";
    commentTextView.layer.cornerRadius = 5;
    commentTextView.layer.masksToBounds = YES;
    commentTextView.layer.borderColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1].CGColor;
    commentTextView.layer.borderWidth = 1.5;
    commentTextView.delegate = self;
//    commentTextView.font = [UIFont systemFontOfSize:15];
//    commentTextView.returnKeyType = UIReturnKeySend;
    //关闭自动更正及大写
    commentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    commentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [commentBgView addSubview:commentTextView];
//    [commentTextView release];
    
    UIButton * sendButton = [MyControl createButtonWithFrame:CGRectMake(260, 10, 55, 20) ImageName:@"" Target:self Action:@selector(sendButtonClick) Title:@"发送"];
    [sendButton setTitleColor:BGCOLOR forState:UIControlStateNormal];
    [commentBgView addSubview:sendButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
#pragma mark - 
-(void)replyClick:(int)row
{
    NSLog(@"replyComment");
//    if (![ControllerManager getIsSuccess]) {
//        //提示注册
//        ToolTipsViewController * vc = [[ToolTipsViewController alloc] init];
//        [self addChildViewController:vc];
//        [self.view addSubview:vc.view];
//        [vc createLoginAlertView];
//        return;
//    }
    isReply = YES;
    replyRow = row;
    bgButton.hidden = NO;
    commentTextView.placeholder = self.replyPlaceHolder;
    [UIView animateWithDuration:0.25 animations:^{
        bgButton.alpha = 0.3;
        commentBgView.frame = CGRectMake(0, self.view.frame.size.height-216-40, 320, 40);
    }];
    [commentTextView becomeFirstResponder];
}
#pragma mark - 回复点击事件监听
-(void)replyBtnClick:(UIButton *)btn
{
    if (![ControllerManager getIsSuccess]) {
        //提示注册
        ShowAlertView;
        return;
    }
    int i = btn.tag-1000;
    NSLog(@"btn.tag:%d-回复:%@", btn.tag, self.nameArray[i]);
    if ([self.usrIdArray[i] isEqualToString:[USER objectForKey:@"usr_id"]]) {
        StartLoading;
        [MMProgressHUD dismissWithError:@"不能回复自己哦" afterDelay:0.7f];
        return;
    }

    NSString * str = [[self.nameArray[i] componentsSeparatedByString:@"&"] objectAtIndex:0];
    
    self.replyPlaceHolder = [NSString stringWithFormat:@"回复 %@", str];
    [self replyClick:i];
}


#pragma mark - 键盘监听
-(void)keyboardWasChange:(NSNotification *)notification
{
    if (!isInThisController) {
        return;
    }
    //如果不是textView触发的变化不改变位置
    if (!isCommentActive) {
        return;
    }
    float y = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    if (y == self.view.frame.size.height) {
        return;
    }
    float height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSString * str = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([str isEqualToString:@"zh-Hans"]) {
        
        [UIView animateWithDuration:0.25 animations:^{
            commentBgView.frame = CGRectMake(0, self.view.frame.size.height-height-commentBgView.frame.size.height, 320, commentBgView.frame.size.height);
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            commentBgView.frame = CGRectMake(0, self.view.frame.size.height-height-commentBgView.frame.size.height, 320, commentBgView.frame.size.height);
        }];
    }
}
#pragma mark - 送礼点击事件及block回调
-(void)sendGiftClick
{
    NSLog(@"赠送礼物");
    
    if (![ControllerManager getIsSuccess]) {
        //提示注册
        ShowAlertView;
        return;
    }else{
        SendGiftViewController *quictGiftvc = [[SendGiftViewController alloc] init];
        quictGiftvc.receiver_aid = self.aid;
        quictGiftvc.receiver_img_id = self.img_id;
        quictGiftvc.receiver_name = self.pet_name;
        
        NSLog(@"%@--%@", self.aid, [USER objectForKey:@"aid"]);
        quictGiftvc.hasSendGift = ^(NSString * itemId){
            self.gifts = [NSString stringWithFormat:@"%d", [self.gifts intValue]+1];
            NSString * str = [NSString stringWithFormat:@"已经收到了%@件礼物", self.gifts];
            NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:str];
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 5)];
            [attString addAttribute:NSForegroundColorAttributeName value:BGCOLOR range:NSMakeRange(5, self.gifts.length)];
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(5+self.gifts.length, 3)];
            giftNum.attributedText = attString;
            /*=====================*/
            [self.txTotalArray removeAllObjects];
            [self.txTypeTotalArray removeAllObjects];
            
            if ([USER objectForKey:@"tx"] == nil || [[USER objectForKey:@"tx"] isEqualToString:@""]) {
                [self.senderTxArray insertObject:@"" atIndex:0];
//                [self.senderTxArray addObject:@""];
            }else{
                [self.senderTxArray insertObject:[USER objectForKey:@"tx"] atIndex:0];
//                [self.senderTxArray addObject:[USER objectForKey:@"tx"]];
            }
//            [self.txTypeTotalArray insertObject:@"sender" atIndex:0];
//            [self.txTypeTotalArray addObject:@"sender"];
            if ([self.senders isKindOfClass:[NSNull class]] || self.senders.length == 0) {
                self.senders = [NSString stringWithFormat:@"%@", [USER objectForKey:@"usr_id"]];
            }else{
                self.senders = [NSString stringWithFormat:@"%@,%@", self.senders, [USER objectForKey:@"usr_id"]];
            }
            [usersBgView removeFromSuperview];
            //【注意】这里是commentsBgView，不是commentBgView
            [commentsBgView removeFromSuperview];
            [self createUsersTx];
            [self createCmt];
            
            ResultOfBuyView * result = [[ResultOfBuyView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [UIView animateWithDuration:0.3 animations:^{
                result.alpha = 1;
            }];
            result.confirm = ^(){
                [quictGiftvc closeGiftAction];
            };
            [result configUIWithName:self.pet_name ItemId:itemId Tx:self.pet_tx];
            [self.view addSubview:result];
        };
        [self addChildViewController:quictGiftvc];
        [quictGiftvc didMoveToParentViewController:self];
        [self.view addSubview:quictGiftvc.view];
        [quictGiftvc release];
    }
//    PresentDetailViewController * vc = [[PresentDetailViewController alloc] init];
//    [self presentViewController:vc animated:YES completion:nil];
//    [vc release];
    
    

}
-(void)commentClick
{
    NSLog(@"comment");
    if (![ControllerManager getIsSuccess]) {
        //提示注册
        ShowAlertView;
        return;
    }
//    buttonRight.userInteractionEnabled = NO;
    
//    NSLog(@"Comment");
//    if (!isCommentCreated) {
//        [self createComment];
//        isCommentCreated = 1;
//    }
    isReply = NO;
    bgButton.hidden = NO;
    commentTextView.placeholder = @"写个评论呗";
    [UIView animateWithDuration:0.25 animations:^{
        bgButton.alpha = 0.3;
        commentBgView.frame = CGRectMake(0, self.view.frame.size.height-216-40, 320, 40);
    }];
    [commentTextView becomeFirstResponder];
}
-(void)shareClick
{
    NSLog(@"share");
//    if (![ControllerManager getIsSuccess]) {
//        //提示注册
//        ToolTipsViewController * vc = [[ToolTipsViewController alloc] init];
//        [self addChildViewController:vc];
//        [self.view addSubview:vc.view];
//        [vc createLoginAlertView];
//        return;
//    }else{
        if (!isMoreCreated) {
            //create more
            [self createMore];
        }
        //show more
        menuBgBtn.hidden = NO;
        CGRect rect = moreView.frame;
        rect.origin.y -= rect.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            moreView.frame = rect;
            menuBgBtn.alpha = 0.5;
        }];
//    }
}
#pragma mark - 创建更多视图
-(void)createMore
{
    menuBgBtn = [MyControl createButtonWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height) ImageName:@"" Target:self Action:@selector(cancelBtnClick) Title:nil];
    menuBgBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:menuBgBtn];
    menuBgBtn.alpha = 0;
    menuBgBtn.hidden = YES;
    
    // 318*234
    moreView = [MyControl createViewWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 120)];
    moreView.backgroundColor = [ControllerManager colorWithHexString:@"efefef"];
    [self.view addSubview:moreView];
    
    //orange line
    UIView * orangeLine = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, 4)];
    orangeLine.backgroundColor = [ControllerManager colorWithHexString:@"fc7b51"];
    [moreView addSubview:orangeLine];
    //label
    UILabel * shareLabel = [MyControl createLabelWithFrame:CGRectMake(15, 10, 80, 15) Font:13 Text:@"分享到"];
    shareLabel.textColor = [UIColor blackColor];
    [moreView addSubview:shareLabel];
    //3个按钮
    NSArray * arr = @[@"more_weixin.png", @"more_friend.png", @"more_sina.png"];
    NSArray * arr2 = @[@"微信好友", @"朋友圈", @"微博"];
    for(int i=0;i<3;i++){
        UIButton * button = [MyControl createButtonWithFrame:CGRectMake(40+i*92, 33, 42, 42) ImageName:arr[i] Target:self Action:@selector(shareClick:) Title:nil];
        button.tag = 200+i;
        [moreView addSubview:button];
        
        CGRect rect = button.frame;
        UILabel * label = [MyControl createLabelWithFrame:CGRectMake(rect.origin.x-10, rect.origin.y+rect.size.height+5, rect.size.width+20, 15) Font:12 Text:arr2[i]];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        //        label.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [moreView addSubview:label];
    }
}

#pragma mark - 分享截图
-(void)shareClick:(UIButton *)button
{
//    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//    [MMProgressHUD showWithStatus:@"正在分享..."];
    [self cancelBtnClick];
    
    [MobClick event:@"photo_share"];
    
    if (button.tag == 200) {
        NSLog(@"微信");
        //强制分享图片
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:self.cmt image:bigImageView.image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [self loadShareAPI];
                shareNum.text = [NSString stringWithFormat:@"%d", [shareNum.text intValue]+1];
                StartLoading;
                [MMProgressHUD dismissWithSuccess:@"分享成功" title:nil afterDelay:0.5];
            }else{
                StartLoading;
                [MMProgressHUD dismissWithError:@"分享失败" afterDelay:0.5];
            }
            
        }];
    }else if(button.tag == 201){
        NSLog(@"朋友圈");
        //强制分享图片
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:self.cmt image:bigImageView.image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [self loadShareAPI];
                shareNum.text = [NSString stringWithFormat:@"%d", [shareNum.text intValue]+1];
                StartLoading;
                [MMProgressHUD dismissWithSuccess:@"分享成功" title:nil afterDelay:0.5];
            }else{
                StartLoading;
                [MMProgressHUD dismissWithError:@"分享失败" afterDelay:0.5];
            }

        }];
    }else{
        NSLog(@"微博");
        NSString * str = [NSString stringWithFormat:@"%@%@", self.cmt, @"http://home4pet.aidigame.com/（分享自@宠物星球社交应用）"];
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:str image:bigImageView.image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [self loadShareAPI];
                shareNum.text = [NSString stringWithFormat:@"%d", [shareNum.text intValue]+1];
                StartLoading;
                [MMProgressHUD dismissWithSuccess:@"分享成功" title:nil afterDelay:0.5];
            }else{
                NSLog(@"失败原因：%@", response);
                StartLoading;
                [MMProgressHUD dismissWithError:@"分享失败" afterDelay:0.5];
            }

        }];
    }
}
#pragma mark - 分享API
-(void)loadShareAPI
{
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"img_id=%@dog&cat", self.img_id]];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", SHAREIMAGEAPI, self.img_id, sig, [ControllerManager getSID]];
    NSLog(@"shareUrl:%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            NSLog(@"%@", load.dataDict);
            if(![[load.dataDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]]){
                return;
            }
            //返回gold
//            int gold = [[[load.dataDict objectForKey:@"data"] objectForKey:@"gold"] intValue];
//            if (gold != [[USER objectForKey:@"gold"] intValue]) {
//                //差值
//                int add = gold-[[USER objectForKey:@"gold"] intValue];
//                [USER setObject:[[load.dataDict objectForKey:@"data"] objectForKey:@"gold"] forKey:@"gold"];
//                [ControllerManager HUDImageIcon:@"gold.png" showView:self.view yOffset:0 Number:add];
//            }
        }else{
            
        }
    }];
    [request release];
}

-(void)cancelBtnClick
{
    NSLog(@"cancel");
    CGRect rect = moreView.frame;
    rect.origin.y += rect.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        moreView.frame = rect;
        menuBgBtn.alpha = 0;
    } completion:^(BOOL finished) {
        menuBgBtn.hidden = YES;
    }];
}
#pragma mark - 跳转到围观群众页
-(void)usersBtnClick
{
    NSLog(@"跳转到围观群众页");
    MassWatchViewController * vc = [[MassWatchViewController alloc] init];
    vc.senders = self.senders;
    vc.likers = self.likers;
//    NSString * str = nil;
//    if (self.likers == nil || self.likers.length == 0) {
//        str = self.senders;
//    }else if(self.senders == nil || self.senders.length == 0){
//        str = self.likers;
//    }else{
//        str = [NSString stringWithFormat:@"%@,%@", self.senders, self.likers];
//    }
//    vc.usr_ids = str;
    vc.txTypesArray = self.txTypeTotalArray;
    vc.isMi = isMi;
    vc.modalTransitionStyle = 2;
    [self presentViewController:vc animated:YES completion:nil];
    [vc release];
}
-(void)bgButtonClick
{
    [commentTextView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        commentBgView.frame = CGRectMake(-self.view.frame.size.width, self.view.frame.size.height-216-40, 320, 40);
        bgButton.alpha = 0;
    } completion:^(BOOL finished) {
        bgButton.hidden = YES;
//        commentTextView.text = @"写个评论呗";
//        commentTextView.textColor = [UIColor lightGrayColor];
    }];
}
#pragma mark - 点赞！！
-(void)zanBtnClick:(UIButton *)btn
{
    if (![ControllerManager getIsSuccess]) {
        //提示注册
        ShowAlertView;
        return;
    }
    //
    if (!btn.selected) {
        
        /*================================*/
        NSString * code = [NSString stringWithFormat:@"img_id=%@dog&cat", self.img_id];
        NSString * sig = [MyMD5 md5:code];
        NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", LIKEAPI, self.img_id, sig, [ControllerManager getSID]];
        NSLog(@"likeURL:%@", url);
//        StartLoading;
        httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
            if (isFinish) {
                NSLog(@"%@", load.dataDict);
//                int a = 
                if (![[[load.dataDict objectForKey:@"data"] objectForKey:@"gold"] isKindOfClass:[NSNumber class]]) {
                    [MMProgressHUD dismissWithError:@"点赞失败" afterDelay:1];
                }else{
                    [MobClick event:@"like"];
                    
                    int a = [[[load.dataDict objectForKey:@"data"] objectForKey:@"gold"] intValue];
                    if (a) {
                        [ControllerManager HUDImageIcon:@"gold.png" showView:self.view yOffset:0 Number:a];
                    }
                    
                    btn.selected = YES;
                    if (isMi) {
                        fish.image = [UIImage imageNamed:@"fish1.png"];
                    }else{
                        fish.image = [UIImage imageNamed:@"bone1.png"];
                    }
                    zanLabel.text = [NSString stringWithFormat:@"%d", [zanLabel.text intValue]+1];
                    zanLabel.textColor = BGCOLOR;
                    CGRect rect = fish.frame;
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        fish.frame = CGRectMake(rect.origin.x-rect.size.width/2, rect.origin.y-rect.size.height/2, rect.size.width*2, rect.size.height*2);
//                        if (isMi) {
//                            //48*23
//                            fish.frame = CGRectMake(0-15, 4-12, 30*2, 14*2);
//                            fish.center = point;
//                        }else{
//                            //41*34
//                            fish.frame = CGRectMake(0-15, 4-12, 20*2, 16*2);
//                            fish.center = point;
//                        }
                        
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.5 animations:^{
                            fish.frame = rect;
//                            if (isMi) {
//                                //48*23
//                                fish.frame = CGRectMake(3, 3, 30, 14);
//                                fish.center = point;
//                            }else{
//                                //41*34
//                                fish.frame = CGRectMake(8, 3, 20, 16);
//                                fish.center = point;
//                            }
                        }];
                    }];
                    //在头像横条中显示
                    /*因为在重新布局的时候会重新在
                     txTotalArray中添加tx数据，所以
                     在这里将数组清空，将自己tx添加
                     在最前端。
                     */
                    [self.txTotalArray removeAllObjects];
                    [self.txTypeTotalArray removeAllObjects];
                    
                    if ([USER objectForKey:@"tx"] == nil || [[USER objectForKey:@"tx"] isEqualToString:@""]) {
                        [self.likerTxArray insertObject:@"" atIndex:0];
//                        [self.txTotalArray addObject:@""];
                    }else{
                        [self.likerTxArray insertObject:[USER objectForKey:@"tx"] atIndex:0];
//                        [self.likerTxArray addObject:[USER objectForKey:@"tx"]];
//                        [self.txTotalArray addObject:[USER objectForKey:@"tx"]];
                    }
//                    [self.txTypeTotalArray insertObject:@"liker" atIndex:0];
//                    [self.txTypeTotalArray addObject:@"liker"];
                    if ([self.likers isKindOfClass:[NSNull class]] || self.likers.length == 0) {
                        self.likers = [NSString stringWithFormat:@"%@", [USER objectForKey:@"usr_id"]];
                    }else{
                        self.likers = [NSString stringWithFormat:@"%@,%@", self.likers, [USER objectForKey:@"usr_id"]];
                    }
                    [usersBgView removeFromSuperview];
                    //【注意】这里是commentsBgView，不是commentBgView
                    [commentsBgView removeFromSuperview];
                    [self createUsersTx];
                    [self createCmt];
                    
//                    [MMProgressHUD dismissWithSuccess:@"点赞成功" title:nil afterDelay:0.5];
                }
            }else{
                LoadingFailed;
//                [MMProgressHUD dismissWithError:@"点赞请求失败" afterDelay:1];
                NSLog(@"数据请求失败");
            }
        }];
        [request release];
    }else{
        PopupView * pop = [[PopupView alloc] init];
        [pop modifyUIWithSize:self.view.frame.size msg:@"您已经点过赞了"];
        [self.view addSubview:pop];
        [pop release];
        
        [UIView animateWithDuration:0.2 animations:^{
            pop.bgView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:0.2 delay:2 options:0 animations:^{
                pop.bgView.alpha = 0;
            } completion:^(BOOL finished) {
                [pop removeFromSuperview];
            }];
        }];
    }
    
//    btn.selected = !btn.selected;
//    if (btn.selected) {
//        fish.image = [UIImage imageNamed:@"fish1.png"];
//        zanLabel.text = [NSString stringWithFormat:@"%d", [zanLabel.text intValue]+1];
//        [UIView animateWithDuration:0.5 animations:^{
//            fish.frame = CGRectMake(0-15, 4-12, 30*2, 12*2);
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.5 animations:^{
//                fish.frame = CGRectMake(0, 4, 30, 12);
//            }];
//        }];
//    }else{
//        fish.image = [UIImage imageNamed:@"fish.png"];
//        zanLabel.text = [NSString stringWithFormat:@"%d", [zanLabel.text intValue]-1];
//    }
}

#pragma mark - 进入国王
- (IBAction)headBtnClick:(id)sender {
    NSLog(@"进入王国");
//    if (![ControllerManager getIsSuccess]) {
//        //提示注册
//        ToolTipsViewController * vc = [[ToolTipsViewController alloc] init];
//        [self addChildViewController:vc];
//        [self.view addSubview:vc.view];
//        [vc createLoginAlertView];
//    }else{
        PetInfoViewController *petInfoKing = [[PetInfoViewController alloc] init];
        petInfoKing.aid = self.aid;
        [self presentViewController:petInfoKing animated:YES completion:^{
            NSLog(@"进入王国");
        }];
//    }
    
}
//- (IBAction)attentionBtnClick:(id)sender {
//    if (![ControllerManager getIsSuccess]) {
//        //提示注册
//        ToolTipsViewController * vc = [[ToolTipsViewController alloc] init];
//        [self addChildViewController:vc];
//        [self.view addSubview:vc.view];
//        [vc createLoginAlertView];
//        return;
//    }
//    if (!self.attentionBtn.selected) {
//        NSString * code = [NSString stringWithFormat:@"aid=%@dog&cat", self.aid];
//        NSString * sig = [MyMD5 md5:code];
//        NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", FOLLOWAPI, self.aid, sig, [ControllerManager getSID]];
//        NSLog(@"url:%@", url);
//        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//        [MMProgressHUD showWithStatus:@"关注中..."];
//        [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
//            if (isFinish) {
//                NSLog(@"%@", load.dataDict);
//                [MMProgressHUD dismissWithSuccess:@"关注成功" title:nil afterDelay:1];
//                self.attentionBtn.selected = YES;
//            }else{
//                [MMProgressHUD dismissWithError:@"关注失败" afterDelay:1];
//            }
//        }];
//    }else{
//        NSString * code = [NSString stringWithFormat:@"aid=%@dog&cat", self.aid];
//        NSString * sig = [MyMD5 md5:code];
//        NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", UNFOLLOWAPI, self.aid, sig, [ControllerManager getSID]];
//        NSLog(@"unfollowApiurl:%@", url);
//        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//        [MMProgressHUD showWithStatus:@"取消关注中..."];
//        [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
//            if (isFinish) {
//                NSLog(@"%@", load.dataDict);
//                [MMProgressHUD dismissWithSuccess:@"取消关注成功" title:nil afterDelay:1];
//                self.attentionBtn.selected = NO;
//            }else{
//                [MMProgressHUD dismissWithError:@"取消关注失败" afterDelay:1];
//            }
//        }];
//    }
//}

-(void)backBtnClick
{
    NSLog(@"返回");
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)sendButtonClick
{
    NSLog(@"发送");
    if (!isReply && ([commentTextView.text isEqualToString:@"写个评论呗"] || commentTextView.text.length == 0)) {
        //        UIAlertView * alert = [MyControl createAlertViewWithTitle:@"不写评论怎么发 = =。"];
        StartLoading;
        [MMProgressHUD dismissWithError:@"不写评论怎么发 = =。" afterDelay:1.5];
        return;
    }
    if (isReply && ([commentTextView.text isEqualToString:self.replyPlaceHolder] || commentTextView.text.length == 0)) {
        StartLoading;
        [MMProgressHUD dismissWithError:@"不写内容怎么回 = =。" afterDelay:1.5];
        return;
    }
    
    //post数据  参数img_id 和 body
    NSString * url = [NSString stringWithFormat:@"%@%@", COMMENTAPI, [ControllerManager getSID]];
    NSLog(@"postUrl:%@", url);
    ASIFormDataRequest * _request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    _request.requestMethod = @"POST";
    _request.timeOutSeconds = 20;
    
    //    if (![commentTextView.text isEqualToString:@"写个评论呗"]) {
//    NSLog(@"%@", commentTextView.text);
    [_request setPostValue:commentTextView.text forKey:@"body"];
    //    }else{
    //        [_request setPostValue:@"" forKey:@"body"];
    //    }
    [_request setPostValue:self.img_id forKey:@"img_id"];
    if (isReply) {
//        NSLog(@"%@--%@--%@", self.usrIdArray[replyRow],self.nameArray[replyRow],[self.nameArray[replyRow] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        [_request setPostValue:self.usrIdArray[replyRow] forKey:@"reply_id"];
        NSLog(@"%@", self.nameArray[replyRow]);
        NSString * str = self.nameArray[replyRow];
        //分割&
        if ([str rangeOfString:@"&"].location != NSNotFound) {
            str = [[str componentsSeparatedByString:@"&"] objectAtIndex:0];
        }else if([str rangeOfString:@"@"].location != NSNotFound){
            //分割@
            str = [[str componentsSeparatedByString:@"@"] objectAtIndex:0];
        }
        
        NSLog(@"%@", str);
        [_request setPostValue:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"reply_name"];
    }
    _request.delegate = self;
    [_request startAsynchronous];
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithStatus:@"评论中..."];
}
#pragma mark - ASI代理
-(void)requestFinished:(ASIHTTPRequest *)request
{
//    buttonRight.userInteractionEnabled = YES;
    
    NSLog(@"success");
    NSLog(@"request.responseData:%@",[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil]);
    //经验弹窗
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@", dict);
    if ([[dict objectForKey:@"state"] intValue] == 2) {
        //过期
        [self login];
    }else{
        if ([[dict objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            int exp = [[USER objectForKey:@"exp"] intValue];
            int addExp = [[[dict objectForKey:@"data"] objectForKey:@"exp"] intValue];
            if (addExp>0) {
                [USER setObject:[NSString stringWithFormat:@"%d", exp+addExp] forKey:@"exp"];
//                [ControllerManager HUDImageIcon:@"Star.png" showView:self.view.window yOffset:0 Number:addExp];
            }
        }
        
        [commentTextView resignFirstResponder];
        
        //添加评论
        NSLog(@"%@", [USER objectForKey:@"usr_id"]);
        [self.usrIdArray insertObject:[USER objectForKey:@"usr_id"] atIndex:0];
        //    [self.usrIdArray addObject:[USER objectForKey:@"usr_id"]];
        if (isReply) {
            [MobClick event:@"comment"];
            
            [self.nameArray insertObject:[NSString stringWithFormat:@"%@&%@", [USER objectForKey:@"name"], self.nameArray[replyRow]] atIndex:0];
            //        [self.nameArray addObject:[NSString stringWithFormat:@"%@&%@", [USER objectForKey:@"name"], self.nameArray[replyRow]]];
        }else{
            [self.nameArray insertObject:[USER objectForKey:@"name"] atIndex:0];
            //        [self.nameArray addObject:[USER objectForKey:@"name"]];
        }
        NSLog(@"%@", commentTextView.text);
        [self.bodyArray insertObject:commentTextView.text atIndex:0];
        //    [self.bodyArray addObject:commentTextView.text];
        [self.createTimeArray insertObject:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]] atIndex:0];
        //    [self.createTimeArray addObject:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]];
        
        [UIView animateWithDuration:0.3 animations:^{
            commentBgView.frame = CGRectMake(-self.view.frame.size.width, self.view.frame.size.height-216-40, 320, 40);
            //评论清空
            commentTextView.placeholder = @"写个评论呗";
            commentTextView.text = nil;
//            commentTextView.textColor = [UIColor lightGrayColor];
        }];
        bgButton.hidden = YES;
        [MMProgressHUD dismissWithSuccess:@"评论成功" title:nil afterDelay:0.2];
        //
        commentNum.text = [NSString stringWithFormat:@"%d", self.nameArray.count];
        
        [commentsBgView removeFromSuperview];
        //    if (!([self.likerTxArray isKindOfClass:[NSNull class]] || self.likerTxArray.count == 0)) {
        //        [txsView removeFromSuperview];
        //    }
        [self createCmt];
    }
    
}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"failed");
    [MMProgressHUD dismissWithError:@"评论失败" afterDelay:1];
}
#pragma mark - 
-(void)login
{
    StartLoading;
    NSString * code = [NSString stringWithFormat:@"uid=%@dog&cat", UDID];
    NSString * url = [NSString stringWithFormat:@"%@&uid=%@&sig=%@", LOGINAPI, UDID, [MyMD5 md5:code]];
    NSLog(@"login-url:%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if(isFinish){
            NSLog(@"%@", load.dataDict);
            [ControllerManager setIsSuccess:[[[load.dataDict objectForKey:@"data"] objectForKey:@"isSuccess"] intValue]];
            [ControllerManager setSID:[[load.dataDict objectForKey:@"data"] objectForKey:@"SID"]];
            [USER setObject:[[load.dataDict objectForKey:@"data"] objectForKey:@"isSuccess"] forKey:@"isSuccess"];
            [USER setObject:[[load.dataDict objectForKey:@"data"] objectForKey:@"SID"] forKey:@"SID"];
            
            [self sendButtonClick];
            LoadingSuccess;
        }else{
            LoadingFailed;
        }
    }];
    [request release];
}

#pragma mark - textView代理
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    isCommentActive = YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    isCommentActive = NO;
}
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    NSLog(@"%d--%@", commentTextView.text.length, text);
//    if ([commentTextView.text isEqualToString:@"写个评论呗"] || [commentTextView.text isEqualToString:self.replyPlaceHolder]) {
//        commentTextView.text = @"";
//    }
//    else if(commentTextView.text.length == 1 && text == nil){
//        
//        return YES;
//    }
//    commentTextView.textColor = [UIColor blackColor];
//    return YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_headerBgView release];
    [_sv release];
    [_headBtn release];
    [_sex release];
    [_name release];
    [_cate release];
//    [_attentionBtn release];
    [_timeLabel release];
    [super dealloc];
}
@end
