/**
 * @File Name          : FullCalendarLWC.cls
 * @Description        : 
 * @Author             : daniel.vazquez@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 10/10/2019 11:41:21
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification    
 * 1.0    30/9/2019   ismael.ocana@s4g.es
**/
public with sharing class FullCalendarLWC {
    @AuraEnabled(cacheable=true)      
    public static eventWithDates getSA(String urgente, String modstamp){
        EventWithDates evt;
        List<EventObj> evtList = new List<EventObj>(); 
        List<ServiceAppointment> saList = null;
        System.debug('urgente ' + urgente);
        if(String.isNotBlank(urgente)){
            Boolean u = Boolean.valueOf(urgente);
            saList = [SELECT ID, AppointmentNumber, SchedStartTime, SchedEndTime, description, ownerId , ParentRecordId , Urgente__c, Status, Tipo_Llamada__c FROM ServiceAppointment WHERE Status != 'Cancelado' AND urgente__c =:u];
        }else{
            saList = [SELECT ID, AppointmentNumber, SchedStartTime, SchedEndTime, description, ownerId , ParentRecordId , Urgente__c, Status, Tipo_Llamada__c FROM ServiceAppointment WHERE Status != 'Cancelado'];
        }
        System.debug('saList ' + saList);
        for(ServiceAppointment sa : saList){
            evtList.add(new EventObj((String) sa.Id, sa.AppointmentNumber, sa.SchedStartTime, sa.SchedEndTime, sa.description, sa.OwnerId, sa.ParentRecordId, sa.Urgente__c, sa.Status, String.valueOf(sa.getSObjectType()), sa.tipo_llamada__c));
        }     
        for(ResourceAbsence ra : [SELECT Id, AbsenceNumber, ResourceId, Type, Start, End FROM ResourceAbsence]){
            evtList.add(new EventObj((String) ra.Id, ra.AbsenceNumber, ra.Start, ra.End, '', '', '', false, ra.Type, String.valueOf(ra.getSObjectType()), false));
        }
        System.debug('evtList ' + evtList);
        evt = new eventWithDates(evtList);
        return evt; 
    } 

    @AuraEnabled
    public static EventObj createObj(String workOrderId, String description, Long ini, Long fin, String objType){
        System.debug('WorkOrder id ' + workOrderId);
        System.debug('description ' + description);
        EventObj evt;
        DateTime dt1 = Datetime.newInstance(ini);
        Datetime dt2 = Datetime.newInstance(fin);

        System.debug('dt1 ' + dt1);
        System.debug('dt2 ' + dt2);
        System.debug('objType ' + objType);
        ServiceResource sr = [SELECT id FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() AND IsActive=true];

        if(String.valueOf(Schema.ServiceAppointment.getSObjectType()) == objType){
            System.debug('in  ' + objType);
            evt = handleServiceAppointment(workOrderId, description, dt1, dt2, sr);
        }else if(String.valueOf(Schema.ResourceAbsence.getSObjectType()) == objType){
            System.debug('in  ' + objType);
            evt = handleResourceAbsence(description, dt1, dt2, sr);
        }
        System.debug('evt  ' + evt);
        return evt;
    }

    public static EventObj handleServiceAppointment(String workOrderId, String description, Datetime ini, Datetime fin , ServiceResource sr){
        EventObj evt;
        if(String.isNotBlank(workOrderId)){
            WorkOrder wo = [SELECT id, Street, City, Country, State, PostalCode, ownerId FROM WorkOrder WHERE id = :workOrderId];
            ServiceAppointment sa = createServiceAppointment(wo, description, ini, fin);
            
            insert sa;
            sa = [SELECT id, AppointmentNumber, SchedStartTime, SchedEndTime, description, urgente__c, tipo_llamada__c, status FROM ServiceAppointment WHERE id = :sa.ID];
            evt = new EventObj((String) sa.Id, sa.AppointmentNumber, sa.SchedStartTime, sa.SchedEndTime, sa.description, (String)wo.OwnerId, (String)wo.Id, sa.Urgente__c, 'Enviado', String.valueOf(sa.getSObjectType()), sa.tipo_llamada__c);
            AssignedResource ar = new AssignedResource(
                ServiceAppointmentId = sa.Id,
                ServiceResourceId = sr.Id
            );
            insert ar;
            updateServiceAppointment(sa.Id, wo.OwnerId);
        }

        return evt;
    }

    public static ServiceAppointment createServiceAppointment(WorkOrder wo, String description, DateTime ini, DateTime fin){
        return new ServiceAppointment(
            parentRecordId = wo.id
            ,EarliestStartTime = ini
            ,DueDate = fin
            ,Street = wo.Street
            ,City = wo.City
            ,Country = wo.Country
            ,State = wo.State
            ,PostalCode = wo.PostalCode
            ,SchedStartTime = ini
            ,SchedEndTime = fin
            ,description = description
        );
    }

    public static EventObj handleResourceAbsence(String description, Datetime ini, Datetime fin, ServiceResource sr){
        ResourceAbsence ra = createResourceAbsence( description,  ini,  fin,  sr);
        insert ra;
        ra = [SELECT Id, AbsenceNumber, ResourceId, Type, Start, End FROM ResourceAbsence WHERE id = :ra.Id];
        return new EventObj((String) ra.Id, ra.AbsenceNumber, ra.Start, ra.End, '', '', '', false, ra.Type, String.valueOf(ra.getSObjectType()), false);
    }

    public static ResourceAbsence createResourceAbsence(String description, Datetime ini, Datetime fin, ServiceResource sr){
        return new ResourceAbsence(
            ResourceId = sr.Id
            , Start = ini
            , End = fin
            , type = 'Vacaciones'
        );
    }


    @future
    public static void updateServiceAppointment(String saId, String ownId){
        ServiceAppointment sa = new ServiceAppointment(Id = saId, Status = 'Enviado', OwnerId = ownId);
        update sa;
    }
    public class EventWithDates{
        @AuraEnabled
        public List<EventObj> evtList;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String endDate;
        
        public eventWithDates(List<EventObj> evtList){
            this.startDate = '06:00';
            this.endDate = '23:00';
            this.evtList = evtList;
        }
    }


    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public DateTime endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String woId {get;set;}
        @AuraEnabled
        public Boolean urgente {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String objType {get;set;}
        @AuraEnabled
        public Boolean tipoLLamada {get;set;}

        public EventObj(String i,String t, DateTime s, DateTime e, String d, String o, String w, Boolean urgente, String status, String objType, Boolean tipoLLamada){
            this.Id = i;
            this.title = t;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;
            this.owner = o;
            this.woId = w;
            this.urgente = urgente;
            this.status = status;
            this.objType = objType;
            this.tipoLLamada = tipoLLamada;
        }
    }
}