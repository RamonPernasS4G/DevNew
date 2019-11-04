trigger GremioSettingTrigger on Gremio_Settings__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	s4gwk.WorkerManager.createAndExecuteWorkers(String.valueOf(Gremio_Settings__c.class));
}