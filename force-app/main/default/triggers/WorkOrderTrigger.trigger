/**
 * @File Name          : WorkOrderTrigger.trigger
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 11/10/2019 8:31:35
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/10/2019   ismael.ocana@s4g.es     Initial Version
**/
trigger WorkOrderTrigger on WorkOrder (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    s4gwk.WorkerManager.createAndExecuteWorkers(String.valueOf(WorkOrder.class));
}