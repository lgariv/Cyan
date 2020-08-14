#import "VioletMusic.h"

BOOL enabled;
BOOL enableMusicApplicationSection;

// Music Application

%group VioletMusic

%hook MusicNowPlayingControlsViewController

%new
- (void)setArtwork { // get and set the artwork

	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
		NSDictionary* dict = (__bridge NSDictionary *)information;
		if (dict) {
			if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]) {
				currentArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
				if (currentArtwork) {
					if (musicArtworkBackgroundSwitch) {
						[musicArtworkBackgroundImageView setImage:currentArtwork];
						[musicArtworkBackgroundImageView setHidden:NO];
						if ([musicArtworkBlurMode intValue] != 0) [musicBlurView setHidden:NO];
					}
				}
			} else { // no artwork
				[musicArtworkBackgroundImageView setImage:nil];
				[musicArtworkBackgroundImageView setHidden:YES];
			}
      	}
  	});

}

- (void)viewDidLoad { // add artwork background and hide other elements

	%orig;

	for (UIView* subview in [[self view] subviews]) { // remove the background color of the controls view
        [subview setBackgroundColor:[UIColor clearColor]];
	}

	[self setArtwork];

	if (musicArtworkBackgroundSwitch) {
		if (!musicArtworkBackgroundImageView) musicArtworkBackgroundImageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];
		[musicArtworkBackgroundImageView setFrame:[[self view] bounds]];
		[musicArtworkBackgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[musicArtworkBackgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
		[musicArtworkBackgroundImageView setHidden:NO];
		[musicArtworkBackgroundImageView setClipsToBounds:YES];
		[musicArtworkBackgroundImageView setAlpha:[musicArtworkOpacityValue doubleValue]];

		if ([musicArtworkBlurMode intValue] != 0) {
			if (!musicBlur) {
				if ([musicArtworkBlurMode intValue] == 1)
					musicBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
				else if ([musicArtworkBlurMode intValue] == 2)
					musicBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
				musicBlurView = [[UIVisualEffectView alloc] initWithEffect:musicBlur];
				[musicBlurView setFrame:[musicArtworkBackgroundImageView bounds]];
				[musicBlurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
				[musicBlurView setClipsToBounds:YES];
				[musicArtworkBackgroundImageView addSubview:musicBlurView];
			}
			[musicBlurView setHidden:NO];
		}

		if (![musicArtworkBackgroundImageView isDescendantOfView:[self view]])
			[[self view] insertSubview:musicArtworkBackgroundImageView atIndex:0];

		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setArtwork) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil]; // add notification to dynamically change artwork
	}

	UIView* grabber = MSHookIvar<UIView *>(self, "grabberView");
	UILabel* titleLabel = MSHookIvar<UILabel *>(self, "titleLabel");
	UIButton* subtitleButton = MSHookIvar<UIButton *>(self, "subtitleButton");
	MPRouteButton* lyricsButton = MSHookIvar<MPRouteButton *>(self, "lyricsButton");
	MPRouteButton* routeButton = MSHookIvar<MPRouteButton *>(self, "routeButton");
	UILabel* routeLabel = MSHookIvar<UILabel *>(self, "routeLabel");
	MPRouteButton* queueButton = MSHookIvar<MPRouteButton *>(self, "queueButton");

	if (hideLyricsButtonSwitch)
		[lyricsButton setHidden:YES];

	if (hideRouteButtonSwitch)
		[routeButton setHidden:YES];

	if (hideRouteLabelSwitch)
		[routeLabel setHidden:YES];

	if (hideQueueButtonSwitch)
		[queueButton setHidden:YES];

	if (hideTitleLabelSwitch)
		[titleLabel setHidden:YES];
	
	if (hideSubtitleButtonSwitch)
		[subtitleButton setHidden:YES];

	if (hideGrabberViewSwitch)
		[grabber setHidden:YES];

}

- (void)viewDidLayoutSubviews {

	%orig;

	UIView *bottomContainerView = MSHookIvar<UIView *>(self, "bottomContainerView");

	[bottomContainerView setBackgroundColor:[UIColor clearColor]];

}

%end

%hook MusicLyricsBackgroundView

-(void)setAlpha:(CGFloat)arg1 {
	if (arg1 > 0) {
		[UIView animateWithDuration:0.2 animations:^{
      musicArtworkBackgroundImageView.alpha = 0;
    }];
		musicArtworkBackgroundImageView.hidden = YES;
	} else {
		theTransportView.superview.hidden = YES;
		[UIView animateWithDuration:0.2 animations:^{
      musicArtworkBackgroundImageView.alpha = 1;
    }];
		musicArtworkBackgroundImageView.hidden = NO;
	}
	%orig;
}

%end

%hook MusicLyricsBackgroundViewX

-(void)setAlpha:(CGFloat)arg1 {
	if (arg1 > 0) {
		[UIView animateWithDuration:0.2 animations:^{
      musicArtworkBackgroundImageView.alpha = 0;
    }];
		musicArtworkBackgroundImageView.hidden = YES;
	} else {
		theTransportView.superview.hidden = YES;
		[UIView animateWithDuration:0.2 animations:^{
      musicArtworkBackgroundImageView.alpha = 1;
    }];
		musicArtworkBackgroundImageView.hidden = NO;
	}
	%orig;
}

%end

%hook QueueNextUpHeaderView

- (void)layoutSubviews { // hide next up header background

	%orig;

	[self setBackgroundColor:[UIColor clearColor]];

}

%end

%hook QueueHistoryView

- (void)layoutSubviews { // hide history header background

	%orig;

	[self setBackgroundColor:[UIColor clearColor]];

}

%end

%hook ArtworkView

- (void)didMoveToWindow { // hide artwork

	%orig;

	if (hideArtworkViewSwitch)
		[self setHidden:YES];

}

%end

%hook TimeControl

- (void)didMoveToWindow { // hide time slider elements

	%orig;

	if (hideTimeControlSwitch) {
		[self setHidden:YES];
		return;
	}

	UIView* knob = MSHookIvar<UIView *>(self, "knobView");
	UILabel* elapsedLabel = MSHookIvar<UILabel *>(self, "elapsedTimeLabel");
	UILabel* remainingLabel = MSHookIvar<UILabel *>(self, "remainingTimeLabel");

	if (hideKnobViewSwitch)
		[knob setHidden:YES];

	if (hideElapsedTimeLabelSwitch)
		[elapsedLabel setHidden:YES];
		
	if (hideRemainingTimeLabelSwitch)
		[remainingLabel setHidden:YES];

}

%end

%hook ContextualActionsButton

- (void)setHidden:(BOOL)hidden { // hide airplay button

	%orig;

	if (hideContextualActionsButtonSwitch)
		%orig(YES);

}

%end

%hook _TtCC16MusicApplication32NowPlayingControlsViewController12VolumeSlider

- (void)didMoveToWindow { // hide volume slider elements

	%orig;

	if (hideVolumeSliderSwitch) {
		[self setHidden:YES];
		return;
	}
	
	UIImageView* minImage = MSHookIvar<UIImageView *>(self, "_minValueImageView");
	UIImageView* maxImage = MSHookIvar<UIImageView *>(self, "_maxValueImageView");

	if (hideMinImageSwitch)
		[minImage setHidden:YES];

	if (hideMaxImageSwitch)
		[maxImage setHidden:YES];

}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.violetpreferences"];

    [preferences registerBool:&enabled default:nil forKey:@"Enabled"];
	[preferences registerBool:&enableMusicApplicationSection default:nil forKey:@"EnableMusicApplicationSection"];

	// Music
	[preferences registerBool:&musicArtworkBackgroundSwitch default:NO forKey:@"musicArtworkBackground"];
	[preferences registerObject:&musicArtworkBlurMode default:@"0" forKey:@"musicArtworkBlur"];
	[preferences registerObject:&musicArtworkOpacityValue default:@"1.0" forKey:@"musicArtworkOpacity"];
	[preferences registerBool:&hideGrabberViewSwitch default:NO forKey:@"musicHideGrabberView"];
	[preferences registerBool:&hideArtworkViewSwitch default:NO forKey:@"musicHideArtworkView"];
	[preferences registerBool:&hideTimeControlSwitch default:NO forKey:@"musicHideTimeControl"];
	[preferences registerBool:&hideKnobViewSwitch default:NO forKey:@"musicHideKnobView"];
	[preferences registerBool:&hideElapsedTimeLabelSwitch default:NO forKey:@"musicHideElapsedTimeLabel"];
	[preferences registerBool:&hideRemainingTimeLabelSwitch default:NO forKey:@"musicHideRemainingTimeLabel"];
	[preferences registerBool:&hideContextualActionsButtonSwitch default:NO forKey:@"musicHideContextualActionsButton"];
	[preferences registerBool:&hideVolumeSliderSwitch default:NO forKey:@"musicHideVolumeSlider"];
	[preferences registerBool:&hideMinImageSwitch default:NO forKey:@"musicHideMinImage"];
	[preferences registerBool:&hideMaxImageSwitch default:NO forKey:@"musicHideMaxImage"];
	[preferences registerBool:&hideTitleLabelSwitch default:NO forKey:@"musicHideTitleLabel"];
	[preferences registerBool:&hideSubtitleButtonSwitch default:NO forKey:@"musicHideSubtitleButton"];
	[preferences registerBool:&hideLyricsButtonSwitch default:NO forKey:@"musicHideLyricsButton"];
	[preferences registerBool:&hideRouteButtonSwitch default:NO forKey:@"musicHideRouteButton"];
	[preferences registerBool:&hideRouteLabelSwitch default:NO forKey:@"musicHideRouteLabel"];
	[preferences registerBool:&hideQueueButtonSwitch default:NO forKey:@"musicHideQueueButton"];

	if (enabled) {
		if (enableMusicApplicationSection) %init(VioletMusic, QueueNextUpHeaderView=objc_getClass("MusicApplication.NowPlayingQueueHeaderView"), QueueHistoryView=objc_getClass("MusicApplication.NowPlayingHistoryHeaderView"), ArtworkView=objc_getClass("MusicApplication.NowPlayingContentView"), TimeControl=objc_getClass("MusicApplication.PlayerTimeControl"), ContextualActionsButton=objc_getClass("MusicApplication.ContextualActionsButton"), MusicLyricsBackgroundViewX=objc_getClass("MusicApplication.LyricsBackgroundView"));
		return;
    }

}