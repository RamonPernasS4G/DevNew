/**
 * @File Name          : WorkOrderUtils.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 14/10/2019 10:42:29
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   ismael.ocana@s4g.es     Initial Version
**/
public with sharing class WorkOrderUtils {
    public static List<Case> relatedCases = new List<Case>();

    public static List<Case> getRelatedCases(String[] caseIds){
        if(relatedCases.isEmpty() && !caseIds.isEmpty()){
            relatedCases = [SELECT id, Compania__c, Compania__r.OperatingHoursId FROM Case WHERE id IN :caseIds];
        }
        return relatedCases;
    }
}