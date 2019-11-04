/**
 * @File Name          : ServiceAppointmentTriggerTest.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : daniel.vazquez@s4g.es
 * @Last Modified On   : 10/16/2019, 12:57:34 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   ismael.ocana@s4g.es     Initial Version
**/
@istest
public with sharing class ServiceAppointmentTriggerTest {
    
    @TestSetup static void prepareEnviroment(){
        WorkType wt = S4GTestFactory.createWorkType(false);
        insert wt;

        Gremio__c guild = S4GTestFactory.createGuild(wt.Name);
        insert guild;

        WorkOrder wo = S4GTestFactory.createWorkOrder();
        wo.Gremio__c = guild.id;
        wo.WorkTypeId = wt.id;
        insert wo;
    }

    @isTest static void testSetGuildToServiceAppointment(){

        WorkOrder wo = [SELECT id FROM WorkOrder LIMIT 1];

        Test.startTest();
            ServiceAppointment sa = S4GTestFactory.createServiceAppointment(wo.Id);
            insert sa;
        Test.stopTest();
        
        Gremio__c guild = [SELECT id,Name FROM Gremio__c LIMIT 1];

        
        //sa = [SELECT Id, GremioRelated__c FROM ServiceAppointment WHERE id =: sa.id];
        //System.assertEquals(guild.id,sa.GremioRelated__c ,'Service appointment guild is diferent that the expeted');


    }

}