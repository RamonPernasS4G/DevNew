/**
 * @File Name          : CopyGuildOnSArFromWO.cls
 * @Description        : 
 * @Author             : daniel.vazquez@s4g.es
 * @Group              : 
 * @Last Modified By   : daniel.vazquez@s4g.es
 * @Last Modified On   : 10/16/2019, 12:56:47 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/10/2019   daniel.vazquez@s4g.es     Initial Version
**/
global with sharing class CopyGuildOnSArFromWO extends s4gwk.AbstractWorker{
    Map<String, String> guildByWoMap = new map <String, String>();
    Set<String> woBySaSet = new set<String>();
    public CopyGuildOnSArFromWO() {
            super(String.valueOf(CopyGuildOnSArFromWO.class));
    }
    public override void bulkBeforeInsert(List<SObject> newRecords){
        for(ServiceAppointment sa : (List<ServiceAppointment>)newRecords){
            woBySaSet.add(sa.ParentRecordId);
        }
        for(WorkOrder wo : [SELECT id, Gremio__c FROM WorkOrder WHERE ID IN: woBySaSet]){
            guildByWoMap.put(wo.id , wo.Gremio__c);
        }
       
    }

    public override void beforeInsert(SObject so) {
        actualizeGuild((ServiceAppointment)so);
    }

    private void actualizeGuild(ServiceAppointment sa){
        if(!guildByWoMap.isEmpty()){
            //sa.GremioRelated__c = guildByWoMap.get(sa.ParentRecordId); 
        }
    }
}