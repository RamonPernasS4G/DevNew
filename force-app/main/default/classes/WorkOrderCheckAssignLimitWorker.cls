/**
 * @File Name          : WorkOrderCheckAssignLimitWorker.cls
 * @Description        : When Gremio or PR Account fields changes in a Work Order, updates the ServiciosCursoMes__c field 
                         from the Account Gremio_Settings__c.
 * @Author             : Ramón P.
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 18/10/2019 12:02:28
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   Ramón P.     Initial Version
**/
global without sharing class WorkOrderCheckAssignLimitWorker extends s4gwk.AbstractWorker {

    // private static Map<String,Gremio_Settings__c> gremioSettingByWorkOrder = new Map<String,Gremio_Settings__c>();
    // private static Map<String,Map<String,Integer>> gremioCountByAccount= new Map<String,Map<String,Integer>>();
    // private static Map<String,Gremio_Service_Resource__c> gremiosServiceResourceByWorkOrder = new Map<String,Gremio_Service_Resource__c>();
    // private static List<Gremio_Settings__c> gremiosSettingsToUpdate = new List<Gremio_Settings__c>();
    // private static List<String> workOrderIdsToCheck = new List<String>();
    // List<Gremio_Settings__c> gremiosConfig = new List<Gremio_Settings__c>();

    public WorkOrderCheckAssignLimitWorker() {
        super(String.valueOf(WorkOrderCheckAssignLimitWorker.class));
    }

    // public override void bulkAfterUpdate(List<SObject> oldRecords, List<SObject> newRecords){
    //     System.debug('WorkOrderCheckAssignLimitWorker');
    //     prepareData();
    // }

    // public override void andFinallyAfter(){
    //     System.debug('andFinallyAfter: ' + gremiosConfig);
    //     if(Trigger.isUpdate && !gremiosConfig.isEmpty()){
    //         // Update the Gremio_Settings__c record.
    //         for(Gremio_Settings__c gremioSetting : gremiosConfig){
    //             if(gremioCountByAccount.containsKey(gremioSetting.PR__c) && gremioCountByAccount.get(gremioSetting.PR__c).containsKey(gremioSetting.Gremio__c)){
    //                 gremioSetting.ServiciosCursoMes__c = gremioCountByAccount.get(gremioSetting.PR__c).get(gremioSetting.Gremio__c);
    //                 gremiosSettingsToUpdate.add(gremioSetting);
    //             }
    //         }
    //         if(!gremiosSettingsToUpdate.isEmpty()){
    //             update gremiosSettingsToUpdate;
    //         }
    //     }
    // }

    // private void prepareData(){

    //     //PR Account ids related to Work Orders
    //     Set<Id> accountPRIds = new Set<Id>();
    //     //Gremio__c ids related to Work Orders
    //     Set<Id> gremiosIds = new Set<Id>();

    //     List<WorkOrder> oldWorkOrders = (List<WorkOrder>)oldRecords;  
    //     System.debug('oldWorkOrders: ' + oldWorkOrders);  
        
    //     for(WorkOrder newWorkOrder : (List<WorkOrder>)newRecords){
    //         WorkOrder oldWorkOrder = (WorkOrder)oldRecordsMap.get(newWorkOrder.Id);
    //         //If GremioRelacionado__c or CuentaProfesional__c fields changes in a Work Order
    //         //Recalculate the ServiciosCursoMes__c for the Account and Guild in the new and old record.
    //         if((newWorkOrder.CuentaProfesional__c != null && newWorkOrder.CuentaProfesional__c != null)){
    //             accountPRIds.add(newWorkOrder.CuentaProfesional__c);
    //             gremiosIds.add(newWorkOrder.Gremio__c);
    //             if(!workOrderIdsToCheck.contains(newWorkOrder.Id)){
    //                 workOrderIdsToCheck.add(newWorkOrder.Id);
    //             }
    //         }
    //         if(oldWorkOrder.CuentaProfesional__c != null && oldWorkOrder.Gremio__c != null){
    //             accountPRIds.add(oldWorkOrder.CuentaProfesional__c);
    //             gremiosIds.add(oldWorkOrder.Gremio__c);
    //             if(!workOrderIdsToCheck.contains(oldWorkOrder.Id)){
    //                 workOrderIdsToCheck.add(oldWorkOrder.Id);
    //             }
    //         }
    //     }

    //     if(!workOrderIdsToCheck.isEmpty()){
    //         getRelatedData(accountPRIds, gremiosIds);
    //         countWorkOrders(accountPRIds, gremiosIds);
    //     }
    // }

    // private void getRelatedData(Set<Id> accountPRIds, Set<Id> gremiosIds){
    //     //Gremio_Settings__c records related to the Work Orders
    //     gremiosConfig = [SELECT Id, PR__c, Gremio__c, Limite_Servicios_Mes__c, ServiciosCursoMes__c
    //                      FROM Gremio_Settings__c 
    //                      WHERE Gremio__c IN :gremiosIds 
    //                         AND PR__c IN :accountPRIds];

    //     System.debug('gremiosConfig: ' + gremiosConfig);
    // }


    // private void countWorkOrders(Set<Id> accountPRIds, Set<Id> gremiosIds){
    //     //Counts the number of Work Orders by Gremio and by PR Account => gremioCountByAccount
    //     List<WorkOrder> workOrdersByGremioAndAccout = [SELECT Id, Gremio__c, CuentaProfesional__c
    //                                                    FROM WorkOrder
    //                                                    WHERE Gremio__c IN :gremiosIds 
    //                                                      AND CuentaProfesional__c IN :accountPRIds];

    //     for(WorkOrder wo : workOrdersByGremioAndAccout){
    //         if(!gremioCountByAccount.containsKey(wo.CuentaProfesional__c)){
    //             Map<String,Integer> gremioCount = new Map<String,Integer>();
    //             gremioCountByAccount.put(wo.CuentaProfesional__c, gremioCount);
    //         }

    //         if(!gremioCountByAccount.get(wo.CuentaProfesional__c).containsKey(wo.Gremio__c)){
    //             gremioCountByAccount.get(wo.CuentaProfesional__c).put(wo.Gremio__c, 1);
    //         }else{
    //             gremioCountByAccount.get(wo.CuentaProfesional__c).put(wo.Gremio__c, gremioCountByAccount.get(wo.CuentaProfesional__c).get(wo.Gremio__c) + 1);
    //         } 
    //     }
    //     System.debug('gremioCountByAccount: ' + gremioCountByAccount);
    // }

}