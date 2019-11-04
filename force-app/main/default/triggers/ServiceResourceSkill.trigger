/**
 * @File Name          : ServiceResourceSkill.trigger
 * @Description        : 
 * @Author             : Ramón P.
 * @Group              : 
 * @Last Modified By   : Ramón P.
 * @Last Modified On   : 8/10/2019 16:03:55
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    8/10/2019   Ramón P.     Initial Version
**/
trigger ServiceResourceSkill on ServiceResourceSkill (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    s4gwk.WorkerManager.createAndExecuteWorkers(String.valueOf(ServiceResourceSkill.class));
}