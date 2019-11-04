/**
 * @File Name          : S4GTestFactory.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 17/10/2019 15:13:44
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   ismael.ocana@s4g.es     Initial Version
**/
@isTest
public with sharing class S4GTestFactory {

  public static Account createAccount(){
    return (Account)S4GSmartFactory.createSObject('Account');
  }

  public static Contact createContact(){
    return (Contact)S4GSmartFactory.createSObject('Contact'); 
  }

  public static Account createAccount(String recordTypeId, String name){
    Account acc = createAccount();
    acc.RecordTypeId = recordTypeId;
    acc.Activo__c = true;
    acc.Name = name;
    acc.ID_Homeserve__c = name;
    return acc;
  }

  public static Contact createContact(Account acc){
    Contact c = createContact();
    c.AccountId = acc.Id;
    c.HasOptedOutOfFax = false;
    c.HasOptedOutOfEmail = false;
    c.DoNotCall = false;
    return c;
  }

  public static OperatingHours createOperatingHours(String name){ 
    OperatingHours oh = new OperatingHours(
      Name = name
    );
    return oh;
  }

  public static ServiceTerritory createServiceTerritory(String name,String operatingHoursId){ 
    ServiceTerritory st = new ServiceTerritory(
      Name = name
      ,OperatingHoursId = operatingHoursId
      ,IsActive = true
    );
    return st;
  }

  public static ServiceTerritoryMember createServiceTerritoryMember (String stId, String srId, String ohId){ 
    ServiceTerritoryMember stm = new ServiceTerritoryMember();
    stm.ServiceTerritoryId = stId;
    stm.ServiceResourceId = srId;
    stm.OperatingHoursId = ohId;
    stm.EffectiveStartDate = datetime.NOW();
    return stm;
  }

  public static Worktype createWorkType(){
    return createWorkType(true);
  }

  public static Worktype createWorkType(Boolean autoServiceAppointment){
    WorkType wt = new WorkType(
      Name = 'Test'
      ,EstimatedDuration = 60
      ,DurationType= 'Minutes'
      ,ShouldAutoCreateSvcAppt = autoServiceAppointment
      ,FSL__Due_Date_Offset__c = null
      ,FSL__Exact_Appointments__c = false
    );
    return wt;
  }

  public static Gremio__c createGuild(String name){
    Gremio__c guild = new Gremio__c(
      Name = name
      ,Nombre_Skill__c = name
    );
    return guild;
  }

  public static WorkOrder createWorkOrder(){
    WorkOrder wo = new WorkOrder();
    return wo;
  }

  public static WorkOrder createWorkOrder(String gremio, String accountId, String contact){
    WorkOrder wo = (WorkOrder)S4GSmartFactory.createSObject('WorkOrder'); 
    wo.AccountId = accountId;
    wo.Gremio__c = gremio;
    return wo;
  }

  public static ServiceAppointment createServiceAppointment(String parentRecordId){
    return new ServiceAppointment(
      EarliestStartTime =  Datetime.now()
      ,DueDate = Datetime.now().addDays(2)
      ,ParentRecordId = parentRecordId
      //,Status = 'Ninguno'
    );
  }

  public static ServiceAppointment createServiceAppointment(String parentRecordId, String Status){
    return new ServiceAppointment(
      EarliestStartTime =  Datetime.now()
      ,DueDate = Datetime.now().addDays(2)
      ,ParentRecordId = parentRecordId
      ,Status = Status
    );
  }

  public static User createUser(String profileId, String id){
		User u = new user();
		u.LastName = 'Test Code';
		u.Email = 'test@test.com';
		u.Alias = id;
		u.Username =  id + 'test123454@test.com';
		u.CommunityNickname = 'test12'+id;
		u.LocaleSidKey = 'en_US';
		u.TimeZoneSidKey = 'GMT';
	  u.ProfileID = profileId;
		u.LanguageLocaleKey = 'en_US';
		u.EmailEncodingKey = 'UTF-8';
		return u;
	}


  public static ServiceResource createServiceResource(String accId, String userId, String type){
    ServiceResource sr = new ServiceResource();
    sr.Name = 'Test' + userId;
    sr.AccountId = accId;
    sr.RelatedRecordId = userId;
    sr.isActive = true;
    sr.ResourceType = type;
    return sr; 
  }

  public static ResourcePreference createResourcePreference(String accId, String srId, String type){
    ResourcePreference rp = new ResourcePreference();
    rp.ServiceResourceId = srId;
    rp.RelatedRecordId = accId;
    rp.PreferenceType = type;
    return rp;
  }

  public static Case createCase(){
    return (Case)S4GSmartFactory.createSObject('Case');
  }

  public static Case createCase(String accId, String compania){
    Case c = createCase();
    c.AccountId = accId;
    c.Compania__c = compania;
    c.isEscalated = false;
    return c;
  }

  public static OperatingHours createOperatingHours(){
    OperatingHours oh = new OperatingHours();
		oh.Name = 'Horario por defecto';
		oh.TimeZone = 'Europe/Paris';
		return oh;
  }

  public static ServiceResourceSkill createServiceResourceSkill (String skillId, String srId){ 
    ServiceResourceSkill srs = new ServiceResourceSkill();
    srs.SkillId = skillId;
    srs.ServiceResourceId = srId;
    srs.EffectiveStartDate = Datetime.now();
    srs.EffectiveEndDate = Datetime.now().addDays(2);
    return srs;
  }

  public static Gremio_Service_Resource__c createGremioServiceResource(){
    return (Gremio_Service_Resource__c)S4GSmartFactory.createSObject('Gremio_Service_Resource__c');
  }
  
  public static Gremio_Service_Resource__c createGremioServiceResource (String guildId, String srId){ 
    Gremio_Service_Resource__c gsr = createGremioServiceResource();
    gsr.Gremio__c= guildId;
    gsr.Service_Resource__c= srId;
    return gsr;
  }

  public static Gremio_Settings__c createGremioSettings(String accId, String gremioId){
    return new Gremio_Settings__c(
      //GremioRelated__c = gremioId,
      PR__c = accId,
      Limite_Servicios_Mes__c = 10 
    );
  }

  public static AssignedResource createAssignedResource (String ServiceAppointmentId, String ServiceResourceId){ 
    AssignedResource ar = new AssignedResource();
    ar.ServiceResourceId = ServiceResourceId;
    ar.ServiceAppointmentId = ServiceAppointmentId;
    return ar;
  }

}