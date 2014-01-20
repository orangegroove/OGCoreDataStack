//
//  OGCoreDataStackTableViewVendor.h
//
//  Created by Jesper <jesper@orangegroove.net>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "OGCoreDataStackVendor.h"

/**
 An OGCoreDataStackVendor specifically for UITableViews.
 */

@interface OGCoreDataStackTableViewVendor : OGCoreDataStackVendor

/**
 The table view to update with the vendor.
 */
@property (strong, nonatomic) UITableView* tableView;

/**
 The animation used for row insertions. Defaults to UITableViewRowAnimationAutomatic.
 */
@property (assign, nonatomic) UITableViewRowAnimation insertionAnimation;

/**
 The animation used for row deletions. Defaults to UITableViewRowAnimationAutomatic.
 */
@property (assign, nonatomic) UITableViewRowAnimation deletionAnimation;

/**
 The animation used for row updates. Defaults to UITableViewRowAnimationAutomatic.
 */
@property (assign, nonatomic) UITableViewRowAnimation updateAnimation;

/**
 The number of updated rows in one batch before calling reloadData instead of reloading each row individually. Defaults to 50.
 */
@property (assign, nonatomic) NSUInteger reloadThreshold;

@end
