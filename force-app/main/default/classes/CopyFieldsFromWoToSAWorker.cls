/**
 * @File Name          : CopyFieldsFromWoToSAWorker.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 21/10/2019 10:19:14
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    17/10/2019   ismael.ocana@s4g.es     Initial Version
**/
global with sharing class CopyFieldsFromWoToSAWorker extends s4gwk.AbstractWorker{


    final String DOT = '.';
    Map<Id, WorkOrder> workOrderByIdsMap;
    Set<WorkOrder_Fields_to_Copy__mdt> woFieldsSet = new Set<WorkOrder_Fields_to_Copy__mdt>();

    global CopyFieldsFromWoToSAWorker() {
        super(String.valueOf(CopyFieldsFromWoToSAWorker.class)); 
    }

    global override void bulkBeforeInsert(List<SObject> newRecords) {
        prepareData();
    }

    global override void beforeInsert(SObject so){
        copyFields((ServiceAppointment) so);
    }


    /** PRIVATE METHODS **/

    private void prepareData(){
        List<String> fieldList = new List<String>();
        List<String> parentList = new List<String>();
        Set<String> parentRecordIdsSet = new Set<String>();
        Set<String> fieldSet = new Set<String>();
        String query = '';

        for(WorkOrder_Fields_to_Copy__mdt wof : [SELECT Work_Order_Field__c, Service_Appointment_Field__c FROM WorkOrder_Fields_to_Copy__mdt WHERE Active__c = true]){
            woFieldsSet.add(wof);
            fieldSet.add(wof.Work_Order_Field__c);
        }
        for(ServiceAppointment sa : (List<ServiceAppointment>)newRecords){
            parentRecordIdsSet.add(sa.ParentRecordId);
        }

        fieldList.addAll(fieldSet);
        parentList.addAll(parentRecordIdsSet);
        query = generateQuery(fieldList, parentList);
        workOrderByIdsMap = new Map<Id,WorkOrder>((List<WorkOrder>)Database.query(query));

    }

    private void copyFields(ServiceAppointment sa){
        WorkOrder wo;
        if(!woFieldsSet.isEmpty() && !workOrderByIdsMap.isEmpty() && workOrderByIdsMap.containsKey(sa.ParentRecordId)){
            wo = workOrderByIdsMap.get(sa.ParentRecordId);
            copyFields(sa, wo);
        }
    }

    private void copyFields(ServiceAppointment sa, WorkOrder wo){
        Object woField;
        for(WorkOrder_Fields_to_Copy__mdt wof : woFieldsSet){
            woField = S4GUtils.getFieldValue((SObject)wo, wof.Work_Order_Field__c);
            if(woField != null){
                sa.put(wof.Service_Appointment_Field__c, woField);
            }
            
        }
    }

    private String generateQuery(List<String> fieldList, List<String> parentList){
        String querySelect = 'SELECT ';
        String queryFrom = ' FROM WorkOrder ';
        String queryWhere = ' WHERE ID IN :parentList'; 

        return querySelect + String.join(fieldList, ',') + ' ' + queryFrom + queryWhere;
    }
}