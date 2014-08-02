//
//  DHLevelSelection2ViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelSelection2ViewController.h"
#import "DHLevelSelection2LevelCell.h"
#import "DHLevelResults.h"
#import "DHLevels.h"
#import "DHLevelViewController.h"
#import "DHSettings.h"


@interface DHTransitionToLevel : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation DHTransitionToLevel

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.8;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    DHLevelSelection2ViewController *fromViewController = (DHLevelSelection2ViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    DHLevelViewController *toViewController = (DHLevelViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];

    // Get a snapshot of the thing cell we're transitioning from
    DHLevelSelection2LevelCell *cell = (DHLevelSelection2LevelCell*)[fromViewController.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:toViewController.levelIndex inSection:0]];
    
    CGRect fromFrame = [containerView convertRect:cell.frame fromView:cell.superview];
    CGRect toFrame = [transitionContext finalFrameForViewController:toViewController];
    
    toViewController.view.alpha = 0.3;
    toViewController.view.frame = toFrame;
    toViewController.view.clipsToBounds = YES;
    toViewController.view.layer.anchorPoint = CGPointMake(0, 0);
    toViewController.view.layer.position = fromFrame.origin;
    toViewController.view.transform = CGAffineTransformMakeScale(fromFrame.size.width/toFrame.size.width,
                                                                 fromFrame.size.height/toFrame.size.height);

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        // Fade in the second view controller's view
        toViewController.view.alpha = 1.0;
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        
    } completion:^(BOOL finished) {
        // Clean up
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end


@interface DHLevelSelection2ViewController () <UINavigationControllerDelegate>

@end

@implementation DHLevelSelection2ViewController {
    NSDictionary* _levelResults;
    NSMutableArray* _levels;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _levelResults = [DHLevelResults levelResults];
    
    // Create levels array
    _levels = [[NSMutableArray alloc] init];
    FillLevelArray(_levels);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setSectionInset:UIEdgeInsetsMake(20, 20, 20, 20)];
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 30;
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView registerClass:[DHLevelSelection2LevelCell class]
            forCellWithReuseIdentifier:@"cellIdentifier"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set outself as the navigation controller's delegate so we're asked for a transitioning object
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection view delegate & data source methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return _levels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DHLevelSelection2LevelCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier"
                                                                           forIndexPath:indexPath];
    
    DHLevel<DHLevel>* level = [_levels objectAtIndex:indexPath.row];
    NSString* title = [NSString stringWithFormat:@"Level %ld", (long)(indexPath.row+1)];
    
    cell.title = title;
    cell.level = level;
    cell.tag = indexPath.item;
    [cell setTouchActionWithTarget:self andAction:@selector(loadLevel:)];
    cell.levelCompleted = NO;
    
    NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu", (unsigned long)self.currentGameMode];
    NSDictionary* levelResult = [_levelResults objectForKey:resultKey];
    if (levelResult) {
        NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
        if (completed.boolValue) {
            cell.levelCompleted = YES;
        }
    }
    
    if (indexPath.item > 0 && [DHSettings allLevelsUnlocked] == NO) {
        id<DHLevel> previousLevel = [_levels objectAtIndex:indexPath.row-1];
        
        cell.enabled = NO;
        
        NSString* previousResultKey = [NSStringFromClass([previousLevel class])
                                       stringByAppendingFormat:@"/%lu", (unsigned long)self.currentGameMode];
        NSDictionary* previousLevelResult = [_levelResults objectForKey:previousResultKey];
        if (previousLevelResult) {
            NSNumber* completedPrevious = [previousLevelResult objectForKey:kLevelResultKeyCompleted];
            if (completedPrevious.boolValue) {
                cell.enabled = YES;
            }
        }
    } else {
        cell.enabled = YES;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(120, 150);
}

#pragma mark Launch level
- (void)loadLevel:(DHLevelSelection2LevelCell*)cell
{
    NSString* storyboardName = @"Main";
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    id<DHLevel> level = cell.level;
    
    if (level) {
        vc.currentLevel = level;
        vc.levelArray = _levels;
        vc.levelIndex = cell.tag;
        vc.title = cell.title;
        vc.currentGameMode = self.currentGameMode;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark Transition delegate methods
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (fromVC == self && [toVC isKindOfClass:[DHLevelViewController class]]) {
        return [[DHTransitionToLevel alloc] init];
    }
    else {
        return nil;
    }
}

@end
