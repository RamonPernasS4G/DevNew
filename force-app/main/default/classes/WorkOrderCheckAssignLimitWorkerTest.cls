/**
 * @File Name          : WorkOrderCheckAssignLimitWorkerTest.cls
 * @Description        : 
 * @Author             : Ramón P.
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 18/10/2019 12:02:38
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   Ramón P.     Initial Version
**/
@istest
public class WorkOrderCheckAssignLimitWorkerTest {

    // private static final String COMPANY_RT = 'Compania';
    // private static final String ACCOUNT_OBJ = 'Account';
    // private static final String PR = 'PR';
    // private static final String SR = 'SR';
    // private static final String RESOURCETYPE = 'T';

    // @TestSetup
    // public static void createData(){
    // List<Account> accList = new List<Account>();
    //     List<Contact> conList = new List<Contact>();
    //     List<User> userList = new List<User>();
    //     List<ServiceResource> sResourceList = new List<ServiceResource>();

    //     String profId = (String)UserInfo.getProfileId();

    //     String companyRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, COMPANY_RT);
    //     String prRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, PR);
        
    //     //Company
    //     Account accCompany = S4GTestFactory.createAccount(companyRTId, COMPANY_RT);
    //     //PR Account
    //     Account accPR = S4GTestFactory.createAccount(prRTId, PR);
    //     accList.add(accCompany);
    //     accList.add(accPR);

    //     insert accList;

    //     //Contacts for the SR and PR Users
    //     Contact prContact = S4GTestFactory.createContact(accPR);
    //     prContact.lastName += PR;
    //     Contact srContact = S4GTestFactory.createContact(accPR);
    //     srContact.lastName += SR;
    //     conList.add(prContact);
    //     conList.add(srContact);
    //     insert conList;

    //     User srUser = S4GTestFactory.createUser(profId, SR);
    //     User prUser = S4GTestFactory.createUser(profId, PR);
    //     userList.add(srUser);
    //     userList.add(prUser);

    //     insert userList;
    
    //     for(User u : userList){
    //         sResourceList.add(S4GTestFactory.createServiceResource((String)accPr.id, (String)u.Id, RESOURCETYPE));
    //     }

    //     insert sResourceList;

    //     //I need the Service Resource per Guild
    //     Gremio__c guild = S4GTestFactory.createGuild('TEST');
    //     insert guild;

    //     Gremio_Settings__c gs = S4GTestFactory.createGremioSettings((String)accPR.Id, (String)guild.Id); 
    //     gs.Limite_Servicios_Mes__c = 1;
    //     gs.ServiciosCursoMes__c = 0;
    //     gs.PR__c = accPR.Id;
    //     gs.Gremio__c = guild.Id;
    //     insert gs;

    //     Gremio_Service_Resource__c gsr = S4GTestFactory.createGremioServiceResource();
    //     gsr.Gremio__c = guild.Id;
    //     gsr.Service_Resource__c = sResourceList[0].Id;
    //     gsr.Fin__c = Datetime.now().addDays(1);
    //     gsr.Inicio__c = Datetime.now().addDays(-1);
    //     gsr.Modificado_por_codigo__c = false;
    //     insert gsr;

    //     WorkOrder wo = S4GTestFactory.createWorkOrder();
    //     wo.Gremio__c = guild.Id;
    //     insert wo;
    //     //wo.CuentaProfesional__c = accPR.Id;
    // }

    // @isTest static void testCheckLimit(){
    //     WorkOrder wo = [SELECT Id, CuentaProfesional__c FROM WorkOrder LIMIT 1];
    //     String prRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, PR);
    //     Account accPR = [SELECT Id FROM Account WHERE RecordTypeId = :prRTId];
    //     Test.startTest();
    //         wo.CuentaProfesional__c = accPR.Id;
    //         update wo;
    //     Test.stopTest();
    // }
    
}