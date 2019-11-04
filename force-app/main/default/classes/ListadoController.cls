/**
 * @File Name          : ListadoController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : daniel.vazquez@s4g.es
 * @Last Modified On   : 10/16/2019, 3:29:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    24/9/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class ListadoController {
    


    /**
    * @description  
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 25/9/2019 
    * @return List<ServiceAppointment> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<ServiceAppointment> getSA(){
        return [SELECT Id, Status, AppointmentNumber, Address, ParentRecord.Name, Gremio__c, SchedStartTime, SchedEndTime, Contact.MobilePhone, Contact.Name FROM ServiceAppointment ];
    }
}