/**
 * @File Name          : SkillsRouting.cls
 * @Description        : 
 * @Author             : S4G
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 3/10/2019 17:39:18
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    23/9/2019           S4G                 Initial Version
**/
global without sharing class SkillsRouting {

    //Listas que almacenan, segun su tipo, los campos que son suceptibles de generar un cambio de skills  
    public static Map<String,List<String>> picklistFields = new Map<String,List<String>>();
    public static Map<String,String> checkboxFields = new Map<String,String>();
    public static Map<String,List<ServiceResourceSkill>> skillsGestorByCase = new Map<String,List<ServiceResourceSkill>>();
    public static Map<String,List<String>> skillsRequiredByCase = new Map<String,List<String>>();
    public static List<ServiceResource> gestores = new List<ServiceResource>();
    public static List<Case> casosToUpdate;

    @InvocableMethod
    global static void routeUsingSkills(List<String> cases) {

        //Traemos de la metadata, los campos susceptibles de generar cambio de skill
        String queryFields = getMetadataFields();

        //Traemos los valores de los campos de los casos que se han modificado
        String query = 'SELECT ' + queryFields + 'Id,OwnerId FROM Case WHERE Id IN :cases';
        List<sobject> casos = Database.query(query);

        //Seteamos las variables skillsGestorByCase(skills que tiene el tramitador del caso) 
        // y skillsRequiredByCase(skills que necesita el caso)
        getSkills(casos);

        //Si la variable gestores esta vacia es porque esta asignado a una cola
        if(!gestores.isEmpty()){
            //Comparamos las skills del tramitador con las que necesita el caso para saber
            // si puede seguir tramitandolo o necesita ser reasignado => casosToUpdate
            checkChangeOwner(casos);

            if(!casosToUpdate.isEmpty()){
                update casosToUpdate;
            }
        }
    }


    /*
    * Metodo que recoge los campos y valores que son susceptibles de generar un cambio de owner desde la custom metadata 
    */
    private static String getMetadataFields(){
        List<String> fieldsAux = new List<String>();
        String queryFields = '';
        List<OmniChannelSkills__mdt> fieldsToCheck = [SELECT MasterLabel,DeveloperName,Field__c,Id,Value__c,IsPicklist__c, IsCheckbox__c
                                                       FROM OmniChannelSkills__mdt];
        for(OmniChannelSkills__mdt field : fieldsToCheck){
            //Campos para query
            if(!fieldsAux.contains(field.Field__c)){
                fieldsAux.add(field.Field__c);
                queryFields += field.Field__c + ',';
            }
            //Para checkbox
            if(field.IsCheckbox__c){
                checkboxFields.put(field.Field__c, field.MasterLabel);
            //Para picklist y lookup
            }else if(field.IsPicklist__c){
                if(picklistFields.get(field.Field__c) != null){
                    picklistFields.get(field.Field__c).add(field.Value__c);
                }else{
                    List<String> aux = new List<String>();
                    aux.add(field.Value__c);
                    picklistFields.put(field.Field__c, aux);
                }
            }
        }
        return queryFields;
    }


    /*
    * Metodo que recoge las skills que requieren los casos(skillsRequiredByCase) 
    * y las skills que tienen sus tramitadores asignados(skillsGestorByCase).
    */
    private static void getSkills(List<SObject> casos){
        List<String> skillsRequired;
        Set<String> gestoresId = new Set<String>();

        for(sobject caso : casos){
            gestoresId.add(String.valueOf(caso.get('OwnerId')));
        }
        
        // tramitadores asignados a los casos
        gestores = [SELECT Id, RelatedRecordId, (SELECT Id,Skill.DeveloperName FROM ServiceResourceSkills) 
                    FROM ServiceResource 
                    WHERE RelatedRecordId = :gestoresId AND IsActive = true];

        for(sObject caso : casos){
            //rellenamos skillsGestorByCase
            for(ServiceResource gestor : gestores){
                if(caso.get('OwnerId') == gestor.RelatedRecordId){
                    skillsGestorByCase.put(String.valueOf(caso.get('Id')), gestor.ServiceResourceSkills);
                }
            }
            
            skillsRequired = new List<String>();
            if(!checkboxFields.keySet().isEmpty()){
                for(String field : checkboxFields.keySet()){
                    if(Boolean.valueOf(caso.get(field))){
                        skillsRequired.add(checkboxFields.get(field));
                    }
                }
            }

            if(!picklistFields.keySet().isEmpty()){ 
                for(String field : picklistFields.keySet()){
                    //Si es una picklist o lookup en un objeto relacionado
                    if(field.contains('.')){
                        List<String> relaciones = field.split('\\.');
                        if(picklistFields.get(field).contains(String.valueOf(  caso.getSObject(relaciones[0]).get(relaciones[1])  ))){
                            skillsRequired.add(String.valueOf(  caso.getSObject(relaciones[0]).get(relaciones[1])  ));
                        }
                    //Si es una picklist o lookup del mismo objeto
                    }else{
                        if(picklistFields.get(field).contains(String.valueOf(caso.get(field)))){
                            skillsRequired.add(String.valueOf(caso.get(field)));
                        }
                    }
                }
            }
            // rellenamos skillsRequiredByCase
            if(!skillsRequired.isEmpty()){
                skillsRequiredByCase.put(String.valueOf(caso.get('Id')), skillsRequired);
            }
        } 
    }


    /*
    * Metodo que comprueba que las skills que tiene el tramitador asignado 
    * cumple las skills que necesita el caso, en caso contrario se debera reasignar
    */
    private static void checkChangeOwner(List<SObject> casos){
        casosToUpdate = new List<Case>();
        List<String> currentUserSkills;
        Boolean transferCase = false;
        for(sObject caso : casos){

            currentUserSkills = new List<String>();
            
            for(ServiceResourceSkill resourceSkill : skillsGestorByCase.get( String.valueOf(caso.get('Id')) )){
                currentUserSkills.add(resourceSkill.skill.DeveloperName);
            }

            for(String skillRequired : skillsRequiredByCase.get(String.valueOf(caso.get('Id')))){
                if(!currentUserSkills.contains(skillRequired)){
                    transferCase = true;
                }
            }

            if(transferCase){
                Case casoUpdate = (Case)caso;
                if(casoUpdate.Urgente__c){
                    //casoUpdate.OwnerId = '00G5E000004VfDX';
                    casoUpdate.OwnerId = Label.QueueUrgentesId;
                }else{
                    //casoUpdate.OwnerId = '00G5E000004VN9a';
                    casoUpdate.OwnerId = Label.QueueNormalesId;
                }
                casosToUpdate.add(casoUpdate);
            }            
        }
    }

}