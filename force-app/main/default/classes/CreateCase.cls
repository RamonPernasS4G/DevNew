/**
 * @File Name          : CreateCase.cls
 * @Description        : 
 * @Author             : daniel.vazquez@s4g.es
 * @Group              : 
 * @Last Modified By   : daniel.vazquez@s4g.es
 * @Last Modified On   : 9/25/2019, 11:57:05 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/25/2019   daniel.vazquez@s4g.es     Initial Version
**/
public with sharing class CreateCase {

    public static Map<String,String> caseRecordTypes = getObjectRecordTypesByDeveloperName('Case');
    public static Map<String,String> accountRecordTypes = getObjectRecordTypesByDeveloperName('Account');

    @AuraEnabled
    public static String createNewCase(String companyId, String clientId, String description, String subject, String motivo, String name, String address, String relacion){
        System.debug('name ' + name);
        System.debug('address ' + address);
        //Crear cuenta 
        Account cliente = new Account(
              name = name
            , recordTypeId = accountRecordTypes.get('Cliente')
        );
        insert cliente;
        clientId = cliente.Id;

        List<SObject> insertList = new List<SObject>();
        Partner__c p = new Partner__c(
            compania__c = companyId,
            Cliente__c = clientId
        );
        insertList.add((SObject)p);
        Contact con = new Contact(
            LastName = name,
            AccountId = clientId
        );
        insertList.add((SObject)con);
        Direccion__c d = new Direccion__c(
            Cliente__c = clientId,
            Direccion_calle__c = address
        );
        insertList.add((SObject)d);

        insert insertList;
        //Crear Partner
        //Crear contacto y dirección
        //Crear caso
        Case c = caseFactory(companyId, clientId, description, subject, motivo, relacion);
        
        insert c;
        System.debug(c);
        return (String)c.Id;
    }

    public static Case caseFactory(String companyId, String clientId, String description, String subject, String motivo, String relacion){
        Case c = new Case(
            subject = subject,
            description = description,
            AccountId = clientId,
            Compania__c = companyId,
            Motivo__c = motivo,
            Quien_llama__c = relacion
        );
        if(caseRecordTypes.containsKey(motivo)){
            c.RecordTypeId = caseRecordTypes.get(motivo);
        }
        return c;
    }

    public static Map<String,String> getObjectRecordTypesByDeveloperName(String objectName){
		return getObjectRecordTypesByDeveloperName(objectName, new String[]{});
	}

	public static Map<String,String> getObjectRecordTypesByDeveloperName(String objectName, String[] developerNames){
		Map<String,String> objectRecordTypesByDeveloperName = new Map<String,String>();
		
		Map<String, Schema.RecordTypeInfo> accountRecordtypeInfos = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();
		
		if(!developerNames.isEmpty()){
			for(String name : developerNames){
				objectRecordTypesByDeveloperName.put(name, accountRecordtypeInfos.get(name).getRecordTypeId());
			}
		}
		else{
			for (Schema.RecordTypeInfo rt : accountRecordtypeInfos.values()){
				objectRecordTypesByDeveloperName.put(rt.getDeveloperName(), rt.getRecordTypeId());
			}
		}
		return objectRecordTypesByDeveloperName;

	}  
}