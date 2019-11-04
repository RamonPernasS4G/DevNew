/**
 * @File Name          : CopyRPrefrenceToWorkOrderWorker.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 16/10/2019 10:13:03
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   ismael.ocana@s4g.es     Initial Version
**/
global with sharing class CopyRPrefrenceToWorkOrderWorker extends s4gwk.AbstractWorker{

    private static Map<String, String> companyIdByCaseIdMap; 

    private static Map<String, List<ResourcePreference>> resourcePreferenceListByCompanyIdMap; 

    private static List<ResourcePreference> rpList;


    global CopyRPrefrenceToWorkOrderWorker() {
        super(String.valueOf(CopyRPrefrenceToWorkOrderWorker.class));
    }

    global override void bulkAfterInsert(List<SObject> newRecords){
        prepareData((List<WorkOrder>)newRecords);
    }

    global override void afterInsert(SObject so){
        WorkOrder wo = (WorkOrder) so;

        copyResourcePreferences(wo);
    }

    global override void andFinallyAfter() {
        if(Trigger.isInsert){
            insertResourcePreferences();
        }
    }

    /** PRIVATE METHODS **/

    private void prepareData(List<WorkOrder> woList){
        String [] caseIdsList = new List<String>();

        rpList = new List<ResourcePreference>();

        companyIdByCaseIdMap = new Map<String,String>(); 

        resourcePreferenceListByCompanyIdMap = new Map<String, List<ResourcePreference>>(); 

        for(WorkOrder wo : woList){
            caseIdsList.add(wo.CaseId);
        }
        for(Case c : WorkOrderUtils.getRelatedCases(caseIdsList)){
            companyIdByCaseIdMap.put(c.Id, c.Compania__c);
        }

        for(ResourcePreference rp : [SELECT Id, ServiceResourceId, RelatedRecordId, PreferenceType FROM ResourcePreference WHERE RelatedRecordId IN :companyIdByCaseIdMap.values()]){
            if(!resourcePreferenceListByCompanyIdMap.containsKey(rp.RelatedRecordId)){
                resourcePreferenceListByCompanyIdMap.put(rp.RelatedRecordId, new List<ResourcePreference>());
            }
            resourcePreferenceListByCompanyIdMap.get(rp.RelatedRecordId).add(rp);
        }
    }

    private static Boolean checkIfCopy(WorkOrder wo){
        return (String.isNotBlank(wo.CaseId) && !companyIdByCaseIdMap.isEmpty() && !resourcePreferenceListByCompanyIdMap.isEmpty() 
            && companyIdByCaseIdMap.containsKey(wo.CaseId));
            //&& resourcePreferenceListByCompanyIdMap.containsKey(companyIdByCaseIdMap.get(wo.CaseId)
    }

    private static void copyResourcePreferences(WorkOrder wo){
        if(checkIfCopy(wo)){
            for(ResourcePreference rp : resourcePreferenceListByCompanyIdMap.get(companyIdByCaseIdMap.get(wo.CaseId))){
                rpList.add(copyResourcePreference(wo.Id, rp));
            }
        }
    }

    private static ResourcePreference copyResourcePreference(String woId, ResourcePreference rp){
        ResourcePreference rPreference = rp.Clone(false,false,false,false);
        rPreference.RelatedRecordId = woId;
        return rPreference;
    }

    private static void insertResourcePreferences(){
        if(!rpList.isEmpty()){
            try{
                insert rpList;
            }catch(Exception e){
                throw new S4GUtils.wsException('Ha habido un problema insertando los Recursos Preferidos. ' + e.getMessage());
            }
        }
    }
}