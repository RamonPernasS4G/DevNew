/**
 * @File Name          : CopyFieldsFromWoToSAWorkerTest.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 21/10/2019 9:28:32
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    17/10/2019   ismael.ocana@s4g.es     Initial Version
**/
@isTest
public with sharing class CopyFieldsFromWoToSAWorkerTest {

    private static final String COMPANY_RT = 'Compania';
    private static final String ACCOUNT_OBJ = 'Account';
    private static final String PR = 'PR';
    private static final String SR = 'SR';
    private static final String EXCLUDED = 'Excluded';
    private static final String RESOURCETYPE = 'T';
    private static final String CLIENTE_RT = 'Cliente';

    @TestSetup
    public static void createSetup(){

        Gremio__c gremio = S4GTestFactory.createGuild('test');
        insert gremio;

        List<Account> accList = new List<Account>();

        String profId = (String)UserInfo.getProfileId();
        //WorkType needed in the WorkOrder
        WorkType wt = S4GTestFactory.createWorkType(false);
        insert wt;

        OperatingHours oh = S4GTestFactory.createOperatingHours();
        insert oh;

        String companyRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, COMPANY_RT);
        String prRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, PR);
        String clienteRTId = S4GUtils.getRecordTypeIdByDeveloperName(ACCOUNT_OBJ, CLIENTE_RT);
        
        //Company
        Account accCompany = S4GTestFactory.createAccount(companyRTId, COMPANY_RT);
        accCompany.operatingHoursId = oh.Id;
        //Client Account
        Account accClient = S4GTestFactory.createAccount(clienteRTId, CLIENTE_RT);
        accList.add(accCompany);
        accList.add(accClient);

        insert accList;

        Contact con = S4GTestFactory.createContact(accClient);
        insert con;

        Case c = S4GTestFactory.createCase((String)accClient.Id, (String)accCompany.Id);
        c.Urgente__c = true;
        insert c;
        //String gremio, String companyId, String accountId, String contact
        WorkOrder wo = S4GTestFactory.createWorkOrder((String) gremio.Id, (String)accClient.Id, (String) con.Id);
        wo.CaseId = c.Id;
        insert wo;
    }

    @IsTest
    public static void testCopyFieldsFromWO(){

        WorkOrder wo = [SELECT id, Gremio__c, Case.Urgente__c, Case.Compania__r.Name FROM WorkOrder LIMIT 1];
        
        ServiceAppointment sa = S4GTestFactory.createServiceAppointment((String)wo.Id);

        Test.startTest();
            insert sa;
        Test.stopTest();
        
        sa = [SELECT Id, Urgente__c, Gremio__c, Description FROM ServiceAppointment WHERE id =:sa.Id];

        System.assertEquals(wo.Gremio__c, sa.Gremio__c, 'Los gremios son distintos WO gremio ' + wo.Gremio__c + ' SA Gremio ' + sa.Gremio__c);
        System.assertEquals(wo.Case.Urgente__c, sa.Urgente__c, 'SA no tiene la misma urgencia que Case Urgente ' + wo.Case.Urgente__c + ' SA Urgente ' + sa.Urgente__c);
    }
}