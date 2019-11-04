/**
 * @File Name          : AssignedResourceTrigger.trigger
 * @Description        : 
 * @Author             : Ramón P.
 * @Group              : 
 * @Last Modified By   : Ramón P.
 * @Last Modified On   : 18/10/2019 12:36:17
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    18/10/2019   Ramón P.     Initial Version
**/
trigger AssignedResourceTrigger on AssignedResource (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    s4gwk.WorkerManager.createAndExecuteWorkers(String.valueOf(AssignedResource.class));
}