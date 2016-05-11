
#ifndef FAE_Constant_h
#define FAE_Constant_h

#ifdef DEBUG

#ifndef DLog
#define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])

#endif

#ifndef ALog

#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]

#endif

#else

#define DLog(...)

#ifndef NS_BLOCK_ASSERTIONS

#define NS_BLOCK_ASSERTIONS

#endif

#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define CHK_TYPE(_OBJ_, _CLASS_)    ((_OBJ_) != nil && [_OBJ_ isKindOfClass:(_CLASS_)])
#define CHK_ERR(_ERR_)              CHK_TYPE(_ERR_, NSError.class)
#define MAKE_ERR(_MSG_)             ([NSError errorWithDomain:APP_NAME code:1020 userInfo:@{NSLocalizedDescriptionKey:(_MSG_)}])
#define ERR_MSG(_ERR_)              (((NSError*)(_ERR_)).localizedDescription)
#define VALID_NULL(_OBJ_, _DEF_)    ((CHK_TYPE((_OBJ_), NSNull.class) || ((_OBJ_) == nil)) ? (_DEF_) : (_OBJ_))
#define SCR_BOUND                   ([UIScreen mainScreen].bounds)

#define SuppressPerformSelectorLeakWarning(Stuff) do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)

typedef void (^MyBlock)(id data);

////////////////////////////////////////////////

// Custom Fonts

#define FONT_BLACK(s)    [UIFont fontWithName:@"SourceSansPro-Black"    size:s]
#define FONT_BLACKIT(s) [UIFont fontWithName:@"SourceSansPro-BlackIt" size:s]
#define FONT_BOLD(s)   [UIFont fontWithName:@"SourceSansPro-Bold"   size:s]
#define FONT_BOLDIT(s)    [UIFont fontWithName:@"SourceSansPro-BoldIt"    size:s]
#define FONT_EXTRALIGHT(s)   [UIFont fontWithName:@"SourceSansPro-ExtraLight"   size:s]
#define FONT_EXTRALIGHTIT(s)    [UIFont fontWithName:@"SourceSansPro-ExtraLightIt"    size:s]
#define FONT_IT(s) [UIFont fontWithName:@"SourceSansPro-It" size:s]

#define FONT_LIGHT(s)   [UIFont fontWithName:@"SourceSansPro-Light"   size:s]

#define FONT_DOT(s)   [UIFont systemFontOfSize:s]

#define FONT_LIGHTIT(s)    [UIFont fontWithName:@"SourceSansPro-LightIt"    size:s]
#define FONT_REGULAR(s) [UIFont fontWithName:@"SourceSansPro-Regular" size:s]
#define FONT_SEMIBOLD(s)   [UIFont fontWithName:@"SourceSansPro-Semibold"   size:s]
#define FONT_SEMIBOLDIT(s) [UIFont fontWithName:@"SourceSansPro-SemiboldIt" size:s]

// Global Colors
#define GRAY_COLOR      RGBA(200, 199, 199, 1)
#define RED_COLOR       RGBA(249, 90, 90, 1)
#define RED_COLOR_WITHOPACITY       RGBA(249, 90, 90, 0.75)
#define ORANGE_COLOR    RGBA(247, 153, 90, 1)
#define YELLOW_COLOR    RGBA(247, 200, 90, 1)

#define Documents_Folder            [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define Tmp_Folder					[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#define Files_Folder				[Documents_Folder stringByAppendingPathComponent:@"files"]
#define Thumbs_Folder				[Documents_Folder stringByAppendingPathComponent:@"thumbs"]
#define Photo_Folder				[Documents_Folder stringByAppendingPathComponent:@"Photo"]

#define kFAEREGISTERED_EMAILS        @"registeredEmails"

#define kApplicationName            @"Fae"

// Status Image names
#define NORMAL_CAT                  @"normal_cat"
#define SMILE_CAT                   @"smile_cat"
#define SAD_CAT                     @"sad_cat"
// Input Fields's Icons - Gray
#define EMAIL_GRAY                  @"email_gray"
#define PHONE_GRAY                  @"phone_gray"
#define PASS_GRAY                   @"password_gray"
#define CONF_PASS_GRAY              @"conf_password_gray"

// Input Fields's Icons - Red
#define EMAIL_RED                   @"email_red"
#define PHONE_RED                   @"phone_red"
#define PASS_RED                    @"password_red"
#define CONF_PASS_RED               @"conf_password_red"

#define PASS_YELLOW                 @"password_yellow"
#define PASS_ORANGE                 @"password_orange"

// Signin

#define SIGNIN_EMAIL_GRAY           @"signin_email_gray"
#define SIGNIN_EMAIL_RED            @"signin_email_red"

// Input Fields's Check Icons
#define CHECK_YES                           @"check_yes"

#define CHECK_CROSS_RED                     @"check_cross_red"
#define CHECK_CROSS_YELLOW                  @"check_cross_yellow"
#define CHECK_CROSS_ORANGE                  @"check_cross_orange"

#define CHECK_EXCLAMATION_RED               @"check_exclamation_red"
#define CHECK_EXCLAMATION_ORANGE            @"check_exclamation_orange"

#define CHECK_EYE_CLOSE_YELLOW              @"check_eye_close_yellow"
#define CHECK_EYE_CLOSE_ORANGE              @"check_eye_close_orange"
#define CHECK_EYE_CLOSE_RED                 @"check_eye_close_red"
#define CHECK_EYE_OPEN_YELLOW               @"check_eye_open_yellow"
#define CHECK_EYE_OPEN_ORANGE               @"check_eye_open_orange"
#define CHECK_EYE_OPEN_RED                  @"check_eye_open_red"

#define TOS_Keyword1                        @"Terms of Service"
#define TOS_Keyword2                        @"Privacy Policy"
#define SIGNIN_PROBLEM                      @"Problems signing in?"
#define PROBLEM_GUEST                       @"Guest"
#define PROBLEM_SUPPORT                     @"Support"

#define TOS_Keyword1_link                   @"faeapp.com/tos"
#define TOS_Keyword2_link                   @"faeapp.com/privacy"
#define SIGNIN_Problem_link                 @"faeapp.com/problem"
#define PROBLEM_GUEST_link                  @"faeapp.com/guest"
#define PROBLEM_SUPPORT_link                @"faeapp.com/support"

#endif
