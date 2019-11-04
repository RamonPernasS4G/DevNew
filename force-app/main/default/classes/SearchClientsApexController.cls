public with sharing class SearchClientsApexController {
    @AuraEnabled
    public static List<DireccionWrapper> getAccounts(String companyId, String identificador){
        List<DireccionWrapper> dwList = new List<DireccionWrapper>();
        /*List<Account> accList =  [SELECT id, Name, BillingAddress, Activo__c , (SELECT id, Compania__c, Cliente__c, Fecha_de_baja__c, Activo__c FROM Clientes__r WHERE Compania__c = :companyId),
                                    (SELECT Id, Codigo_postal__c, Direccion_calle__c, Pais__c, Poblacion__c, Provincia__c FROM Direcciones__r)
                                    FROM Account WHERE Numero_de_documento__c = :identificador];
        System.debug('accList ' + accList);
        Set<String> companyIds = new Set<String>();
        Set<String> addressIds = new Set<String>();
        for(Account acc : accList){
            if(!acc.Clientes__r.isEmpty()){
                companyIds.add(companyId);
            }
            for(Direccion__c d : acc.Direcciones__r){
                addressIds.add(d.Id);
            }
        }
        System.debug('companyIds ' + companyIds);
        //traer datos de "Vesta"
        if(companyIds.isEmpty()){
            for(Account acc : accList){
                for(Integer i = 0; i < 2; i++){
                    dwList.add(new DireccionWrapper(acc.Name, true,(String) acc.Id, companyId, '', 'Dir ' + i, 'Póliza', System.today().addMonths(10), 'Vesta'));
                }
            }
        }else{
            Map<String, String> direccionesPolizaIdByDireccionId = new Map<String,String>();
            //Se que tienen relacion de partner
            Map<String, Procedencia__c> procedenciasById = new Map<String,Procedencia__c>([SELECT id, Name FROM Procedencia__c]);
            System.debug('procedenciasById ' + procedenciasById);
            //Saber si tienen direcciones poliza
            List<Direccion_Tipo_Poliza__c> dtpList = [SELECT id, Tipo_Poliza__c, Tipo_Poliza__r.Name, Direccion__c FROM Direccion_Tipo_Poliza__c WHERE Direccion__c IN :addressIds AND Compania__c = :companyId];
            System.debug('dtpList ' + dtpList);
            for(Direccion_Tipo_Poliza__c d : dtpList){
                direccionesPolizaIDByDireccionId.put(d.Direccion__c, d.Tipo_Poliza__r.Name);
            }
            for(Account acc : accList){
                for(Direccion__c d : acc.Direcciones__r){
                    //La dirección está relacionada con la compañia
                    if(direccionesPolizaIDByDireccionId.containsKey(d.id)){
                        String address = d.Direccion_calle__c + ', ' +  d.Poblacion__c + ', ' + d.Codigo_Postal__c + ', ' + d.Provincia__c + ', ' +  d.Pais__c;
                        dwList.add(new DireccionWrapper(acc.Name, acc.Clientes__r.get(0).Activo__c,(String) acc.Id, companyId, (String) d.Id, address, direccionesPolizaIDByDireccionId.get(d.id), acc.Clientes__r.get(0).Fecha_de_baja__c, 'Salesforce'));
                    }
                }
            }
        }*/
        Boolean act = false;
        dwList.add(new DireccionWrapper('Juana Valenzuela',true, 'María de Molina, 37, Madrid', '12345', System.today().addMonths(10), 'Vesta', 'Hogar',  'SegurCaixa Siniestros'));
        dwList.add(new DireccionWrapper('Juana Valenzuela',true, 'San Cipriano, 13, Madrid', '12346', System.today().addMonths(14), 'Vesta', 'Hogar', 'SegurCaixa Asistencia'));
        return dwList;
    }



    public class DireccionWrapper{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Boolean activo;
        @AuraEnabled
        public String address;
        @AuraEnabled
        public String polizaName;
        @AuraEnabled
        public Date fechaVencimiento;
        @AuraEnabled
        public String origen;
        @AuraEnabled
        public String producto;
        @AuraEnabled
        public String procedencia;

        public DireccionWrapper(String name, Boolean activo, String address, String polizaName, Date fechaVencimiento, String origen, String producto, String procedencia){
            this.name = name;
            this.activo = activo;
            this.address = address;
            this.polizaName = polizaName;
            this.fechaVencimiento = fechaVencimiento;
            this.origen = origen;
            this.producto = producto;
            this.procedencia = procedencia;
        }
    }
}