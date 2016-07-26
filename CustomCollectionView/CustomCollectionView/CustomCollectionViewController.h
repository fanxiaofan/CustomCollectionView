//
//  CustomCollectionViewController.h
//  JSCoreTest
//
//  Created by fanfengyan on 16/6/1.
//  Copyright © 2016年 RW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCollectionViewLayout.h"

@interface CustomCollectionViewController : UIViewController<CustomCollectionViewLayoutDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
