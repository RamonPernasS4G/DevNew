/**
 * @File Name          : WorkOrderTriggerTest.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 11/10/2019 13:28:57
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   ismael.ocana@s4g.es     Initial Version
**/
@isTest
global with sharing class WorkOrderTriggerTest {

    private static final String COMPANY_RT = 'Compania';
    private static final String ACCOUNT_OBJ = 'Account';
    private static final String PR = 'PR';
    private static final String SR = 'SR';
    private static final String EXCLUDED = 'Excluded';
    private static final String RESOURCETYPE = 'T';
    private static final String CLIENTE_RT = 'Cliente';
    
    @TestSetup
    static void createData(){

        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<User> userList = new List<User>();
        List<ServiceResource> sResourceList = new List<ServiceResource>();
        List<ResourcePreference> rpList = new List<ResourcePreference>();

        String profId = (String)UserInfo.getProfileId();
        //WorkType needed in the WorkOrder
        WorkType wt = S4GTestFactory.createWorkType(true);
        insert wt;

        OperatingHours oh = S4GTestFactory.createOperatingHours();
        insert oh;

        String companyRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, COMPANY_RT);
        String prRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, PR);
        String clienteRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, CLIENTE_RT);
        
        //Company
        Account accCompany = S4GTestFactory.createAccount(companyRTId, COMPANY_RT);
        accCompany.operatingHoursId = oh.Id;
        //PR Account
        Account accPR = S4GTestFactory.createAccount(prRTId, PR);
        //Client Account
        Account accClient = S4GTestFactory.createAccount(clienteRTId, CLIENTE_RT);
        accList.add(accCompany);
        accList.add(accPR);
        accList.add(accClient);

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

        for(ServiceResource sr : sResourceList){
            rpList.add(S4GTestFactory.createResourcePreference((String)accCompany.Id, (String)sr.Id, EXCLUDED));
        }

        insert rpList;

        Case c = S4GTestFactory.createCase((String)accClient.Id, (String)accCompany.Id);
        insert c;
    }

    @isTest
    global static void checkCopyResourcePreferencesOK(){

        Case c = [SELECT id, Compania__c FROM Case LIMIT 1];
        WorkOrder wo = S4GTestFactory.createWorkOrder();
        wo.CaseId = c.Id;

        Test.startTest();
            insert wo;  
        Test.stopTest();

        List<ResourcePreference> rpCompany = [SELECT id FROM ResourcePreference WHERE RelatedRecordId = :c.Compania__c];
        List<ResourcePreference> rpWO = [SELECT id FROM ResourcePreference WHERE RelatedRecordId = :wo.Id];

        System.assertEquals(rpCompany.size(), rpWO.size(), 'RP Company Size is ' + rpCompany.size() + ' vs ' + rpWO.size() + ' RP Work Order');
    }

    @isTest
    global static void checkCopyResourcePreferencesKO(){

        Case c = [SELECT id, Compania__c FROM Case LIMIT 1];
        WorkOrder wo = S4GTestFactory.createWorkOrder();
        wo.CaseId = c.Id;

        ServiceResource sr = [SELECT id, isActive FROM ServiceResource LIMIT 1];
        sr.isActive = false;
        update sr;

        Test.startTest();
            try{
                insert wo;  
            }catch(Exception e){
                System.debug('Exception ' + e);
                System.assert(e.getMessage().contains('Ha habido un problema insertando los Recursos Preferidos.'), 'Error desconocido.');
            }
            
        Test.stopTest();
    }

    @isTest
    global static void checkCopyOperatingHours(){

        Case c = [SELECT id, Compania__c FROM Case LIMIT 1];
        WorkOrder wo = S4GTestFactory.createWorkOrder();
        wo.CaseId = c.Id;

        Test.startTest();
            insert wo;  
        Test.stopTest();

        Account company = [SELECT id, OperatingHoursId FROM Account WHERE id = :c.Compania__c];
        wo = [SELECT id, FSL__VisitingHours__c FROM WorkOrder WHERE id = :wo.Id];

        System.assertEquals(company.OperatingHoursId, wo.FSL__VisitingHours__c, 'Operating Hours are not the same: ' + company.OperatingHoursId + ' vs ' + wo.FSL__VisitingHours__c);
    }
}