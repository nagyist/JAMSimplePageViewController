
/* The MIT License (MIT)
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "JAMSimplePageViewController.h"

static const CGFloat kUIPageControlHeight = 36.f;

@interface JAMSimplePageViewController ()
@property (nonatomic) NSArray *controllers;
@property (nonatomic) UIPageControl *pageControl;
@end

@implementation JAMSimplePageViewController

- (id)initWithViewControllers:(NSArray *)viewControllers transitionStyle:(UIPageViewControllerTransitionStyle)style;
{
    if (self = [super initWithTransitionStyle:style
                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                      options:nil]) {
        for (id object in viewControllers) {
            if (![object isKindOfClass:[UIViewController class]]) {
                [NSException raise:@"One of these is not a view controller" format:@""];
                return nil;
            }
        }
        self.controllers = viewControllers;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (id)initWithViewControllerClassNames:(NSArray *)classNames transitionStyle:(UIPageViewControllerTransitionStyle)style;
{
    return [self initWithViewControllers:[self createViewControllersWithClassNames:classNames]
                         transitionStyle:style];
}

- (NSArray *)createViewControllersWithClassNames:(NSArray *)classNames;
{
    NSMutableArray *newControllers = NSMutableArray.new;
    for (NSString *className in classNames) {
        UIViewController *controller = NSClassFromString(className).new;
        if ([controller isKindOfClass:[UIViewController class]]) {
            [newControllers addObject:controller];
        } else {
            NSLog(@"Could not create controller with class name: %@", className);
        }
    }
    return newControllers.copy;
}

- (void)viewDidLoad
{
    self.pageControl = [UIPageControl.alloc initWithFrame:CGRectMake(0, self.view.frame.size.height - kUIPageControlHeight, self.view.frame.size.width, kUIPageControlHeight)];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.pageControl addTarget:self
                         action:@selector(pageControlWasTapped:)
               forControlEvents:UIControlEventValueChanged];
    self.pageControl.numberOfPages = self.controllers.count;
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    [self setViewControllers:@[self.controllers[0]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (NSUInteger)currentPageIndex
{
    return [self.controllers indexOfObject:self.viewControllers[0]];
}

#pragma mark - UIPageViewController Data Source and Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger nextIndex = [self.controllers indexOfObject:viewController] + 1;
    return (nextIndex < self.controllers.count) ? self.controllers[nextIndex] : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger previousIndex = [self.controllers indexOfObject:viewController] - 1;
    return (previousIndex >= 0) ? self.controllers[previousIndex] : nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed;
{
    self.pageControl.currentPage = self.currentPageIndex;
}

#pragma mark - UIPageControl Action

-(void)pageControlWasTapped:(UIPageControl *)pageControl;
{
    [self setViewControllers:@[self.controllers[pageControl.currentPage]]
                   direction:pageControl.currentPage > self.currentPageIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                    animated:YES
                  completion:nil];
}

@end
