@IsTest
public with sharing class SanboxInitScriptTest {
    @testSetup static void prepareData() {

    }
    @IsTest static void test() {
        SandboxContext context = null;
        SanboxInitScript.runApexClass(context);
        
        List<WorkType> wt = [SELECT id FROM WorkType];
        System.assertEquals(1, wt.size());

        List<SkillRequirement> skillR = [SELECT id FROM SkillRequirement];
        System.assertEquals(1, skillR.size());

        List<OperatingHours> oh = [SELECT id FROM OperatingHours];
        System.assertEquals(1, oh.size());

        List<TimeSlot> ts = [SELECT id FROM TimeSlot];
        System.assertEquals(6, ts.size());

        List<ServiceTerritory> st = [SELECT id FROM ServiceTerritory];
        System.assertEquals(1, st.size());

        List<FSL__Scheduling_Policy__c> sp = [SELECT id FROM FSL__Scheduling_Policy__c];       
        System.assertEquals(2, sp.size());

        List<FSL__Work_Rule__c> wr = [SELECT id FROM FSL__Work_Rule__c];
        System.assertEquals(3, wr.size());

        List<FSL__Service_Goal__c> sg = [SELECT id FROM FSL__Service_Goal__c];
        System.assertEquals(4, sg.size());

        List<Account> acc = [SELECT id FROM Account];
        System.assertEquals(1, acc.size());

        List<ServiceResource> sr = [SELECT id FROM ServiceResource];
        System.assertEquals(1, sr.size());

        List<ServiceTerritoryMember> stm = [SELECT id FROM ServiceTerritoryMember];
        System.assertEquals(1, stm.size());

        List<ServiceResourceSkill> srs = [SELECT id FROM ServiceResourceSkill];
        System.assertEquals(1, srs.size());
    }  
    
}