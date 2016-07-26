//
//  CustomCollectionViewLayout.m
//  JSCoreTest
//
//  Created by fanfengyan on 16/6/1.
//  Copyright © 2016年 RW. All rights reserved.
//

#import "CustomCollectionViewLayout.h"

#define  DefaultHeaderHeight 50;
#define  DefaultFooterHeight 50;

@interface CustomCollectionViewLayout (/*Private Methods*/)
@property (nonatomic, strong) NSMutableDictionary *lastYValueForColumn;
@property (strong, nonatomic) NSMutableDictionary *lastYValueForHeader;
@property (strong, nonatomic) NSMutableDictionary *lastYValueForFooter;

@property (strong, nonatomic) NSMutableDictionary *layoutInfo;
@property (strong, nonatomic) NSMutableDictionary *layoutInfoHeader;
@property (strong, nonatomic) NSMutableDictionary *layoutInfoFooter;

@property (assign, nonatomic) BOOL isLoadingMore;
@end

@implementation CustomCollectionViewLayout{
    NSMutableDictionary *lastYForColumn;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.lastYValueForColumn = [NSMutableDictionary dictionary];
        self.lastYValueForHeader = [NSMutableDictionary dictionary];
        self.lastYValueForFooter = [NSMutableDictionary dictionary];
        
        self.layoutInfo = [NSMutableDictionary dictionary];
        self.layoutInfoHeader = [NSMutableDictionary dictionary];
        self.layoutInfoFooter = [NSMutableDictionary dictionary];
  
        lastYForColumn = [NSMutableDictionary dictionary];
        
        [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.lastYValueForColumn = [NSMutableDictionary dictionary];
        self.lastYValueForHeader = [NSMutableDictionary dictionary];
        self.lastYValueForFooter = [NSMutableDictionary dictionary];
        
        self.layoutInfo = [NSMutableDictionary dictionary];
        self.layoutInfoHeader = [NSMutableDictionary dictionary];
        self.layoutInfoFooter = [NSMutableDictionary dictionary];

        lastYForColumn = [NSMutableDictionary dictionary];
    
        
        [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
}

//判断是否添加了Header
-(BOOL)isUseHeader{
    return ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]&&([self.collectionView.dataSource collectionView:self.collectionView viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]!=nil));
}
//是否添加了Footer
-(BOOL)isUseFooter{
    return ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]&&([self.collectionView.dataSource collectionView:self.collectionView viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]!=nil));
}

//此section对应item的列数
-(NSUInteger)numberOfColumnsInSection:(NSInteger)section{
    return [self.delegate numberOfColumnsForSection:section];
}
//此section对应item的间距
-(CGFloat)interItemSpacingInSection:(NSInteger)section{
    return [self.delegate interItemSpacingForSection:section];
}

//Header高
-(CGFloat)heightForHeaderInSection:(NSInteger)section{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        return [(id<UICollectionViewDelegateFlowLayout>)self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section].height;
    }
    return DefaultHeaderHeight
}

//Footer高
-(CGFloat)heightForFooterInSection:(NSInteger)section{
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        return [(id<UICollectionViewDelegateFlowLayout>)self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section].height;
    }
    return DefaultFooterHeight;
}
//section- Item最大Y值
-(CGFloat)lastItemYValueForSection:(NSInteger)section{
    return [self.lastYValueForColumn[@(section)] doubleValue];
}
//section- Header最大Y值
-(CGFloat)lastHeaderYValueForSection:(NSInteger)section{
    if (section<0||self.lastYValueForHeader.count<section+1) {
        return 0;
    }else{
        return [self.lastYValueForHeader[@(section)] doubleValue];
    }
}
//section- Footer最大Y值
-(CGFloat)lastFooterYValueForSection:(NSInteger)section{
    if (section<0||self.lastYValueForFooter.count<section+1) {
        return 0;
    }else{
        return [self.lastYValueForFooter[@(section)] doubleValue];
    }

}
//取最大值
-(CGFloat)itemMaxYForSection:(NSInteger)section yValueInfo:(NSDictionary*)yInfo{
    CGFloat maxY = 0;
    NSInteger currentColumn = 0;
    NSInteger numberOfColumn = [self.delegate numberOfColumnsForSection:section];
    do {
        CGFloat height = [yInfo[@(currentColumn)] doubleValue];
        if (height>maxY) {
            maxY = height;
        }
        currentColumn++;
    } while (currentColumn<numberOfColumn);
    
    return maxY;
}



#pragma mark -override super-methods

//Bounds改变时，是否应该更新布局！
//可以计算局部的layout, 以减轻压力，但跟新布局的时机有待商定！
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    if (self.isLoadingMore) {
        return NO;
    }else{
        CGSize size = self.collectionView.contentSize;
        if (CGRectGetMaxY(newBounds)+CGRectGetHeight(self.collectionView.frame)>=size.height) {
            self.isLoadingMore = YES;
            self.collectionView.contentInset = UIEdgeInsetsMake(-80, 0, 0, 0);
            //这里上拉加载更多，设定一秒时间准备layout
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate allowLoadMoreData];
                self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                // 结束刷新
                self.isLoadingMore = NO;
            });
            
            return YES;
            
        }else{
            return NO;
        }
    }

}

//重新开始布局
-(void)invalidateLayout{
    [super invalidateLayout];
    
    //可以全部重新计算或计算局部，根据实现
//    [self.lastYValueForColumn removeAllObjects];
//    [self.lastYValueForHeader removeAllObjects];
//    [self.lastYValueForFooter removeAllObjects];
//    [self.layoutInfo       removeAllObjects];
//    [self.layoutInfoHeader removeAllObjects];
//    [self.layoutInfoFooter removeAllObjects];
//    [lastYForColumn removeAllObjects];
}


//准备布局, 可以对新增加的Item进行布局
//item所在的列，默认是根据下标(indexPath.row),从左－>右，从上－>下排列的。可以优化，防止不同列的高度相差太大。
-(void) prepareLayout{
    [super prepareLayout];
    
    NSInteger start = 0;
    if (self.isLoadingMore) {//上拉加载更多
        start = [self.lastYValueForColumn count];
    }else{//全部重新计算
        [self.lastYValueForColumn removeAllObjects];
        [self.lastYValueForHeader removeAllObjects];
        [self.lastYValueForFooter removeAllObjects];
        [self.layoutInfo       removeAllObjects];
        [self.layoutInfoHeader removeAllObjects];
        [self.layoutInfoFooter removeAllObjects];
        [lastYForColumn removeAllObjects];
    }
    
    //开始计算
    CGFloat fullWidth = self.collectionView.frame.size.width;//总宽度
    NSInteger sections = [self.collectionView numberOfSections];//section个数
    
    static CGFloat x= 0, y= 0;
    for (int i=start; i<sections; i++) {
        CGFloat interItemSpace = [self interItemSpacingInSection:i];//section对应的间隔
        NSInteger columnsForSection= [self numberOfColumnsInSection:i];//section对应的列数
        CGFloat actualWidth = fullWidth - interItemSpace*(columnsForSection +1);
        CGFloat itemWidth = actualWidth/columnsForSection;//item宽度
        NSInteger numberForSection = [self.collectionView numberOfItemsInSection:i];//section中item个数
        
        //有Header
        if([self isUseHeader]){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0  inSection:i];
            CGFloat height = [self heightForHeaderInSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
            
            self.layoutInfoHeader[indexPath] = attributes;
            self.lastYValueForHeader[@(i)] = @([self lastFooterYValueForSection:i-1]+height);
        }else{
            self.lastYValueForHeader[@(i)] = @([self lastFooterYValueForSection:i-1]);
        }
        
        //items for section-i
        [lastYForColumn removeAllObjects];
        for (int index=0; index<columnsForSection; index++) {
            lastYForColumn[@(index)] = @([self lastHeaderYValueForSection:i]+interItemSpace);
        }
        NSInteger currentColumn = 0;//
        for (int j=0; j<numberForSection; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            CGFloat height = [self.delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath];
            x = interItemSpace + currentColumn*(itemWidth + interItemSpace);
            y = [lastYForColumn[@(currentColumn)] doubleValue];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(x, y, itemWidth, height);
            
            y += interItemSpace;
            y += height;
            lastYForColumn[@(currentColumn)] = @(y);
            currentColumn++;
            if (currentColumn==columnsForSection)currentColumn=0;
            self.layoutInfo[indexPath] = attributes;
        }
        self.lastYValueForColumn[@(i)] = @([self itemMaxYForSection:i yValueInfo:lastYForColumn]);
        
        
        //有Footer
        if([self isUseFooter]){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
             CGFloat height = [self heightForFooterInSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
            self.layoutInfoFooter[indexPath] = attributes;
            self.lastYValueForFooter[@(i)] = @([self lastItemYValueForSection:i]+height);
        }else{
            self.lastYValueForFooter[@(i)] = @([self lastItemYValueForSection:i]);
        }
        
    }
    
}
//展示将要可见的Item和header及footer
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *attributes = [NSMutableArray array];
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, UICollectionViewLayoutAttributes *obj, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [attributes addObject:obj];
        }
    }];
    
    [self.layoutInfoHeader enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, UICollectionViewLayoutAttributes *obj, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [attributes addObject:obj];
        }
    }];
    
    [self.layoutInfoFooter enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, UICollectionViewLayoutAttributes *obj, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [attributes addObject:obj];
        }
    }];
    return attributes;
}

//Header及Footer的Attributes, 当创建ReuseView时，也会调用此方法
-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    if (!attributes) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    }
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        CGFloat height = [self heightForHeaderInSection:indexPath.section];
        attributes.frame = CGRectMake(self.collectionView.frame.origin.x, [self lastFooterYValueForSection:indexPath.section-1], self.collectionView.frame.size.width, height);
        return attributes;
    }else{
        CGFloat height = [self heightForFooterInSection:indexPath.section];
        attributes.frame = CGRectMake(self.collectionView.frame.origin.x, [self lastItemYValueForSection:indexPath.section], self.collectionView.frame.size.width, height);
        return attributes;
    }
    
}

//ContentSize
-(CGSize) collectionViewContentSize{
    CGFloat maxHeight = [self lastFooterYValueForSection:[self.collectionView numberOfSections]-1];
    
    return CGSizeMake(self.collectionView.frame.size.width, MAX(self.collectionView.frame.size.height, maxHeight));
}
@end
