/**
 * @File Name          : PocAsingacionTest.cls
 * @Description        : 
 * @Author             : daniel.vazquez@s4g.es
 * @Group              : 
 * @Last Modified By   : daniel.vazquez@s4g.es
 * @Last Modified On   : 9/23/2019, 9:44:32 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/23/2019   daniel.vazquez@s4g.es     Initial Version
**/
@isTest
private class PocAsingacionTest {
  
  @TestSetup
  static void prepareEnviroment(){
    OperatingHours oh = S4GTestFactory.createOperatingHours(PocAsignacion.OPERATING_HOURS_NAME);
    insert oh;

    ServiceTerritory st = S4GTestFactory.createServiceTerritory(PocAsignacion.TERRITORY_NAME,oh.Id);
    insert st;

    WorkType wt = S4GTestFactory.createWorkType();
    insert wt;
  }

  @isTest private static void testRunPOC(){
    Test.startTest();
      PocAsignacion.runMe('Fontanero', 10, 5, 5, 20, 100, 50);
    Test.stopTest();
      
    Account ac = [SELECT Id FROM Account WHERE RecordType.Developername = 'PR' LIMIT 1];
    System.assert(ac != null,'La cuenta del PR no se ha creado correctamente');
      
    List<ServiceAppointment> citas = [SELECT Id FROM ServiceAppointment]; 
    System.assert(citas.size() == 100,'Las citas no se han creado correctamente');

    List<PermissionSetAssignment> psa=[select Id 
                                        from PermissionSetAssignment 
                                        where permissionSet.Name IN ('FSL_Community_Dispatcher_Permissions','FSL_Resource_Permissions')];
    System.debug('Permisos asignados: '+psa.size());
    System.assert(psa.size()>0,'Se ha asignado el permissionSet');
  }

  @isTest private static void testClear(){
    System.assert(false,'WIP');
  }
}