/**
 * @File Name          : CallPhonehelper.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2/10/2019 13:44:33
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/10/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class CallPhonehelper {
    @AuraEnabled
    public static void createTask(String serviceAppointmetId, String contactId, String numero) {
        
        Task tsk = new Task();
        tsk.Subject = numero;
        tsk.Status = 'Completed';
        tsk.Priority = 'Normal';
        tsk.WhatId = serviceAppointmetId;
        tsk.WhoId = contactId;
        tsk.OwnerId = UserInfo.getUserId();
        insert tsk;

    }
}