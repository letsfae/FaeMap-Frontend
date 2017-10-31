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
    var boolPush = false
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
        let btnBack = UIButton(frame: CGRect(x: 0, y: 25, width: 48, height: 40))
        btnBack.setImage(#imageLiteral(resourceName: "Fill 1"), for: UIControlState())
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
        
        let titleImageView = UIImageView(frame: CGRect(x: screenWidth / 2 - 25, y: 5, width: 50, height: 50))
        titleImageView.image = #imageLiteral(resourceName: "app_icon_new")
        scrollView.addSubview(titleImageView)
        
        let titleLabel = UILabel(frame: CGRect(x: screenWidth / 2 - 100, y: 67, width: 200, height: 36))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        let astrTitle = NSMutableAttributedString(string: "PRIVACY POLICY\nFae Maps")
        
        let attrRange1 = NSRange(location: 0, length: 14)
        let attrRange2 = NSRange(location: 15, length: 8)
        
        astrTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor._898989(), range: attrRange1)
        astrTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor._115115115(), range: attrRange2)
        astrTitle.addAttribute(NSAttributedStringKey.font, value:UIFont(name: "AvenirNext-DemiBold", size: 13)!, range: attrRange1)
        astrTitle.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "AvenirNext-DemiBold", size: 13)!, range: attrRange2)
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
            //indicator.backgroundColor = .red//UIColor._2499090()
            //indicator.tintColor = UIColor._2499090()
            indicator.backgroundColor = UIColor._2499090()
            indicator.tintAdjustmentMode = .normal
            indicator.tintColor = UIColor._2499090()
            indicator.image = indicator.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc func backButtonTapped(_ sender:UIButton) {
        if boolPush {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func astrContent() -> NSAttributedString {
        func numberBullet(_ num: Int) -> String {
            return "        \(num).  "
        }
        
        let astrContent = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 12)!]).mutableCopy() as! NSMutableAttributedString
        astrContent.appendDefaultString("Last Updated: Dec 6, 2017\n\n", bold: true)
        astrContent.appendDefaultString("Welcome to Fae Maps! We drafted this Privacy Policy (“Policy”) for Fae Map (“Software”) to describe how we collect, store, use, protect and share your information, including what we will share and with whom we share it.\n\n")
        astrContent.appendDefaultString("Your access to and use of the Software and our Services (“Services”) is conditioned on your acceptance of and compliance with our")
        astrContent.appendDefaultString(" Term ", bold: true, red: true)
        astrContent.appendDefaultString("[www.faemaps.com/legal/terms] and this Privacy Policy; therefore it is recommended that you read our Terms and Privacy Policy carefully.\n\n")
        astrContent.appendDefaultString("This Policy applies to persons anywhere in the world who use Fae Map and its Services.  You agree that we can collect, store, use, and share your information as described in this Policy. \n\n")
        
        astrContent.appendDefaultString("Information We Collect:\n\n", bold: true)
        astrContent.appendDefaultString("There are three basic categories of information we collect:\n\n", bold: false)
        astrContent.appendDotBullet("Information you give us.", level: 2)
        astrContent.appendDotBullet("Information obtained from the use of our Services.", level: 2)
        astrContent.appendDotBullet("Information obtained from third parties.", level: 2)
        
        astrContent.appendDefaultString("Here’s a little more detail on each of these categories.\n\n", bold: false)

        astrContent.appendDefaultString("           A.   Information You Give Us:\n\n", bold: true)
        astrContent.appendDefaultString("           We collect information that you choose to share with us when you use the Software. Our Services require you to set up a Faevorite Account; to set up the account we need to collect a few details about you. You may change the information in your account and we may add information to your account while you are using our Services. Additional information for your account may be needed or added from future/other Services at Faevorite to ensure you have the fullest experience. Your Faevorite Account is mainly used for verification and identification purposes. To start, a Faevorite Account collects the following basic information:\n\n")
        astrContent.appendDotBullet("Full Name;", level: 2, oneLine: true)
        astrContent.appendDotBullet("Username;", level: 2, oneLine: true)
        astrContent.appendDotBullet("Email address(es);", level: 2, oneLine: true)
        astrContent.appendDotBullet("Gender", level: 2, oneLine: true)
        astrContent.appendDotBullet("Date of Birth", level: 2)
        
        astrContent.appendDefaultString("           In Fae Maps, you will create a profile and a Display Name. Your personal information can always be toggled to show/not show in settings. Fae Maps value user privacy and will not share information without notice and permission from the user.   All information collected will be kept private within Faevorite’s database. Fae Maps collect and use the following basic information:\n\n")
        astrContent.appendDotBullet("A Display Name", level: 2, oneLine: true)
        astrContent.appendDotBullet("Username and Profile", level: 2, oneLine: true)
        astrContent.appendDotBullet("Gender and Age (Toggle to show/not show)", level: 2, oneLine: true)
        astrContent.appendDotBullet("Real-Time Location Information (Invisible Option Anytime)", level: 2, oneLine: true)
        astrContent.appendDotBullet("Demographic Information", level: 2, oneLine: true)
        astrContent.appendDotBullet("Information from other Applications", level: 2, oneLine: true)
        astrContent.appendDotBullet("Fae Account (Identification Purposes)", level: 2)

        astrContent.appendDefaultString("           B.   Information Obtained From Your Use of Our Services.\n\n", bold: true)
        astrContent.appendDefaultString("           We may collect additional information from the way you use Fae Maps and its features. Faevorite will do its best with our Security System to protect the data collected from you and ensure that they stay private. Below is a more complete picture of the types of information we obtain:\n\n")
        
        astrContent.appendDotBullet("Location Data.  When you visit Fae Maps, we receive information about your true location data and send it through our Security System to protect you from unnecessary harm. Our Security System also makes sure your true location data is not seen by others unless you manually share it with a friend. Additionally we will also have the following categories of information: (1) your Internet protocol address and MAC address; (2) the date and time of your visit to Fae Maps; (3) the type of system you used for access; (4) your device’s GPS information; (5) the pages that you accessed during your use (collectively, \"Location Data\"). Location Data is semi-anonymous information that does not identify or track you personally. We use this Location Data as part of our analytics to evaluate and improve Fae Maps, including our content to users, and to make Fae Maps more useful to visitors.  We also may use this data to diagnose problems with our servers, to keep our servers running smoothly, and to monitor the number of users, the type of technology they use, and some of the actions they do to develop necessary improvements of features.", level: 2, boldFirstSentence: true)
        astrContent.appendDotBullet(" Usage Information.  This is how you interact with the Services and other users, such as which features you use, which pages you view, which things you are interested in, how you interact with the map and other users, the time and date of your interactions, and other interactions within the application for example when you as when you contact a place or capture a screenshot.", level: 2, boldFirstSentence: true)
        astrContent.appendDotBullet("Information Collected by Cookies and Other Technologies.  Like most online services and mobile applications, we may use cookies and other technologies, such as beacons, web storage, and unique advertising identifiers, to collect information about your activity, browser, and device. We may also use these technologies to collect information when you interact with the Services we offer through one of our partners. Most web browsers are set to accept cookies by default. If you prefer, you can usually change the settings on cookies through your browser or device. Keep in mind, though, that changing the settings on cookies could affect the availability and functionality of our services, and affect your general experience with the particular Service as well as other services from other providers that you currently use.", level: 2, boldFirstSentence: true)
        
        astrContent.appendDefaultString("           C.   Information Obtained from Third Parties. \n\n", bold: true)
        astrContent.appendDefaultString("           We may collect information that other providers/users/services collect or create about you when they use our services. For example, if another user recommends you or referred you to our Services — we may combine the information we collect from that user with other information we have collected about you. We may also obtain information from other companies that are owned or operated by us, or any other third-party sources, and combine that with the information we collect through our services.\n\n", bold: false)
        
        astrContent.appendDefaultString("Use of Information Collected:\n\n", bold: true)
        astrContent.appendDefaultString("           We use collected information mainly for internal data analytics to improve our Software and Services. The analytics we do include machine learning, artificial intelligence, individual persona, and more. These analytics will eventually allow us to run features such as smart matching the things you are interested in directly to you. This results the Software to be safer, more private and more individually tailored for you. Below is more details on how we use the information we collected about you: \n\n", bold: false)
        astrContent.appendDotBullet("Provide, maintain, and improve our services, including, for example, to facilitate payments, send receipts, provide products and services you request (and send related information), develop new features, provide customer support to users, authenticate users, and send product updates and administrative messages;", level: 2)
        astrContent.appendDotBullet("Perform internal operations, including, for example, to prevent fraud and abuse of our Services; to troubleshoot software bugs and operational problems; to test, analyze, conduct data analysis, and to monitor and analyze usage and activity trends;", level: 2)
        astrContent.appendDotBullet("Improving systems such as machine learning, artificial intelligence, and recommendation algorithms. We will be able to send you information we think will be of interest to you more accurately;", level: 2)
        astrContent.appendDotBullet("We may share or use information to comply with laws. We may share information to respond to lawful requests and legal processes, and also for emergency purposes. This includes protecting the safety of our employees and agents, our customers, or any person.", level: 2)
        astrContent.appendDotBullet("We may share information to protect the rights and property of the Company, our agents, customers, and others. This includes enforcing our agreements, policies, and terms of use.", level: 2)
        astrContent.appendDotBullet("We may share information about you with service providers who perform services on our behalf, sellers that provide goods/services through our platforms, and business partners that provide services and functionality. We may share information with those who need it to do work for us.", level: 2)
        astrContent.appendDotBullet("Even though we analyze most data internally, in some cases, we may have the need to share with third parties, such as advertisers, but only when the shared information is aggregated. Any personally identifiable information will be scrubbed or hidden so that the advertiser cannot use your data to identify you personally.", level: 2)
        astrContent.appendDotBullet("We may transfer the information described in this Policy to, and process and store it in, the United States, Canada, and other countries, some of which may have less protective data protection laws than the region in which you reside. Where this is the case, we will take appropriate measures to protect your personal information in accordance with this Statement.", level: 2)

        astrContent.appendDefaultString("Information Choices and Changes:\n\n", bold: true)
        astrContent.appendDotBullet("If we have any promotional emails, subscriptions, etc. there will be information on how to “opt-out.” If you opt out, we may still send you Non-Promotional Emails. Non-Promotional emails include emails such as information about your accounts, security, and our business dealings with you.", level: 2)
        astrContent.appendDotBullet("You may send requests about personal information to our contact email or support. You can always request to change contact choices and update your personal information through us or through your Account Settings.", level: 2)
        astrContent.appendDotBullet("The services may also contain third-party links and search results, include third-party integrations, or offer a co-branded or third-party-branded service. By going to those links, using the third-party integration, or using a co-branded or third-party-branded service, you may be providing information (including personal information) directly to the third party, us, or both. You acknowledge and agree that we are not responsible for how those third parties collect or use your information. As always, we encourage you to review the privacy policies of every third-party website or service that you visit or use, including those third parties you interact with through our services.", level: 2)
        
        astrContent.appendDefaultString("Transmittals from Us:\n\n", bold: true)
        astrContent.appendDotBullet("We may send you periodic announcements including the details of our existing and new programs.", level: 2)
        astrContent.appendDotBullet("If you provide your information to us, use our Services, or subscribe to any of our services, you will have created a commercial relationship with us.  In having done so, you understand that even unsolicited commercial email sent from us or our affiliates is not SPAM as that term is defined under the law. As courtesy to our users, we will always only send you relevant or important information that you are part of or that you took interest in.", level: 2)
        
        astrContent.appendDefaultString("Our Commitment to Data Security:\n\n", bold: true)
        astrContent.appendDefaultString("           We take great measures and try our best to protect the transmission of sensitive end-user information. Additionally we make the best efforts to ensure the integrity and security of our network and systems. Nevertheless, given the resourcefulness of cyber-criminals nowadays, there may still be ways that hackers may use to illegally attack our systems to try and obtain protected information. While we try to ensure that all our security measures now or future will consistently prevent hackers from obtaining this information, we cannot always guarantee that all our system will be absolutely without security holes even though security is one of our top priorities. You assume the risk of such breaches to the extent that they may occur despite our extensive security measures.\n\n", bold: false)

        astrContent.appendDefaultString("Access and Modification of your Information:\n\n", bold: true)
        astrContent.appendDefaultString("           Users have the opportunity to access or modify information provided during registration.  You can easily do so in your Fae Account Settings or anytime by emailing us at support@letsfae.com. \n\n", bold: false)
        
        astrContent.appendDefaultString("Minors and Children:\n\n", bold: true)
        astrContent.appendDefaultString("           Certain parts of our services or information displayed by third parties or other businesses and partners through our platform may not be all suitable for anyone under the age of 18. For young users under the age of 18, parent’s discretion is advised, you must have a parent/guardian agreement/consent to agree to use our Services. \n\n", bold: false)
        
        astrContent.appendDefaultString("Questions about our Privacy Policy:\n\n", bold: true)
        astrContent.appendLetterBullet("If you have any questions about this Policy or the practices described herein, you may contact us at support@letsfae.com", letter: "A", level: 2)
        astrContent.appendLetterBullet("We welcome your comments or questions about this privacy policy.", letter: "B", level: 2)

        astrContent.appendDefaultString("Questions about our Privacy Policy:\n\n", bold: true)
        astrContent.appendDefaultString("           We may change and update this Privacy Policy when necessary. We will notify all users every time this Policy updates. When we make changes, we’ll update the date at the top of the Privacy Policy. We may also provide you with other additional notices (such as adding an email or statement to visit our website or providing you with an in-app notification).\n\n", bold: false)

        return astrContent
    }
}
