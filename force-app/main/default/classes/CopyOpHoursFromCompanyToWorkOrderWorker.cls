/**
 * @File Name          : CopyOpHoursFromCompanyToWorkOrderWorker.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 14/10/2019 10:13:08
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   ismael.ocana@s4g.es     Initial Version
**/
global with sharing class CopyOpHoursFromCompanyToWorkOrderWorker extends s4gwk.AbstractWorker{

    private static Map<String,String> operatingHoursByCaseMap;

    global CopyOpHoursFromCompanyToWorkOrderWorker() {
        super(String.valueOf(CopyOpHoursFromCompanyToWorkOrderWorker.class));
    }

    global override void bulkBeforeInsert(List<SObject> newRecords) {
        prepareData();
    }

    global override void beforeInsert(SObject so) {
        WorkOrder wo = (WorkOrder)so;

        copyOperatingHours(wo);
    }


    private void prepareData(){
        operatingHoursByCaseMap = new Map<String,String>();

        String [] caseIdsList = new List<String>();

        for(WorkOrder wo : (List<WorkOrder>)newRecords){
            caseIdsList.add(wo.CaseId);
        }

        for(Case c : WorkOrderUtils.getRelatedCases(caseIdsList)){
            operatingHoursByCaseMap.put(c.Id, c.Compania__r.OperatingHoursId);
        }
    }

    private void copyOperatingHours(WorkOrder wo){
        if(chechIfCopy(wo.CaseId)){
            wo.FSL__VisitingHours__c = operatingHoursByCaseMap.get(wo.CaseId);
        }
    }

    private Boolean chechIfCopy(String caseId){
        return String.isNotBlank(caseId) && !operatingHoursByCaseMap.isEmpty() && operatingHoursByCaseMap.containsKey(caseId);
    }

}