


import 'package:base/data/services/utils/base_json_parser.dart';

class LoginResponse {
  int statusCode = 0;
  String statusMessage= "";
  String mandatoryVersionYN = "N";
  List<LoginModules> modules = [];
  SSNIDN? ssnidn;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];

    if (json['resultObject'] != null) {
      modules =[];
      json['resultObject'].forEach((mod) {
        if(mod["mandatoryversionyn"] != null){
          mandatoryVersionYN = "Y";
        }
        else
        modules.add(new LoginModules.cast(mod));
      });
    }
    if (json['ssnidn'] != null) {
      ssnidn = SSNIDN.fromJson(json['ssnidn']);
    }
  }

  @override
  String toString() {
    return 'statusCode : $statusCode  status message: $statusMessage modules : $modules ssnIdn $ssnidn';
  }
}

class LoginModules {
  String listtype = "";
  String list = "";

  List<BusinessLevelModel> businessLevelModel = [];
  List<ModuleListModel> moduleListModel= [];
  List<CompanyConstants> companyConstants= [];
  List<UserInfoModel> userInfo= [];
  LoginModules();
  LoginModules.cast(Map<String, dynamic> json) {
    print("1");
    listtype = json['listtype'] ?? "";
    if (listtype == "BusinessLevelList")
      businessLevelModel = saveBusinessLevelData(json);
    else if (listtype == "CompanyConstants")
      companyConstants = saveCompanyData(json);
    else if (listtype == "ModuleList")
      moduleListModel = saveModulesData(json);
    else if (listtype == "UserInfo") {
      userInfo = BaseJsonParser.goodList(json, "list")
          .map((e) => UserInfoModel.fromJson(e))
          .toList();
    } else
      list = json['list'].toString();
  }
}

class SSNIDN {
  String? ssnId ;

  SSNIDN.fromJson(Map<String, dynamic> json) {
    ssnId = json['value'];
  }
}

class ModuleListModel {
  int? optionId;
  int? id;
  int? parentoptionid;
  String? title;
  String? optiondescription;
  String? isactive;
  String? ishidden;
  String src = "";
  int? sortorder;
  bool isAttachmentReq = false;
  String? context;

  ModuleListModel.fromJson(Map<String, dynamic> json) {

    id = json["id"];
    title = json["title"];
    optiondescription = json["optiondescription"];
    sortorder = json["sortorder"];
    isactive = json["isactive"];
    ishidden = json["ishidden"];
    src = json["src"] ?? "";
    parentoptionid = BaseJsonParser.goodInt(json, "parentoptionid");
    isAttachmentReq = BaseJsonParser.goodBoolean(json, "docattachmentreqyn");
    optionId = parentoptionid ?? BaseJsonParser.goodInt(json, "optionid");
    context = BaseJsonParser.goodString(json, "context");
  }

  @override
  String toString() {
    return 'optionId   : $optionId' +
        'id : $id' +
        'title : $title' +
        'optiondescription : $optiondescription' +
        'isactive  : $isactive' +
        'ishidden : $ishidden' +
        'src : $src' +
        'parentoptionid: $parentoptionid' +
        'isAttachmentReq: $isAttachmentReq' +
        'sortorder : $sortorder';
  }
}

class BusinessLevelModel {
  int? levelvalue;
  String? levelcode;
  int? levelid;
  String? levelname;
  String? businesslocationname;

  BusinessLevelModel.fromJson(Map<String, dynamic> json) {

    levelvalue = BaseJsonParser.goodInt(json, "levelvalue");
    levelcode = BaseJsonParser.goodString(json, "levelcode");
    levelid = BaseJsonParser.goodInt(json, "levelid");
    levelname = BaseJsonParser.goodString(json, "levelname");
    businesslocationname =
        BaseJsonParser.goodString(json, "businesslocationname");
  }

  @override
  String toString() {
    String tostring = " levelvalue : " + levelvalue.toString();
    tostring += "levelcode : " + levelcode!;
    tostring += " levelid : " + levelid.toString();
    tostring += " levelname : " + levelname!;
    tostring += " businesslocationname : " + businesslocationname!;
    return tostring;
  }
}

class CompanyConstants {
  int? finyearid;
  String? attchmentupdpath;
  String? attchmentdwdpath;
  String? dsattchmentupdpath;
  String? dsattchmenttempupdpath;
  String? dsattchmentdwdpath;
  String? username;
  int? userid;
  bool isSuperUser = false;

  CompanyConstants.fromJson(Map<String, dynamic> json) {
    finyearid = json["finyearid"];
    attchmentupdpath = json["attchmentupdpath"];
    attchmentdwdpath = json["attchmentdwdpath"];
    dsattchmentupdpath = json["dsattchmentupdpath"];
    dsattchmenttempupdpath = json["dstemplateuploadpath"];
    dsattchmentdwdpath = json["dsattchmentdwdpath"];
    username = json["username"];
    userid = json["userid"];
    isSuperUser = BaseJsonParser.goodBoolean(json, "superuseryn");
  }
}

class UserInfoModel {
  String? address1;
  String? address2;
  String? address3;
  int? areaId;
  int? countryId;
  int? districtId;
  String? emailId;
  String? firstName;
  String? lastName;
  String? middleName;
  String? mobileNo;
  String? otp;
  String? password;
  String? photoPhysicalName;
  int? stateId;
  int? userId;
  String? username;
  String? zipcode;
  String? apptype;
  String? areaName;
  String? districtName;
  String? stateName;
  String? countryName;
  String? androidOrIosNotificationTopic;

  List<String> notificationTopics = [];
  int? userid;
  String? profilePicName;


  UserInfoModel({
      this.address1,
      this.address2,
      this.address3,
      this.areaId,
      this.countryId,
      this.districtId,
      this.emailId,
      this.firstName,
      this.lastName,
      this.middleName,
      this.mobileNo,
      this.otp,
      this.password,
      this.photoPhysicalName,
      this.stateId,
      this.userId,
      this.username,
      this.zipcode,
      this.apptype,
      this.areaName,
      this.districtName,
      this.stateName,
      this.countryName,
      this.androidOrIosNotificationTopic,
      this.notificationTopics = const [],
      this.userid,
      this.profilePicName,});



  UserInfoModel.fromJson(Map<String, dynamic> json) {
    print(json);
    address1 = BaseJsonParser.goodString(json, "address1");
    address2 = BaseJsonParser.goodString(json, "address2");
    address3 = BaseJsonParser.goodString(json, "address3");
    areaId = BaseJsonParser.goodInt(json, "areaid");
    countryId = BaseJsonParser.goodInt(json, "countryid");
    districtId = BaseJsonParser.goodInt(json, "districtid");
    emailId = BaseJsonParser.goodString(json, "emailid");
    firstName = BaseJsonParser.goodString(json, "firstname");
    lastName = BaseJsonParser.goodString(json, "lastname");
    middleName = BaseJsonParser.goodString(json, "middlename");
    mobileNo = BaseJsonParser.goodString(json, "mobileno");
    otp = BaseJsonParser.goodString(json, "otp");
    password = BaseJsonParser.goodString(json, "password");
    photoPhysicalName = BaseJsonParser.goodString(json, "photophysicalname");
    stateId = BaseJsonParser.goodInt(json, "stateid");
    userId = BaseJsonParser.goodInt(json, "userid");
    username = BaseJsonParser.goodString(json, "username");
    zipcode = BaseJsonParser.goodString(json, "zipcode");
    areaName = BaseJsonParser.goodString(json, "areaname");
    districtName = BaseJsonParser.goodString(json, "districtname");
    stateName = BaseJsonParser.goodString(json, "statename");
    countryName = BaseJsonParser.goodString(json, "countryname");
    apptype=BaseJsonParser.goodString(json, "apptype");
    userid = BaseJsonParser.goodInt(json, "userid");
    androidOrIosNotificationTopic=BaseJsonParser.goodString(json, "notificationtopics");
    profilePicName = BaseJsonParser.goodString(json, "photophysicalname");
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> kMap = Map();
    kMap["address1"] = address1;
    kMap["address2"] = address2;
    kMap["address3"] = address3;
    kMap["areaid"] = areaId;
    kMap["countryid"] = countryId;
    kMap["districtid"] = districtId;
    kMap["emailid"] = emailId;
    kMap["firstname"] = firstName;
    kMap["lastname"] = lastName;
    kMap["middlename"] = middleName;
    kMap["password"] = password;
    kMap["photophysicalname"] = photoPhysicalName;
    kMap["stateid"] = stateId;
    kMap["userid"] = userId;
    kMap["username"] = username;
    kMap["zipcode"] = zipcode;
    kMap["areaname"] = areaName;
    kMap["districtname"] = districtName;
    kMap["statename"] = stateName;
    kMap["countryname"] = countryName;
    kMap['apptype']=apptype??"AGROAPP";
    return kMap;
  }

  UserInfoModel copyWith({
    String? address1,
    String? address2,
    String? address3,
    int? areaId,
    int? countryId,
    int? districtId,
    String? emailId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? mobileNo,
    String? otp,
    String? password,
    String? photoPhysicalName,
    int? stateId,
    int? userId,
    String? username,
    String? zipcode,
    String? apptype,
    String? areaName,
    String? districtName,
    String? stateName,
    String? countryName,
    String? androidOrIosNotificationTopic,
    List<String> notificationTopics =const [],
    int? userid,
    String? fileName ="",

  }) {
    return UserInfoModel(
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      address3: address3 ?? this.address3,
      areaId: areaId ?? this.areaId,
      countryId: countryId ?? this.countryId,
      districtId: districtId ?? this.districtId,
      emailId: emailId ?? this.emailId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      mobileNo: mobileNo ?? this.mobileNo,
      otp: otp ?? this.otp,
      password: password ?? this.password,
      photoPhysicalName: photoPhysicalName ?? this.photoPhysicalName,
      stateId: stateId ?? this.stateId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      zipcode: zipcode ?? this.zipcode,
      apptype: apptype ?? this.apptype,
      areaName: areaName ?? this.areaName,
      districtName: districtName ?? this.districtName,
      stateName: stateName ?? this.stateName,
      countryName: countryName ?? this.countryName,
      userid: userid ?? this.userid,
      profilePicName: fileName ?? this.profilePicName,

    );
  }
}

List<BusinessLevelModel> saveBusinessLevelData(
    Map<String, dynamic> businessData) {
  List<BusinessLevelModel> businessList = [];

  businessData['list']
      .forEach((data) => {businessList.add(BusinessLevelModel.fromJson(data))});
  return businessList;
}

List<ModuleListModel> saveModulesData(Map<String, dynamic> modulesData) {
  List<ModuleListModel> moduleList = [];

  modulesData['list']
      .forEach((data) => moduleList.add(ModuleListModel.fromJson(data)));
  return moduleList;
}

List<CompanyConstants> saveCompanyData(Map<String, dynamic> companyData) {
  List<CompanyConstants> companyList = [];
  companyData['list']
      .forEach((data) => {companyList.add(CompanyConstants.fromJson(data))});
  return companyList;
}
