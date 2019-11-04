/**
 * @File Name          : GremioSettingsCheckLimitWorker.cls
 * @Description        : Checks if the monthly service`s limit is reached by PRAccount and Guild
                         Expires or enables the Gremio_Service_Resource__c related record
 * @Author             : Ramón P.
 * @Group              : 
 * @Last Modified By   : Ramón P.
 * @Last Modified On   : 27/10/2019 19:30:19
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   Ramón P.     Initial Version
**/
global class GremioSettingsCheckLimitWorker extends s4gwk.AbstractWorker{

    List<Gremio_Service_Resource__c> gremioServiceResources = new List<Gremio_Service_Resource__c>();
    Map<String,Gremio_Service_Resource__c> gremioServiceResourceByGremioSetting = new Map<String,Gremio_Service_Resource__c>();
    List<Gremio_Service_Resource__c> gremioServiceResourceToUpdate = new List<Gremio_Service_Resource__c>();

    public GremioSettingsCheckLimitWorker() {
        super(String.valueOf(GremioSettingsCheckLimitWorker.class));
        System.debug('GremioSettingsCheckLimitWorker');
    }

    public override void bulkAfterUpdate(List<SObject> oldRecords, List<SObject> newRecords){
        prepareData();
    }

    public override void afterUpdate(SObject oldSo, SObject so){
        Gremio_Settings__c gs = (Gremio_Settings__c)so;
        gremioServiceResourceByGremioSetting.get(gs.Id).Modificado_por_codigo__c = true;

        if(gs.ServiciosCursoMes__c >= gs.Limite_Servicios_Mes__c){
            //Disable Gremio_Settings__c
            gremioServiceResourceByGremioSetting.get(gs.Id).Fin__c = Datetime.now();
        }else{
            //Enable Gremio_Settings__c until last day of the month
            gremioServiceResourceByGremioSetting.get(gs.Id).Fin__c = null;
        }
    }

    public override void andFinallyAfter(){
        if(Trigger.isUpdate){
            if(!gremioServiceResourceByGremioSetting.isEmpty()){
                update gremioServiceResourceByGremioSetting.values();
            }
        }
    }

    private void prepareData(){
        List<Gremio_Settings__c> newGremiosSettings = (List<Gremio_Settings__c>)newRecords;  
        List<Gremio_Settings__c> oldGremiosSettings = (List<Gremio_Settings__c>)oldRecords;  
        Set<String> accountPRIds = new Set<String>();
        Set<String> gremiosIds = new Set<String>();

        for(Gremio_Settings__c gremioSetting : newGremiosSettings){
            accountPRIds.add(gremioSetting.PR__c);
            gremiosIds.add(gremioSetting.Gremio__c);
        }
        //Get the related Gremio_Service_Resource__c records
        gremioServiceResources = [SELECT Id, Gremio__c	, Service_Resource__c, Service_Resource__r.AccountId,
                                        Inicio_actividad__c, Fin_actividad__c, Inicio__c, Fin__c
                                  FROM Gremio_Service_Resource__c
                                  WHERE Gremio__c IN :gremiosIds
                                    AND Service_Resource__c IN (SELECT Id 
                                                                FROM ServiceResource
                                                                WHERE AccountId IN :accountPRIds)];
        
        for(Gremio_Settings__c gs : (List<Gremio_Settings__c>)newRecords){
            for(Gremio_Service_Resource__c gremioServiceResource : gremioServiceResources){
                if(gs.PR__c == gremioServiceResource.Service_Resource__r.AccountId && gs.Gremio__c == gremioServiceResource.Gremio__c){
                    gremioServiceResourceByGremioSetting.put(gs.Id, gremioServiceResource);
                }
            } 
        }
    }


}