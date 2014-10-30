//
//  MDIOSDeveloperTreeViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 30.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSDeveloperTreeViewController.h"
#import "MDDSSManager.h"
@interface MDIOSDeveloperTreeViewController ()
@property NSDictionary *json;
@property NSMutableDictionary *values;
@property BOOL isLoading;
@property int amountOfCalls;
@end

@implementation MDIOSDeveloperTreeViewController
@synthesize isLoading=_isLoading;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    self.isLoading = YES;
    [[MDDSSManager defaultManager] getProperty:self.path callback:^(NSDictionary *json, NSError *error) {
        self.amountOfCalls = 0;
        self.isLoading = NO;
        self.json = json;
        [self.tableView reloadData];
        
        for(NSDictionary *dict in [self.json objectForKey:@"result"])
        {
            
            NSString *pPath = [NSString stringWithFormat:@"%@/%@", self.path, [dict objectForKey:@"name"]];
            if([[dict objectForKey:@"type"] isEqualToString:@"string"])
            {
                self.isLoading = YES;
                self.amountOfCalls++;
                [[MDDSSManager defaultManager] getString:pPath callback:^(NSDictionary *json, NSError *error) {
                    if(!self.values) { self.values = [NSMutableDictionary dictionary]; }
                    self.amountOfCalls--;
                    if(self.amountOfCalls == 0)
                    {
                        self.isLoading = NO;
                    }
                    
                    [self.values setObject:[[json objectForKey:@"result"] objectForKey:@"value"] forKey:pPath];
                    [self.tableView reloadData];
                }];
            }
            if([[dict objectForKey:@"type"] isEqualToString:@"integer"])
            {
                self.isLoading = YES;
                self.amountOfCalls++;
                [[MDDSSManager defaultManager] getInteger:pPath callback:^(NSDictionary *json, NSError *error) {
                    if(!self.values) { self.values = [NSMutableDictionary dictionary]; }
                    self.amountOfCalls--;
                    if(self.amountOfCalls == 0)
                    {
                        self.isLoading = NO;
                    }
                    [self.values setObject:[[[json objectForKey:@"result"] objectForKey:@"value"] stringValue] forKey:pPath];
                    [self.tableView reloadData];
                }];
            }
        }
    }];
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
    
    if(_isLoading)
    {
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicator stopAnimating];
    }
}

- (BOOL)isLoading
{
    return _isLoading;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if(self.json)
    {
    return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.json objectForKey:@"result"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"propertyCell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"propertyCell"];
    }
    
    NSDictionary *data = [[self.json objectForKey:@"result"] objectAtIndex:indexPath.row];
    cell.textLabel.text = [data objectForKey:@"name"];
    
    if([[data objectForKey:@"type"] isEqualToString:@"none"])
    {
        cell.imageView.image = [UIImage imageNamed:@"folder.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"property.png"];
    }
    
    NSString *pPath = [NSString stringWithFormat:@"%@/%@", self.path, [data objectForKey:@"name"]];
    if(self.values && [self.values objectForKey:pPath])
    {
        cell.detailTextLabel.text = [self.values objectForKey:pPath];
    }
    else
    {
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDIOSDeveloperTreeViewController *nextTree = [[MDIOSDeveloperTreeViewController alloc] init];
    NSDictionary *data = [[self.json objectForKey:@"result"] objectAtIndex:indexPath.row];
    nextTree.path = [NSString stringWithFormat:@"%@/%@", self.path, [data objectForKey:@"name"]];
    nextTree.path = [nextTree.path stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    
    [self.navigationController pushViewController:nextTree animated:YES];
}

@end
