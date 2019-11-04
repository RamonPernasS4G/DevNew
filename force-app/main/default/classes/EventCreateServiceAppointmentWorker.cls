/**
 * @File Name          : EventCreateServiceAppointmentWorker.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 23/9/2019 11:44:46
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/9/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class EventCreateServiceAppointmentWorker extends s4gwk.AbstractWorker {

    public static Map<String, WorkOrder> woById = new Map<String, WorkOrder>();

    public EventCreateServiceAppointmentWorker() {
        super(String.valueOf(EventCreateServiceAppointmentWorker.class));
    }

    public override void bulkBeforeInsert(List<SObject> newRecords){
        
    }

    private void prepareRelatedWorkOrders(List<Event> newEvents){

    }
}