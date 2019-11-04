/**
 * @File Name          : CleanGremioSettingsBatch.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 16/10/2019 11:36:56
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   ismael.ocana@s4g.es     Initial Version
**/
public with sharing class CleanGremioSettingsBatch implements Database.Batchable<sObject>, Schedulable {

    public static final Integer SCOPE_SIZE = 200;

    public void execute(SchedulableContext sc) {
       Database.executebatch(new CleanGremioServiceResourceBatch(), SCOPE_SIZE);
    }

	public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Limite_Servicios_Mes__c FROM Gremio_Settings__c';
		System.debug('*** Query: ' + query);

		return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
       CleanGremioSettingsBatchHelper.resetGremioSettings((List<Gremio_Settings__c>) scope);
    }

    public void finish(Database.BatchableContext BC){
        
    }

}