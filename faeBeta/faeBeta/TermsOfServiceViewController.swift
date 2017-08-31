//
//  TermsOfServiceViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/18/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        let btnBack = UIButton(frame: CGRect(x: 10, y: 25, width: 40, height: 40))
        btnBack.setImage(UIImage(named: "Fill 1"), for: UIControlState())
        btnBack.addTarget(self, action: #selector(self.backButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(btnBack)
        
        self.view.backgroundColor = UIColor.white
        generateScrollView()
    }
    
    func backButtonTapped(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func generateScrollView() {
    
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: screenWidth, height: 2000)
        
        let titleImageView = UIImageView(frame: CGRect(x: screenWidth / 2 - 23, y: 5, width: 46, height: 49))
        titleImageView.image = #imageLiteral(resourceName: "app_icon_new")
        scrollView.addSubview(titleImageView)
        
        let titleLabel = UILabel(frame: CGRect(x: screenWidth / 2 - 100, y: 67, width: 200, height: 36))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        let astrTitle = NSMutableAttributedString(string: "TERMS OF SERVICE\nFaevorite Maps")
        
        let attrRange1 = NSRange(location: 0, length: 16)
        let attrRange2 = NSRange(location: 17, length: 15)
        
        astrTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor._898989(), range: attrRange1)
        astrTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor._107107107(), range: attrRange2)
        astrTitle.addAttribute(NSFontAttributeName, value:UIFont(name: "AvenirNext-DemiBold", size: 13)!, range: attrRange1)
        astrTitle.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-DemiBold", size: 13)!, range: attrRange2)
        titleLabel.attributedText = astrTitle
        scrollView.addSubview(titleLabel)
        let textView = UITextView(frame: CGRect(x: 27, y: 113, width: screenWidth - 54, height: 500))
        textView.attributedText = astrContent()
        textView.sizeToFit()
        textView.isEditable = false
        textView.tintColor = UIColor._2499090()
        textView.isScrollEnabled = false
        scrollView.addSubview(textView)
        scrollView.contentSize.height = CGFloat(123) + textView.frame.size.height
        scrollView.indicatorStyle = .white
        scrollView.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indicator = scrollView.subviews.last as? UIImageView {
//            indicator.backgroundColor = UIColor._2499090()
            indicator.tintColor = UIColor._2499090()
        }
    }
    
    private func astrContent() -> NSAttributedString {
        func numberBullet(_ num: Int) -> String {
            return "        \(num).  "
        }
        
        let astrContent = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 12)!]).mutableCopy() as! NSMutableAttributedString
        astrContent.appendDefaultString("Effective: ", bold: true)
        astrContent.appendDefaultString("November 11, 2016.\n\nWelcome to Fae Interactive! We are focused on building real-time interactions to enrich our online experiences with the wonderful things we do in life and to power our lives with the connections from the online world.\n\nWe drafted these Terms of Service (the “Terms”) for our first product Fae Map, an interactive, real-time social map (the “Software”) provided by Fae Interactive (“Fae”), a branch of Faevorite Inc., a Delaware Corporation (“Faevorite” is intentionally spelled that way).  These Terms and our Privacy Policy [www.faemaps.com/legal/privacy] govern your access to and use of our services (the “Services”) and any content, videos, information, texts, graphics, photos or other materials uploaded, downloaded, or appearing in the Software (the “Content”).\n\nYour access to and use of our Services is conditioned on your acceptance of and compliance with these Terms and Privacy Policy; therefore it is recommended that you read these Terms and Privacy Policy carefully.\n\n", bold: false)
        
        astrContent.appendDefaultString("About Fae Map:\n\n", bold: true)
        astrContent.appendDotBullet("Fae Map is an interactive, live social map that uses location based technologies to provide a novel social media platform for discovering people, new things and events all in true real-time.", level: 1)
        
        astrContent.appendDefaultString("Who Can Use Fae Map:\n\n", bold: true)
        astrContent.appendDotBullet("You may only use Fae Map: (i) You can form a binding contract (that is, you are at least 18 years of age), for younger users, parent’s discretion is advised, you must have a parent/guardian agreement/consent; (ii) are not a person barred from receiving the Services under the laws of the United States or other applicable jurisdiction; and (iii) are in compliance with these Terms, Privacy Policy, and all applicable laws.", level: 1)
        astrContent.appendDotBullet("If you are using the Services on behalf of a business or entity, you state that you are authorized to grant all licenses set forth in these Terms and to agree to these Terms on behalf of the business or entity.  ", level: 1)
        
        astrContent.appendDefaultString("Privacy and Safety\n\n", bold: true)
        astrContent.appendDotBullet("Your privacy and safety are very important to us.  Due to the interactive, live, location based nature of the Service, we developed a robust privacy and safety system that masks your true location by default.  You have the option to choose who to share your actual location and reveal your true identity, but please be careful, only share your location to those you want to and you are sharing at your own risk.", level: 1)
        astrContent.appendDotBullet("For more information on safety measures and community guidelines, please see the sections below.  For more information about our data collection methods and privacy rights in general, please see our Privacy Policy [www.faemaps.com/legal/privacy].", level: 1)
        
        astrContent.appendDefaultString("Rights You Grant Us\n\n", bold: true)
        astrContent.appendDotBullet("Our Services let you to create, upload, post, send, receive, and store Content.  When you do that, you retain the ownership rights in the Content you had to begin with, but, by doing so, you grant us a personal, worldwide, royalty-free, sub-licensable, and transferable right to host, store, use, display, reproduce, modify, edit, publish, and distribute that Content.", level: 1)
        astrContent.appendDotBullet("Because our Services are inherently public and chronicle matters of public interest, the license you grant us for such Content is universally broad, and includes a perpetual license to create derivative works from, promote, exhibit, broadcast, syndicate, sublicense, publicly perform, and publicly display content submitted to our Services in any form and in any and all media or distribution methods (now known or later developed).", level: 1)
        astrContent.appendDotBullet("To the extent it’s necessary, when you appear in, create, upload, post, or send Content, you also grant us and our business partners the unrestricted, worldwide, perpetual right and license to use your name, likeness, and voice. In other words, this means that you will not be entitled to any compensation from Faevorite or our business partners if your name, likeness, or voice is conveyed through our Services, either on Fae Map or on another platform.", level: 1)
        
        astrContent.appendDefaultString("Rights We Grant You\n\n", bold: true)
        astrContent.appendDotBullet("Subject to your compliance with these Terms, Faevorite grants you a limited, non-exclusive, revocable, non-transferrable license to: (i) download, install, use a copy of Fae Map on your device solely in connection with your use of the Services; (ii) access and use any content, information and related materials that may be made available through the Services, in each case solely for your personal, noncommercial use.  Any rights not expressly granted herein are reserved by Faevorite and our affiliates and licensors.", level: 1)
        
        astrContent.appendDefaultString("Use and Content Restrictions\n\n", bold: true)
        astrContent.appendDotBullet("You are solely responsible for any Content that you share on Fae Map.  While we are not required to do so, we reserve the right to modify, screen, view, or delete your Content at any time and for any reason, including for violating these Terms.  You alone are responsible for your Content used on the Services, and we are merely acting as a passive conduit for publishing or using such Content.", level: 1)
        astrContent.appendDotBullet("Treat your community and fellow humans with respect and dignity.  These restrictions will be the absolute minimum standards of decency that users must follow in order to continue accessing the Services:", level: 1)
        
        astrContent.appendIndexBullet("Don’t be a creep or stalker.  Do not defame, attempt to stalk with Fae Map, bully, abuse, harass, threaten, hack, impersonate or intimidate others.  No one enjoys having fun with jerks and creeps. When in doubt, follow the Golden Rule.  We want to ensure everyone to have a great time.", index: 1, level: 2, underlineFirstSentence: true)
        astrContent.appendIndexBullet("We have a strict, “No Doxing” policy.  Do not post confidential or personally identifiable information about people, including their email addresses, phone numbers, credit card numbers, social security or national identity numbers. Please respect yourself and others’ information.", index: 2, level: 2, underlineFirstSentence: true)
        astrContent.appendIndexBullet("Hide your keys, hide your passwords.  Please be responsible with your Fae Account. Those credentials will be used to access all our Services.  We encourage you to use strong passwords (a combination of upper and lower case letters, numbers and symbols).  We cannot and will not be liable for any loss or damage arising from your failure to protect your account.", index: 3, level: 2, underlineFirstSentence: true)
        astrContent.appendIndexBullet("No Drugs.  Do not use Fae Map for any illegal or improper purposes.  That means no illegal drug dealing through our Services.  You need to comply with all laws, rules and regulations concerning the Content you post and your use of the Services.", index: 4, level: 2, underlineFirstSentence: true)
        astrContent.appendIndexBullet("No Spam.  You must not post or submit spam or other forms of commercial communications to people or the communities in Fae Map.  We have specific Business/VIP Services if you want to promote your organization, business, or yourself and they are much more effective than Spam. ", index: 5, level: 2, underlineFirstSentence: true)
        astrContent.appendIndexBullet("No Black Hats, Please. Please do not interfere or disrupt our Services, security systems, servers, networks connected to the Services, including by transmitting any worms, viruses, spyware, malware or any other code of a destructive or disruptive nature.  Use your hacking powers for good.", index: 6, level: 2, underlineFirstSentence: true)
        
        astrContent.appendDotBullet("Content is prohibited if it:", level: 1)
        astrContent.appendIndexBullet("Is illegal;", index: 1, level: 2)
        astrContent.appendIndexBullet("Is involving nudity and pornography;", index: 2, level: 2)
        astrContent.appendIndexBullet("Encourages or incites violence;", index: 3, level: 2)
        astrContent.appendIndexBullet("Threatens, harasses, bullies or encourages others to do so;", index: 4, level: 2)
        astrContent.appendIndexBullet("Inappropriate use of personal and confidential information of yourself or others;", index: 5, level: 2)
        astrContent.appendIndexBullet("Impersonates someone in a misleading or deceptive manner;", index: 6, level: 2)
        astrContent.appendIndexBullet("Is spam;", index: 7, level: 2)
        astrContent.appendIndexBullet("Is sexist, racist, including hate speech.", index: 8, level: 2)
        astrContent.appendDotBullet("Violation of these Terms, including the Use and Content Restrictions above, may result in termination of your account in Fae Map’s sole and absolute discretion. You understand and agree that we will not be responsible for the Content posted on our Services, and you use and view the Content of other users at your own risk. If you violate these Terms, you understand and agree that we can close your account and deny you access to the Services.", level: 1)
        astrContent.appendDotBullet("Fae Map allows you, among other things, to share Content and provide feedback to make your experience better.  We love feedback, but if you volunteer any suggestions or feedback, please know that we can use them without compensation.", level: 1)
        
        astrContent.appendDefaultString("General Conditions\n\n", bold: true)
        astrContent.appendDotBullet("We reserve the right to modify or terminate the Services, and further reserve the right to modify or deny your access to the Services, including for violations of these Terms, with or without notice, at any time, and without liability to us. If we terminate your access to the Services, your Content will no longer be accessible through your account.", level: 1)
        astrContent.appendDotBullet("Upon termination, all licenses and other rights granted to you in these Terms will immediately cease.", level: 1)
        astrContent.appendDotBullet("You are solely responsible for your interaction with other users on Fae Map, whether online or offline. You agree that Faevorite will not be held responsible or liable for the conduct of any user.", level: 1)
        astrContent.appendDotBullet("You may incur data and other charges because of your use of the Services. These are your responsibility.", level: 1)
        astrContent.appendDotBullet("The Services allow you to post Content that is publicly accessible to others.  To the extent you broadcast or share information, you agree there is no reasonable expectation of privacy for any material you post on Fae Map.", level: 1)
        astrContent.appendDotBullet("The Services may include advertisements, which may be targeted to the users based on Content or relevant information from the Services. The types and extent of advertising by Fae Map on the Services are subject to change. In consideration for Faevorite granting you access to and use of the Services, you agree that Faevorite and its third party providers and partners may place such advertising on the Services or in connection with the display of Content or information from the Services whether submitted by you or others.", level: 1)
        astrContent.appendDotBullet("You represent and warrant that: (i) you own the Content posted by you on or through the Services; (ii) the posting and use of your Content on or through the Services does not violate, misappropriate or infringe on the rights of any third party; and (iii) you agree to pay for any royalties, fees, and any other monies owed by reason of Content you post on or through the Services.", level: 1)
        astrContent.appendDotBullet("You may not: (i) remove any copyright, trademark or other proprietary notices from any portion of the Services; (ii) reproduce, modify, prepare derivative works based upon, distribute, license, lease, sell, resell, transfer, publicly display, publicly perform, transmit, stream, broadcast or otherwise exploit the Services except as expressly permitted by Faevorite; (iii) decompile, reverse engineer or disassemble the Services except as may be permitted by applicable law; (iv) link to, mirror or frame any portion of the Services without our agreement; (v) cause or launch any programs or scripts for the purpose of scraping, indexing, surveying, or otherwise data mining any portion of the Services or unduly burdening or hindering the operation and/or functionality of any aspect of the Services; or (vi) attempt to gain unauthorized access to or impair any aspect of the Services or its related systems or networks.", level: 1)
        astrContent.appendDotBullet("The Services contains intellectual property owned or licensed by Faevorite, including its name and logo and those of Fae Interactive, which are all protected by copyright, trademark, patent, trade secret and other laws, and, as between you and Faevorite, we own all rights in our intellectual property. You will not infringe or use any of our intellectual property.", level: 1)
        astrContent.appendDotBullet("We cannot guaranty that there will never be interruptions of your use of the Services. Some of these interruptions are for scheduled maintenance and service, but others are beyond our control. We will try our best to ensure you a smooth experience in all situations. In case of any event, Faevorite has no liability for your inability to access or use the Services. We will not be liable to you for any modification, suspension, or discontinuation of the Services, or the removal or loss of any Content. You also acknowledge that the internet may be subject to breaches of security and that the submission of Content or other information may not be secure.", level: 1)
        astrContent.appendDotBullet("Faevorite is not responsible for, and does not endorse, support, represent or guarantee the completeness, truthfulness, accuracy or reliability of any Content or communications posted within the Services.", level: 1)
        
        astrContent.appendDefaultString("Copyright Policy\n\n", bold: true)
        astrContent.appendDefaultString("Faevorite respects the intellectual property rights of others. We therefore take reasonable steps to expeditiously remove from our Services any infringing material that we become aware of.  You can help us in ensuring a safe and fun community on Fae Map by reporting any infringing material you come across.\n\n", bold: false)
        astrContent.appendDefaultString("You should report to us any suspected claim if you believe that your Content has been copied in a way that constitutes copyright infringement.  Please provide our copyright agent with the information required by the Digital Millennium Copyright Act (DMCA).  If you file a notice with our Copyright Agent, it must comply with the requirements set forth at 17 U.S.C. § 512(c)(3) [http://www.copyright.gov/title17/92chap5.html]. That means the notice must:\n\n", bold: false)
        
        astrContent.appendDotBullet("contain the physical or electronic signature of a person authorized to act on behalf of the copyright owner.", level: 2)
        astrContent.appendDotBullet("identify the copyrighted work claimed to have been infringed.", level: 2)
        astrContent.appendDotBullet("identify the material that is claimed to be infringing or to be the subject of infringing activity and that is to be removed, or access to which is to be disabled, and information reasonably sufficient to let us locate the material.", level: 2)
        astrContent.appendDotBullet("provide your contact information, including your address, telephone number, and an email address.", level: 2)
        astrContent.appendDotBullet("provide a personal statement that you have a good-faith belief that the use of the material in the manner complained of is not authorized by the copyright owner, its agent, or the law.", level: 2)
        astrContent.appendDotBullet("provide a statement that the information in the notification is accurate and, under penalty of perjury, that you are authorized to act on behalf of the copyright owner.", level: 2)
        
        astrContent.appendDefaultString("Our designated copyright agent for notice of alleged copyright infringement or other legal notices regarding Content appearing on the Services is:\n\n", bold: false)
        astrContent.appendRegularBullet("Faevorite, Inc.", level: 5)
        astrContent.appendRegularBullet("Attn: Copyright Agent", level: 5)
        astrContent.appendRegularBullet("Email: legal@letsfae.com\n", level: 5)
        
        astrContent.appendDotBullet("We reserve the right to remove Content alleged to be infringing or otherwise illegal without prior notice and at our sole discretion. In appropriate circumstances, Faevorite will also terminate a user's account if the user is determined to be a repeat infringer.", level: 1)
        
        astrContent.appendDefaultString("Disclaimer of Warranties\n\n", bold: true)
        astrContent.appendDefaultString("THE SERVICE, INCLUDING, WITHOUT LIMITATION, ANY CONTENT, IS PROVIDED ON AN \"AS IS\", \"AS AVAILABLE\" AND \"WITH ALL FAULTS\" BASIS. TO THE FULLEST EXTENT PERMISSIBLE BY LAW, NEITHER FAEVORITE NOR ANY OF ITS EMPLOYEES, MANAGERS, OFFICERS OR AGENTS (COLLECTIVELY, THE \"FAEVORITE PARTIES\") MAKE ANY REPRESENTATIONS OR WARRANTIES OR ENDORSEMENTS OF ANY KIND WHATSOEVER, EXPRESS OR IMPLIED, AS TO: (A) THE SERVICES; (B) ITS CONTENT; (C) USER CONTENT; OR (D) SECURITY ASSOCIATED WITH THE TRANSMISSION OF CONTENT OR ACCESS TO THE SERVICE.\n\n", bold: false)
        astrContent.appendDefaultString("FAEVORITE HEREBY DISCLAIMS, TO THE FULLEST EXTENT ALLOWED BY APPLICABLE LAW, ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, TITLE, CUSTOM, TRADE, QUIET ENJOYMENT, SYSTEM INTEGRATION AND FREEDOM FROM COMPUTER VIRUS, OR THAT THE SERVICE WILL BE ERROR FREE OR UNINTERRUPTED.\n\n", bold: false)
        astrContent.appendDefaultString("BY ACCESSING OR USING THE SERVICE YOU REPRESENT AND WARRANT THAT YOUR ACTIVITIES ARE LAWFUL IN EVERY JURISDICTION WHERE YOU ACCESS OR USE THE SERVICE.\n\n",bold:false)
        astrContent.appendDefaultString("FAEVORITE SPECIFICALLY DISCLAIMS ANY RESPONSIBILITY OR LIABILITY TO ANY PERSON OR ENTITY FOR ANY LOSS, DAMAGE (WHETHER ACTUAL, CONSEQUENTIAL, PUNITIVE OR OTHERWISE), INJURY, CLAIM, LIABILITY OR OTHER CAUSE OF ANY KIND OR CHARACTER BASED UPON OR RESULTING FROM ANY CONTENT, WHETHER POSTED BY A USER, A BUSINESS PARTNER, OR BY A PERSON OR ENTITY GAINING UNAUTHORIZED ACCESS TO THE SERVICE.\n\n",bold:false)
        
        astrContent.appendDefaultString("Limitation of Liability; Waiver\n\n", bold: true)
        astrContent.appendDefaultString("UNDER NO CIRCUMSTANCES WILL FAEVORITE BE LIABLE TO YOU FOR ANY LOSS OR DAMAGES OF ANY KIND (INCLUDING, WITHOUT LIMITATION, FOR ANY DIRECT, INDIRECT, ECONOMIC, EXEMPLARY, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL LOSSES OR DAMAGES) THAT ARE DIRECTLY OR INDIRECTLY RELATED TO: (A) THE SERVICES; (B) ITS CONTENT; (C) USER CONTENT; (D) YOUR USE OF, INABILITY TO USE, OR THE PERFORMANCE OF THE SERVICE; (E) ANY ACTION TAKEN IN CONNECTION WITH AN INVESTIGATION BY THE FAEVORITE PARTIES OR LAW ENFORCEMENT AUTHORITIES REGARDING YOUR OR ANY OTHER PARTY'S USE OF THE SERVICE; (F) ANY ACTION TAKEN IN CONNECTION WITH COPYRIGHT OR OTHER INTELLECTUAL PROPERTY OWNERS; (G) ANY ERRORS OR OMISSIONS IN THE OPERATION OF THE SERVICES; OR (H) ANY DAMAGE TO ANY USER'S COMPUTER, MOBILE DEVICE, OR OTHER EQUIPMENT OR TECHNOLOGY INCLUDING, WITHOUT LIMITATION, DAMAGE FROM ANY SECURITY BREACH OR FROM ANY VIRUS, BUGS, TAMPERING, FRAUD, ERROR, OMISSION, INTERRUPTION, DEFECT, DELAY IN OPERATION OR TRANSMISSION, COMPUTER LINE OR NETWORK FAILURE OR ANY OTHER TECHNICAL OR OTHER MALFUNCTION, INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOST PROFITS, LOSS OF GOODWILL, LOSS OF DATA, WORK STOPPAGE, ACCURACY OF RESULTS, OR COMPUTER FAILURE OR MALFUNCTION, EVEN IF FORESEEABLE OR EVEN IF THE FAEVORITE PARTIES HAVE BEEN ADVISED OF OR SHOULD HAVE KNOWN OF THE POSSIBILITY OF SUCH DAMAGES, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE, STRICT LIABILITY OR TORT (INCLUDING, WITHOUT LIMITATION, WHETHER CAUSED IN WHOLE OR IN PART BY NEGLIGENCE, ACTS OF GOD, TELECOMMUNICATIONS FAILURE, OR THEFT OR DESTRUCTION OF THE SERVICE). IN NO EVENT WILL FAEVORITE BE LIABLE TO YOU OR ANYONE ELSE FOR LOSS, DAMAGE OR INJURY, INCLUDING, WITHOUT LIMITATION, DEATH OR PERSONAL INJURY. SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION OR EXCLUSION MAY NOT APPLY TO YOU. IN NO EVENT WILL FAEVORITE’S TOTAL LIABILITY TO YOU FOR ALL DAMAGES, LOSSES OR CAUSES OR ACTION EXCEED ONE HUNDRED UNITED STATES DOLLARS ($100.00).\n\n",bold: false)
        astrContent.appendDefaultString("FAEVORITE IS NOT RESPONSIBLE FOR THE ACTIONS, CONTENT, INFORMATION, OR DATA OF THIRD PARTIES, AND YOU RELEASE US, OUR DIRECTORS, OFFICERS, EMPLOYEES, AND AGENTS FROM ANY CLAIMS AND DAMAGES, KNOWN AND UNKNOWN, ARISING OUT OF OR IN ANY WAY CONNECTED WITH ANY CLAIM YOU HAVE AGAINST ANY SUCH THIRD PARTIES.\n\n", bold: false)
        
        astrContent.appendDefaultString("YOU AGREE THAT FAEVORITE WILL HAVE NO RESPONSIBILITY OR LIABILITY AS A RESULT OF ANY ACTION OR CONDUCT IN WHICH USERS MAY ENGAGE ONCE THEY HAVE LOCATED EACH OTHER THROUGH THEIR USE OF THE SERVICE.\n\n", bold: false)
        
        astrContent.appendDefaultString("Indemnification\n\n", bold: true)
        astrContent.appendDefaultString("By using the Services, you agree to defend, indemnify and hold Faevorite harmless from and against any claims, liabilities, damages, losses, and expenses, including without limitation, reasonable attorney's fees and costs, arising out of or in any way connected with any of the following (including as a result of your direct activities on the Services or those conducted on your behalf): (i) your Content or your access to or use of the Services; (ii) your breach or alleged breach of these Terms; (iii) your violation of any third-party right, including without limitation, any intellectual property right, publicity, confidentiality, property or privacy right; (iv) your violation of any laws, rules, regulations, codes, statutes, ordinances or orders of any governmental and quasi-governmental authorities, including, without limitation, all regulatory, administrative and legislative authorities; or (v) any misrepresentation made by you. You will cooperate as fully required by us in the defense of any claim. We reserve the right to assume the exclusive defense and control of any matter subject to indemnification by you, and you will not in any event settle any claim without our prior written consent.\n\n", bold: false)
        
        astrContent.appendDefaultString("Alternative Dispute Resolution\n\n", bold: true)
        astrContent.appendDefaultString("You agree that any and all disputes between you and Faevorite (whether or not such dispute involves a third party) will be resolved by binding, individual arbitration under the American Arbitration Association's rules, except that each party retains the right to bring an individual action in small claims court and the right to seek injunctive or other equitable relief in a court of competent jurisdiction to prevent the actual or threatened infringement, misappropriation or violation of a party's copyrights, trademarks, trade secrets, patents or other intellectual property rights.\n\n", bold: false)
        astrContent.appendDefaultString("YOU ACKNOWLEDGE AND AGREE THAT YOU AND FAEVORITE ARE EACH WAIVING THE RIGHT TO A TRIAL BY JURY OR TO PARTICIPATE AS A PLAINTIFF OR CLASS IN ANY PURPORTED CLASS ACTION OR REPRESENTATIVE PROCEEDING.\n\n", bold: false)
        astrContent.appendDefaultString("Further, unless both you and Faevorite otherwise agree in writing, the arbitrator may not consolidate more than one person's claims, and may not otherwise preside over any form of any class or representative proceeding. If this specific paragraph is held unenforceable, then the entirety of this \"Dispute Resolution\" section will be deemed void. Except as provided in the preceding sentence, this \"Dispute Resolution\" section will survive any termination of these Terms.\n\n", bold: false)
        
        astrContent.appendDefaultString("Time Limitation on Claims\n\n", bold: true)
        astrContent.appendDefaultString("You agree that any claim you may have arising out of or related to your relationship with us must be filed within one year after such claim arose; otherwise, your claim is permanently barred.\n\n", bold: false)
        
        astrContent.appendDefaultString("Governing Law & Venue\n\n", bold: true)
        astrContent.appendDefaultString("These Terms are governed by and construed in accordance with the laws of the State of California, without giving effect to any principles of conflicts of law.\n\n", bold: false)
        
        astrContent.appendDefaultString("Severability\n\n", bold: true)
        astrContent.appendDefaultString("If any provision of these Terms is held to be unlawful, void, or for any reason unenforceable during arbitration or by a court of competent jurisdiction, then that provision will be deemed severable from these Terms and will not affect the validity and enforceability of any remaining provisions. Our failure to insist upon or enforce strict performance of any provision of these Terms will not be construed as a waiver of any provision or right. No waiver of any of these Terms will be deemed a further or continuing waiver of such term or condition or any other term or condition, unless we agree to a waiver which is specifically documented in writing.\n\n", bold: false)
        
        astrContent.appendDefaultString("Entire Agreement\n\n", bold: true)
        astrContent.appendDefaultString("These Terms constitute the entire agreement between you and Faevorite and govern your use of the Services, superseding any prior agreements between you and us. Faevorite may assign these Terms or any rights hereunder without your consent. Neither the course of conduct between the parties nor trade practice will act to modify the Terms. These Terms do not confer any third-party beneficiary rights.\n\n", bold: false)
        
        astrContent.appendDefaultString("Territorial Restrictions\n\n", bold: true)
        astrContent.appendDefaultString("The information provided within the Services is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject Faevorite to any registration requirement within such jurisdiction or country.  We reserve the right to limit the availability of the Services to any person, geographic area, or jurisdiction, at any time and in our sole discretion, and to limit the quantities of any content, program, product, Services or other feature that we provide.\n\n", bold: false)
        
        astrContent.appendDefaultString("Contact Us:\n\n", bold: true)
        astrContent.appendDefaultString("You may contact us if you have any legal questions regarding our Terms or Privacy Policy at legal@letsfae.com\n", bold: false)
        
        return astrContent
    }
}
