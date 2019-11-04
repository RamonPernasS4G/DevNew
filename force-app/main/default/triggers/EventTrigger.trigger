/**
 * @File Name          : EventTrigger.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 23/9/2019 11:25:55
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/9/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    s4gwk.WorkerManager.createAndExecuteWorkers(String.valueOf(Event.class));
}