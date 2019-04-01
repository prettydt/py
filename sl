//
//  ViewController.m
//  扫雷畅玩版
//
//  Created by 国梁李 on 2019/3/29.
//  Copyright © 2019 国梁李. All rights reserved.
//

#import "ViewController.h"
#import "Grid.h"
@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //初始的行和列
    self.rowNumber = 3;
    self.colNumber = 3;
    //初始的雷数
    self.leiNumber = 5;

    self.muArr = [NSMutableArray new];
    for (int x= 0; x < self.rowNumber; x++) {
         NSMutableArray *arr = [NSMutableArray new];
        for (int y = 0 ; y < self.colNumber; y++) {
            //
            Grid *grid1 = [Grid new];
            [arr addObject:grid1];

            NSButton *button = [[NSButton alloc]init];
            button.frame=CGRectMake(0+31*x, 0+31*y, 32, 32);
            [button setTitle:[NSString stringWithFormat:@"%d%d",x,y]];
            [button setTarget:self];
            [button setImage:[NSImage imageNamed:@"befor.png"]];
            [button setAction:@selector(buttonClick:)];
            [self.view addSubview:button];
        }
        [self.muArr addObject:arr];
        
    }
    
    //生成雷，算法是，按照雷的总数，random每一个类，知道到了总数，如果重复则进行下一次

    int k = 0;
    while(k<self.leiNumber)
    {
        int row  = arc4random() % self.rowNumber;
        int col  = arc4random() % self.colNumber;
        Grid *grid2 = [Grid new];
        grid2 = (Grid*)self.muArr[row][col];
        if(!grid2.IsLei)
        {
            grid2.IsLei = true;
            k++;
        }
    }
    for (NSMutableArray *arr1 in self.muArr) {
        for(Grid * arr2 in arr1){
            NSLog(@"%hhu",arr2.IsLei);
        }
    }
    
    // Do any additional setup after loading the view.
}
- (IBAction)buttonClick:(id)sender {
    NSButton *btn = (NSButton *)sender;


    btn.enabled = false;
    int row = [[btn.title substringWithRange:NSMakeRange(0, 1)] intValue];
    int col = [[btn.title substringWithRange:NSMakeRange(1, 1)] intValue];
    NSLog(@"c%d",row);
    NSLog(@"col==%d",col);
    Grid *clickGrid = [Grid new];
    clickGrid = self.muArr[row][col];
    if (clickGrid.IsLei) {
        btn.title = @"😭";
    }

    NSLog(@"grid is %hhu",clickGrid.IsLei);
    NSMutableArray  *arround_8 = [NSMutableArray new];
    if ((row-1) > 0 && (row+1 <= self.rowNumber) && (col-1) >0 &&(col + 1<= self.colNumber) ) {
        [arround_8 addObject:self.muArr[row-1][col-1]];
        [arround_8 addObject:self.muArr[row-1][col]];
        [arround_8 addObject:self.muArr[row-1][col+1]];
        [arround_8 addObject:self.muArr[row][col-1]];
        [arround_8 addObject:self.muArr[row][col+1]];
        [arround_8 addObject:self.muArr[row+1][col]];
        [arround_8 addObject:self.muArr[row+1][col+1]];
        [arround_8 addObject:self.muArr[row+1][col-1]];
    }
    int count = 0;
    for (Grid *grid in arround_8) {
        if(grid.IsLei)
        {
            count++;
        }
    }
    btn.title = [NSString stringWithFormat:@"%d",count];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

//实验button的字体是否能变成红色，失败了，暂时搁浅

//NSColor *color = [NSColor blueColor];
//NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//[paragraphStyle setAlignment:NSTextAlignmentCenter];
//NSString *content = btn.title;
//NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:btn.title attributes:@{
//                                                                                                            NSForegroundColorAttributeName: [NSColor redColor],
//                                                                                                            NSBaselineOffsetAttributeName: @3,
//                                                                                                            NSParagraphStyleAttributeName: paragraphStyle
//                                                                                                            }];
//[btn setAttributedTitle:title];
//
//////  btn setTitle:<#(NSString * _Nonnull)#>
//[btn setImage:[NSImage imageNamed:@"after.png"]];
