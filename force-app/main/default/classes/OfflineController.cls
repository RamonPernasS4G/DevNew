/**
 * @File Name          : OfflineController.cls
 * @Description        : 
 * @Author             : daniel.vazquez@s4g.es
 * @Group              : 
 * @Last Modified By   : daniel.vazquez@s4g.es
 * @Last Modified On   : 10/15/2019, 11:13:28 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/15/2019   daniel.vazquez@s4g.es     Initial Version
**/
public with sharing class OfflineController {
    
    @AuraEnabled
    public static void uploadFile(String recordId, String fileName,String fileData){
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode(fileData);
        cv.Title = fileName;
        cv.PathOnClient = filename;         
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        insert cdl;
    }
}