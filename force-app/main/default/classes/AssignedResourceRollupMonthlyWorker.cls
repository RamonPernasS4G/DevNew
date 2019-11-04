/**
 * @File Name          : AssignedResourceRollupMonthlyWorker.cls
 * @Description        : Recalculates the WorkOrders number by PR Account and Guild in the current month.
 * @Author             : Ramón P.
 * @Last Modified By   : Ramón P.
 * @Last Modified On   : 29/10/2019 16:59:57
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    18/10/2019   Ramón P.     Initial Version
**/
global without sharing class AssignedResourceRollupMonthlyWorker extends s4gwk.AbstractWorker {

    List<Gremio_Settings__c> gremiosConfig = new List<Gremio_Settings__c>();
    private static Map<String,Map<String,List<String>>> workOrderCountByAccountAndGuild;
    private static List<Gremio_Settings__c> gremiosSettingsToUpdate = new List<Gremio_Settings__c>();

    global AssignedResourceRollupMonthlyWorker() {
        super(String.valueOf(AssignedResourceRollupMonthlyWorker.class));
        System.debug('AssignedResourceRollupMonthlyWorker');
    }

    global override void bulkAfterInsert(List<SObject> newRecords) {
        prepareData(newRecordsMap.keySet());
    }

    global override void bulkBeforeDelete(List<SObject> oldRecords){
        prepareData(oldRecordsMap.keySet());
    }

    public override void andFinallyAfter(){
        if((Trigger.isInsert || Trigger.isDelete) && !gremiosConfig.isEmpty()){
            // Update the Gremio_Settings__c record.
            updateGremioSettings();
        }
        workOrderCountByAccountAndGuild = new Map<String,Map<String,List<String>>>();
        gremiosSettingsToUpdate = new List<Gremio_Settings__c>();
    }


    private void prepareData(Set<Id> assignedResourcesIds){
        
        //Service appointments ids related to Assigned resource
        Set<Id> prAccounts = new Set<Id>();
        //Service Resources ids related to Assigned resource
        Set<Id> guilds = new Set<Id>();
 
        //Gets the PR Accounts and Guilds related to AssignedResources in trigger
        List<AssignedResource> assignedReourcesToCheck = [SELECT Id, ServiceAppointmentId, ServiceResourceId, 
                                                             ServiceAppointment.ParentRecordId, ServiceResource.AccountId,
                                                             ServiceAppointment.Gremio__c, CreatedDate
                                                          FROM AssignedResource
                                                          WHERE Id IN :assignedResourcesIds];

        for(AssignedResource ar : assignedReourcesToCheck){
            prAccounts.add(ar.ServiceResource.AccountId);
            guilds.add(ar.ServiceAppointment.Gremio__c);
        }

        //Get the related GremioSettings records related to PR Accounts and Guilds
        gremiosConfig = [SELECT Id, PR__c, Gremio__c, Limite_Servicios_Mes__c, ServiciosCursoMes__c
                         FROM Gremio_Settings__c 
                         WHERE Gremio__c IN :guilds 
                            AND PR__c IN :prAccounts];

        //Counts the number of WorkOrders by PR Account and Guild.(workOrderCountByAccountAndGuild)
        getWorkOrdersByGuildAndPRAccount(prAccounts, guilds);
    }


    /*
    * Counts the number of WorkOrders assigned this month by PR Account and Guild.
    */
    private void getWorkOrdersByGuildAndPRAccount(Set<Id> accountPRIds, Set<Id> guildsIds){
        //Gets the AssignedResources created this month by PR Account and Guild.
        List<AssignedResource> assignedResourcesTotal = [SELECT Id, ServiceAppointmentId, ServiceResourceId, 
                                                                ServiceAppointment.ParentRecordId, ServiceResource.AccountId,
                                                                ServiceAppointment.Gremio__c, CreatedDate
                                                        FROM AssignedResource
                                                        WHERE ServiceResource.AccountId IN :accountPRIds
                                                          AND ServiceAppointment.Gremio__c IN :guildsIds
                                                          AND CreatedDate = THIS_MONTH];

        //Checks if an AssignedResources created this month have been counted in a previous month.
        //by another AssignerResource from the same workorder. 
        Set<AssignedResource> assignedResourcesToCount = checkOldAssignedResource(assignedResourcesTotal);
        
        //Counts the number os WorkOrders by PR Account and Guild assigned this month.
        countWorkOrdersByPRAccountAndGuild(assignedResourcesToCount);
        
    }

    /*
    * Checks if the AssignedResources have been counted in a previous month.
    * Returns the AssignedResources by PRAccount and Guild not counted in a previous month.
    */
    private Set<AssignedResource> checkOldAssignedResource(List<AssignedResource> assignedResourcesToCheck){
        
        Set<AssignedResource> assignedResourcesResult = new Set<AssignedResource>();
        Set<Id> workOrdersIds = new Set<Id>();
        Boolean counted;

        for(AssignedResource ar : assignedResourcesToCheck){
            workOrdersIds.add(ar.ServiceAppointment.ParentRecordId);
        }
        //Get the all the AssignedResources from workorders related to AssignedResources created this month.
        List<AssignedResource> siblingsAssignedResources = [SELECT Id, ServiceAppointmentId, ServiceResourceId, CreatedDate,
                                                                ServiceAppointment.ParentRecordId, ServiceResource.AccountId
                                                             FROM AssignedResource   
                                                             WHERE ServiceAppointment.ParentRecordId IN :workOrdersIds];

        //If an AssignedResource created this month, have another AssignedResource created in a previous month
        //with the same related workorder, we wont count it. The work order have been counted in a previous month.
        for(AssignedResource ar : assignedResourcesToCheck){
            counted = false;
            for(AssignedResource siblingAr : siblingsAssignedResources){
                if(ar.ServiceAppointment.ParentRecordId == siblingAr.ServiceAppointment.ParentRecordId &&
                    (siblingAr.CreatedDate.month() < ar.CreatedDate.month() || siblingAr.CreatedDate.year() < ar.CreatedDate.year())){
                        counted = true;                        
                } 
            }
            if(!counted){
                assignedResourcesResult.add(ar);
            }
        }

        return assignedResourcesResult;
    }


    /*
    * Counts the number of WorkOrders by PR Account and Guild assigned this month.
    */
    private void countWorkOrdersByPRAccountAndGuild(Set<AssignedResource> assignedResources){
        for(AssignedResource ar : assignedResources){
            if(!workOrderCountByAccountAndGuild.containsKey(ar.ServiceResource.AccountId)){
                Map<String,List<String>> gremioCount = new Map<String,List<String>>();
                workOrderCountByAccountAndGuild.put(ar.ServiceResource.AccountId, gremioCount);
            }
            if(!workOrderCountByAccountAndGuild.get(ar.ServiceResource.AccountId).containsKey(ar.ServiceAppointment.Gremio__c)){
                List<String> workordersIds = new List<String>();
                //If the AssignedResource is being deleted, we wont count it.
                if(!Trigger.isDelete || (Trigger.isDelete && !oldRecordsMap.containsKey(ar.Id))){
                    workordersIds.add(ar.ServiceAppointment.ParentRecordId);
                }
                workOrderCountByAccountAndGuild.get(ar.ServiceResource.AccountId).put(ar.ServiceAppointment.Gremio__c, workordersIds);
            }else{
                //If the AssignedResource is being deleted, we wont count it.
                if(!Trigger.isDelete || (Trigger.isDelete && !oldRecordsMap.containsKey(ar.Id))){
                    if(!workOrderCountByAccountAndGuild.get(ar.ServiceResource.AccountId).get(ar.ServiceAppointment.Gremio__c).contains(ar.ServiceAppointment.ParentRecordId) ){
                        workOrderCountByAccountAndGuild.get(ar.ServiceResource.AccountId).get(ar.ServiceAppointment.Gremio__c).add(ar.ServiceAppointment.ParentRecordId);
                    }
                }
            }
        }
    }

    /*
    * Updates the GremioSettings records recalculated.
    */
    private void updateGremioSettings(){
        
        for(Gremio_Settings__c gremioSetting : gremiosConfig){
            if(workOrderCountByAccountAndGuild.containsKey(gremioSetting.PR__c) 
               && workOrderCountByAccountAndGuild.get(gremioSetting.PR__c).containsKey(gremioSetting.Gremio__c)
               && gremioSetting.ServiciosCursoMes__c != workOrderCountByAccountAndGuild.get(gremioSetting.PR__c).get(gremioSetting.Gremio__c).size()){
                    gremioSetting.ServiciosCursoMes__c = workOrderCountByAccountAndGuild.get(gremioSetting.PR__c).get(gremioSetting.Gremio__c).size();
                    gremiosSettingsToUpdate.add(gremioSetting);
            } 
        }
        if(!gremiosSettingsToUpdate.isEmpty()){
            update gremiosSettingsToUpdate;
        }
    }

}