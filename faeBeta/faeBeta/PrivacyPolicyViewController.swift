//
//  PrivacyPolicyViewController.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/18/16.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController, UIScrollViewDelegate {

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
    
    private func generateScrollView() {
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: screenWidth, height: 2000)
        
        let titleImageView = UIImageView(frame: CGRect(x: screenWidth / 2 - 23, y: 5, width: 46, height: 49))
        titleImageView.image = #imageLiteral(resourceName: "faeWingIcon")
        scrollView.addSubview(titleImageView)
        
        let titleLabel = UILabel(frame: CGRect(x: screenWidth / 2 - 100, y: 67, width: 200, height: 36))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        let astrTitle = NSMutableAttributedString(string: "PRIVACY POLICY\nFae Interactive")
        
        let attrRange1 = NSRange(location: 0, length: 14)
        let attrRange2 = NSRange(location: 15, length: 15)
        
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
            indicator.backgroundColor = UIColor._2499090()
        }
    }
    
    func backButtonTapped(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    private func astrContent() -> NSAttributedString {
        func numberBullet(_ num: Int) -> String {
            return "        \(num).  "
        }
        
        let astrContent = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 12)!]).mutableCopy() as! NSMutableAttributedString
        astrContent.appendDefaultString("Last Updated: Nov 11, 2016\n\n", bold: true)
        astrContent.appendDefaultString("Welcome to Fae Interactive! We drafted this Privacy Policy (“Policy”) for Fae Map (“Software”) to describe how we collect, store, use, protect and share your information and with whom we share it.\n\n", bold: false)
        astrContent.appendDefaultString("Your access to and use of the Software and our Services (“Services”) is conditioned on your acceptance of and compliance with our Terms [www.faemaps.com/legal/terms] and this Privacy Policy; therefore it is recommended that you read our Terms and Privacy Policy carefully.\n\n", bold: false)
        astrContent.appendDefaultString("This Policy applies to persons anywhere in the world who use Fae Map and its Services.  You agree that we can collect, transfer, store, disclose and use your information as described in this Policy.\n\n", bold: false)
        
        astrContent.appendDefaultString("Information We Collect:\n\n", bold: true)
        astrContent.appendDefaultString("      There are three basic categories of information we collect:\n\n", bold: false)
        astrContent.appendDotBullet("Information you give us.", level: 2)
        astrContent.appendDotBullet("Information obtained from your use of our services.", level: 2)
        astrContent.appendDotBullet("Information obtained from third parties.", level: 2)
        
        astrContent.appendDefaultString("      Here’s a little more detail on each of these categories.\n\n", bold: false)

        astrContent.appendDefaultString("           A.   Information You Give Us:\n\n", bold: true)
        astrContent.appendDefaultString("           We collect information that you choose to share with us when you use the Software. Our services will require you to set up a Fae Account, so we will need to collect a few details about you to start. We may add information to your Fae Account from different Services you use at Fae. Each Service at Fae uses information from your Fae Account differently. A Fae Account collects the following basic information:\n\n", bold: false)
        astrContent.appendDotBullet("Full Name;", level: 3, oneLine: true)
        astrContent.appendDotBullet("Username;", level: 3, oneLine: true)
        astrContent.appendDotBullet("Email address(es);", level: 3, oneLine: true)
        astrContent.appendDotBullet("Gender", level: 3, oneLine: true)
        astrContent.appendDotBullet("Date of Birth", level: 3)
        
        astrContent.appendDefaultString("           In Fae Map, we don’t use information from your Fae Account directly due to the openness of the application. Fae Map will have you create a profile about you and a Display Name instead of using your Full Name and we will not show any of your personal information unless you choose to share them in your profile. Everything in your profile can be toggled to show/not show according to your preference. Fae Map will and may collect and use the following basic information:\n\n", bold: false)
        astrContent.appendDotBullet("A Display Name", level: 3, oneLine: true)
        astrContent.appendDotBullet("Username and Profile", level: 3, oneLine: true)
        astrContent.appendDotBullet("Gender and Age (Toggle to show/not show)", level: 3, oneLine: true)
        astrContent.appendDotBullet("Real-Time Location Information (Invisible Option Anytime)", level: 3, oneLine: true)
        astrContent.appendDotBullet("Demographic Information", level: 3, oneLine: true)
        astrContent.appendDotBullet("Information from other Applications", level: 3, oneLine: true)
        astrContent.appendDotBullet("Fae Account for Log In and Identification Purposes", level: 3)

        astrContent.appendDefaultString("           B.   Information Obtained From Your Use of Our Services.\n\n", bold: true)
        astrContent.appendDefaultString("           We may collect additional information in connection with your use of Fae Map.  For instance, we are able to determine your actions in Fae Map when a situation comes up that requires us to do so. For example, we may determine your location data, or whether you participated in certain content, shared content, or watched a specific video.  This is a more complete picture of the types of information we obtain:\n\n", bold: false)
        
        astrContent.appendRegularBullet("                  •    Traffic Data.  When you visit Fae Map, we have information about your location data and we need that to use our security system to correctly protect you from harm. We will also have the following categories of information: (1) your Internet protocol address and MAC address; (2) the date and time of your visit Fae Map; (3) the type of system you used for access; (4) your device’s GPS information; (5) the pages that you accessed during your use (collectively, \"Traffic Data\"). Traffic Data is semi-anonymous information that does not identify or track you personally. We use Traffic Data to evaluate and improve Fae Map, our content to users, and to make Fae Map more useful to visitors.  We also use it to diagnose problems with our servers, to keep our servers running smoothly, and to monitor the number of users, the type of technology they use, and some of the actions they do to develop necessary improvements of features.\n", level: 1, boldFirstSentence: true)
        astrContent.appendRegularBullet("                  •    Usage Information.  This is how you interact with the services and other users, such as which videos you watch, which pins you post, how you communicate with other users, the time and date of your communications, the number of items you post, your interactions with messages (such as when you open a message or capture a screenshot).\n", level: 1, boldFirstSentence: true)
        astrContent.appendRegularBullet("                  •    Information Collected by Cookies and Other Technologies.  Like most online services and mobile applications, we may use cookies and other technologies, such as beacons, web storage, and unique advertising identifiers, to collect information about your activity, browser, and device. We may also use these technologies to collect information when you interact with services we offer through one of our partners. Most web browsers are set to accept cookies by default. If you prefer, you can usually remove or reject browser cookies through the settings on your browser or device. Keep in mind, though, that removing or rejecting cookies could affect the availability and functionality of our services.\n", level: 1, boldFirstSentence: true)
        astrContent.appendRegularBullet("                  •    Information Obtained from Third Parties.  We may collect information that other users provide about you when they use our services. For example, if another user recommends you or referred you to our Services — we may combine the information we collect from that user with other information we have collected about you. We may also obtain information from other companies that are owned or operated by us, or any other third-party sources, and combine that with the information we collect through our services.\n", level: 1, boldFirstSentence: true)
        
        astrContent.appendDefaultString("Use of Information Collected:\n\n", bold: true)
        astrContent.appendDefaultString("           We may use the information we collect about you to:\n\n", bold: false)
        astrContent.appendDotBullet("Provide, maintain, and improve our services, including, for example, to facilitate payments, send receipts, provide products and services you request (and send related information), develop new features, provide customer support to users, authenticate users, and send product updates and administrative messages;", level: 3)
        astrContent.appendDotBullet("Perform internal operations, including, for example, to prevent fraud and abuse of our Services; to troubleshoot software bugs and operational problems; to test, analyze, conduct data analysis, and to monitor and analyze usage and activity trends;", level: 3)
        astrContent.appendDotBullet("Send you communications we think will be of interest to you;", level: 3)
        astrContent.appendDotBullet("Share personal information about you with your consent. For example, you may let us share personal information with others for their own marketing uses.", level: 3)
        astrContent.appendDotBullet("We may share information to comply with laws.", level: 3)
        astrContent.appendDotBullet("We may share information to respond to lawful requests and legal processes, and also for emergency purposes. This includes protecting the safety of our employees and agents, our customers, or any person.", level: 3)
        astrContent.appendDotBullet("We may share information to protect the rights and property of the Company, our agents, customers, and others. This includes enforcing our agreements, policies, and terms of use.", level: 3)
        astrContent.appendDotBullet("We may share information about you with service providers who perform services on our behalf, sellers that provide goods through our services, and business partners that provide services and functionality. We may share information with those who need it to do work for us.", level: 3)
        astrContent.appendDotBullet("We may also share with third parties, such as advertisers, but only if that information is aggregated and if any personally identifiable information is scrubbed so that the advertiser cannot reasonably be used to identify you personally.", level: 3)
        astrContent.appendDotBullet("We may transfer the information described in this Policy to, and process and store it in, the United States, Canada, and other countries, some of which may have less protective data protection laws than the region in which you reside. Where this is the case, we will take appropriate measures to protect your personal information in accordance with this Statement.", level: 3)

        astrContent.appendDefaultString("Information Choices and Changes:\n\n", bold: true)
        astrContent.appendDotBullet("If we have any promotional emails, there will be information on how to “opt-out.” If you opt out, we may still send you Non-Promotional Emails. Non-Promotional emails include emails about your accounts, security, and our business dealings with you.", level: 2)
        astrContent.appendDotBullet("You may send requests about personal information to our contact email below. You can always request to change contact choices and update your personal information.", level: 2)
        astrContent.appendDotBullet("The services may also contain third-party links and search results, include third-party integrations, or offer a co-branded or third-party-branded service. By going to those links, using the third-party integration, or using a co-branded or third-party-branded service, you may be providing information (including personal information) directly to the third party, us, or both. You acknowledge and agree that we are not responsible for how those third parties collect or use your information. As always, we encourage you to review the privacy policies of every third-party website or service that you visit or use, including those third parties you interact with through our services.", level: 2)
        
        astrContent.appendDefaultString("Transmittals from Us:\n\n", bold: true)
        astrContent.appendDotBullet("We may send you periodic announcements including the details of our existing and new programs. ", level: 2)
        astrContent.appendDotBullet("If you provide your information to us, use our Services, or subscribe to any of our services, you will have created a commercial relationship with us.  In having done so, you understand that even unsolicited commercial email sent from us or our affiliates is not SPAM as that term is defined under the law. As courtesy to our users, we will always only send you relevant or important information that you are part of or that you took interest in.", level: 2)
        
        astrContent.appendDefaultString("Our Commitment to Data Security:\n\n", bold: true)
        astrContent.appendDefaultString("           We take certain measures and try our best to protect the transmission of sensitive end-user information.  We make reasonable efforts to ensure the integrity and security of our network and systems.  Nevertheless, we cannot 100% guarantee that our security measures will always prevent hackers from illegally obtaining this information.  Given the resourcefulness of cyber-criminals, we are unable to guarantee that our security is completely without security holes even though security is one of our top priorities. You assume the risk of such breaches to the extent that they may occur despite our extensive security measures.\n\n", bold: false)

        astrContent.appendDefaultString("Access and Modification of your Information and our Privacy Updates:\n\n", bold: true)
        astrContent.appendDefaultString("           Users have the opportunity to access or modify information provided during registration.  You can easily do so in your Fae Account Settings or anytime by emailing us at support@letsfae.com.\n\n", bold: false)
        
        astrContent.appendDefaultString("Minors and Children:\n\n", bold: true)
        astrContent.appendDefaultString("           Our services are not intended for—and we don’t direct them to—anyone under the age of 18, and that’s why we do not knowingly collect personal information from anyone under the age of 18. For young users under the age of 18, parent’s discretion is advised, you must have a parent/guardian agreement/consent to agree to use our Services.\n\n", bold: false)
        
        astrContent.appendDefaultString("Questions about our Privacy Policy:\n\n", bold: true)
        astrContent.appendLetterBullet("If you have any questions about this Policy or the practices described herein, you may contact us at support@letsfae.com", letter: "A", level: 2)
        astrContent.appendLetterBullet("We welcome your comments or questions about this privacy policy.", letter: "B", level: 2)

        astrContent.appendDefaultString("Questions about our Privacy Policy:\n\n", bold: true)
        astrContent.appendDefaultString("           We may change this Privacy Policy from time to time. But when we do, we’ll let users know.  When we make changes, we’ll update the date at the top of the Privacy Policy.  We may provide you with other additional notices (such as adding an email or statement to visit our website or providing you with an in-app notification).\n\n", bold: false)

        return astrContent
    }
}
