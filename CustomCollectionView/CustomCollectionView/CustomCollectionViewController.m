//
//  CustomCollectionViewController.m
//  JSCoreTest
//
//  Created by fanfengyan on 16/6/1.
//  Copyright © 2016年 RW. All rights reserved.
//

#import "CustomCollectionViewController.h"
#import "Header.h"
#import "Footer.h"
#import "CustomCell.h"

@interface CustomCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSInteger sectionCount;
}

@end

@implementation CustomCollectionViewController

static NSString * const reuseIdentifier = @"customCell";
static NSString * const reuseHeaderIdentifier = @"CustomHeader1";
static NSString * const reuseFooterrIdentifier = @"CustomFooter1";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    
    [(CustomCollectionViewLayout*)self.collectionView.collectionViewLayout setDelegate:self];
    
    sectionCount = 1;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh{
    [self.collectionView reloadData];
}

#pragma mark -<CustomCollectionViewLayoutDelegate>
-(NSInteger)numberOfColumnsForSection:(NSInteger)section{
    if (section==0) {
        return 3;
    }else if(section==1){
        return 2;
    }else{
        return 4;
    }
}

-(CGFloat)interItemSpacingForSection:(NSInteger)section{
    if (section==0) {
        return 12.5;
    }else{
        return 20;
    }
}

- (CGFloat)collectionView:(UICollectionView*) collectionView
                   layout:(CustomCollectionViewLayout*) layout
 heightForItemAtIndexPath:(NSIndexPath*) indexPath{
    return 50+arc4random()%100;
}

-(void)allowLoadMoreData{
    if (sectionCount<6) {
        sectionCount++;
        [self.collectionView reloadData];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return sectionCount;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [((CustomCell*)cell).photo setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",1+arc4random()%3]]];
    
    // Configure the cell
    
    return cell;
}



-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseHeaderIdentifier forIndexPath:indexPath];
        [((Header *)view).title setText:[NSString stringWithFormat:@"Header: section_%d,row_%d",indexPath.section,indexPath.row]];
        return view;
    }else{
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseFooterrIdentifier forIndexPath:indexPath];
       
        return view;
        return nil;

    }
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80, 80+arc4random()%100);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(200, 50);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(200, 50);
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

//- (IBAction)buttontouched:(id)sender {
//    NSLog(@"button touched");
//}



@end
