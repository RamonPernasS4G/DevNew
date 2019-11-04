/**
 * @File Name          : ServiceResourceSkill.trigger
 * @Description        : 
 * @Author             : Andoni
 * @Group              : 
 * @Last Modified By   : Andoni
 * @Last Modified On   : 11/10/2019 16:03:55
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   Andoni     Initial Version
**/
@istest
public with sharing class ServiceResourceSkillCopyTest {

    @TestSetup 
    static void prepareData(){
        Account ac = S4GTestFactory.createAccount();
        insert ac;

        User u = S4GTestFactory.createUser(S4GUtils.getProfileIdByProfileName('Administrador del sistema') , '1234');
        insert u;

        Gremio__c guild = S4GTestFactory.createGuild('S4GTest');
        insert guild;

        Gremio__c guild2 = S4GTestFactory.createGuild('S4GTest2');
        insert guild2;

        ServiceResource sr = S4GTestFactory.createServiceResource(ac.id , u.id,' ');
        insert sr;

        Skill skillobj =[SELECT id FROM Skill WHERE DeveloperName = 'S4GTest'];
        ServiceResourceSkill srs = S4GTestFactory.createServiceResourceSkill(skillobj.id , sr.id);
        insert srs;

    }

    @isTest static void testCreateGremioSR(){
        Skill skillobj =[SELECT id FROM Skill WHERE DeveloperName = 'S4GTest2'];
        ServiceResource sr = [SELECT id FROM ServiceResource LIMIT 1];
        Test.startTest();
            ServiceResourceSkill srs = S4GTestFactory.createServiceResourceSkill(skillobj.id , sr.id);
            insert srs;
        Test.stopTest();
        List <Gremio_Service_Resource__c> gsrList = [SELECT id FROM Gremio_Service_Resource__c];
        //System.debug('-------> '+gsrList);
        System.assertEquals(2, gsrList.size(),'Service appointment guild is diferent that the expeted');
    }


     @isTest static void testDeleteGremioSR(){
        
        ServiceResourceSkill srs = [SELECT id FROM ServiceResourceSkill LIMIT 1];
        Test.startTest();
            delete srs;
        Test.stopTest();
        List <Gremio_Service_Resource__c> gsrList = [SELECT id FROM Gremio_Service_Resource__c];
        System.assertEquals(0, gsrList.size(),'Service appointment guild is diferent that the expeted');
    }
}