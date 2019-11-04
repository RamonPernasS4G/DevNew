/**
 * @File Name          : CleanGremioSettingsBatchTest.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 16/10/2019 11:34:54
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   ismael.ocana@s4g.es     Initial Version
**/
@isTest
public with sharing class CleanGremioSettingsBatchTest {

    private static final String COMPANY_RT = 'Compania';
    private static final String ACCOUNT_OBJ = 'Account';
    private static final String PR = 'PR';
    private static final String SR = 'SR';
    private static final String RESOURCETYPE = 'T';

    @TestSetup
    public static void createData(){
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<User> userList = new List<User>();
        List<ServiceResource> sResourceList = new List<ServiceResource>();

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

        Gremio_Settings__c gs = S4GTestFactory.createGremioSettings((String)accPR.Id, (String)guild.Id); 
        insert gs;
    }

    @isTest
    public static void checkBatch(){
        Test.startTest();
			Database.executeBatch(new CleanGremioSettingsBatch());
		Test.stopTest();

        Gremio_Settings__c gs = [SELECT id, Limite_Servicios_Mes__c FROM Gremio_Settings__c LIMIT 1];

        System.assertEquals(0, gs.Limite_Servicios_Mes__c, 'El límite de Servicios no es 0 ' + gs.Limite_Servicios_Mes__c);
    }
}