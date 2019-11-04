/**
 * @File Name          : CleanGremioServiceResourceBatch.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 14/10/2019 13:22:49
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    14/10/2019   ismael.ocana@s4g.es     Initial Version
**/
public with sharing class CleanGremioServiceResourceBatch implements Database.Batchable<sObject>, Schedulable {

    public static final Integer SCOPE_SIZE = 200;

    public void execute(SchedulableContext sc) {
        Database.executebatch(new CleanGremioServiceResourceBatch(), SCOPE_SIZE);
    }

	public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Inicio__c, Fin__c FROM Gremio_Service_Resource__c WHERE Service_Resource__r.IsActive = true';
		System.debug('*** Query: ' + query);

		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        CleanGremioServiceResourceBatchHelper.ResetGremioServiceResource((List<Gremio_Service_Resource__c>) scope);
    }

    public void finish(Database.BatchableContext BC){
        
    }
}