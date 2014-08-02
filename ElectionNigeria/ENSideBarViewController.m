//
// Class:    ENSideBarViewController
//
// Project:	 ElectionNigeria
//
// Date:     12/02/14
//
// Author:	 Vikas Kumar
//


#import "ENSideBarViewController.h"

@interface ENSideBarViewController ()
{
    NSInteger myQueueCount;
}

@property (nonatomic, strong) NSMutableArray * menuItems;

@end

@implementation ENSideBarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _menuItems = [NSMutableArray arrayWithArray:@[@"Election 2015 Newsfeed", @"Polling stations", @"Peoples Democratic Party", @"All Parties", @"About us", @"Settings"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initialSetUp];
}

- (void)initialSetUp
{
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideBarCell"];
    cell.textLabel.text = _menuItems[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)showViewControllerWIthIdentifier:(NSString*)identifier
{
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self.revealViewController setFrontViewController:viewController animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
           
            break;
        case 1:

            break;
        case 2:
            
            break;
        case 3:
            [self showViewControllerWIthIdentifier:@"PoliticalPartiesViewController"];

            break;
            
            
        default:
            break;
    }
}


@end
