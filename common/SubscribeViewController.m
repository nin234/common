//
//  SubscribeViewController.m
//  sharing
//
//  Created by Ninan Thomas on 4/28/21.
//  Copyright © 2021 Sinacama. All rights reserved.
//

#import "SubscribeViewController.h"
#import "NotesViewController.h"
#import "AppCmnUtil.h"
#import "sharing/Consts.h"

@interface SubscribeViewController ()

@end

@implementation SubscribeViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        [pAppCmnUtil.inapp startProductRequest];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)Buy:(id)sender {
    
    NSLog(@"Buying subscription");
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil.inapp buy:self];
    
}
- (IBAction)Restore:(id)sender {
    
    NSLog(@"Restoring subscription");
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil.inapp restore:self];
}


- (IBAction)privacy:(id)sender {
    
    NSLog(@"Displaying Privacy");
    
    NSString *privacyPolicy = @"Privacy Policy\n";
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    switch (pAppCmnUtil.appId) {
        case EASYGROCLIST_ID:
        {
            privacyPolicy = [privacyPolicy stringByAppendingString:@"This privacy notice discloses the privacy practices for NShare LLC for our EasyGrocList App.\nWhen you share a grocery list with your contacts using our share feature, the grocery list is stored in the server until your contacts have downloaded it.  We  store iOS remote notification token and firebase messaging token in our server to send remote notifications about shared Items. Your information in our servers is not shared with any other third party.\nWe are striving to use commercially acceptable means of protecting this information. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security. The transmission between our server and EasyGrocList app is  encrypted.\nIf you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us. Any update or changes to the policy will be posted here."];
        }
        break;
            
        case NSHARELIST_ID:
        {
            privacyPolicy = [privacyPolicy stringByAppendingString:@"This privacy notice discloses the privacy practices for NShare LLC for our nsharelist App.\nWhen you share a list with your contacts using our share feature, the  list is stored in the server until your contacts have downloaded it.  We  store iOS remote notification token and firebase messaging token in our server to send remote notifications about shared Items. Your information in our servers is not shared with any other third party.\nWe are striving to use commercially acceptable means of protecting this information. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security. The transmission between our server and nsharelist app is  encrypted.\nIf you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us. Any update or changes to the policy will be posted here"];
        }
        break;
            
        case OPENHOUSES_ID:
        {
            privacyPolicy = [privacyPolicy stringByAppendingString:@"This privacy notice discloses the privacy practices for NShare LLC for our OpenHouses App.\n When you share details of a house (including pictures and video) with your contacts using our share feature, we keep a copy of the item in our server. This is primarily to facilitate the sharing from a technological point of view. In addition to this the other information we store in our servers are the contact list as a back up. We also store iOS remote notification token and firebase messaging token in our server to send remote notifications about shared Items. Your information in our servers is not shared with any other third party.\nWe are striving to use commercially acceptable means of protecting this information. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security. The transmission between our server and OpenHouses app is  encrypted.\nIf you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us. Any update or changes to the policy will be posted here."];
        }
        break;
            
        case AUTOSPREE_ID:
        {
            privacyPolicy = [privacyPolicy stringByAppendingString:@"This privacy notice discloses the privacy practices for NShare LLC for our AutoSpree App.\n When you share details of a car (including pictures and video) with your contacts using our share feature, we keep a copy of the item in our server. This is primarily to facilitate the sharing from a technological point of view. In addition to this the other information we store in our servers are the contact list as a back up. We also store iOS remote notification token and firebase messaging token in our server to send remote notifications about shared Items.\n We are striving to use commercially acceptable means of protecting this information. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security. The transmission between our server and AutoSpree app is encrypted.\n If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us. Any update or changes to the policy will be posted here"];
        }
        break;
            
        default:
            break;
    }
    
    NotesViewController *notesViewController = [NotesViewController alloc] ;
    NSLog(@"Pushing Notes view controller for Terms Of Use %s %d\n" , __FILE__, __LINE__);
    //  albumContentsViewController.assetsGroup = group_;
    notesViewController.notes.editable = NO;
    notesViewController.mode = eNotesModeDisplay;
    
    notesViewController.title = @"Privacy Policy";
    notesViewController.notesTxt = privacyPolicy;
    notesViewController = [notesViewController initWithNibName:@"NotesViewController" bundle:nil];
    notesViewController.notes.font = [UIFont fontWithName:@"ArialMT" size:20];
    [self.navigationController pushViewController:notesViewController animated:NO];
}


- (IBAction)termsOfUse:(id)sender {
    
    NSLog(@"Displaying Terms of Use");
    
    NSString *termsOfUse = @"TERMS OF USE\n\n PLEASE SCROLL DOWN AND READ THE SUBSCRIBER AGREEMENT AND TERMS OF USE BELOW.\n This Subscriber Agreement and Terms of Use govern your use of EasyGrocList, nsharelist, OpenHouses, AutoSpree, AlexaAskRoger iOS apps from Nshare LLC. These Apps are hereafter referred to as the Nshare apps.\n. For the avoidance of doubt, this Agreement is solely between Nshare LLC and You. Apple (a) is a third party beneficiary of this Agreement; and (b) is not (i) liable for any third party claims that may be brought solely in connection with the Nshare Apps; or (ii) obligated to provide any support service or maintenance in connection with the Nshare Apps.\n\n 1. Changes to Subscriber Agreement. \nWe may change the terms of this Agreement at any time by notifying you of the change in writing or electronically (including without limitation,  by posting a notice on the Service that the terms have been updated or by providing a pop up screen on the Apps). The changes also will appear in this document, which you can access at any time by going to the iOS app page in the App Store or our developer website. You signify that you agree to be bound by such changes by using a Service after changes are made to this Agreement.\n\n";
    
    termsOfUse = [termsOfUse stringByAppendingString:@"2. Privacy and Your Account.\n Registration data and other information about you are subject to our Privacy Policy. Your information may be stored and processed in the United States or any other country where Nshare  LLC has facilities, and by subscribing to a Service, you consent to the transfer of information outside of your country.\n\n"];
    termsOfUse = [termsOfUse stringByAppendingString:@"3. Fees and Payments. \nYou agree to pay the subscription fees and any other charges incurred in connection with your share Id for a Service (including any applicable taxes) at the rates in effect when the charges were incurred. If your subscription includes access to areas containing premium content or services, your access to such areas may be subject to additional fees, terms and conditions, which will be separately disclosed in such areas. The subscription fees as of now are 0.99 dollars per year. We will bill all charges automatically to your credit card or any payment method specified in App Store. All the charges are collected using auto renewable subscription in Apple App Store. Subscription fees will be billed at the beginning of your subscription or any renewal. Unless we state in writing otherwise, all fees and charges are nonrefundable. We may change the fees and charges then in effect, or add new fees or charges, by giving you notice in advance. You are responsible for any fees or charges incurred to access a Service through an Internet access provider or other third-party service.\n\n"];
    termsOfUse = [termsOfUse stringByAppendingString:@"4. Renewal.\n Your subscription will renew automatically after one year, unless we terminate it. You can terminate the subscription by using the Settings app on iOS devices . You must cancel your subscription before it renews in order to avoid billing of subscription fees for the renewal term to your credit card.\n"];
    termsOfUse = [termsOfUse stringByAppendingString:@"5. Limitations on Use.\n"];
    termsOfUse = [termsOfUse stringByAppendingString:@"a. You agree not to use the Services for any unlawful purpose. We reserve the right to terminate or restrict your access to a Service if, in our opinion, your use of the Service may violate any laws, regulations or rulings, infringe upon another person's rights or violate the terms of this Agreement.\n\n"];

    termsOfUse = [termsOfUse stringByAppendingString:@"6. PROPRIETARY RIGHTS\n You hereby acknowledge that Nshare owns all rights, titles and interest in and to the Nshare Apps and to any and all proprietary and confidential information contained therein (“Nshare Information”). The Nshare Apps and Nshare Information are protected by applicable intellectual property and other laws, including patent law, copyright law, trade secret law, trademark law, unfair competition law, and any and all other proprietary rights, and any and all Appss, renewals, extensions and restorations thereof, now or hereafter in force and effect worldwide. You agree that you will not (and will not allow any third party to) (i) modify, adapt, translate, prepare derivative works from, decompile, reverse engineer or disassemble the Nshare Appsor otherwise attempt to derive source code from the Nshare Apps; (ii) copy, distribute, transfer, sell or license the Nshare Apps; (iii) transfer the Nshare Apps to, or use the Nshare Apps on, a device other than the Authorized Device; (iv) take any action to circumvent, compromise or defeat any security measures implemented in the Nshare Apps; (v) use the Nshare Apps to access, copy, transfer, retransmit or transcode Content (as defined below) or any other content in violation of any law or third party rights; (vi) remove, obscure, or alter Nshare's (or any third party's) copyright notices, trademarks, or other proprietary rights notices affixed to or contained within or accessed through the Nshare Apps.\n\n 7. Community; User Generated Content.\ni. User Content. We offer you the opportunity to create or share content with in NShare Apps. It is your responsibility that all the contents confirm to all the applicable laws. You cannot share content that are constitute sexual or racial harassment or are discriminatory in terms of age , race, religion or color\nii. Cautions Regarding Other Users and User Content. You understand and agree that User Content includes information, views, opinions, and recommendations of many individuals and organizations and is designed to help you gather the information you need to help you make your own decisions. Importantly, you are responsible for your own  decisions and for properly analyzing and verifying any information you intend to rely upon. We do not endorse any recommendation or opinion made by any user. We do not routinely screen, edit, or review User Content. However, we reserve the right to monitor or remove any User Content from the Services at any time without notice. You should also be aware that other users may use our Services for personal gain. As a result, please approach messages with appropriate skepticism. User Content may be misleading, deceptive, or in error.\niii. Grant of Rights and Representations by You. If you create or share any User Content on Nshare apps, you represent to us that you have all the necessary legal rights to create or share such User Content and it will not violate any law or the rights of any person.\niv. We may also remove any User Content for any reason and without notice to you. This includes all materials related to your use of the Services or membership, including friend lists, postings, profiles or other personalized information you have created while on the Services.\n\n"];

    termsOfUse = [termsOfUse stringByAppendingString:@"8. INDEMNITY\nYou agree to hold harmless and indemnify Nshare and its subsidiaries, affiliates, officers, agents, and employees (and their subsidiaries, affiliates, officers, agents, and employees) from and against any claim, suit or action arising from or in any way related to your use of the Nshare Apps or your violation of this Agreement, including any liability or expense arising from all claims, losses, damages, suits, judgments, litigation costs and attorneys' fees, of every kind and nature. In such a case, Nshare will provide you with written notice of such claim, suit or action.\n\n"];

    termsOfUse = [termsOfUse stringByAppendingString:@"9. DISCLAIMER OF WARRANTIES\n THE NSHARE APPS ARE PROVIDED ON AN AS IS BASIS AND WITHOUT WARRANTY OF ANY KIND. TO THE MAXIMUM EXTENT PERMITTED BY LAW, NSHARE LLC EXPRESSLY DISCLAIMS ALL WARRANTIES AND CONDITIONS OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES AND CONDITIONS OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. YOUR USE OF THE NSHARE APPS IS AT YOUR SOLE RISK. NSHARE LLC SHALL NOT BE OBLIGATED TO PROVIDE YOU WITH ANY MAINTENANCE OR SUPPORT SERVICES IN CONNECTION WITH THE NSHARE APPS. NSHARE LLC MAKES NO WARRANTY (I) THAT THE NSHARE APPS WILL MEET YOUR REQUIREMENTS; (II) THAT THE NSHARE APPS WILL BE ERROR-FREE; (III) REGARDING THE SECURITY, RELIABILITY, OR PERFORMANCE OF THE NSHARE Apps; AND (IV) THAT ANY ERRORS IN THE NSHARE Apps WILL BE CORRECTED. ANY CONTENT OR MATERIAL YOU DOWNLOAD OR OTHERWISE OBTAIN THROUGH THE NSHARE APPS IS OBTAINED AT YOUR OWN DISCRETION AND RISK. YOU WILL BE SOLELY RESPONSIBLE FOR ANY DAMAGE TO YOUR AUTHORIZED DEVICE (OR ANY OTHER DEVICE) OR ANY LOSS OF DATA THAT MAY RESULT FROM DOWNLOADING ANY SUCH CONTENT OR MATERIAL. THE NSHARE APPS ARE NOT INTENDED FOR USE IN ANY ACTIVITIES DURING WHICH THE FAILURE OF THE NSHARE APPS COULD LEAD TO DEATH, PERSONAL INJURY, OR SEVERE PHYSICAL OR ENVIRONMENTAL DAMAGE. NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED BY YOU FROM Nshare OR THROUGH THE Nshare Apps SHALL CREATE ANY WARRANTY NOT EXPRESSLY STATED IN THESE TERMS AND CONDITIONS.\n\n"];

    termsOfUse = [termsOfUse stringByAppendingString:@"10. LIMITATION OF LIABILITY\nYOU EXPRESSLY UNDERSTAND AND AGREE THAT NSHARE SHALL NOT BE LIABLE TO YOU FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL OR EXEMPLARY DAMAGES, INCLUDING BUT NOT LIMITED TO, DAMAGES FOR LOSS OF PROFITS, GOODWILL, USE, DATA OR OTHER INTANGIBLE LOSSES (EVEN IF NSHARE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES) RESULTING FROM: (I) THE USE OR THE INABILITY TO USE THE NSHARE Apps; (II) THE INABILITY TO USE THE NSHARE Apps TO ACCESS CONTENT OR DATA; (III) THE COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; (IV) UNAUTHORIZED ACCESS TO OR ALTERATION OF YOUR TRANSMISSIONS OR DATA; OR (V) ANY OTHER MATTER RELATING TO THE NSHARE Apps. THE FOREGOING LIMITATIONS SHALL APPLY NOTWITHSTANDING A FAILURE OF ESSENTIAL PURPOSE OF ANY LIMITED REMEDY AND TO THE FULLEST EXTENT PERMITTED BY LAW.\n\n"];

    termsOfUse = [termsOfUse stringByAppendingString:@"11. EXCLUSIONS AND LIMITATIONS\nNOTHING IN THIS AGREEMENT IS INTENDED TO EXCLUDE OR LIMIT ANY CONDITION, WARRANTY, RIGHT OR LIABILITY WHICH MAY NOT BE LAWFULLY EXCLUDED OR LIMITED. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF CERTAIN WARRANTIES OR CONDITIONS OR THE LIMITATION OR EXCLUSION OF LIABILITY FOR LOSS OR DAMAGE CAUSED BY NEGLIGENCE, BREACH OF CONTRACT OR BREACH OF IMPLIED TERMS, OR INCIDENTAL OR CONSEQUENTIAL DAMAGES. ACCORDINGLY, ONLY THE ABOVE LIMITATIONS IN SECTIONS 10 AND 11 WHICH ARE LAWFUL IN YOUR JURISDICTION WILL APPLY TO YOU AND NSHARE’S LIABILITY WILL BE LIMITED TO THE MAXIMUM EXTENT PERMITTED BY LAW.\n\n"];



    termsOfUse = [termsOfUse stringByAppendingString:@"12. General.\n This Agreement contains the final and entire agreement between us regarding your use of the Nshare LLC apps and supersedes all previous and contemporaneous oral or written agreements regarding your use of the Services. We may discontinue or change the Apps, or their availability to you, at any time. This Agreement is personal to you, which means that you may not assign your rights or obligations under this Agreement to anyone. No third party is a beneficiary of this Agreement. You agree that this Agreement, as well as any and all claims arising from this Agreement will be governed by and construed in accordance with the laws of the State of New Jersey, United States of America applicable to contracts made entirely within New Jersey and wholly performed in New Jersey, without regard to any conflict or choice of law principles. The sole jurisdiction and venue for any litigation arising out of this Agreement will be an appropriate federal or state court located in New Jersey. This Agreement will not be governed by the United Nations Convention on Contracts for the International Sale of Goods.\n\n"];

    NotesViewController *notesViewController = [NotesViewController alloc] ;
    NSLog(@"Pushing Notes view controller for Terms Of Use %s %d\n" , __FILE__, __LINE__);
    //  albumContentsViewController.assetsGroup = group_;
    notesViewController.notes.editable = NO;
    notesViewController.mode = eNotesModeDisplay;
    
    notesViewController.title = @"Terms of Use";
    notesViewController.notesTxt = termsOfUse;
    notesViewController.notes.font = [UIFont fontWithName:@"ArialMT" size:20];
    notesViewController = [notesViewController initWithNibName:@"NotesViewController" bundle:nil];
    [self.navigationController pushViewController:notesViewController animated:NO];   
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
