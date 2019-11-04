/**
 *   Static Class to include helpers
 *
 * @author      S4G
 * @version     1.0                 
 * @since       2013-11-14
 */
global class S4GUtils {
	
	/**
	* Generic Exception class
	*/
	global class wsException extends Exception {}
	global class wsSFDataException extends Exception {}

	/**
	* Email address to send the unexpected errors.
	*/
	private static String EMAIL_ERROR_TO = 'sflog+error+homeserve+claims@s4g.es';
	
	/**
	* Email subject to send the unexpected errors.
	*/
	private static String EMAIL_ERROR_PRESUBJECT = '[HS Claims]Unexpected Error -';

	/**
	* Custom Setting Name that we use to save the email address to send the errors
	*/
	private static String EMAIL_ERROR_ADDRESSES_NAME = 'Error Emails';
   
	/**
	* Get Exception information and send this by email.
	*/     
	global static void sendExceptionError(String subject,Exception e){
		
		S4GUtils.debugException(e);
	
		S4GUtils.sendUnexpectedError(subject,'Exception catched:'+e.getMessage()+'line:'+e.getLineNumber()+','+e.getStackTraceString()+'\n User: '+UserInfo.getUserName());
		   
	}
	
	global static void sendExceptionError(String subject,Exception e, String log){
		
		S4GUtils.debugException(e);
	
		S4GUtils.sendUnexpectedError(subject,'Exception catched:'+e.getMessage()+'line:'+e.getLineNumber()+','+e.getStackTraceString()+'\n User: '+UserInfo.getUserName()+'\n'+log);
		   
	}
	
	/**
	* Send Error information by email.
	*/
	global static void sendUnexpectedError(String subject, String body){
		
		String targetEmails = EMAIL_ERROR_TO;
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setReplyTo('sflog@s4g.es');
		mail.setPlainTextBody(body);
		mail.saveAsActivity = false;
		mail.setSenderDisplayName('Unexpected Error');
		mail.setSubject(EMAIL_ERROR_PRESUBJECT + subject);
		mail.setToAddresses(targetEmails.split(','));
		//Messaging.sendEmail(new Messaging.SingleEmailmessage[] {mail});
	
	}
   
	/**
	 * This method returns a query result containing the whole fields from an object
	 *
	 * @objectName String object name to be queried
	 * @additionalFilters String this should be the where, limit or sort clause
	 *
	 * @return SObject[] the list of object queried
	 */
	public static SObject[] selectByName(String objectName,  String additionalFilters){
		
		//get object fields
		List<String> fieldList = new List<String>(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet());
		String fields = String.join(fieldList,',');
		return (SObject[])Database.query('SELECT '+fields+' FROM '+objectName+ ' '+additionalFilters);
	}

	public static SObject[] selectByName(String objectName,  String additionalFilters, Boolean onlyUpdateableFields){
		
		String fields = String.join(getFieldsBySobject(objectName,onlyUpdateableFields,false),',');
		String query = 'SELECT '+fields+' FROM '+objectName+ ' '+additionalFilters;		
		return (SObject[])Database.query(query);
	}

	public static SObject[] selectByName(String objectName,  String additionalFilters, Boolean updatableFields, Boolean createableField){
		
		String fields = String.join(getFieldsBySobject(objectName,updatableFields,createableField),',');
		String query = 'SELECT '+fields+' FROM '+objectName+ ' '+additionalFilters;		
		return (SObject[])Database.query(query);
	}

	public static SObject[] selectById(String objectName,  String parentField, Set<String> parentIds ,Boolean updatableFields, Boolean createableField){
		
		String fields = String.join(getFieldsBySobject(objectName,updatableFields,createableField),',');
		Set<String> ids = parentIds;
		String query = 'SELECT '+fields+' FROM '+objectName+ ' WHERE '+parentField +' IN :ids';		
		return (SObject[])Database.query(query);
	}

	public static String[] getFieldsBySobject(String objectName,Boolean updatablefield, Boolean createableField){
		//get object fields
		List<String> fieldList = new List<String>();

		if(!updatablefield && ! createableField){
			fieldList = new List<String>(
				Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet()
			);
		} else {
			for(Schema.SObjectField field : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()){
				Schema.DescribeFieldResult  desField = field.getDescribe();

				if((updatablefield && desField.isUpdateable()) || (createableField && desField.isCreateable())){
					fieldList.add(desField.getName());
				}
			}
		}
		return fieldList;
	}  
	
	/**
	* this method will returns a map using as a key the object value of the indicated field. 
	*
	*/
	public static Map<String,SObject> listToMap(List<SObject> listSo, String fieldNameToKey){
		
		Map<String,SObject> newMap = new Map<String,SObject>();
		for(SObject so : listSo){
			newMap.put((String)so.get(fieldNameToKey),so);
		}

		return newMap;
	}
	
	public static Map<String,String> getObjectRecordTypesByDeveloperName(String objectName){
		return getObjectRecordTypesByDeveloperName(objectName, new String[]{});
	}

	public static Map<String,String> getObjectRecordTypesByDeveloperName(String objectName, String[] developerNames){
		Map<String,String> objectRecordTypesByDeveloperName = new Map<String,String>();
		
		Map<String, Schema.RecordTypeInfo> accountRecordtypeInfos = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName();
		
		if(!developerNames.isEmpty()){
			for(String name : developerNames){
				objectRecordTypesByDeveloperName.put(name, accountRecordtypeInfos.get(name).getRecordTypeId());
			}
		}
		else{
			for (Schema.RecordTypeInfo rt : accountRecordtypeInfos.values()){
				objectRecordTypesByDeveloperName.put(rt.getName(), rt.getRecordTypeId());
			}
		}

		System.debug('objectRecordTypesByDeveloperName: '+objectRecordTypesByDeveloperName);
		return objectRecordTypesByDeveloperName;

	}  

	public static String joinErrors(Database.Error[] errors){
		String[] errorList = new String[]{};

		for(Database.Error er : errors){
			errorList.add(er.getMessage());
		}

		return String.join(errorList, ' ');
	}  

	/**
	* Check if a value field has changed
	* @param SObject, old SObject, FieldName
	* @return Boolean
	*/
	public static Boolean isChangedField(SObject so, SObject oldSo, String fieldName){
		return oldSo == null || (so.get(fieldName) != oldSo.get(fieldName));
	}

	public static Boolean isChangedField(Sobject so, Sobject oldSo, String[] fieldNames){
		for(String field : fieldNames){
			if(isChangedField(so,oldSo,field)){
				return true;
			}
		}

		return false;
	}

	public static String cleanExcepionMessage(String exceptionMessage,String fromIndex, String toIndex){
		String result = exceptionMessage;

		if( result.contains(fromIndex)){
			result = result.substringAfter(fromIndex);

			if(result.contains(toIndex)){
				result = result.substringBefore(toIndex);
			}
		}

		//result = 'menudaMIerda';
		return result;
	}

	/**
	 * [integerFromString description]
	 * @param  s [description]
	 * @return   [description]
	 */
	public static Integer integerFromString(String s){
		return String.isNotBlank(s) ? Integer.valueOf(s) : null;
	}

	/**
	 * 1
	 * @param  bo [description]
	 * @return    [description]
	 */
	public static Integer integerFromBoolean(Boolean bo){
		return bo ? 1 : 0;
	}

	/**
	 * Get the int value from a Decimal Number
	 * @param  de [description]
	 * @return    [description]
	 */
	public static Integer integerFromDecimal(Decimal de){
		return de != null ? de.intValue() : null;
	}

	public static Boolean booleanFromDecimal(Decimal de){
		return de != null && de > 0;
	}

	/**
	 * Get the country code from a String thtat it starts with the countryCode 
	 */
	public static String countryCodeFromString(String s){

		return String.isBlank(s) ? s : ( s.startsWith('34') ? 'ES' : s.substring(0,2));
	}

	public static void manageUpdateResult(Database.SaveResult[] results){
		
		String[] erros = new String[]{};

		for(Database.SaveResult result : results){
			if(!result.isSuccess()){
				erros.add(S4GUtils.joinErrors(result.getErrors()));
			}
		}

		if(!erros.isEmpty()){
			throw new S4GUtils.wsSFDataException(String.join(erros, '.\n'));
		}
	}
	
	public static void manageUpdateResult(Database.SaveResult result){
		if(!result.isSuccess()){
			throw new S4GUtils.wsSFDataException(S4GUtils.joinErrors(result.getErrors()));
		}
	}

	public static Boolean findSobjectById(SObject[] soList, String soId){
		for(SObject so : soList){
			if(String.isNotBlank(so.Id) && so.Id == soId){
				return true;
			}
		}

		return false;
	}

	public static void debugException(Exception e){
		System.debug('Exception: '+e+'. '+e.getStackTraceString());
	}

	public static Boolean validaCuentaBancaria(String entidad, String oficina, String dc, String nCuenta){

		if(String.isBlank(entidad) || String.isBlank(oficina) || String.isBlank(dc) || String.isBlank(nCuenta)){
			return false;
		}
		
		String[] cEntidad = entidad.split(''),
		cOficina = oficina.split(''),
		cCuenta = nCuenta.split(''),
		cDC = dc.split('');
		//Versión 35 solved, si está logica está en version 28 falla
		//cEntidad.remove(0);
		//cOficina.remove(0);
		//cCuenta.remove(0);
		//cDC.remove(0);

		Integer[] pesosEntidadByPos = new Integer[]{4,8,5,10},
				pesosOficinaByPos = new Integer[]{9,7,3,6},
				pesosCuentaByPos = new Integer[]{1,2,4,8,5,10,9,7,3,6};

		if(cEntidad.size() != pesosEntidadByPos.size() 
			|| cOficina.size() != cOficina.size() 
			|| cCuenta.size() != pesosCuentaByPos.size()){
			return false;
		}		

		Integer sum = sumPesosByPos(pesosEntidadByPos,cEntidad) + sumPesosByPos(pesosOficinaByPos,cOficina);
		
		if(cDC[0] != String.valueOf(getDigitControl(sum))){
			return false;
		}

		sum = sumPesosByPos(pesosCuentaByPos,cCuenta);
		
		return cDC[1] == String.valueOf(getDigitControl(sum));
	}

	public static Map<String,SObject> convertListToMapByFields(SObject[] soList, String[] fieldNamesAreKey){
		Map<String,SObject> sobjectByKey = new Map<String,sObject>();

		String key;
		String[] keyL;
		String fieldValue;
		for(SObject so : soList){
			keyL = new String[]{};
			for(String fieldName : fieldNamesAreKey){
				fieldValue = String.valueOf( so.get(fieldName));
				if(String.isNotBlank(fieldValue)){
					keyL.add(fieldValue);
				}
			}
			key = String.join(keyL,'//');
			sobjectByKey.put(key,so);
		}

		return sobjectByKey;
	}

	public static void cleanFields(Sobject so, String[] fields){
		for(String field : fields){
			so.put(field,null);
		}
	}

	public static String urlEncode(String url){
		return EncodingUtil.urlEncode(url, 'UTF-8');
	}

	private static Integer sumPesosByPos(Integer[] pesoByPos,String[] s){
		Integer result = 0;
		for(Integer i = 0 ; i < s.size(); i++){
			result += Integer.valueOf(s.get(i)) * pesoByPos.get(i);
		}

		return result;
	}

	private static Integer getDigitControl(Integer n){
		Integer remainder = 11 - (Math.mod(n,11));
		return remainder == 11 ? 0 : remainder == 10 ? 1 : remainder;
	}

	public static Decimal getDecimalFromObject(Object o){
		Decimal result = 0;
		try{
			result = (Decimal) o;
		} catch(Exception e){
			debugException(e);
		}

		return result;
	}

	/**
     * @description Retrieves the CustomFields which contain the input substring in their name.
     *
     * @param sObjectName
     * @param fieldSubstring
     *
     * @return List of the field names
     */
	public static String[] getFieldSubset(String sObjectName, String fieldSubstring){
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();

		String[] fieldSubset = new String[]{};
		for (String fieldName: fieldMap.keySet()) {
			if(fieldName.containsIgnoreCase(fieldSubstring)){
				String developerName = fieldMap.get(fieldName).getDescribe().getName();
				fieldSubset.add(developerName);
			}
		}

		return fieldSubset;
	}
	
	public static Boolean canEnqueueJob(){
		return Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
	}

	public static String enqueueJob(Queueable queueable){
		return !Test.isRunningTest() && canEnqueueJob()
		? System.enqueueJob(queueable)
		: null;
	}

	public static void copyFields(SObject origin, SObject target){
		Map<String,Object> valueByField = origin.getPopulatedFieldsAsMap();

		for(String field : valueByField.keySet()){
			target.put(field,origin.get(field));
		}
	}

	@future (callout=true)
  public static void sendToApproveRecord(String recordId, String comment){
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(recordId);
		req.setComments(comment);
		Approval.process(req);
  }

	public static Map<String,SObject> cloneChildsByOldId(String oldParentId, String newParentId, String sobjectName, String parentField){
		Map<String,SObject> childs = new Map<String,SObject>{};
		SObject newSO;
		for(SObject so : S4GUtils.selectByName(sobjectName,'WHERE '+parentField+' = \''+oldParentId+'\'',true,true)){
			System.debug('so:'+JSON.serialize(so));
			newSO = so.clone(false,true,false,false);
			newSO.put(parentField,newParentId);
			childs.put(so.Id,newSO);
		}

		return childs;
	}

	public static Map<String,SObject> cloneChildsByOldId(Map<String,SObject> newParentByOldParentId, String sobjectName, String parentField){
		Map<String,SObject> childs = new Map<String,SObject>{};
		SObject newSO;

		String oldParentId;
		for(SObject so : S4GUtils.selectById(sobjectName,parentField,newParentByOldParentId.keySet(),true,true)){
			newSO = so.clone(false,true,false,false);
			oldParentId = (String) newSO.get(parentField);
			newSO.put(parentField,newParentByOldParentId.get(oldParentId).Id);
			childs.put(so.Id,newSO);
		}

		return childs;
	}

	public static Map<String,Schema.RecordTypeInfo> getRecordTypes(String objectName){
		return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();		
	}
	@AuraEnabled(cacheable = true)
	public static String getRecordTypeIdByDeveloperName(String objectName, String developerName){
		return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
	}

	public static Map<String,String> getPicklistValuesByLabel(String objectName, String fieldName){
		Map<String,String> valueByLabel = new Map<String,String>();

		for(Schema.PicklistEntry pe : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()){
			valueByLabel.put(pe.getLabel(),pe.getValue());
		}

		return valueByLabel;
	}

	public static String getProfileIdByProfileName (String profileName){
		Profile p = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
		return p.Id;
	}

	@AuraEnabled(cacheable=true)
	public static String[] getFieldsFromFieldSet(String sObjectName, String fieldSetName){
		String[] apiNames = new String[]{};
		
		for(Schema.FieldSetMember fsm : Schema.getGlobalDescribe().get(sObjectName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields()){
			apiNames.add(fsm.getFieldPath());
		}
		
		return apiNames;
	}
	
	@AuraEnabled(cacheable=true) 
	public static String[] getFieldsFromFieldSetLabels(String sObjectName, String fieldSetName, Boolean picklistAsLabel){
		String[] apiNames = new String[]{};
		String field;
		for(Schema.FieldSetMember fsm : Schema.getGlobalDescribe().get(sObjectName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields()){
			field = fsm.getFieldPath();
			if(String.valueOf(fsm.getType()) == 'PICKLIST' && picklistAsLabel){
				field = 'toLabel('+ field + ')';
			}
			apiNames.add(field);
		}
		return apiNames;
	}

	public static String getUserId (String userName){
		User u = [SELECT id FROM user WHERE Name =: userName];
		String id = u.id;
		return  id;
	}

	public static Object getFieldValue(SObject o,String field){
        if(o == null){
            return null;
        }
        if(field.contains('.')){
            String nextField = field.substringAfter('.');
            String relation = field.substringBefore('.');
            return getFieldValue((SObject)o.getSObject(relation),nextField);
        }
        else{
            return o.get(field);
        }
    }
}