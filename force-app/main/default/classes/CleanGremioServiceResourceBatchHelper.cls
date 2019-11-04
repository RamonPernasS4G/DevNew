/**
 * @File Name          : CleanGremioServiceResourceBatchHelper.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : Ramón P.
 * @Last Modified On   : 16/10/2019 15:02:27
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    14/10/2019   ismael.ocana@s4g.es     Initial Version
**/
public with sharing class CleanGremioServiceResourceBatchHelper {
    
    public static DateTime startTime;
    public static DateTime endTime;

    public static void ResetGremioServiceResource(List<Gremio_Service_Resource__c> gsrList){

        DateTime now = System.now();
        startTime = DateTime.newInstanceGMT(now.Year(), now.Month(), 1);
        endTime = startTime.addMonths(1);
        endTime = endTime.addMinutes(-1);

        System.debug('Start Time --- ' + startTime);
        System.debug('End Time --- ' + endTime);

        for(Gremio_Service_Resource__c gsr : gsrList){
            gsr.Inicio__c = startTime;
            gsr.Fin__c = endTime;
            gsr.Modificado_por_codigo__c = false;
        }

        update gsrList;
    }
}