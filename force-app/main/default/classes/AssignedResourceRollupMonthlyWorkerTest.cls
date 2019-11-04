/**
 * @File Name          : CleanGremioServiceResourceBatchTest.cls
 * @Description        : 
 * @Author             : Andoni Raya
 * @Group              : 
 * @Last Modified By   : Ramón P.
 * @Last Modified On   : 29/10/2019 17:00:18
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/10/2019   Andoni Raya     Initial Version
**/ 
@isTest
public class AssignedResourceRollupMonthlyWorkerTest {

    //private static Savepoint sp;
    private static String said;
    private static String srid;
    private static String gsid;

    public static void createSetup() {
        //sp = Database.setSavepoint();
        String accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('PR').getRecordTypeId();
        Account acc = S4GTestFactory.createAccount(accRecordTypeId, 'test-prueba');
        insert acc;

        Contact cont = S4GTestFactory.createContact(acc);
        insert cont;

        String profileid = S4GUtils.getProfileIdByProfileName('Administrador del sistema');
        User u = S4GTestFactory.createUser(profileid, '12345');
        insert u;
        
        Gremio__c guild = S4GTestFactory.createGuild('Test');
        insert guild;

        Gremio_Settings__c gs = S4GTestFactory.createGremioSettings(acc.id, guild.id);
        gs.Gremio__c = guild.id;
        gs.Limite_Servicios_Mes__c = 2;
        insert gs;
        gsid = gs.id;

        WorkOrder wo = S4GTestFactory.createWorkOrder(guild.id ,acc.id, cont.id);
        insert wo;

        OperatingHours oh =S4GTestFactory.createOperatingHours('Test');
        insert oh;

        ServiceTerritory st = S4GTestFactory.createServiceTerritory('Test', oh.id);
        insert st;

        ServiceAppointment sa = S4GTestFactory.createServiceAppointment(wo.id, 'Ninguno');
        sa.SchedStartTime = datetime.NOW();
        sa.SchedEndTime = datetime.NOW();
        sa.Gremio__c = guild.id;
        sa.ServiceTerritoryId = st.id;
        insert sa;
        said = sa.id;

        ServiceResource sr = S4GTestFactory.createServiceResource(acc.id, u.id, 'A');
        sr.AccountId = acc.id;
        insert sr;
        srid = sr.id;

        ServiceTerritoryMember stm = S4GTestFactory.createServiceTerritoryMember(st.id, sr.id, oh.id);
        insert stm;

        FSL.GlobalAPIS.addStatusTransition('Ninguno', 'Programado');
        FSL.GlobalAPIS.addStatusTransition('Programado', 'Enviado');

}



    @istest(seeAlldata=true)
    public static void testCreateAssignedResource(){
        createSetup();
        ServiceAppointment sa = [SELECT id, status FROM ServiceAppointment WHERE id =: said LIMIT 1];
        ServiceResource sr = [SELECT id FROM ServiceResource WHERE id =: srid LIMIT 1];

        sa.status = 'Programado';
        update sa;
        Test.startTest();
        AssignedResource ar = S4GTestFactory.createAssignedResource(sa.id, sr.id);
        System.debug('------> '+sa.status);
        insert ar;
        Test.stopTest();
        List<AssignedResource> arList = new List<AssignedResource>();
        arList = [SELECT id FROM AssignedResource WHERE ServiceResourceId =:srid AND ServiceAppointmentId =: said ];
        Gremio_Settings__c gs = [SELECT id, serviciosCursoMes__c FROM Gremio_Settings__c LIMIT 1];
        System.assertEquals(gs.serviciosCursoMes__c , arList.size());
    }
   
    @istest (seeAlldata=true)
    public static void testDeleteAssignedResource(){
        createSetup();
        ServiceAppointment sa = [SELECT id,Gremio__c FROM ServiceAppointment WHERE id =: said LIMIT 1];
        ServiceResource sr = [SELECT id,AccountId  FROM ServiceResource WHERE id =: srid LIMIT 1];
        AssignedResource ar = S4GTestFactory.createAssignedResource(sa.id, sr.id);
        System.debug('************* Inserto');
        insert ar;
        ar = [SELECT id,ServiceResourceId, ServiceAppointmentId FROM AssignedResource WHERE ServiceResourceId =:srid AND ServiceAppointmentId =: said LIMIT 1];
        System.debug('************* Borro');
        Test.startTest();
        delete ar;
         Test.stopTest();
        //ar = [SELECT id FROM AssignedResource WHERE ServiceResourceId =:srid AND ServiceAppointmentId =: said];
        List<AssignedResource> arList = new List<AssignedResource>();
        //arList = [SELECT id FROM AssignedResource WHERE ServiceResourceId =:srid AND ServiceAppointmentId =: said];
        arList = [SELECT Id, ServiceAppointmentId, ServiceResourceId, 
                         ServiceAppointment.ParentRecordId, ServiceResource.AccountId,
                         ServiceAppointment.Gremio__c, CreatedDate
                         FROM AssignedResource
                         WHERE ServiceResource.AccountId = :sr.AccountId
                         AND ServiceAppointment.Gremio__c = :sa.Gremio__c];
        
        Gremio_Settings__c gs = [SELECT id, serviciosCursoMes__c FROM Gremio_Settings__c WHERE id =: gsid LIMIT 1];
        System.assertEquals(gs.serviciosCursoMes__c , arList.size());
        //Database.rollback(sp);
    }
}