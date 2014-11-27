//
//  UserInfoViewController.m
//  MyPetty
//
//  Created by miaocuilin on 14-8-11.
//  Copyright (c) 2014年 AidiGame. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoActivityCell.h"
#import "UserInfoRankCell.h"
#import "UserPetListModel.h"
#import "PetInfoModel.h"
#import "ChooseInViewController.h"
#import "TalkViewController.h"
#import "UserActivityListModel.h"
#import "PicDetailViewController.h"
#import "ModifyPetOrUserInfoViewController.h"

#import "PetInfoViewController.h"

@interface UserInfoViewController ()
{
    NSDictionary *headerDict;
}
@end

@implementation UserInfoViewController
-(void)viewWillAppear:(BOOL)animated
{
    if (isLoaded) {
        [self loadMyCountryInfoData];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    isLoaded = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MobClick event:@"personal_homepage"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.userPetListArray = [NSMutableArray arrayWithCapacity:0];
    self.userAttentionListArray = [NSMutableArray arrayWithCapacity:0];
    self.userActivityListArray = [NSMutableArray arrayWithCapacity:0];
    
    self.goodsArray = [NSMutableArray arrayWithCapacity:0];
    self.goodsNumArray = [NSMutableArray arrayWithCapacity:0];
    
    cellNum = 15;
//    isOwner = YES;
    
    [self createScrollView];
    [self createFakeNavigation];
//    [self createHeader];
    [self createTableView1];
    [self loadUserInfoData];
    [self loadMyCountryInfoData];
}

#pragma mark - 用户信息
- (void)loadUserInfoData
{
    LOADING;
//    user/infoApi&usr_id=
    NSString *userInfoSig = [MyMD5 md5:[NSString stringWithFormat:@"usr_id=%@dog&cat", self.usr_id]];
    NSString *userInfoString = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", USERINFOAPI, self.usr_id, userInfoSig,[ControllerManager getSID]];
    NSLog(@"用户信息API:%@",userInfoString);
    httpDownloadBlock *request = [[httpDownloadBlock alloc] initWithUrlStr:userInfoString Block:^(BOOL isFinish, httpDownloadBlock *load) {
        if (isFinish) {
            NSLog(@"用户信息数据：%@",load.dataDict);
           headerDict=  [[load.dataDict objectForKey:@"data"] objectAtIndex:0];
            [USER setObject:[headerDict objectForKey:@"gold"] forKey:@"gold"];
            
            if ([[headerDict objectForKey:@"usr_id"] isEqualToString:[USER objectForKey:@"usr_id"]]) {
                titleLabel.text = @"我的档案";
            }else{
                titleLabel.text = @"TA的档案";
            }
            if ([[headerDict objectForKey:@"usr_id"] isEqualToString:[USER objectForKey:@"usr_id"]]) {
                isOwner = YES;
            }
            ENDLOADING;
            [self createHeader];
            //
            
        }else{
            LOADFAILED;
        }
        
    }];
    [request release];

}
-(void)loadMyCountryInfoData
{
//    user/petsApi&usr_id=(若用户为自己则留空不填)
    LOADING;
    NSString * code = [NSString stringWithFormat:@"is_simple=0&usr_id=%@dog&cat", self.usr_id];
    NSString * url = [NSString stringWithFormat:@"%@%d&usr_id=%@&sig=%@&SID=%@", USERPETLISTAPI, 0, self.usr_id, [MyMD5 md5:code], [ControllerManager getSID]];
    NSLog(@"%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            NSLog(@"%@", load.dataDict);
            [self.userPetListArray removeAllObjects];
            NSArray * array = [load.dataDict objectForKey:@"data"];
            for (NSDictionary * dict in array) {
                UserPetListModel * model = [[UserPetListModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [self.userPetListArray addObject:model];
                [model release];
            }
            [tv reloadData];
            ENDLOADING;
        }else{
            LOADFAILED;
        }
    }];
    [request release];
}
-(void)loadMyAttentionCountryData
{
    NSString * code = [NSString stringWithFormat:@"usr_id=%@dog&cat", self.usr_id];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", USERATTENTIONLISTAPI, self.usr_id, [MyMD5 md5:code], [ControllerManager getSID]];
    NSLog(@"%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
//            NSLog(@"%@", load.dataDict);
            [self.userAttentionListArray removeAllObjects];
            NSArray * array = [load.dataDict objectForKey:@"data"];
            for (NSDictionary * dict in array) {
                PetInfoModel * model = [[PetInfoModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [self.userAttentionListArray addObject:model];
                [model release];
            }
            [tv2 reloadData];
        }else{
            
        }
    }];
    [request release];
}
-(void)loadActData
{
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"usr_id=%@dog&cat", self.usr_id]];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", USERACTLISTAPI, self.usr_id, sig, [ControllerManager getSID]];
    NSLog(@"%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
//            NSLog(@"%@", load.dataDict);
            NSArray * array = [load.dataDict objectForKey:@"data"];
            for (NSDictionary * dict in array) {
                UserActivityListModel * model = [[UserActivityListModel alloc] init];
                [model setValuesForKeysWithDictionary:dict];
                [self.userActivityListArray addObject:model];
                [model release];
            }
            [tv3 reloadData];
        }else{
            
        }
    }];
    [request release];
}
-(void)loadBagData
{
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"usr_id=%@dog&cat", self.usr_id]];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", USERGOODSLISTAPI, self.usr_id, sig, [ControllerManager getSID]];
    NSLog(@"%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            NSLog(@"背包物品:%@", load.dataDict);
            if ([[load.dataDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary * dict = [load.dataDict objectForKey:@"data"];
                [self.goodsArray removeAllObjects];
                [self.goodsNumArray removeAllObjects];
                
                for (NSString * itemId in [dict allKeys]) {
                    if ([itemId intValue]%10 >4 || [itemId intValue]>=2200) {
                        continue;
                    }
                    [self.goodsArray addObject:itemId];
                }
                //排序
                for (int i=0; i<self.goodsArray.count; i++) {
                    for (int j=0; j<self.goodsArray.count-i-1; j++) {
                        if ([self.goodsArray[j] intValue] > [self.goodsArray[j+1] intValue]) {
                            NSString * str1 = [NSString stringWithFormat:@"%@", self.goodsArray[j]];
                            NSString * str2 = [NSString stringWithFormat:@"%@", self.goodsArray[j+1]];
                            self.goodsArray[j] = str2;
                            self.goodsArray[j+1] = str1;
                        }
                    }
                }
                //获取对应数量
                for (int i=0; i<self.goodsArray.count; i++) {
                    self.goodsNumArray[i] = [dict objectForKey:self.goodsArray[i]];
                }
                //剔除数目为0的物品
                for(int i=0;i<self.goodsArray.count;i++){
                    if ([self.goodsNumArray[i] intValue] == 0) {
                        [self.goodsArray removeObjectAtIndex:i];
                        [self.goodsNumArray removeObjectAtIndex:i];
                        i--;
                    }
                }
            }
            [self createTableView3];
        }else{
            
        }
    }];
    [request release];
}

#pragma mark - 用户列表

#pragma mark - 
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
    
    titleLabel = [MyControl createLabelWithFrame:CGRectMake(60, 64-20-15, 200, 20) Font:17 Text:@"用户资料"];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    
    UIImageView * more = [MyControl createImageViewWithFrame:CGRectMake(self.view.frame.size.width-17-17, 32, 17, 17) ImageName:@"moreBtn.png"];
    [navView addSubview:more];
    
    UIButton * moreBtn = [MyControl createButtonWithFrame:CGRectMake(270, 25, 47/2+20, 9/2+16+10+4) ImageName:@"" Target:self Action:@selector(moreBtnClick) Title:nil];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
//    moreBtn.showsTouchWhenHighlighted = YES;
    [navView addSubview:moreBtn];
}

#pragma mark - 导航点击事件
-(void)backBtnClick
{
    NSLog(@"back");
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)moreBtnClick
{
    NSLog(@"more");
    /********截图***********/
    UIImage * image = [MyControl imageWithView:[UIApplication sharedApplication].keyWindow];
    //存到本地
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingString:@"screenshot_user.png"];
    //将下载的图片存放到本地
    NSData * data = UIImageJPEGRepresentation(image, 0.5);
    BOOL isWriten = [data writeToFile:filePath atomically:YES];
    NSLog(@"--isWriten:%d", isWriten);
    /**********************/
    if (!isMoreCreated) {
        //create more
        [self createMore];
        isMoreCreated = YES;
    }
    [self.view bringSubviewToFront:menuBgBtn];
    [self.view bringSubviewToFront:moreView];
    
    //show more
    menuBgBtn.hidden = NO;
    CGRect rect = moreView.frame;
    rect.origin.y -= rect.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        moreView.frame = rect;
        menuBgBtn.alpha = 0.5;
    }];
    
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
    moreView = [MyControl createViewWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 234)];
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
    //grayLine1
    UIView * grayLine1 = [MyControl createViewWithFrame:CGRectMake(0, 105, 320, 2)];
    grayLine1.backgroundColor = [ControllerManager colorWithHexString:@"e3e3e3"];
    [moreView addSubview:grayLine1];
    
    //OwnerView
    UIView * ownerView = [MyControl createViewWithFrame:CGRectMake(0, 127, 320, 76/2)];
    [moreView addSubview:ownerView];
    
    UIButton * privateMessage = [MyControl createButtonWithFrame:CGRectMake(20, 0, 250/2, 76/2) ImageName:@"" Target:self Action:@selector(sendMessage) Title:@"私信"];
    privateMessage.backgroundColor = BGCOLOR5;
    privateMessage.showsTouchWhenHighlighted = YES;
    privateMessage.layer.cornerRadius = 5;
    privateMessage.layer.masksToBounds = YES;
    privateMessage.titleLabel.font = [UIFont systemFontOfSize:15];
    [ownerView addSubview:privateMessage];
    
    UIButton * report = [MyControl createButtonWithFrame:CGRectMake(self.view.frame.size.width-20-250/2, 0, 250/2, 76/2) ImageName:@"" Target:self Action:@selector(reportClick) Title:@"举报"];
    report.backgroundColor = [UIColor lightGrayColor];
    report.showsTouchWhenHighlighted = YES;
    report.layer.cornerRadius = 5;
    report.layer.masksToBounds = YES;
    report.titleLabel.font = [UIFont systemFontOfSize:15];
    [ownerView addSubview:report];
    
    UIButton * modifyUserInfo = [MyControl createButtonWithFrame:CGRectMake(30, 0, 526/2, 76/2) ImageName:@"" Target:self Action:@selector(modifyUserInfo) Title:@"修改资料"];
    modifyUserInfo.titleLabel.font = [UIFont systemFontOfSize:15];
    modifyUserInfo.backgroundColor = [UIColor lightGrayColor];
    modifyUserInfo.layer.cornerRadius = 5;
    modifyUserInfo.layer.masksToBounds = YES;
    modifyUserInfo.showsTouchWhenHighlighted = YES;
    modifyUserInfo.hidden = YES;
    [ownerView addSubview:modifyUserInfo];
    
    //grayLine2
    UIView * grayLine2 = [MyControl createViewWithFrame:CGRectMake(0, 180, 320, 5)];
    grayLine2.backgroundColor = [ControllerManager colorWithHexString:@"e3e3e3"];
    [moreView addSubview:grayLine2];
    
    //cancelBtn
    UIButton * cancelBtn = [MyControl createButtonWithFrame:CGRectMake(0, 188, 320, 46) ImageName:@"" Target:self Action:@selector(cancelBtnClick) Title:@"取消"];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.showsTouchWhenHighlighted = YES;
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [moreView addSubview:cancelBtn];
    
    /*************************/
    if (isOwner || self.isFromSideMenu) {
        privateMessage.hidden = YES;
        report.hidden = YES;
        modifyUserInfo.hidden = NO;
//        grayLine1.hidden = YES;
//        moreView.frame = CGRectMake(0, self.view.frame.size.height, 320, 156);
//        grayLine2.frame = CGRectMake(0, 104, 320, 4);
//        cancelBtn.frame = CGRectMake(0, 110, 320, 46);
    }
}
-(void)reportClick
{
    ReportAlertView * report = [[ReportAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    report.AlertType = 3;
    [report makeUI];
    [self.view addSubview:report];
    [UIView animateWithDuration:0.2 animations:^{
        report.alpha = 1;
    }];
    report.confirmClick = ^(){
        [self reportIt];
    };
}
-(void)reportIt
{
    StartLoading;
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"usr_id=%@dog&cat", self.usr_id]];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", REPORTUSERAPI, self.usr_id, sig, [ControllerManager getSID]];
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
-(void)modifyUserInfo
{
    NSLog(@"跳转到修改用户资料");
    ModifyPetOrUserInfoViewController * vc = [[ModifyPetOrUserInfoViewController alloc] init];
    vc.isModifyUser = YES;
    vc.refreshUserInfo = ^(void){
        for (UIView * view in self.view.subviews) {
            [view removeFromSuperview];
        }
        
        isCreated[0] = 0;
        isCreated[1] = 0;
        isCreated[2] = 0;
        isCreated[3] = 0;
        isMoreCreated = 0;
        isOwner = 0;
        [self viewDidLoad];
    };
    if(!isFromHeader){
        [self cancelBtnClick];
    }
    isFromHeader = NO;
    [self presentViewController:vc animated:YES completion:nil];
    [vc release];
}


-(void)shareClick:(UIButton *)button
{
    NSString * imagePath = [NSTemporaryDirectory() stringByAppendingString:@"screenshot_user.png"];
    UIImage * screenshotImage = [UIImage imageWithContentsOfFile:imagePath];
    if (button.tag == 200) {
        NSLog(@"微信");
        //强制分享图片
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:nil image:screenshotImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [self cancelBtnClick];
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
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:nil image:screenshotImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [self cancelBtnClick];
                StartLoading;
                [MMProgressHUD dismissWithSuccess:@"分享成功" title:nil afterDelay:0.5];
            }else{
                StartLoading;
                [MMProgressHUD dismissWithError:@"分享失败" afterDelay:0.5];
            }
            
        }];
    }else{
        NSLog(@"微博");
        NSString * str = [NSString stringWithFormat:@"我发现了一枚萌萌哒新伙伴%@，可以一起愉快的玩耍啦！http://home4pet.aidigame.com/（分享自@宠物星球社交应用）", [headerDict objectForKey:@"name"]];
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:str image:screenshotImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [self cancelBtnClick];
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
-(void)sendMessage
{
    if (![[USER objectForKey:@"isSuccess"] intValue]) {
        ShowAlertView;
        [self cancelBtnClick];
        return;
    }
    NSLog(@"发私信");
    TalkViewController * vc = [[TalkViewController alloc] init];
    [self cancelBtnClick];
    vc.friendName = [headerDict objectForKey:@"name"];
    vc.usr_id = [headerDict objectForKey:@"usr_id"];
    vc.otherTX = [headerDict objectForKey:@"tx"];
    [self presentViewController:vc animated:YES completion:nil];
    [vc release];
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
#pragma mark - 创建tableView的tableHeaderView
-(void)createHeader
{
    bgView = [MyControl createViewWithFrame:CGRectMake(0, 64, 320, 200)];
    [self.view addSubview:bgView];
    
    [self.view bringSubviewToFront:navView];
    [self.view bringSubviewToFront:toolBgView];
    //
    bgImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    UIImage * image = [UIImage imageNamed:@"defaultUserHead.png"];
    bgImageView1.image = [image applyBlurWithRadius:20 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
    [bgView addSubview:bgImageView1];
    [bgImageView1 release];
    
    //蒙版
    UIView * alphaView = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, 200)];
    alphaView.alpha = 0.7;
    alphaView.backgroundColor = [ControllerManager colorWithHexString:@"a85848"];
    [bgView addSubview:alphaView];
    
    //头像
    
    BOOL equal = [self.usr_id isEqualToString:[USER objectForKey:@"usr_id"]];
    if (equal) {
        headBtn = [MyControl createButtonWithFrame:CGRectMake(10, 25, 70, 70) ImageName:@"defaultPetHead.png" Target:self Action:@selector(headerClick) Title:nil];
        headBtn.layer.cornerRadius = 70/2;
        headBtn.layer.masksToBounds = YES;
        [bgView addSubview:headBtn];
    }else{
        headerImageView = [[ClickImage alloc]initWithFrame:CGRectMake(10, 25, 70, 70)];
        headerImageView.image = [UIImage imageNamed:@"defaultPetHead.png"];
        headerImageView.canClick = YES;
        headerImageView.layer.cornerRadius = 70/2;
        headerImageView.layer.masksToBounds = YES;
        [bgView addSubview:headerImageView];
        [headerImageView release];
    }

    /**************************/
    if (!([[headerDict objectForKey:@"tx"] isKindOfClass:[NSNull class]] || [[headerDict objectForKey:@"tx"] length]==0)) {
        NSString * docDir = DOCDIR;
        NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [headerDict objectForKey:@"tx"]]];
        //        NSLog(@"--%@--%@", txFilePath, self.headImageURL);
        UIImage * image = [UIImage imageWithContentsOfFile:txFilePath];
        if (image) {
            if(equal){
                [headBtn setBackgroundImage:image forState:UIControlStateNormal];
            }else{
                headerImageView.image = image;
            }
            bgImageView1.image = [image applyBlurWithRadius:20 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
        }else{
            //下载头像
            httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:[NSString stringWithFormat:@"%@%@", USERTXURL, [headerDict objectForKey:@"tx"]] Block:^(BOOL isFinish, httpDownloadBlock * load) {
                if (isFinish) {
                    if(equal){
                        [headBtn setBackgroundImage:load.dataImage forState:UIControlStateNormal];
                    }else{
                        headerImageView.image = load.dataImage;
                    }
                    bgImageView1.image = [load.dataImage applyBlurWithRadius:20 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
                    NSString * docDir = DOCDIR;
                    NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [headerDict objectForKey:@"tx"]]];
                    [load.data writeToFile:txFilePath atomically:YES];
                }else{
                    NSLog(@"头像下载失败");
                }
            }];
            [request release];
        }
    }
    /**************************/
    
    //等级
//    UILabel * exp = [MyControl createLabelWithFrame:CGRectMake(headImageView.frame.origin.x+70-20, headImageView.frame.origin.y+70-16, 30, 16) Font:10 Text:[NSString stringWithFormat:@"Lv.%@",[headerDict objectForKey:@"lv"]]];
//    exp.textAlignment = NSTextAlignmentCenter;
//    exp.backgroundColor = [UIColor colorWithRed:249/255.0 green:135/255.0 blue:88/255.0 alpha:1];
//    exp.textColor = [UIColor colorWithRed:229/255.0 green:79/255.0 blue:36/255.0 alpha:1];
//    exp.layer.cornerRadius = 3;
//    exp.layer.masksToBounds = YES;
//    exp.font = [UIFont boldSystemFontOfSize:10];
//    [bgView addSubview:exp];
    
//    UIButton * attentionBtn = [MyControl createButtonWithFrame:CGRectMake(60, 75, 20, 20) ImageName:@"" Target:self Action:@selector(attentionBtnClick) Title:@"关注"];
//    attentionBtn.titleLabel.font = [UIFont systemFontOfSize:10];
//    attentionBtn.layer.cornerRadius = 20/2;
//    attentionBtn.layer.masksToBounds = YES;
//    attentionBtn.backgroundColor = BGCOLOR4;
//    //    attentionBtn.showsTouchWhenHighlighted = YES;
//    [bgView addSubview:attentionBtn];
    
    //
    NSString *str = [NSString stringWithFormat:@"%@",[headerDict objectForKey:@"name"]];
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(120, 20) lineBreakMode:NSLineBreakByCharWrapping];
    UILabel * name = [MyControl createLabelWithFrame:CGRectMake(105, 25, size.width+3, 20) Font:14 Text:str];
    [bgView addSubview:name];
    
    UIImageView * sex = [MyControl createImageViewWithFrame:CGRectMake(name.frame.origin.x+name.frame.size.width, 25, 17, 17) ImageName:@"man.png"];
    if ([[headerDict objectForKey:@"gender"] intValue] == 2) {
        sex.image = [UIImage imageNamed:@"woman.png"];
    }
    [bgView addSubview:sex];
    
    //
    NSString * str4 = [ControllerManager returnProvinceAndCityWithCityNum:[headerDict objectForKey:@"city"]];
    CGSize size4 = [str4 sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(130, 100) lineBreakMode:NSLineBreakByCharWrapping];
    UILabel * cateNameLabel = [MyControl createLabelWithFrame:CGRectMake(105, 55, size4.width, size4.height) Font:14 Text:[ControllerManager returnProvinceAndCityWithCityNum:[headerDict objectForKey:@"city"]]];
//    cateNameLabel.font = [UIFont boldSystemFontOfSize:14];
//    cateNameLabel.alpha = 0.65;
    [bgView addSubview:cateNameLabel];
    
    //
    
    NSString * str2 = [NSString stringWithFormat:@"最爱萌星—%@", [headerDict objectForKey:@"a_name"]];
    CGSize size2 = [str2 sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(200, 100) lineBreakMode:NSLineBreakByCharWrapping];
    UILabel * positionAndUserName = [MyControl createLabelWithFrame:CGRectMake(105, 170/2, size2.width, 20) Font:14 Text:str2];
    //    positionAndUserName.font = [UIFont boldSystemFontOfSize:15];
    [bgView addSubview:positionAndUserName];
    
    //宠物头像，点击进入宠物主页
    UIButton * userImageBtn = [MyControl createButtonWithFrame:CGRectMake(positionAndUserName.frame.origin.x+positionAndUserName.frame.size.width+5, 160/2, 30, 30) ImageName:@"defaultPetHead.png" Target:self Action:@selector(jumpToUserInfo) Title:nil];
    if (self.petHeadImage != nil) {
        [userImageBtn setBackgroundImage:self.petHeadImage forState:UIControlStateNormal];
    }else{
        /**************************/
        if (!([[headerDict objectForKey:@"a_tx"] isKindOfClass:[NSNull class]] || [[headerDict objectForKey:@"a_tx"] length]==0)) {
            NSString * docDir = DOCDIR;
            NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [headerDict objectForKey:@"a_tx"]]];
            //        NSLog(@"--%@--%@", txFilePath, self.headImageURL);
            UIImage * image = [UIImage imageWithContentsOfFile:txFilePath];
            if (image) {
                [userImageBtn setBackgroundImage:image forState:UIControlStateNormal];
                //            headImageView.image = image;
            }else{
                //下载头像
                httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:[NSString stringWithFormat:@"%@%@", PETTXURL, [headerDict objectForKey:@"tx"]] Block:^(BOOL isFinish, httpDownloadBlock * load) {
                    if (isFinish) {
                        [userImageBtn setBackgroundImage:load.dataImage forState:UIControlStateNormal];
                        //                    headImageView.image = load.dataImage;
                        NSString * docDir = DOCDIR;
                        NSString * txFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [headerDict objectForKey:@"a_tx"]]];
                        [load.data writeToFile:txFilePath atomically:YES];
                    }else{
                        NSLog(@"头像下载失败");
                    }
                }];
                [request release];
            }
        }
        /**************************/
    }
    
    userImageBtn.layer.cornerRadius = 15;
    userImageBtn.layer.masksToBounds = YES;
    [bgView addSubview:userImageBtn];
    
    //123  164
    UIImageView * flagImageView = [MyControl createImageViewWithFrame:CGRectMake(240, 0, 123*0.45, 164*0.45) ImageName:@"flag_gold.png"];
    [bgView addSubview:flagImageView];
    
    UILabel * gold = [MyControl createLabelWithFrame:CGRectMake(0, 5, flagImageView.frame.size.width, 24) Font:12 Text:[NSString stringWithFormat:@"%@",[headerDict objectForKey:@"gold"]]];
    gold.textAlignment = NSTextAlignmentCenter;
    [flagImageView addSubview:gold];
    
    UIButton * GXList = [MyControl createButtonWithFrame:CGRectMake(0, 0, 123*0.45, 164*0.45-5) ImageName:@"" Target:self Action:@selector(GXListClick) Title:@""];
//    GXList.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [flagImageView addSubview:GXList];

    //五角星
    UIImageView * star = [MyControl createImageViewWithFrame:CGRectMake(74/2, 126, 20, 20) ImageName:@"yellow_star.png"];
    [bgView addSubview:star];
    
    NSString * str3= [NSString stringWithFormat:@"Lv.%@",[headerDict objectForKey:@"lv"]];
    CGSize size3 = [str3 sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(100, 100) lineBreakMode:1];
    UILabel * RQLabel = [MyControl createLabelWithFrame:CGRectMake(64, 130, size3.width, 15) Font:13 Text:str3];
    [bgView addSubview:RQLabel];
    
    UIImageView * RQBgImageView = [MyControl createImageViewWithFrame:CGRectMake(64+size3.width, 132, 350/2, 13) ImageName:@""];
    RQBgImageView.image = [[UIImage imageNamed:@"RQBg.png"] stretchableImageWithLeftCapWidth:37/2 topCapHeight:26/2];
    //边缘处理
    RQBgImageView.layer.cornerRadius = 6;
    RQBgImageView.layer.masksToBounds = YES;
    [bgView addSubview:RQBgImageView];
    
    int needExp = [ControllerManager returnExpOfNeedWithLv:[headerDict objectForKey:@"lv"]];
    int length = [[headerDict objectForKey:@"exp"] floatValue]/needExp*173;
    //    float length = 3.5/2*70;
    NSLog(@"%d", length);
    UIImageView * RQImageView = [MyControl createImageViewWithFrame:CGRectMake(1, 1, length, 11) ImageName:@""];
    RQImageView.image = [[UIImage imageNamed:@"RQImage.png"] stretchableImageWithLeftCapWidth:51/2 topCapHeight:25/2];
    [RQBgImageView addSubview:RQImageView];
    
    UILabel * RQNumLabel = [MyControl createLabelWithFrame:CGRectMake(50, 0, 75, 13) Font:12 Text:[NSString stringWithFormat:@"%d/%d", [[headerDict objectForKey:@"exp"] intValue], needExp]];
    RQNumLabel.textAlignment = NSTextAlignmentCenter;
    [RQBgImageView addSubview:RQNumLabel];
    
}
-(void)headerClick
{
    isFromHeader = YES;
    [self modifyUserInfo];
}
#pragma mark - 跳转点击事件
-(void)jumpToUserInfo
{
    NSLog(@"isFromPetInfo:%d", self.isFromPetInfo);
    if (self.isFromPetInfo) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"跳到petInfoViewController aid:%@", [headerDict objectForKey:@"aid"]);
        PetInfoViewController * vc = [[PetInfoViewController alloc] init];
        vc.aid = [headerDict objectForKey:@"aid"];
        [self presentViewController:vc animated:YES completion:nil];
        [vc release];
    }
    
}
-(void)GXListClick
{
    NSLog(@"跳转充值");
}

#pragma mark - 创建scrollView
-(void)createScrollView
{
    sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    sv.contentSize = CGSizeMake(320*4, self.view.frame.size.height);
    sv.delegate = self;
    sv.pagingEnabled = YES;
    //为防止和cell的手势冲突需要关闭scrollView的滑动属性。
    sv.scrollEnabled = NO;
    [self.view addSubview:sv];
}

#pragma mark - 创建tableView&&createTool

-(void)createTableView1
{
    tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tv.delegate = self;
    tv.dataSource = self;
    tv.separatorStyle = 0;
    [sv addSubview:tv];
    
    UIView * tvHeaderView = [MyControl createViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 264)];
    tv.tableHeaderView = tvHeaderView;

    isCreated[0] = 1;
    
    [self.view bringSubviewToFront:bgView];
    [self.view bringSubviewToFront:navView];
    
    //为保证切换条在所有层的最上面，所以在此创建
    toolBgView = [MyControl createViewWithFrame:CGRectMake(0, 64+200-44, self.view.frame.size.width, 44)];
    [self.view addSubview:toolBgView];
    
    UIView * toolAlphaView = [MyControl createViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolAlphaView.alpha = 0.4;
    toolAlphaView.backgroundColor = [ControllerManager colorWithHexString:@"8e2918"];
    [toolBgView addSubview:toolAlphaView];
    
    NSArray * unSeletedArray = @[@"page1.png", @"page3.png", @"page4.png"];
    NSArray * seletedArray = @[@"page1_selected.png", @"page3_selected.png", @"page4_selected.png"];
    int a = (self.view.frame.size.width-30*3)/4.0;
    for(int i=0;i<seletedArray.count;i++){
        UIButton * imageButton = [MyControl createButtonWithFrame:CGRectMake(a-15+i*(self.view.frame.size.width/3.0), 9, 30, 30) ImageName:unSeletedArray[i] Target:self Action:@selector(imageButtonClick) Title:nil];
        [imageButton setBackgroundImage:[UIImage imageNamed:seletedArray[i]] forState:UIControlStateSelected];
        [toolBgView addSubview:imageButton];
        imageButton.tag = 100+i;
        if (i == 0) {
            imageButton.selected = YES;
        }
//        4+i*(self.view.frame.size.width/3.0-4), 0, (self.view.frame.size.width/3.0-8), 44
        UIButton * button = [MyControl createButtonWithFrame:CGRectMake(i*(self.view.frame.size.width/3.0), 0, (self.view.frame.size.width/3.0), 44) ImageName:@"" Target:self Action:@selector(toolBtnClick:) Title:nil];
        button.tag = 200+i;
//        button.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [toolBgView addSubview:button];
    }
    //移动底条
    bottom = [MyControl createViewWithFrame:CGRectMake(0, 40, (self.view.frame.size.width/3.0), 4)];
    bottom.backgroundColor = BGCOLOR;
    [toolBgView addSubview:bottom];
    
    [self.view bringSubviewToFront:toolBgView];
    
    //加入从商店跳背包偏移量设置320*3 这里将直接偏移
//    sv.contentOffset = CGPointMake(self.offset, 0);
}
-(void)createTableView2
{
    //
    tv2 = [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, self.view.frame.size.height) style:UITableViewStylePlain];
    tv2.delegate = self;
    tv2.dataSource = self;
    tv2.separatorStyle = 0;
    [sv addSubview:tv2];
    
    UIView * tvHeaderView2 = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, 264)];
    tv2.tableHeaderView = tvHeaderView2;
    
    [self.view bringSubviewToFront:bgView];
    [self.view bringSubviewToFront:navView];
    [self.view bringSubviewToFront:toolBgView];
    isCreated[1] = 1;
}
-(void)createTableView3
{
    //
    tv3 = [[UITableView alloc] initWithFrame:CGRectMake(320*2, 0, 320, self.view.frame.size.height) style:UITableViewStylePlain];
    tv3.delegate = self;
    tv3.dataSource = self;
    tv3.separatorStyle = 0;
    [sv addSubview:tv3];
    
    UIView * tvHeaderView3 = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, 264)];
    tv3.tableHeaderView = tvHeaderView3;
    
    [self.view bringSubviewToFront:bgView];
    [self.view bringSubviewToFront:navView];
    [self.view bringSubviewToFront:toolBgView];
    isCreated[2] = 1;
}
//-(void)createTableView4
//{
//    //
//    tv4 = [[UITableView alloc] initWithFrame:CGRectMake(320*3, 0, 320, self.view.frame.size.height) style:UITableViewStylePlain];
//    tv4.delegate = self;
//    tv4.dataSource = self;
//    tv4.separatorStyle = 0;
//    [sv addSubview:tv4];
//    
//    UIView * tvHeaderView4 = [MyControl createViewWithFrame:CGRectMake(0, 0, 320, 264)];
//    tv4.tableHeaderView = tvHeaderView4;
//    
//    [self.view bringSubviewToFront:bgView];
//    [self.view bringSubviewToFront:navView];
//    [self.view bringSubviewToFront:toolBgView];
//    isCreated[3] = 1;
//}



-(void)imageButtonClick
{
    
}
-(void)toolBtnClick:(UIButton *)button
{
    NSLog(@"%d", button.tag);
    for(int i=0;i<3;i++){
        UIButton * btn = (UIButton *)[toolBgView viewWithTag:100+i];
        btn.selected = NO;
    }
    int a = button.tag;
    UIButton * temp = (UIButton *)[toolBgView viewWithTag:a-100];
    temp.selected = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        bottom.frame = CGRectMake((a-200)*(self.view.frame.size.width/3.0), 40, (self.view.frame.size.width/3.0), 4);
        
        sv.contentOffset = CGPointMake(self.view.frame.size.width*(a-200), 0);
    }];
    
    if (a == 200) {
        if (!isCreated[a-200]) {
            [self createTableView1];
        }
    }else if(a == 201) {
        if (!isCreated[a-200]) {
            [self createTableView2];
//            [self loadActData];
//            [self createTableView2];
//            [self loadMyAttentionCountryData];
        }
    }else if(a == 202) {
        if (!isCreated[a-200]) {
            [self loadBagData];
            [self createTableView3];
//            [self loadActData];
        }
    }
//    else{
//        if (!isCreated[a-200]) {
////            [self loadBagData];
//        }
//    }
}

#pragma mark - scrollView代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    int x = sv.contentOffset.x;
//    
//    if (scrollView == sv && x%320 == 0) {
//        tempTv = nil;
//        if (x/320 == 0) {
//            tempTv = tv;
//        }else if(x/320 == 1){
//            tempTv = tv2;
//        }else if(x/320 == 2){
//            tempTv = tv3;
//        }
////        else{
////            tempTv = tv4;
////        }
//        //对应的按钮变颜色
//        UIButton * button = (UIButton *)[toolBgView viewWithTag:200+x/self.view.frame.size.width];
////        [self toolBtnClick:button];
//        //小橘条位置变化
//        [UIView animateWithDuration:0.2 animations:^{
//            bottom.frame = CGRectMake((self.view.frame.size.width/3.0)*x/self.view.frame.size.width, 40, (self.view.frame.size.width/3.0), 4);
//            tempTv.contentOffset = CGPointMake(0, 0);
//            tempTv = nil;
//            bgView.frame = CGRectMake(0, 64, (self.view.frame.size.width/3.0), 200);
//            toolBgView.frame = CGRectMake(0, 64+200-44, (self.view.frame.size.width/3.0), 44);
//        }];
//    }
//    
    if (scrollView != sv) {
        bgView.frame = CGRectMake(0, 64-scrollView.contentOffset.y, self.view.frame.size.width, 200);
        //
        if (scrollView.contentOffset.y<=200-44) {
            toolBgView.frame = CGRectMake(0, 64+200-44-scrollView.contentOffset.y, self.view.frame.size.width, 44);
        }else{
            toolBgView.frame = CGRectMake(0, 64, self.view.frame.size.width, 44);
            
        }
    }
    //        else{
    //        //每次转换tableView后校准header和tool的位置
    //        bgView.frame = CGRectMake(0, 64-scrollView.contentOffset.y, 320, 200);
    //        toolBgView.frame = CGRectMake(0, 64, 320, 44);
    //    }
}
#pragma mark - tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tv3) {
        if (self.goodsArray.count) {
            return 1;
        }else{
            return 0;
        }
    }else if(tableView == tv){
        //+的这个1是添加王国的按钮
        if ([self.usr_id isEqualToString:[USER objectForKey:@"usr_id"]]) {
            return self.userPetListArray.count+1;
        }else{
            return self.userPetListArray.count;
        }
    }else
//        if(tableView == tv2){
//        return self.userAttentionListArray.count;
//    }else
    {
        return 1;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tv) {
        if (indexPath.row == self.userPetListArray.count) {
            static NSString * cellID0 = @"ID0";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID0];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[cellID0 autorelease]];
            }
            cell.selectionStyle = 0;
            
            UIButton * button = [MyControl createButtonWithFrame:CGRectMake(40, 8, 240, 35) ImageName:@"" Target:self Action:@selector(addCountry) Title:@"+"];
            [cell addSubview:button];
            button.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1];
            button.layer.cornerRadius = 5;
            button.layer.masksToBounds = YES;
            button.titleLabel.font = [UIFont systemFontOfSize:30];
            return cell;
        }
        
        static NSString * cellID = @"ID";
        CountryInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CountryInfoCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor whiteColor];
        //不要忘记指针指向
        cell.delegate = self;
        cell.selectionStyle = 0;
//        if (indexPath.row == 0) {
//            UIImageView * crown = [MyControl createImageViewWithFrame:CGRectMake(55, 52, 20, 20) ImageName:@"crown.png"];
//            [cell addSubview:crown];
//        }
        if ([self.usr_id isEqualToString:[USER objectForKey:@"usr_id"]]) {
            [cell modify:indexPath.row isSelf:YES];
        }else{
            [cell modify:indexPath.row isSelf:NO];
        }
        [cell configUI:self.userPetListArray[indexPath.row]];
        return cell;
    }else if (tableView == tv2) {
        static NSString * cellID3 = @"ID3";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID3];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID3] autorelease];
            //471   307
            UIImageView * image = [MyControl createImageViewWithFrame:CGRectMake((self.view.frame.size.width-471/2)/2, 30, 471/2, 307/2) ImageName:@"activity_wait.png"];
            [cell addSubview:image];
        }
        cell.selectionStyle = 0;
        return cell;
//        static NSString * cellID2 = @"ID2";
//        UserInfoRankCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID2];
//        if(!cell){
//            cell = [[[NSBundle mainBundle] loadNibNamed:@"UserInfoRankCell" owner:self options:nil] objectAtIndex:0];
//        }
//        cell.selectionStyle = 0;
//        [cell configUI:self.userAttentionListArray[indexPath.row]];
//        return cell;
    }else{
        static NSString * cellID3 = @"ID3";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID3];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID3] autorelease];
        }
        cell.selectionStyle = 0;
        
        for(int i=0;i<self.goodsArray.count;i++){
            CGRect rect = CGRectMake(20+i%3*100, 15+i/3*100, 85, 90);
            NSDictionary * dict = [ControllerManager returnGiftDictWithItemId:self.goodsArray[i]];
            
            UIImageView * imageView = [MyControl createImageViewWithFrame:rect ImageName:@"product_bg.png"];
            if ([[dict objectForKey:@"no"] intValue]>=2000) {
                imageView.image = [UIImage imageNamed:@"trick_bg.png"];
            }
            [cell addSubview:imageView];
            
            //            UIImageView * triangle = [MyControl createImageViewWithFrame:CGRectMake(0, 0, 32, 32) ImageName:@"gift_triangle.png"];
            //            [imageView addSubview:triangle];
            
            UILabel * rq = [MyControl createLabelWithFrame:CGRectMake(-1, 4, 20, 9) Font:8 Text:@"人气"];
            rq.font = [UIFont boldSystemFontOfSize:8];
            rq.transform = CGAffineTransformMakeRotation(-45.0*M_PI/180.0);
            [imageView addSubview:rq];
            
            UILabel * rqNum = [MyControl createLabelWithFrame:CGRectMake(-1, 11, 25, 10) Font:8 Text:nil];
            rqNum.font = [UIFont systemFontOfSize:8];
            if ([[dict objectForKey:@"add_rq"] rangeOfString:@"-"].location == NSNotFound) {
                rqNum.text = [NSString stringWithFormat:@"+%@", [dict objectForKey:@"add_rq"]];
            }else{
                rqNum.text = [dict objectForKey:@"add_rq"];
            }
            rqNum.transform = CGAffineTransformMakeRotation(-45.0*M_PI/180.0);
            rqNum.textAlignment = NSTextAlignmentCenter;
            //            rqNum.backgroundColor = [UIColor redColor];
            [imageView addSubview:rqNum];
            
            UILabel * giftName = [MyControl createLabelWithFrame:CGRectMake(0, 6, 85, 15) Font:10 Text:[dict objectForKey:@"name"]];
            giftName.textColor = [UIColor grayColor];
            giftName.textAlignment = NSTextAlignmentCenter;
            [imageView addSubview:giftName];
            
            //98*0.6=59  83*0.6=50   85  90
            UIImageView * giftPic = [MyControl createImageViewWithFrame:CGRectMake(13, 20, 59, 50) ImageName:[NSString stringWithFormat:@"%@.png", [dict objectForKey:@"no"]]];
            [imageView addSubview:giftPic];
            
            UIImageView * gift = [MyControl createImageViewWithFrame:CGRectMake(20, 90-14-5, 12, 14) ImageName:@"detail_gift.png"];
            [imageView addSubview:gift];
            
            UILabel * giftNum = [MyControl createLabelWithFrame:CGRectMake(35, 90-18, 40, 15) Font:13 Text:[NSString stringWithFormat:@" × %@", self.goodsNumArray[i]]];
            giftNum.textColor = BGCOLOR;
            [imageView addSubview:giftNum];
            
            UIButton * button = [MyControl createButtonWithFrame:rect ImageName:@"" Target:self Action:@selector(buttonClick:) Title:nil];
            [cell addSubview:button];
            button.tag = 1000+i;
        }
        return cell;
        
//        UserInfoActivityCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID3];
//        if(!cell){
//            cell = [[[NSBundle mainBundle] loadNibNamed:@"UserInfoActivityCell" owner:self options:nil] objectAtIndex:0];
//        }
//        cell.selectionStyle = 0;
//        UserActivityListModel * model = self.userActivityListArray[indexPath.row];
//        [cell configUI:model];
//        cell.jumpToDetail = ^(NSString * img_id){
//            PicDetailViewController * vc = [[PicDetailViewController alloc] init];
//            vc.img_id = img_id;
//            [self presentViewController:vc animated:YES completion:nil];
//            [vc release];
//        };
////        [cell modifyWithString:@"# 萌宠时装秀 #"];
//        return cell;
    }
//    else{
//        
//    }
}
//-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"取消关注";
//}

//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.usr_id isEqualToString:[USER objectForKey:@"usr_id"]] && tableView == tv2) {
//        return UITableViewCellEditingStyleDelete;
//    }else{
//        return 0;
//    }
//}
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tableView == tv2 && editingStyle==UITableViewCellEditingStyleDelete) {
////        [self unFollow:indexPath.row];
//        AlertView * view = [[AlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//        view.AlertType = 4;
//        [view makeUI];
//        view.jump = ^(){
//            NSString * code = [NSString stringWithFormat:@"aid=%@dog&cat", [self.userAttentionListArray[indexPath.row] aid]];
//            NSString * sig = [MyMD5 md5:code];
//            NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", UNFOLLOWAPI, [self.userAttentionListArray[indexPath.row] aid], sig, [ControllerManager getSID]];
//            NSLog(@"unfollowApiurl:%@", url);
//            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//            [MMProgressHUD showWithStatus:@"取消关注中..."];
//            httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
//                if (isFinish) {
//                    //            NSLog(@"%@", load.dataDict);
//                    [MMProgressHUD dismissWithSuccess:@"取消关注成功" title:nil afterDelay:1];
//                    [self.userAttentionListArray removeObjectAtIndex:indexPath.row];
//                    //删除单元格的某一行时，在用动画效果实现删除过程
//                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                }else{
//                    [MMProgressHUD dismissWithError:@"取消关注失败" afterDelay:1];
//                }
//            }];
//            [request release];
//        };
//        [self.view addSubview:view];
//        [view release];
//    }
////    else if(tableView == tv){
////        if ([self.usr_id isEqualToString:[self.userPetListArray[indexPath.row] master_id]]) {
////            StartLoading;
////            [MMProgressHUD dismissWithError:@"不能退出自己的国家" afterDelay:1];
////            return;
////        }
////        [self quitCountryWithRow:indexPath.row];
////        [self.userPetListArray removeObjectAtIndex:indexPath.row];
////        //删除单元格的某一行时，在用动画效果实现删除过程
////        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
////    }
//}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tv) {
        return 100.0f;
    }else if(tableView == tv2){
        return 200.0f;
    }else{
        int i = self.goodsArray.count;
        if (i%3) {
            return 15+(i/3+1)*100;
        }else{
            return 15+i/3*100;
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tv) {
        NSLog(@"%d", indexPath.row);
        PetInfoViewController * vc = [[PetInfoViewController alloc] init];
        vc.aid = [self.userPetListArray[indexPath.row] aid];
        [self presentViewController:vc animated:YES completion:nil];
        [vc release];
    }
//    else if(tableView == tv2){
//        PetInfoViewController * vc = [[PetInfoViewController alloc] init];
//        vc.aid = [self.userAttentionListArray[indexPath.row] aid];
//        [self presentViewController:vc animated:YES completion:nil];
//        [vc release];
//    }
}

#pragma mark - cell代理,退出王国和设置默认
-(void)swipeTableViewCell:(CountryInfoCell *)cell didClickButtonWithIndex:(NSInteger)index
{
    if (sv.contentOffset.x == 0) {
        if (index == 1) {
            //退出联萌
            NSIndexPath * cellIndexPath = [tv indexPathForCell:cell];
            NSLog(@"%@", [self.userPetListArray[cellIndexPath.row] master_id]);
//            NSLog(@"%@--%@--%@", [self.userPetListArray[cellIndexPath.row] master_id], self.usr_id, [USER objectForKey:@"usr_id"]);
            if ([[USER objectForKey:@"usr_id"] isEqualToString:[self.userPetListArray[cellIndexPath.row] master_id]]) {
//                StartLoading;
//                [MMProgressHUD dismissWithError:@"不能不捧最爱萌星" afterDelay:1];
                PopupView * pop = [[PopupView alloc] init];
                [pop modifyUIWithSize:self.view.frame.size msg:@"不能不捧自己创建的萌星"];
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
                return;
            }
            if (self.userPetListArray.count == 1) {
//                StartLoading;
//                [MyControl loadingFailedWithContent:@"您仅有1个，不能退出" afterDelay:1];
                PopupView * pop = [[PopupView alloc] init];
                [pop modifyUIWithSize:self.view.frame.size msg:@"就剩一个啦~不能不捧啊~"];
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
                return;
            }
            
//            NSLog(@"%@", [USER objectForKey:@"aid"]);
            if ([[USER objectForKey:@"aid"] isEqualToString:[self.userPetListArray[cellIndexPath.row] aid]]) {
                NSMutableArray * tempArray = [NSMutableArray arrayWithArray:self.userPetListArray];
                [tempArray removeObjectAtIndex:cellIndexPath.row];
                //其他中贡献度最高的一个
                NSLog(@"退出的圈子aid：%@", [USER objectForKey:@"aid"]);
                isNeedChangeDefault = YES;
                quitIndex = cellIndexPath.row;
                Index = 0;
                Contri = [[tempArray[0] t_contri] intValue];
                for(int i=1;i<tempArray.count;i++){
                    if ([[tempArray[i] t_contri]intValue]>Contri) {
                        Index = i;
                        Contri = [[tempArray[i] t_contri] intValue];
                    }
                }
                NSLog(@"需要切换到默认aid：%@", [tempArray[Index] aid]);
//                if (Index) {
                    [self changeDefaultPetAid:[tempArray[Index] aid] MasterId:[tempArray[Index] master_id]];
                    return;
//                }
//                StartLoading;
//                [MyControl loadingFailedWithContent:@"不能退出默认宠物" afterDelay:1];
//                PopupView * pop = [[PopupView alloc] init];
//                [pop modifyUIWithSize:self.view.frame.size msg:@"不能不捧最爱萌星，请将其他萌星设为最爱"];
//                [self.view addSubview:pop];
//                [pop release];
//                
//                [UIView animateWithDuration:0.2 animations:^{
//                    pop.bgView.alpha = 1;
//                } completion:^(BOOL finished) {
//                    [UIView animateKeyframesWithDuration:0.2 delay:2 options:0 animations:^{
//                        pop.bgView.alpha = 0;
//                    } completion:^(BOOL finished) {
//                        [pop removeFromSuperview];
//                    }];
//                }];
//                return;
            }
//            [self quitCountryWithRow:cellIndexPath.row];
            /***************************/
            AlertView * view = [[AlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            view.AlertType = 5;
            [view makeUI];
            view.jump = ^(){
                NSString * code = [NSString stringWithFormat:@"aid=%@dog&cat", [self.userPetListArray[cellIndexPath.row] aid]];
                NSString * sig = [MyMD5 md5:code];
                NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", EXITFAMILYAPI, [self.userPetListArray[cellIndexPath.row] aid], sig, [ControllerManager getSID]];
                NSLog(@"quitApiurl:%@", url);
                [MyControl startLoadingWithStatus:@"退出中..."];
                httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
                    if (isFinish) {
                        if ([[[load.dataDict objectForKey:@"data"] objectForKey:@"isSuccess"] intValue]) {
                            [MMProgressHUD dismissWithSuccess:@"退出成功" title:nil afterDelay:0.5];
                            [self.userPetListArray removeObjectAtIndex:cellIndexPath.row];
                            [tv deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                            if (Index) {
//                                [self changeDefaultPetAid:[self.userPetListArray[Index] aid] MasterId:[self.userPetListArray[Index] master_id]];
//                            }else{
                                [tv reloadData];
//                            }
                            
                        }else{
                            [MMProgressHUD dismissWithSuccess:@"退出失败" title:nil afterDelay:0.7];
                        }
                    }else{
                        [MMProgressHUD dismissWithError:@"退出失败" afterDelay:0.7];
                    }
                }];
                [request release];
            };
            [self.view addSubview:view];
            [view release];
            
        }else if(index == 2){
            //设为默认
            NSIndexPath * cellIndexPath = [tv indexPathForCell:cell];
            if (![[self.userPetListArray[cellIndexPath.row] aid] isEqualToString:[USER objectForKey:@"aid"]]) {
                [self changeDefaultPetAid:[self.userPetListArray[cellIndexPath.row] aid] MasterId:[self.userPetListArray[cellIndexPath.row] master_id]];
            }
        }
    }
}
#pragma mark -
-(void)changeDefaultPetAid:(NSString *)aid MasterId:(NSString *)master_id
{
    
    [MyControl startLoadingWithStatus:@"切换中..."];
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"aid=%@dog&cat", aid]];
    NSString * url =[NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", CHANGEDEFAULTPETAPI, aid, sig, [ControllerManager getSID]];
    //    NSLog(@"%@", url);
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            NSLog(@"%@", load.dataDict);
            if ([[load.dataDict objectForKey:@"data"] objectForKey:@"isSuccess"]) {
                NSLog(@"%@", aid);
                
                
                //退出圈子
                if (isNeedChangeDefault) {
                    isNeedChangeDefault = NO;
                    NSString * code = [NSString stringWithFormat:@"aid=%@dog&cat", [USER objectForKey:@"aid"]];
                    NSString * sig2 = [MyMD5 md5:code];
                    NSString * url2 = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", EXITFAMILYAPI, [USER objectForKey:@"aid"], sig2, [ControllerManager getSID]];
                    NSLog(@"quitApiurl:%@", url2);
                    [MyControl startLoadingWithStatus:@"退出中..."];
                    [USER setObject:aid forKey:@"aid"];
                    [USER setObject:master_id forKey:@"master_id"];
                    NSLog(@"%@--%@--%@", [USER objectForKey:@"aid"], [USER objectForKey:@"master_id"], [USER objectForKey:@"usr_id"]);
                    httpDownloadBlock * request2 = [[httpDownloadBlock alloc] initWithUrlStr:url2 Block:^(BOOL isFinish, httpDownloadBlock * load) {
                        if (isFinish) {
                            if ([[[load.dataDict objectForKey:@"data"] objectForKey:@"isSuccess"] intValue]) {
                                [MMProgressHUD dismissWithSuccess:@"退出成功" title:nil afterDelay:0.5];
                                [self.userPetListArray removeObjectAtIndex:quitIndex];
//                                [tv deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                //                            if (Index) {
                                //                                [self changeDefaultPetAid:[self.userPetListArray[Index] aid] MasterId:[self.userPetListArray[Index] master_id]];
                                //                            }else{
                                [tv reloadData];
                                [self loadPetInfo];
                                //                            }
                                
                            }else{
                                [MMProgressHUD dismissWithSuccess:@"退出失败" title:nil afterDelay:0.7];
                            }
                        }else{
                            [MMProgressHUD dismissWithError:@"退出失败" afterDelay:0.7];
                        }
                    }];
                    [request2 release];
                }else{
                    [USER setObject:aid forKey:@"aid"];
                    [USER setObject:master_id forKey:@"master_id"];
                    NSLog(@"%@--%@--%@", [USER objectForKey:@"aid"], [USER objectForKey:@"master_id"], [USER objectForKey:@"usr_id"]);
                    [tv reloadData];
                    [self loadPetInfo];
                }
                

            }else{
                [MMProgressHUD dismissWithError:@"切换失败" afterDelay:0.8];
            }
            
        }else{
            [MMProgressHUD dismissWithError:@"切换失败" afterDelay:0.8];
        }
    }];
    [request release];
}
-(void)loadPetInfo
{
    [MyControl startLoadingWithStatus:@"切换成功，更新信息中..."];
    NSString * sig = [MyMD5 md5:[NSString stringWithFormat:@"aid=%@dog&cat", [USER objectForKey:@"aid"]]];
    NSString * url = [NSString stringWithFormat:@"%@%@&sig=%@&SID=%@", PETINFOAPI, [USER objectForKey:@"aid"], sig, [ControllerManager getSID]];
    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
        if (isFinish) {
            NSLog(@"petInfo:%@", load.dataDict);
            if ([[load.dataDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                
                //记录默认宠物信息
                [USER setObject:[load.dataDict objectForKey:@"data"] forKey:@"petInfoDict"];
            }
            [MMProgressHUD dismissWithSuccess:@"更新成功" title:nil afterDelay:0.5];
        }else{
            [MMProgressHUD dismissWithError:@"更新失败" afterDelay:0.5];
        }
    }];
    [request release];
}

//礼物点击事件
-(void)buttonClick:(UIButton *)btn
{
    NSLog(@"%d", btn.tag);
}
-(void)addCountry
{
    NSLog(@"加入国家");
    //先判断是否已经有10个，是type = 3
//    LOADING;
//    NSString * code = [NSString stringWithFormat:@"is_simple=0&usr_id=%@dog&cat", self.usr_id];
//    NSString * url = [NSString stringWithFormat:@"%@%d&usr_id=%@&sig=%@&SID=%@", USERPETLISTAPI, 0, self.usr_id, [MyMD5 md5:code], [ControllerManager getSID]];
//    NSLog(@"%@", url);
//    httpDownloadBlock * request = [[httpDownloadBlock alloc] initWithUrlStr:url Block:^(BOOL isFinish, httpDownloadBlock * load) {
//        if (isFinish) {
//            ENDLOADING;
//            NSArray * array = [load.dataDict objectForKey:@"data"];
//            [USER setObject:[NSString stringWithFormat:@"%d", array.count] forKey:@"countryNum"];
//            if (array.count>=10) {
//                if((array.count+1)*5>[[USER objectForKey:@"gold"] intValue]){
//                    //余额不足
//                    [MyControl popAlertWithView:self.view Msg:@"钱包君告急！挣够金币再来捧萌星吧~"];
//                    return;
//                }
//                AlertView * view = [[AlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//                view.AlertType = 3;
//                view.CountryNum = array.count;
//                view.jump = ^(){
                    ChooseInViewController * vc = [[ChooseInViewController alloc] init];
                    vc.isOldUser = YES;
                    vc.isFromAdd = YES;
                    [self presentViewController:vc animated:YES completion:nil];
                    [vc release];
//                };
//                [view makeUI];
//                [self.view addSubview:view];
//                [view release];
//            }else{
//                ChooseInViewController * vc = [[ChooseInViewController alloc] init];
//                vc.isOldUser = YES;
//                vc.isFromAdd = YES;
//                [self presentViewController:vc animated:YES completion:nil];
//                [vc release];
//            }
//        }else{
//            LOADFAILED;
//        }
//    }];
//    [request release];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
