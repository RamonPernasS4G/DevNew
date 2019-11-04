/**
 * @File Name          : CleanGremioSettingsBatchHelper.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : Ramón P.
 * @Last Modified On   : 16/10/2019 15:03:47
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   ismael.ocana@s4g.es     Initial Version
**/
public with sharing class CleanGremioSettingsBatchHelper {

    public static void resetGremioSettings(List<Gremio_Settings__c> gsList){
        for(Gremio_Settings__c gs : gsList){
            gs.ServiciosCursoMes__c = 0;
        }

        update gsList;
    }
}