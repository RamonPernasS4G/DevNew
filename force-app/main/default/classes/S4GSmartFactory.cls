/*
   Copyright 2011 Mavens Consulting, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/   


/**
 * To turn off logging Setup - Develop - Apex Classes - S4GSmartFactory - Log Filters - System = NONE
 */

@isTest
public with sharing class S4GSmartFactory {

  /**
   * Fill all available fields that are not explictely excluded
   */
  public static Boolean fillAllFields = false;

  private static final Map<String, Map<String, Schema.SObjectField>> FieldMapCache = new Map<String, Map<String, Schema.SObjectField>>();
  private static final Map<String, Schema.SObjectType> GlobalDescribe = Schema.getGlobalDescribe();
  private static final Set<String> ExceptionCascadeSObjects = new Set<String>{
    'ExternalDataSource',
    'BusinessHours'
  };

  // Default Country and State
  // When Country and State Picklists are enabled, cannot dynamically resolve which States are within a Country
  public static string DefaultCountry = 'United States';
  public static string DefaultCountryCode = 'US';
  public static string DefaultState = 'Pennsylvania';
  public static string DefaultStateCode = 'PA';

  // Key: sobject.field
  // Value: first picklist value
  private static final Map<String, String> defaultPicklistValue = new Map<String, String>();

  /**
   * Fields to be excluded per object
   */
  public static Map<String, set<String>> excludedFields = new map<String, set<String>>{
    'All' => new Set<String>{'OwnerId', 'LastModifiedById', 'CreatedById', 'LastModifiedDate', 'CreatedDate'},
    'Account' => new Set<String>{'FirstName', 'LastName'},
    'User' => new Set<String>{'IsActive','DelegatedApproverId','CallCenterId','ContactId','DelegatedApproverId','ManagerId','UserRoleId','FederationIdentifier'},
    'OpportunityLineItem' => new Set<String>{'TotalPrice'}
  };

  /**
   * Specific fields to be auto-filled per object
   */
  public static Map<String, set<String>> includedFields = new map<String, set<String>>();

  /**
   * Key-value pairs of default values per object
   */
  public static Map<String, Map<String, Object>> defaultValues = new Map<String, Map<String, Object>>();


  /**
   * Create an sobject record
   * @param  objectType - name of sobject
   */
  public static SObject createSObject(String objectType) {
    return createSObject(objectType, false);
  }

  /**
   * Create an sobject record and its inmediate related dependencies
   * @param  objectType   - name of sobject
   * @param  cascade     - flag indicating if the cascading object should be automatically created
   */
  public static SObject createSObject(String objectType, boolean cascade) {
    return createSObject(objectType, cascade, 1);
  }

  public static SObject createSObject(String objectType, Boolean cascade, Integer counter) {

    System.debug('Creating ' + objectType);
    Schema.sObjectType token = GlobalDescribe.get(objectType);
    if (token == null) {
      throw new UnsupportedObjectTypeException('Unsupported ObjectType ' + objectType);
    }

    SObject obj = token.newSObject();    

    for (Schema.SObjectField field : fieldMapFor(objectType).values()) {
      setFieldValue(obj, field, cascade, counter);
    }


    return obj;
  }


  /**
   * Create a sobject list and it's inmediate related dependencies
   * @param  objectType      - name of sobject
   * @param  cascade         - flag indicating if the cascading object should be automatically created
   * @param  numberOfObjects - amount of records to create
   */
  public static List<SObject> createSObjectList(String objectType, boolean cascade, Integer numberOfObjects) {

    List<SObject> sos = new List<SObject>();
    
    for( Integer i=0; i<numberOfObjects; i++ ){
      sos.add(createSObject(objectType, cascade, i));
    }

    return sos;  
  }


  public static  Map<String, Schema.SObjectField> fieldMapFor(String objectType) {
    Map<String, Schema.SObjectField> fieldMap = null;
    String normalizedObjectType = objectType.toLowerCase();

    if (FieldMapCache.containsKey(normalizedObjectType)) {
      fieldMap = FieldMapCache.get(normalizedObjectType);
    } else {
      fieldMap = GlobalDescribe.get(objectType).getDescribe().fields.getMap();
      // cache it for next use
      FieldMapCache.put(normalizedObjectType, fieldMap);
    }

    return fieldMap;
  }

  static String getDefaultPicklistValue(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
    String key = obj.getSObjectType() + '.' + fieldDescribe.getName();

    if (!defaultPicklistValue.containsKey(key)) {
      List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
      String value = entries.size() > 0 ? entries[0].getValue() : null;
      defaultPicklistValue.put(key, value);
    }

    return defaultPicklistValue.get(key);
  }

  static boolean isExcludedField(Schema.DescribeFieldResult fieldDescribe) {
    return excludedFields.get('All').contains(fieldDescribe.getName());
  }

  static boolean isExcludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
    set<String> fields = excludedFields.get(obj.getSObjectType().getDescribe().getName());
    return fields == null ? false : fields.contains(fieldDescribe.getName());
  }

  static boolean isIncludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
    set<String> fields = includedFields.get(obj.getSObjectType().getDescribe().getName());
    return fields == null ? false : fields.contains(fieldDescribe.getName());
  }

  static boolean isPersonAccountField(Schema.DescribeFieldResult fieldDescribe) {
                Boolean isPersonAccountEnabled = fieldMapFor('Account').get('IsPersonAccount') != null;
                set<string> skipPersonAccountFields = new set<string>{ 'Salutation' };
            
                Boolean CustomPerson = fieldDescribe.isCustom() && fieldDescribe.getName().endsWith('pc');
                Boolean StandardPerson = !fieldDescribe.isCustom() && fieldDescribe.getName().startsWith('Person');

                return CustomPerson || StandardPerson || 
                    (isPersonAccountEnabled && skipPersonAccountFields.contains(fieldDescribe.getName()));
  }

  static void setFieldValue(SObject obj, Schema.SObjectField field, boolean cascade) {
    setFieldValue(obj, field, cascade, 0);
  }

  static void setFieldValue(SObject obj, Schema.SObjectField field, boolean cascade, Integer counter) {
    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

    if (fieldDescribe.isCreateable() && 
      (
        isIncludedField(obj, fieldDescribe) || 
        (
          (
            (!fieldDescribe.isNillable() || 
            fillAllFields) || 
            (fieldDescribe.getType() == Schema.DisplayType.Reference && cascade) // always fill references with cascade
          ) && 
          !isExcludedField(fieldDescribe) &&
          !isExcludedField(obj, fieldDescribe) &&
          !isPersonAccountField(fieldDescribe)
        )
       )
      ) {

      String sobjName = obj.getSObjectType().getDescribe().getName();

      if (defaultValues.containsKey(sobjName) && 
        defaultValues.get(sobjName).containsKey(fieldDescribe.getName())) {

        obj.put(field, defaultValues.get(sobjName).get(fieldDescribe.getName()));

      } else if (fieldDescribe.getName().endsWith('Country')) {
        obj.put(field, DefaultCountry);
      } else if (fieldDescribe.getName().endsWith('State')) {
        obj.put(field, DefaultState);
      } else if (fieldDescribe.getName().endsWith('CountryCode')) {
        obj.put(field, DefaultCountryCode);
      } else if (fieldDescribe.getName().endsWith('StateCode')) {
        obj.put(field, DefaultStateCode);
      } else if (fieldDescribe.getType() == Schema.DisplayType.base64) {
        obj.put(field, blob.valueOf(counter.format()));
      } else if (fieldDescribe.getType() == Schema.DisplayType.Boolean) {
        obj.put(field, fieldDescribe.getDefaultValue());
      } else if (fieldDescribe.getType() == Schema.DisplayType.Combobox) {
        obj.put(field, counter.format());
      } else if (fieldDescribe.getType() == Schema.DisplayType.Currency) {
        obj.put(field, counter);
      } else if (fieldDescribe.getType() == Schema.DisplayType.Date) {
        obj.put(field, Date.today());
      } else if (fieldDescribe.getType() == Schema.DisplayType.DateTime) {
        obj.put(field, DateTime.now());
      } else if (fieldDescribe.getType() == Schema.DisplayType.Double) {
        obj.put(field, counter);
      } else if (fieldDescribe.getType() == Schema.DisplayType.Email) {
        obj.put(field, 'test' + counter.format() + '@test.com');
      } else if (fieldDescribe.getType() == Schema.DisplayType.EncryptedString) {
        obj.put(field, 's');
      } else if (fieldDescribe.getType() == Schema.DisplayType.Id) {
        //System.debug('Id field ' + fieldDescribe.getName());
      } else if (fieldDescribe.getType() == Schema.DisplayType.Integer) {
        obj.put(field, counter);
      } else if (fieldDescribe.getType() == Schema.DisplayType.MultiPicklist) {
        obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
      } else if (fieldDescribe.getType() == Schema.DisplayType.Percent) {
        obj.put(field, counter);
      } else if (fieldDescribe.getType() == Schema.DisplayType.Phone) {
        obj.put(field, '123-456-7890');
      } else if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
        obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
      } else if (fieldDescribe.getName() == 'CommunityNickname' && fieldDescribe.getType() == Schema.DisplayType.String) { 
        obj.put(field, 'test'+ string.valueof(math.roundtolong(math.random()*1000000)) ); 
      } else if (fieldDescribe.getName() == 'UserName' && fieldDescribe.getType() == Schema.DisplayType.String) { 
        obj.put(field, 'test'+ string.valueof(Userinfo.getOrganizationId())+ string.valueof(math.roundtolong(math.random()*1000000))+ string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','')+'@test.com'); // was a@a.com
      } else if (fieldDescribe.getType() == Schema.DisplayType.String) {
        obj.put(field, counter.format()); 
      } else if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
        String referenceObjectType = fieldDescribe.getReferenceTo()[0].getDescribe().getName();

        if (referenceObjectType == 'RecordType') {
          setRecordType(obj);
                }else if (referenceObjectType == 'Profile') { 
          obj.put(field, UserInfo.getProfileId());
        } else if (referenceObjectType == 'Pricebook2') { 
          obj.put(field, Test.getStandardPricebookId());
        }else if (cascade && referenceObjectType != obj.getSObjectType().getDescribe().getName() &&
                            !ExceptionCascadeSObjects.contains(referenceObjectType)) {
                    

                    // TODO avoid infinite loop for same-type references
          System.debug('Creating reference to ' + referenceObjectType + ' for field ' + obj.getSObjectType().getDescribe().getName() + '.' + fieldDescribe.getName());
          
          SObject reference = createSObject(referenceObjectType);
          System.debug('Inserting ' + reference);
          insert reference;
          
          obj.put(field, reference.Id);
        }
      } else if (fieldDescribe.getType() == Schema.DisplayType.TextArea) {
        obj.put(field, counter.format()); 
      } else if (fieldDescribe.getType() == Schema.DisplayType.Time) {
        obj.put(field, Time.newInstance(0, 0, 0, 0)); 
      } else if (fieldDescribe.getType() == Schema.DisplayType.URL) {
        obj.put(field, 'http://test' + counter + '.com'); 
      } else {
        System.debug('Unhandled field type ' + fieldDescribe.getType());
      }
    }  
  }


  static void setRecordType(SObject obj) {
    List<Schema.RecordTypeInfo> recordTypes = obj.getSObjectType().getDescribe().getRecordTypeInfos();

    if (recordTypes.size() > 1) { // all objects have default Master type
      //System.debug('RecordTypes ' + recordTypes);
      for (Schema.RecordTypeInfo recordType : recordTypes) {
        if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) {
          obj.put('RecordTypeId', recordType.getRecordTypeId());
        }
      }
    }
  }


  public with sharing class UnsupportedObjectTypeException extends Exception {}
}