trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    s4gwk.WorkerManager.createAndExecuteWorkers(String.valueOf(ServiceAppointment.class));
}