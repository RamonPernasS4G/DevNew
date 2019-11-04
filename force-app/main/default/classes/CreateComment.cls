/**
 * @File Name          : CreateComment.cls
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 16/10/2019 9:51:06
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   ismael.ocana@s4g.es     Initial Version
**/
public with sharing class CreateComment {

    @AuraEnabled
    public static void createComentario(String workOrderId, String com){
        insert new Comentario__c(Comentario__c = com, Servicio__c = workOrderId);
    }
}