//
//  CustomCollectionViewLayout.h
//  JSCoreTest
//
//  Created by fanfengyan on 16/6/1.
//  Copyright © 2016年 RW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomCollectionViewLayout;

@protocol CustomCollectionViewLayoutDelegate <NSObject>
@required
//item的高度
- (CGFloat)collectionView:(UICollectionView*) collectionView
                    layout:(CustomCollectionViewLayout*) layout
  heightForItemAtIndexPath:(NSIndexPath*) indexPath;
//section数量
-(NSInteger)numberOfColumnsForSection:(NSInteger)section;
//item间距
-(CGFloat)interItemSpacingForSection:(NSInteger)section;
//允许加载更多
-(void)allowLoadMoreData;
@end

@interface CustomCollectionViewLayout : UICollectionViewLayout
@property (nonatomic, assign,readonly) NSUInteger numberOfColumns;
@property (nonatomic, assign,readonly) CGFloat interItemSpacing;
@property (weak, nonatomic) id<CustomCollectionViewLayoutDelegate> delegate;

@end
