/**
 * @File Name          : ServiceResourceSkillCopy.cls
 * @Description        : 
 * @Author             : Andoni
 * @Group              : 
 * @Last Modified By   : Andoni 
 * @Last Modified On   : 11/10/2019 13:11:09
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   Andoni     Initial Version
**/
global with sharing class ServiceResourceSkillCopy extends s4gwk.AbstractWorker {

    //public List<ServiceResourceSkill> serviceResourceSkills = [SELECT Id FROM ServiceResourceSkill];
    Map<String, String> skillBSrSkillMap = new Map <String, String>();
    Map<String, String> serviceResBySrSkillMap = new Map <String, String>();
    Map<String,String> nameByskillIdMap = new Map<String,String>();
    Map<String,String> nameByGuildMap = new Map<String,String>();
    Set<String> skillIdSet = new Set<String>();
    Set<String> srSet = new Set<String>();
    List<Gremio_service_resource__c> guildSerResInsertList = new List<Gremio_service_resource__c>();
    List<Gremio_service_resource__c> guildSerResDeleteList = new List<Gremio_service_resource__c>();

    public ServiceResourceSkillCopy() {
        super(String.valueOf(ServiceResourceSkillCopy.class));
    }

    public override void bulkAfterInsert(List<SObject> newRecords){
        completeInsertMaps((List<ServiceResourceSkill>) newRecords);
    }

    public override void bulkAfterDelete(List<SObject> newRecords){
        completeInsertMaps((List<ServiceResourceSkill>) newRecords);
    }


    public override void afterInsert(SObject so) {
        createGuildSerRes((ServiceResourceSkill)so);
    } 

    public override void afterDelete(SObject so) {
        deleteGuildSerRes((ServiceResourceSkill)so);
    } 

    public override void andFinallyAfter() {
        guildSerResListIsInsert((List<Gremio_service_resource__c>)guildSerResInsertList);
        guildSerResListIsDelete((List<Gremio_service_resource__c>)guildSerResDeleteList);

    }

    private void completeInsertMaps(List<ServiceResourceSkill> newRecords){
        for(ServiceResourceSkill srs : (List<ServiceResourceSkill>)newRecords){
            skillIdSet.add(srs.SkillId);
        }
        for(Skill s : [SELECT id, DeveloperName FROM Skill WHERE id IN: skillIdSet]){
            nameByskillIdMap.put(s.id, s.DeveloperName);
        }
        for(Gremio__c g: [SELECT id, Name FROM Gremio__c WHERE name IN: nameByskillIdMap.values()]){
            nameByGuildMap.put(g.name, g.id);
        }
        System.debug('------> '+newRecords);
    }

    private void createGuildSerRes(ServiceResourceSkill srs){
        Gremio_service_resource__c gsr = createGremioServiceResource();
        String skillName = nameByskillIdMap.get(srs.Skillid);
        gsr.gremio__c = nameByGuildMap.get(skillName);
        gsr.service_resource__c = srs.ServiceResourceId;
        guildSerResInsertList.add(gsr);
    }

    private void deleteGuildSerRes(ServiceResourceSkill srs){
        for(Gremio_service_resource__c gsr :[SELECT id, Service_Resource__c FROM Gremio_service_resource__c WHERE Service_Resource__c =: srs.ServiceResourceId]){
            guildSerResDeleteList.add(gsr);
            
        }
    }


    private Gremio_service_resource__c createGremioServiceResource(){
        Gremio_service_resource__c gsr = new Gremio_service_resource__c();
        return gsr;
    }
    
    private void guildSerResListIsInsert (List<Gremio_service_resource__c> gsrl){
        if(!gsrl.isEmpty()){
            insert gsrl;
        }
    }

    private void guildSerResListIsDelete (List<Gremio_service_resource__c> gsrl){
        if(!gsrl.isEmpty()){
            delete gsrl;
        }
    }
}