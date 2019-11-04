/**
 * @File Name          : LWCButtonsController.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 31/10/2019 14:13:15
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    31/10/2019   ismael.ocana@s4g.es     Initial Version
**/
public with sharing class LWCButtonsController {
    
    @AuraEnabled(cacheable=true)
    public static List<LWC_Button__mdt> getButtons(String screenName){
        return [SELECT ID, Click_Action__c,  Next_Action__c, Screen_Name__c FROM LWC_Button__mdt WHERE Screen_Name__c = : screenName AND disabled__c = false ORDER BY Order__c];
    }
}