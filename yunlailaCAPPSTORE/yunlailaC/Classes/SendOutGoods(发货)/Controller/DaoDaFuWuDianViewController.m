//
//  DaoDaFuWuDianViewController.m
//  yunlailaC
//
//  Created by admin on 16/7/22.
//  Copyright © 2016年 com.yunlaila. All rights reserved.
//

#import "DaoDaFuWuDianViewController.h"

@interface DaoDaFuWuDianViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *items;
    NSMutableArray *tmpitems;
    int currentIndex;
}
@end

@implementation DaoDaFuWuDianViewController
@synthesize sheng;
@synthesize shi;
@synthesize diqu;
- (void)setSheng:(NSDictionary *)sheng1
{
    sheng = sheng1;
}

- (void)setShi:(NSDictionary *)shi1
{
    shi = shi1;
}

- (void)setDiqu:(NSDictionary *)diqu1
{
    diqu = diqu1;
    NSLog(@"diqu:%@",diqu);
    [items removeAllObjects];
    NSArray *fuwudian = [diqu1 objectForKey:@"child"];
    [items addObjectsFromArray:fuwudian];
    [_collectionView reloadData];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        currentIndex = -1;
        items = [[NSMutableArray alloc] init];
        tmpitems = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
    {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    if (IsIOS7)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
    currentIndex = -1;
    [_collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNav];
    [self initView];
    [APP_DELEGATE() storyBoradAutoLay:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNav
{
    self.title = @"到达服务点";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"fanhuijianfanhui" highIcon:@"fanhuijianfanhui" target:self action:@selector(pop:)];
    
}

- (void) initView
{
    UIImageView *iconView1 = [[UIImageView alloc]initWithImage:[UIImage imageWithName:@"searchbar_textfield_search_icon"]];
    iconView1.contentMode = UIViewContentModeCenter;
    
    UITextField *searchText = [[UITextField alloc] init];
    searchText.leftView = iconView1;
    searchText.leftViewMode = UITextFieldViewModeAlways;
    searchText.leftView.frame = CGRectMake(0, 0, 30, 44);
    searchText.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchText.borderStyle = UITextBorderStyleNone;
    searchText.frame = CGRectMake(15, 7, 290, 30);
    searchText.delegate = self;
    searchText.placeholder = @"搜索服务点";
    searchText.returnKeyType = UIReturnKeySearch;
    searchText.keyboardType = UIKeyboardTypeDefault;
    searchText.font = viewFont2;
    searchText.textColor = fontColor;
    searchText.backgroundColor = [UIColor whiteColor];
    searchText.borderStyle = UITextBorderStyleRoundedRect;
    [searchText setValue:[UIColor colorWithRed:172/255.0 green:172/255.0 blue:172/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [searchText setValue:viewFont2 forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:searchText];
    [searchText addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.headerReferenceSize = CGSizeMake(320,0);//头部
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 44, [UIScreen mainScreen].bounds.size.width -30 , [UIScreen mainScreen].bounds.size.height - TabbarHeight  - 44) collectionViewLayout:flowLayout];
    
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewIdentifier"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
    
    [_collectionView setBackgroundColor:bgViewColor];
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [_collectionView reloadData];
    
    
}

#pragma mark - collectionView代理
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 50);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //    if (section==0)
    //    {
    //    return CGSizeMake(0, 0);
    //    }
    //    else
    //    {
    //    return CGSizeMake(320, 30);
    //    }
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

#pragma mark - collection数据源代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
      [collectionView tableViewDisplayWitMsg:@"暂无数据" ifNecessaryForRowCount:items.count];
    return [items count];
}

//头部显示的内容
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//
//    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
//                                            UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
//
//    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
//    view1.backgroundColor = [UIColor whiteColor];
//
//    UILabel *label1 = [[UILabel alloc] init];
//    label1.frame = CGRectMake(15, 3, 210, 30);
//    label1.font=[UIFont systemFontOfSize:12];
//    label1.numberOfLines = 0;
//    label1.textColor = [UIColor colorWithRed:186/255.0 green:186/255.0 blue:186/255.0 alpha:1];
//    label1.text = @"本地服务";
//    [view1 addSubview:label1];
//    if (indexPath.section==0)
//    {
//        label1.text = @"本地服务";
//    }
//    else
//    {
//        label1.text = @"网络服务";
//    }
//
//    [headerView addSubview:view1];//头部广告栏
//    return headerView;
//}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewIdentifier" forIndexPath:indexPath];
    
    for (UIView* view in [cell.contentView subviews])
    {
        [view removeFromSuperview];
    }
    
    cell.contentView.backgroundColor = bgViewColor;
    
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 90, 41)];
    [button1 setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageWithColor:titleViewColor] forState:UIControlStateHighlighted];
    [button1 setBackgroundImage:[UIImage imageWithColor:titleViewColor] forState:UIControlStateSelected];
    
    NSDictionary *shi = [items objectAtIndex:indexPath.row];
    [button1 setTitle:[NSString stringWithFormat:@"%@",[shi objectForKey:@"receipt_name"]] forState:UIControlStateNormal];
    [button1 setTitle:[NSString stringWithFormat:@"%@",[shi objectForKey:@"receipt_name"]] forState:UIControlStateHighlighted];
    [button1 setTitle:[NSString stringWithFormat:@"%@",[shi objectForKey:@"receipt_name"]] forState:UIControlStateSelected];
    
    
    
    [button1 setTitleColor:fontColor forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    button1.titleLabel.font = viewFont1;
    button1.titleLabel.lineBreakMode = 0;
    button1.tag = indexPath.row;
    
    [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    LRViewBorderRadius(button1,5,1,[UIColor clearColor]);
    [cell.contentView addSubview:button1];
    if (indexPath.row==currentIndex)
    {
        button1.selected = YES;
    }
    else
    {
        button1.selected = NO;
    }
    
    
    return cell;
}

-(void)buttonClick:(UIButton *)sender
{
    currentIndex = sender.tag;
    [_collectionView reloadData];
    NSDictionary *fuwudian = [items objectAtIndex:sender.tag];
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@",[sheng objectForKey:@"receipt_name"],[shi objectForKey:@"receipt_name"],[diqu objectForKey:@"receipt_name"],[fuwudian objectForKey:@"receipt_name"]];
//    NSString *text = [NSString stringWithFormat:@"%@",[fuwudian objectForKey:@"receipt_name"]];
    NSDictionary *info = @{
                           @"text" :text ,
                           @"receipt_region_id" : [fuwudian objectForKey:@"receipt_region_id"],
                           };
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_XuanKaiTong1 object:nil userInfo:info];
    }];
    
}


- (void)pop:(id)sender
{
    //    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    //
    //    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [tmpitems removeAllObjects];
    [tmpitems addObjectsFromArray:items];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [items removeAllObjects];
    [items addObjectsFromArray:tmpitems];
    [_collectionView reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [items removeAllObjects];
    [items addObjectsFromArray:tmpitems];
    [_collectionView reloadData];
    return YES;
}

- (void)textFieldEditChanged:(UITextField *)textField
{
    if (textField.text.length==0)
    {
        [items removeAllObjects];
        [items addObjectsFromArray:tmpitems];
        [_collectionView reloadData];
    }
    else
    {
        [items removeAllObjects];
        for (NSDictionary *info in tmpitems)
        {
            NSRange range = [[info objectForKey:@"receipt_name"] rangeOfString:textField.text];
            if (range.location !=NSNotFound)
            {
                [items addObject:info];
            }
        }
        
        [_collectionView reloadData];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
