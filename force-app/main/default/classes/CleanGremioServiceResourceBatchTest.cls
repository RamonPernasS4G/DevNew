/**
 * @File Name          : CleanGremioServiceResourceBatchTest.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 14/10/2019 13:25:37
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    14/10/2019   ismael.ocana@s4g.es     Initial Version
**/
@isTest
public with sharing class CleanGremioServiceResourceBatchTest {
    
    private static final String COMPANY_RT = 'Compania';
    private static final String ACCOUNT_OBJ = 'Account';
    private static final String PR = 'PR';
    private static final String SR = 'SR';
    private static final String RESOURCETYPE = 'T';

    @TestSetup
    public static void createSetup(){

        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<User> userList = new List<User>();
        List<ServiceResource> sResourceList = new List<ServiceResource>();
        List<Gremio_Service_Resource__c> gsrList = new List<Gremio_Service_Resource__c>();

        String profId = (String)UserInfo.getProfileId();

        String companyRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, COMPANY_RT);
        String prRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, PR);
        
        //Company
        Account accCompany = S4GTestFactory.createAccount(companyRTId, COMPANY_RT);
        //PR Account
        Account accPR = S4GTestFactory.createAccount(prRTId, PR);
        accList.add(accCompany);
        accList.add(accPR);

        insert accList;

        //Contacts for the SR and PR Users
        Contact prContact = S4GTestFactory.createContact(accPR);
        prContact.lastName += PR;
        Contact srContact = S4GTestFactory.createContact(accPR);
        srContact.lastName += SR;
        conList.add(prContact);
        conList.add(srContact);
        insert conList;

        User srUser = S4GTestFactory.createUser(profId, SR);
        User prUser = S4GTestFactory.createUser(profId, PR);
        userList.add(srUser);
        userList.add(prUser);

        insert userList;
    
        for(User u : userList){
            sResourceList.add(S4GTestFactory.createServiceResource((String)accPr.id, (String)u.Id, RESOURCETYPE));
        }

        insert sResourceList;

        //I need the Service Resource per Guild
        Gremio__c guild = S4GTestFactory.createGuild('TEST');
        insert guild;

        for(ServiceResource sr : sResourceList){
            Gremio_Service_Resource__c gsr = S4GTestFactory.createGremioServiceResource((String)guild.Id, (String)sr.Id);
            gsr.Inicio__c = System.now().addMonths(-1);
            gsr.Fin__c = System.now().addDays(-7);
            gsrList.add(gsr);
        }

        insert gsrList;
    }

    @isTest
    public static void testRunBatch(){
        Test.startTest();
			Database.executeBatch(new CleanGremioServiceResourceBatch());
		Test.stopTest();

        List<Gremio_Service_Resource__c> gsrList = [SELECT Id, Inicio__c, Fin__c FROM Gremio_Service_Resource__c WHERE Service_Resource__r.IsActive = true];

        System.debug(gsrList);
        //System.assertEquals();
    }
}