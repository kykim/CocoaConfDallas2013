//
//  DetailViewController.h
//  cocoaconfdc
//
//  Created by Kevin Y. Kim on 3/23/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *lastName;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
