//
//  Macros.h
//  HamQTH Lookup
//
//  Created by Fabrice Masachs on 5/10/15.
//  Copyright (c) 2015 Fabrice Masachs. All rights reserved.
//

#define IS_IPHONE                       ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPAD                         ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define IS_OS_7_OR_EARLIER              ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
#define IS_OS_8_OR_LATER                ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE_4_PORTRAIT            ([[UIScreen mainScreen] bounds].size.height == 480 & [[UIScreen mainScreen] bounds].size.width == 320)
#define IS_IPHONE_5_PORTRAIT            ([[UIScreen mainScreen] bounds].size.height == 568 & [[UIScreen mainScreen] bounds].size.width == 320)
#define IS_IPHONE_6_PORTRAIT            ([[UIScreen mainScreen] bounds].size.height == 667 & [[UIScreen mainScreen] bounds].size.width == 375)
#define IS_IPHONE_6_PLUS_PORTRAIT       ([[UIScreen mainScreen] bounds].size.height == 736 & [[UIScreen mainScreen] bounds].size.width == 414)

#define IS_IPHONE_4_LANDSCAPE           ([[UIScreen mainScreen] bounds].size.height == 320 & [[UIScreen mainScreen] bounds].size.width == 480)
#define IS_IPHONE_5_LANDSCAPE           ([[UIScreen mainScreen] bounds].size.height == 320 & [[UIScreen mainScreen] bounds].size.width == 568)
#define IS_IPHONE_6_LANDSCAPE           ([[UIScreen mainScreen] bounds].size.height == 375 & [[UIScreen mainScreen] bounds].size.width == 667)
#define IS_IPHONE_6_PLUS_LANDSCAPE      ([[UIScreen mainScreen] bounds].size.height == 414 & [[UIScreen mainScreen] bounds].size.width == 736)

#define ACCEPTABLE_CHARACTERS           @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/"