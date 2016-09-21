//
//  TestViewController.swift
//  faeBeta
//
//  Created by 王彦翔 on 16/9/9.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var testLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
//        signUpTest()
//        logInTest()
        //logOutTest()
        //checkEmailExistTest()
        //checkUsernameExistTest()
        //sendCodeToEmailTest()
//        VerifyCodeTest()
//        changePasswordTest()
//        getAccountInformationTest()
//        updateAccountInformationTest()
//        VerifyCodeTest()
        //print(userTokenEncode)
//        verifyPasswordTest()
//        updatePasswordTest()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signUpTest(){
        let user = FaeUser()
        user.whereKey("password", value: "A1234567")
        user.whereKey("email",value: "yanxianw@usc.edu")
        user.whereKey("user_name", value: "heheda")
        user.whereKey("first_name", value: "hehe")
        user.whereKey("last_name", value: "haha")
        user.whereKey("birthday", value: "1993-01-01")
        user.whereKey("gender",value: "male")
        user.signUpInBackground{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //sign up success
                self.testLabel.text = "sign up success"
            }
            else{
                //sign up failse
                self.testLabel.text = "sign up failure"
            }
        }
    }
    
    func logInTest(){
        let user = FaeUser()
        user.whereKey("email", value: "user100@email.com")
        user.whereKey("password", value: "A1234567")
        user.whereKey("user_name", value: "heheda")
        // for iphone: device_id is required and is_mobile should set to true
        user.whereKey("device_id", value: headerDeviceID)
        user.whereKey("is_mobile", value: "false")
        user.logInBackground { (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                self.testLabel.text = "login success"
            }
            else{
                //failure
                self.testLabel.text = "login failure"
            }
        }
    }
    
    func logOutTest(){
        let user = FaeUser()
        user.logOut{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                self.testLabel.text = "logout success"
            }
            else{
                //failure
                self.testLabel.text = "logout failure"
            }
        }
    }
    
    func checkEmailExistTest(){
        let user = FaeUser()
        user.whereKey("email", value: "user100@email.com")
        user.checkEmailExistence{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                if message != nil{
                    if message!["existence"] != nil{
                        let exist: Bool = message!["existence"] as! Bool
                        if exist==true{
                            //email exist
                            self.testLabel.text = "email exist"
                        }
                        else{
                            // email not exist
                            self.testLabel.text = "email not exist"
                        }
                    }
                }
            }
            else{
                //failure
                self.testLabel.text = "check failure"
            }
        }
    }
    
    
    // problem with check user name in back end
    func checkUsernameExistTest(){
        let user = FaeUser()
        user.whereKey("user_name", value: "heheda")
        user.checkUserExistence{ (status:Int?, message:AnyObject?) in
            if ( status! / 100 == 2 ){
                //success
                if message != nil{
                    if message!["existence"] != nil{
                        let exist: Bool = message!["existence"] as! Bool
                        if exist==true{
                            // username exist
                            self.testLabel.text = "username exist"
                        }
                        else{
                            // username not exist
                            self.testLabel.text = "username not exist"
                        }
                    }
                }
            }
            else{
                //failure
                self.testLabel.text = "check failure"
            }
        }
    }
    
    func sendCodeToEmailTest(){
        let user = FaeUser()
        user.whereKey("email",value: "yanxianw@usc.edu")
        user.sendCodeToEmail{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //send success
                self.testLabel.text = "send success"
            }
            else{
                //send failse
                self.testLabel.text = "send failure"
            }
        }
    }
    
    func VerifyCodeTest(){
        let user = FaeUser()
        user.whereKey("email",value: "yanxianw@usc.edu")
        user.whereKey("code", value: "898110")
        user.validateCode{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //verify success
                self.testLabel.text = "verify success"
            }
            else{
                //verify failse
                self.testLabel.text = "verify failure"
            }
        }
    }
    
    func changePasswordTest(){
        let user = FaeUser()
        user.whereKey("password", value: "A1234567")
        user.whereKey("email",value: "yanxianw@usc.edu")
        user.whereKey("code", value: "898110")
        user.changePassword{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //change password success
                self.testLabel.text = "change password success"
            }
            else{
                //change password failse
                self.testLabel.text = "change password failure"
            }
        }
    }
    
    func getAccountInformationTest(){
        let user = FaeUser()
        user.getAccountBasicInfo{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //get info success
                self.testLabel.text = "get info success"
            }
            else{
                //get info failse
                self.testLabel.text = "get info failure"
            }
        }
    }
    
    
    func updateAccountInformationTest(){
        let user = FaeUser()
        user.whereKey("user_name", value: "heheda")
        user.whereKey("first_name", value: "hehe")
        user.whereKey("last_name", value: "haha")
        user.whereKey("birthday", value: "1993-01-01")
        user.whereKey("gender",value: "male")
        user.updateAccountBasicInfo{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //update info success
                self.testLabel.text = "update info success"
            }
            else{
                //update info failse
                self.testLabel.text = "update info failure"
            }
        }
    }
    
    func verifyPasswordTest(){
        let user = FaeUser()
        user.whereKey("password", value: "A1234567")
        user.verifyPassword{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //verify password success
                self.testLabel.text = "verify password success"
            }
            else{
                //verify password failse
                self.testLabel.text = "verify password failure"
            }
        }
    }
    
    func updatePasswordTest(){
        let user = FaeUser()
        user.whereKey("new_password", value: "A1234567")
        user.whereKey("old_password", value: "A1234567")
        user.updatePassword{(status: Int, message: AnyObject?) in
            if(status / 100 == 2){
                //update password success
                self.testLabel.text = "update password success"
            }
            else{
                //update password failse
                self.testLabel.text = "update password failure"
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //TEST: test get self profile function
    //FaeUser().getSelfProfile {(status:Int,message:AnyObject?) in}
    //TEST: test get profile
    //FaeUser().getOthersProfile("1") {(status:Int,message:AnyObject?) in
    //}
    //TEST: test update self profile
    //                let user2 = FaeUser()
    //                user2.whereKey("gender", value: "female")
    //                user2.whereKey("address", value: "trod")
    //                user2.updateProfile{(status:Int,message:AnyObject?) in}
    //TEST: test renewCoordinate
    //                let user3 = FaeUser()
    //                user3.whereKey("geo_latitude", value: "21")
    //                user3.whereKey("geo_longitude", value: "21")
    //                user3.renewCoordinate{(status:Int,message:AnyObject?) in}
    //TEST: test get map information
    //                let user4 = FaeUser()
    //                user4.whereKey("geo_latitude", value: "21")
    //                user4.whereKey("geo_longitude", value: "21")
    //                user4.whereKey("radius", value: "20000000000")
    //                user4.getMapInformation{(status:Int,message:AnyObject?) in}
    
    //TEST: test post comment
    //                let user5 = FaeUser()
    //                user5.whereKey("geo_latitude", value: "21")
    //                user5.whereKey("geo_longitude", value: "21")
    //                user5.whereKey("content", value: "First Comment")
    //                user5.postComment{(status:Int,message:AnyObject?) in}
    
    //TEST: test get comment by id
    //                let user6 = FaeUser()
    //                user6.getComment("23"){(status:Int,message:AnyObject?) in}
    
    //TEST: test user all comments
    //                let user7 = FaeUser()
    //                user7.getUserAllComments("2"){(status:Int,message:AnyObject?) in}
    
    //TEST: test get comment by id
    //                let user8 = FaeUser()
    //                user8.deleteCommentById("23"){(status:Int,message:AnyObject?) in}

}
