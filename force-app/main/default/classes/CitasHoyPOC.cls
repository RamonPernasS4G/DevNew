/**
 * @File Name          : CitasHoyPOC.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 3/10/2019 17:10:50
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/10/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class CitasHoyPOC {

    @AuraEnabled(cacheable=true)
    public static List<ServiceAppointment> getSA(){
        return [SELECT id, Status, Street, City, State, PostalCode, Country, Contact.MobilePhone FROM ServiceAppointment WHERE Status != 'Cancelado'];
    }
}