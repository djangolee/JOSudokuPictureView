//
//  JOAlbumBrowserCell.m
//  JOSudokuPictureBrowser
//
//  Created by django on 8/2/16.
//  Copyright © 2016 django. All rights reserved.
//

#import "Masonry.h"
#import "YYWebimage.h"
#import "JOImageView.h"
#import "YYImageCache.h"
#import "JOAlbumBrowserCell.h"
#import "JOPictureSouceModel.h"
#import "JOSudokuPictureView.h"

@interface JOAlbumBrowserCell () <UIScrollViewDelegate>

@property (nonatomic, strong) JOPictureSouceModel *model;
@property (nonatomic, strong) UIButton *fullPictureButton;
@property (nonatomic, strong) JOImageView *pictureImageView;
@property (nonatomic, strong) YYWebImageOperation *operation;

@end

@implementation JOAlbumBrowserCell

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark - Public methods

- (void)showWithModel:(JOPictureSouceModel *)model {
    self.model = model;
    
    BOOL fullimageDowned = [[YYImageCache sharedCache] containsImageForKey:model.origin];
    self.fullPictureButton.hidden = fullimageDowned;
    if (!fullimageDowned) {
        [self.fullPictureButton setTitle:@"Full Image" forState:(UIControlStateNormal)];
        self.fullPictureButton.enabled = YES;
    }
    [self setImageWithUrl:[NSURL URLWithString:fullimageDowned ? model.origin : model.img_300] progress:nil];
}

- (void)setImageWithUrl:(NSURL *)url progress:(YYWebImageProgressBlock)progress {
    [self.operation cancel];
    self.operation = nil;
    self.operation = [[YYWebImageManager sharedManager] requestImageWithURL:url
                                                                    options:kNilOptions
                                                                   progress:progress
                                                                  transform:nil
                                                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             self.pictureImageView.image = image;
             if (progress) {
                 [self.fullPictureButton setTitle:@"finsh" forState:(UIControlStateNormal)];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     self.fullPictureButton.hidden = YES;
                 });
             }
         });
    }];
    
    
    [[UIImageView new] yy_imageURL];
}

- (void)setImageViewDelegate:(id <JOImageViewTransformDelegate>)delegate {
    self.pictureImageView.delegate = delegate;
}

#pragma mark - Private methods

#pragma mark - Event methods

- (void)showFullPicture:(UIButton *)button {
    button.enabled = NO;
    [button setTitle:@"Loading..." forState:(UIControlStateNormal)];
    __weak typeof(self) _self = self;
    [self setImageWithUrl:[NSURL URLWithString:self.model.origin] progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (receivedSize != -1 && expectedSize != -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat progress = 100.0 * receivedSize / expectedSize;
                [_self.fullPictureButton setTitle:[NSString stringWithFormat:@"%.2f%%", progress] forState:(UIControlStateNormal)];
            });
        }
    }];
}


#pragma mark - Initialize subviews and make subviews for layout

- (void)setupView {
    [self addSubviews];
    [self makeSubviewsLayout];
}

- (void)addSubviews {
    [self.contentView addSubview:self.pictureImageView];
    [self.contentView addSubview:self.fullPictureButton];
}

- (void)makeSubviewsLayout {
    [self.pictureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.fullPictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(88, 25));
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-15);
    }];
}

#pragma mark - Setter and getter

- (JOImageView *)pictureImageView {
    if (!_pictureImageView) {
        _pictureImageView = [JOImageView new];
        _pictureImageView.placeholderImage = [UIImage imageNamed:JOSudokuPicturePlaceholderImageName];
    }
    return _pictureImageView;
}

- (UIButton *)fullPictureButton {
    if (!_fullPictureButton) {
        _fullPictureButton = [UIButton new];
        _fullPictureButton.layer.cornerRadius = 3;
        _fullPictureButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        _fullPictureButton.layer.borderColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.0].CGColor;
        _fullPictureButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_fullPictureButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_fullPictureButton addTarget:self action:@selector(showFullPicture:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _fullPictureButton;
}

- (UIImageView *)imageView {
    return self.pictureImageView.imageView;
}

@end
