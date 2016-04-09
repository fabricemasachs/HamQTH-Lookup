//
//  HamQTHLookupResultTableViewController.m
//  HamQTH Lookup
//
//  Created by Fabrice Masachs on 5/10/15.
//  Copyright (c) 2015 Fabrice Masachs. All rights reserved.
//

#import "HamQTHLookupResultTableViewController.h"
//#import "Macros.h"
#import "Reachability.h"

@interface HamQTHLookupResultTableViewController ()

@end

@implementation HamQTHLookupResultTableViewController

@synthesize callsign;
@synthesize sessionId;
@synthesize sessionError;
@synthesize nodeContent;
@synthesize lookupOutputArray;
@synthesize xmlParser;
@synthesize hamQTH;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There is no internet connection");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"There is no internet connection." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSLog(@"There is internet connection");
        
        NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
        
        if ([[[userSettings dictionaryRepresentation] allKeys] containsObject:@"hamQthUsernameKey"] & [[[userSettings dictionaryRepresentation] allKeys] containsObject:@"hamQthPasswordKey"]) {
            
            lookupOutputArray = [[NSMutableArray alloc] init];
            
            if (![[[userSettings dictionaryRepresentation] allKeys] containsObject:@"sessionIdDateKey"]) {
                NSDate *sessionIdDate = [NSDate date];
                
                [self getSessionId];
                
                [userSettings setObject:sessionIdDate forKey:@"sessionIdDateKey"];
                [userSettings synchronize];
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"HH:mm:ss"];
            NSDate *sessionIdDate = [userSettings objectForKey:@"sessionIdDateKey"];
            
            NSTimeInterval timeOfTheSessionIdAsked = fabs([sessionIdDate timeIntervalSinceNow]);
            NSTimeInterval validityOfTheSessionId = 60 * 60 * 1;
            
            if (timeOfTheSessionIdAsked > validityOfTheSessionId) {
                [userSettings removeObjectForKey:@"sessionIdDateKey"];
                [userSettings synchronize];
                
                [self getSessionId];
                
                [userSettings setObject:[NSDate date] forKey:@"sessionIdDateKey"];
                [userSettings synchronize];
            }
            
            sessionId = [userSettings stringForKey:@"hamQthSessionIdKey"];
            
            NSLog(@"New session ID in %.0fmin", 60 - (timeOfTheSessionIdAsked / 60));
            NSLog(@"First session ID asked at %@",[formatter stringFromDate:sessionIdDate]);
            NSLog(@"Session ID: %@", sessionId);
            
            NSString *urlString = [NSString stringWithFormat:@"http://www.hamqth.com/xml.php?id=%@&callsign=%@&prg=HamQTH-Lookup", sessionId, callsign];
            
            NSData *xmlData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:urlString]];
            
            xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
            xmlParser.delegate = self;
            [xmlParser parse];
        } else {
            if (![[[userSettings dictionaryRepresentation] allKeys] containsObject:@"hamQthUsernameKey"] || ![[[userSettings dictionaryRepresentation] allKeys] containsObject:@"hamQthPasswordKey"]) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Enter your HamQTH Login Information in setting." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [alert addAction:ok];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getSessionId {
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [userSettings stringForKey:@"hamQthUsernameKey"];
    NSString *password  = [userSettings stringForKey:@"hamQthPasswordKey"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.hamqth.com/xml.php?u=%@&p=%@", username, password];
    
    NSData *xmlData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:urlString]];
    
    xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    xmlParser.delegate = self;
    [xmlParser parse];
}

#pragma mark - NSXMLParser delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"session_id"]) {
        
    } else if ([elementName isEqualToString:@"error"]) {
        hamQTH = [[HamQTH alloc] init];
    } else if ([elementName isEqualToString:@"search"]) {
        hamQTH = [[HamQTH alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    nodeContent = [[NSMutableString alloc] initWithString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"session"]) {
        
    } else if ([elementName isEqualToString:@"session_id"]) {
        sessionId = nodeContent;
        
        NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
        [userSettings setObject:sessionId forKey:@"hamQthSessionIdKey"];
        [userSettings synchronize];
        
        NSLog(@"Session ID: %@", nodeContent);
    } else if ([elementName isEqualToString:@"error"]) {
        sessionError = nodeContent;
    }
    
    if ([elementName isEqualToString:@"search"]) {
        
    } else if ([elementName isEqualToString:@"callsign"]) {
        hamQTH.callsign = nodeContent;
        NSLog(@"Callsign: %@", [nodeContent uppercaseString]);
    } else if ([elementName isEqualToString:@"nick"]) {
        hamQTH.nick = nodeContent;
        NSLog(@"Nick: %@", nodeContent);
    } else if ([elementName isEqualToString:@"qth"]) {
        hamQTH.qth = nodeContent;
        NSLog(@"QTH: %@", nodeContent);
    } else if ([elementName isEqualToString:@"country"]) {
        hamQTH.country = nodeContent;
        NSLog(@"Country: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adif"]) {
        hamQTH.adif = nodeContent;
        NSLog(@"ADIF: %@", nodeContent);
    } else if ([elementName isEqualToString:@"itu"]) {
        hamQTH.itu = nodeContent;
        NSLog(@"ITU: %@", nodeContent);
    } else if ([elementName isEqualToString:@"cq"]) {
        hamQTH.cq = nodeContent;
        NSLog(@"CQ: %@", nodeContent);
    } else if ([elementName isEqualToString:@"grid"]) {
        hamQTH.grid = nodeContent;
        NSLog(@"Grid: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_name"]) {
        hamQTH.adr_name = nodeContent;
        NSLog(@"Address Name: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_street1"]) {
        hamQTH.adr_street1 = nodeContent;
        NSLog(@"Address Street 1: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_street2"]) {
        hamQTH.adr_street2 = nodeContent;
        NSLog(@"Address Street 2: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_street3"]) {
        hamQTH.adr_street3 = nodeContent;
        NSLog(@"Address Street 3: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_city"]) {
        hamQTH.adr_city = nodeContent;
        NSLog(@"Address City: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_zip"]) {
        hamQTH.adr_zip = nodeContent;
        NSLog(@"Address Zip: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_country"]) {
        hamQTH.adr_country = nodeContent;
        NSLog(@"Address Country: %@", nodeContent);
    } else if ([elementName isEqualToString:@"adr_adif"]) {
        hamQTH.adr_adif = nodeContent;
        NSLog(@"Address ADIF: %@", nodeContent);
    } else if ([elementName isEqualToString:@"district"]) {
        hamQTH.district = nodeContent;
        NSLog(@"Address District: %@", nodeContent);
    } else if ([elementName isEqualToString:@"us_state"]) {
        hamQTH.us_state = nodeContent;
        NSLog(@"US State: %@", nodeContent);
    } else if ([elementName isEqualToString:@"us_county"]) {
        hamQTH.us_county = nodeContent;
        NSLog(@"US County: %@", nodeContent);
    } else if ([elementName isEqualToString:@"oblast"]) {
        hamQTH.oblast = nodeContent;
        NSLog(@"Oblast: %@", nodeContent);
    } else if ([elementName isEqualToString:@"dok"]) {
        hamQTH.dok = nodeContent;
        NSLog(@"DOK: %@", nodeContent);
    } else if ([elementName isEqualToString:@"iota"]) {
        hamQTH.iota = nodeContent;
        NSLog(@"IOTA: %@", nodeContent);
    } else if ([elementName isEqualToString:@"qsl_via"]) {
        hamQTH.qsl_via = nodeContent;
        NSLog(@"QSL Via: %@", nodeContent);
    } else if ([elementName isEqualToString:@"lotw"]) {
        hamQTH.lotw = nodeContent;
        NSLog(@"LOTW: %@", nodeContent);
    } else if ([elementName isEqualToString:@"eqsl"]) {
        hamQTH.eqsl = nodeContent;
        NSLog(@"eQSL: %@", nodeContent);
    } else if ([elementName isEqualToString:@"qsl"]) {
        hamQTH.qsl = nodeContent;
        NSLog(@"QSL Bureau: %@", nodeContent);
    } else if ([elementName isEqualToString:@"qsldirect"]) {
        hamQTH.qsldirect = nodeContent;
        NSLog(@"QSL Direct: %@", nodeContent);
    } else if ([elementName isEqualToString:@"email"]) {
        hamQTH.email = nodeContent;
        NSLog(@"Email: %@", nodeContent);
    } else if ([elementName isEqualToString:@"jabber"]) {
        hamQTH.jabber = nodeContent;
        NSLog(@"Jabber: %@", nodeContent);
    } else if ([elementName isEqualToString:@"icq"]) {
        hamQTH.icq = nodeContent;
        NSLog(@"ICQ: %@", nodeContent);
    } else if ([elementName isEqualToString:@"msn"]) {
        hamQTH.msn = nodeContent;
        NSLog(@"MSN: %@", nodeContent);
    } else if ([elementName isEqualToString:@"skype"]) {
        hamQTH.skype = nodeContent;
        NSLog(@"Skype: %@", nodeContent);
    } else if ([elementName isEqualToString:@"birth_year"]) {
        hamQTH.birth_year = nodeContent;
        NSLog(@"Year of birth: %@", nodeContent);
    } else if ([elementName isEqualToString:@"lic_year"]) {
        hamQTH.lic_year = nodeContent;
        NSLog(@"Licenced since: %@", nodeContent);
    } else if ([elementName isEqualToString:@"web"]) {
        hamQTH.web = nodeContent;
        NSLog(@"Website: %@", nodeContent);
    } else if ([elementName isEqualToString:@"picture"]) {
        hamQTH.picture = nodeContent;
        NSLog(@"Picture Link: %@", nodeContent);
    } else if ([elementName isEqualToString:@"latitude"]) {
        hamQTH.latitude = nodeContent;
        NSLog(@"Latitude: %@", nodeContent);
    } else if ([elementName isEqualToString:@"longitude"]) {
        hamQTH.longitude = nodeContent;
        NSLog(@"Longitude: %@", nodeContent);
    } else if ([elementName isEqualToString:@"continent"]) {
        hamQTH.continent = nodeContent;
        NSLog(@"Continent: %@", nodeContent);
    } else if ([elementName isEqualToString:@"utc_offset"]) {
        hamQTH.utc_offset = nodeContent;
        NSLog(@"UTC Offset: %@", nodeContent);
    } else if ([elementName isEqualToString:@"facebook"]) {
        hamQTH.facebook = nodeContent;
        NSLog(@"Facebook: %@", nodeContent);
    } else if ([elementName isEqualToString:@"twitter"]) {
        hamQTH.twitter = nodeContent;
        NSLog(@"Twitter: %@", nodeContent);
    } else if ([elementName isEqualToString:@"gplus"]) {
        hamQTH.gplus = nodeContent;
        NSLog(@"Google+: %@", nodeContent);
    } else if ([elementName isEqualToString:@"youtube"]) {
        hamQTH.youtube = nodeContent;
        NSLog(@"Youtube: %@", nodeContent);
    } else if ([elementName isEqualToString:@"linkedin"]) {
        hamQTH.linkedin = nodeContent;
        NSLog(@"Linkedin: %@", nodeContent);
    } else if ([elementName isEqualToString:@"flicker"]) {
        hamQTH.flicker = nodeContent;
        NSLog(@"Flickr: %@", nodeContent);
    } else if ([elementName isEqualToString:@"vimeo"]) {
        hamQTH.vimeo = nodeContent;
        NSLog(@"Vimeo: %@", nodeContent);
    }
    
    if ([elementName isEqualToString:@"search"]) {
        [lookupOutputArray addObject:hamQTH];
        hamQTH = nil;
    }
    
    if ([elementName isEqualToString:@"error"]) {
        [lookupOutputArray addObject:hamQTH];
        hamQTH = nil;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:sessionError preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    nodeContent = nil;
    nodeContent = [[NSMutableString alloc] init];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"XMLParser error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"XMLParser error: %@", [validationError localizedDescription]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberofRows = 0;
    
    if (section == 0) {
        numberofRows = 17;
    }
    
    if (section == 1) {
        numberofRows = 5;
    }
    
    if (section == 2) {
        numberofRows = 2;
    }
    
    if (section == 3) {
        numberofRows = 2;
    }
    
    if (section == 4) {
        numberofRows = 4;
    }
    
    if (section == 5) {
        numberofRows = 7;
    }
    
    return numberofRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    CGFloat heightForRow = 44;
    
    NSString *text;
    
    UIFont *font = cell.detailTextLabel.font;
    
    if (indexPath.section == 3) {
        if (indexPath.row == 1 & cell.detailTextLabel.text != nil) {
            if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"] == nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"] == nil) {
                text = [NSString stringWithFormat:@"%@\n%@, %@\n%@", [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_zip"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_city"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_country"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"] == nil) {
                text = [NSString stringWithFormat:@"%@\n%@\n%@, %@\n%@", [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_zip"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_city"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_country"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"] != nil) {
                text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@\n%@", [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_zip"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_city"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_country"]];
            }
            
            heightForRow = [text boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil].size.height + 24;
        }
    }
    
    return heightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [[[lookupOutputArray objectAtIndex:0] valueForKey:@"callsign"] uppercaseString];
        }
        
        if (indexPath.row == 1) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"nick"];
        }
        
        if (indexPath.row == 2) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"qth"];
        }
        
        if (indexPath.row == 3) {
            if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"country"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adif"] != nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [[lookupOutputArray objectAtIndex:0] valueForKey:@"country"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adif"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"country"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adif"] == nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - ?", [[lookupOutputArray objectAtIndex:0] valueForKey:@"country"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"country"] == nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adif"] != nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - ?", [[lookupOutputArray objectAtIndex:0] valueForKey:@"adif"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"country"] == nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adif"] == nil) {
                cell.detailTextLabel.text = nil;
            }
        }
        
        if (indexPath.row == 4) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"grid"];
        }
        
        if (indexPath.row == 5) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"district"];
        }
        
        if (indexPath.row == 6) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"dok"];
        }
        
        if (indexPath.row == 7) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"oblast"];
        }
        
        if (indexPath.row == 8) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"us_state"];
        }
        
        if (indexPath.row == 9) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"us_county"];
        }
        
        if (indexPath.row == 10) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"iota"];
        }
        
        if (indexPath.row == 11) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"cq"];
        }
        
        if (indexPath.row == 12) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"itu"];
        }
        
        if (indexPath.row == 13) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"utc_offset"];
        }
        
        if (indexPath.row == 14) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"continent"];
        }
        
        if (indexPath.row == 15) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"latitude"];
        }
        
        if (indexPath.row == 16) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"longitude"];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"qsl_via"];
        }
        
        if (indexPath.row == 1) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"lotw"];
        }
        
        if (indexPath.row == 2) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"eqsl"];
        }
        
        if (indexPath.row == 3) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"qsl"];
        }
        
        if (indexPath.row == 4) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"qsldirect"];
        }
        
        cell.detailTextLabel.numberOfLines = 0;
        [cell.detailTextLabel sizeToFit];
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"birth_year"];
        }
        
        if (indexPath.row == 1) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"lic_year"];
        }
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_name"];
        }
        
        if (indexPath.row == 1) {
            if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"] == nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"] == nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@, %@\n%@", [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_zip"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_city"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_country"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"] == nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@, %@\n%@", [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_zip"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_city"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_country"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"] != nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"] != nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@\n%@", [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_zip"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_city"], [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_country"]];
            } else if ([[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street1"] == nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street2"] == nil & [[lookupOutputArray objectAtIndex:0] valueForKey:@"adr_street3"] == nil) {
                cell.detailTextLabel.text = nil;
            }
            
            cell.detailTextLabel.numberOfLines = 0;
            [cell.detailTextLabel sizeToFit];
        }
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            NSString *web = [[lookupOutputArray objectAtIndex:0] valueForKey:@"web"];
            
            if (web == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 1) {
            NSString *email = [[lookupOutputArray objectAtIndex:0] valueForKey:@"email"];
            
            if (email == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Send";
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 2) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"skype"];
        }
        
        if (indexPath.row == 3) {
            cell.detailTextLabel.text = [[lookupOutputArray objectAtIndex:0] valueForKey:@"jabber"];
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            NSString *facebook = [[lookupOutputArray objectAtIndex:0] valueForKey:@"facebook"];
            
            if (facebook == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 1) {
            NSString *twitter = [[lookupOutputArray objectAtIndex:0] valueForKey:@"twitter"];
            
            if (twitter == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 2) {
            NSString *gplus = [[lookupOutputArray objectAtIndex:0] valueForKey:@"gplus"];
            
            if (gplus == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 3) {
            NSString *youtube = [[lookupOutputArray objectAtIndex:0] valueForKey:@"youtube"];
            
            if (youtube == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 4) {
            NSString *linkedin = [[lookupOutputArray objectAtIndex:0] valueForKey:@"linkedin"];
            
            if (linkedin == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 5) {
            NSString *flicker = [[lookupOutputArray objectAtIndex:0] valueForKey:@"flicker"];
            
            if (flicker == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        if (indexPath.row == 6) {
            NSString *vimeo = [[lookupOutputArray objectAtIndex:0] valueForKey:@"vimeo"];
            
            if (vimeo == nil) {
                cell.detailTextLabel.text = @"";
            } else {
                cell.detailTextLabel.text = @"Link";
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"web"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
        
        if (indexPath.row == 1) {
            NSString *launchEmail = [[lookupOutputArray objectAtIndex:0] valueForKey:@"email"];
            
            if (launchEmail == nil) {
                
            } else {
                [self showEmailComposeViewController];
            }
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"facebook"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
        
        if (indexPath.row == 1) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"twitter"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
        
        if (indexPath.row == 2) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"gplus"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
        
        if (indexPath.row == 3) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"youtube"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
        
        if (indexPath.row == 4) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"linkedin"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
        
        if (indexPath.row == 5) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"flicker"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
        
        if (indexPath.row == 6) {
            NSString *launchUrl = [[lookupOutputArray objectAtIndex:0] valueForKey:@"vimeo"];
            
            if (launchUrl == nil) {
                
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showEmailComposeViewController {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *emailTitle = @"";
        NSString *messageBody = @"";
        NSString *email = [[lookupOutputArray objectAtIndex:0] valueForKey:@"email"];
        NSArray *toRecipents = [NSArray arrayWithObject:email];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:emailTitle];
        [mailComposeViewController setMessageBody:messageBody isHTML:NO];
        [mailComposeViewController setToRecipients:toRecipents];
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Email Account" message:@"You must set up an email account before you can send mail." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end