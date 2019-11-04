global class SanboxInitScript implements SandboxPostCopy {
  
  global static void runApexClass(SandboxContext context){
    
    //DVL 1/9/2019 : No se puede crear la skill a través de apex. Como se copian durante la creación de un sandbox vamos a utilizar una skill por defecto.
    Skill skill = [SELECT Id FROM Skill WHERE IsDeleted = false ORDER BY Developername ASC LIMIT 1];

    //Crear WORK TYPES
    WorkType[] workTypes = createWorkTypes();
    insert workTypes;

    SkillRequirement skillrequirement = createSkillRequirement(skill.Id, workTypes[0].Id, 2);
    insert skillrequirement;

    //Crear OperatingHours
    OperatingHours oh = createDefaultOperatingHours();
    insert oh;
    
    //Crear Timeslot de las Operatinghours
    TimeSlot[] timeSlots = createTimeSlots(oh.Id);
    insert timeSlots;
    
    //Crear Territorio
    ServiceTerritory[] territories = createServiceTerritories(oh.Id);
    insert territories; 

    //Crear Politica de programación (Scheduling Policies)
    FSL__Scheduling_Policy__c[] sp = createSchedulingPolicies();
    insert sp;
    //Crear WorkRules
    FSL__Work_Rule__c wr = createWorkRules();
    insert wr;

    //Crear serviceObjectives
    FSL__Service_Goal__c[] sg = createServiceObjectives();
    insert sg;

    //Crear PR
    Account ac = createPRCompany();
    //System.debug();
    insert ac;

    //Crear SR
    ServiceResource sr = createServiceResources();
    insert sr;

    //Asignar SR al territorio
    ServiceTerritory territory = [SELECT id FROM ServiceTerritory LIMIT 1];
    ServiceTerritoryMember str = createServiceTerritoryMembers(territory.id , sr.id );
    insert str;

    //Asignar al SR la SKill
    //crear un Service Resource Skills y relacionarlo con Skills y Service Resource
    ServiceResourceSkill srs = createServiceResourceSkill(skill.id, sr.id);
    insert srs;
  }
   
  @testVisible private static ServiceResourceSkill createServiceResourceSkill(String idSkill, String idSR){
    ServiceResourceSkill srs = new ServiceResourceSkill();
    srs.SkillId= idSkill;
    srs.ServiceResourceId = idSR;
    srs.EffectiveStartDate = DateTime.now();
    return srs;
  }

 
  @testVisible private static ServiceTerritoryMember createServiceTerritoryMembers(String idTerritory, String idSR){
    ServiceTerritoryMember str = new ServiceTerritoryMember();
      str.city= 'Madrid';
      str.country= 'España';
      str.geocodeAccuracy= 'Block';
      str.latitude= 40.43765618077331;
      str.longitude= -3.6806093194044824;
      str.postalCode= '28006';
      str.state= null;
      str.street= 'Calle de María de Molina 37';
      str.EffectiveStartDate= DateTime.now();
      str.TerritoryType = 'P';
      str.ServiceTerritoryId = idTerritory;
      str.ServiceResourceId = idSR;
    return str;
  }


  @testVisible private static ServiceResource createServiceResources(){
    ServiceResource sr = new ServiceResource();
        sr.ResourceType ='T';
        sr.Prioridad_Mizad__c = 1;
        sr.Ranking__c = 55;
        sr.Name = 'Benito SR';
        sr.RelatedRecordId = S4GUtils.getUserId('Benito SR');
        sr.IsActive = true;
    return sr;
  }

  @testVisible private static FSL__Service_Goal__c[] createServiceObjectives(){
    list <FSL__Service_Goal__c> soList = new list <FSL__Service_Goal__c>();
    soList.add(new FSL__Service_Goal__c( Name='Minimizar desplazamiento',
                                              RecordTypeId = S4GUtils.getRecordTypeIdByDeveloperName('FSL__Service_Goal__c','Objective_Minimize_Travel')));
    soList.add(new FSL__Service_Goal__c( Name='Priorización Fraquiciados',
                                              RecordTypeId = S4GUtils.getRecordTypeIdByDeveloperName('FSL__Service_Goal__c','Objective_Resource_Priority')));
    soList.add(new FSL__Service_Goal__c( Name='Priorización Mizad',
                                              RecordTypeId = S4GUtils.getRecordTypeIdByDeveloperName('FSL__Service_Goal__c','Objective_Resource_Priority'),
                                              FSL__Resource_Priority_Field__c = 'prioridad_mizad__c',
                                              FSL__Object_Group_Field__c = 'mizad__c'));
    soList.add(new FSL__Service_Goal__c( Name='Priorización por Ranking',
                                              RecordTypeId = S4GUtils.getRecordTypeIdByDeveloperName('FSL__Service_Goal__c','Objective_Resource_Priority'),
                                              FSL__Resource_Priority_Field__c = 'ranking__c'));
    return soList;
  }

  @testVisible private static FSL__Scheduling_Policy__c[] createSchedulingPolicies(){
    list <FSL__Scheduling_Policy__c> spList = new list <FSL__Scheduling_Policy__c>();
    spList.add(new FSL__Scheduling_Policy__c( Name = 'Claims standard',
                                              FSL__Description__c = 'Política estándar de asignación de citas',
                                              FSL__Commit_Mode__c = 'AlwaysCommit')); 
    spList.add(new FSL__Scheduling_Policy__c( Name = 'Claims urgencia',
                                              FSL__Description__c = 'Política de asignación de citas urgentes',
                                              FSL__Commit_Mode__c = 'AlwaysCommit'));                                           
    return spList;
  }


  @testVisible private static FSL__Work_Rule__c createWorkRules(){
    FSL__Work_Rule__c wr = new FSL__Work_Rule__c();
        wr.FSL__Active__c = true;
        wr.FSL__Maximum_Travel_From_Home_Type__c = 'Distance';
        wr.FSL__Service_Property__c ='ServiceTerritory';
        wr.FSL__Service_Schedule_Time_Property__c = 'SchedStartTime';
        wr.FSL__Service_Time_Operator__c = 'Before';
        wr.FSL__Service_Time_Property__c = 'EarliestStartTime';
        wr.RecordTypeId = S4GUtils.getRecordTypeIdByDeveloperName('FSL__Work_Rule__c','Match_Skills_Service');
        wr.Name = 'Required Skills';
    return wr;
  }
  

  @testVisible private static WorkType[] createWorkTypes(){
    return new WorkType[]{
      createDefaultWorkType('Fontanería','01','01;02')
    };
  }

  @testVisible private static ServiceTerritory[] createServiceTerritories(String operatingHoursId){
    return new ServiceTerritory[]{
      createDefaultServiceTerritory('Madrid',operatingHoursId)
    };
  }

  @testVisible private static WorkType createDefaultWorkType(String name,String gremio, String categorias){
    return new WorkType(
      Name = name
      //,TDT_SEL_Gremio__c = gremio
      //,TDT_SEL_Categoria__c= categorias
      ,EstimatedDuration = 2
      ,DurationType = 'Hours'
      ,ShouldAutoCreateSvcAppt = true
    );
  }

  @testVisible private static ServiceTerritory createDefaultServiceTerritory(String name, String operatingHoursId){
    return new ServiceTerritory(
      Name = name
      ,OperatingHoursId = operatingHoursId
      ,IsActive = true
      //,TDS_SEL_Provincia__c = '28'
    );
  }

  @testVisible private static OperatingHours createDefaultOperatingHours(){
    return new OperatingHours(
      Name = 'Standar'
    );
  }

  @testVisible private static TimeSlot[] createTimeSlots(String operatingHoursId){
    
    Time startTime = Time.newInstance(8, 0, 0, 0), endTime = Time.newInstance(18, 0, 0, 0);

    TimeSlot[] timeSlots = new TimeSlot[]{
      createTimeSlot(operatingHoursId,startTime,endTime,'Monday','Normal')
      ,createTimeSlot(operatingHoursId,startTime,endTime,'Tuesday','Normal')
      ,createTimeSlot(operatingHoursId,startTime,endTime,'Wednesday','Normal')
      ,createTimeSlot(operatingHoursId,startTime,endTime,'Thursday','Normal')
      ,createTimeSlot(operatingHoursId,startTime,endTime,'Friday','Normal')
      ,createTimeSlot(operatingHoursId,startTime,endTime,'Saturday','Extended')
    };

    return timeSlots;
  }

  @testVisible private static TimeSlot createTimeSlot(String operatingHoursId, Time startTime,Time endTime, String dayOfWeek, String type){
    return new TimeSlot(
      OperatingHoursId = operatingHoursId
      ,StartTime = startTime
      ,EndTime = endTime
      ,DayOfWeek = dayOfWeek
      ,Type = type
    );
  }

  @testVisible private static Skill createSkill(){
    return new Skill(
      Masterlabel = 'Fontaneria'
      ,DeveloperName = 'Fontaneria'
    );
  }

  @testVisible private static SkillRequirement createSkillRequirement(String skillId, String workTypeId, Double level){
    return new SkillRequirement(
      SkillId = skillId
      ,RelatedRecordId = workTypeId
      ,SkillLevel = level
    );
  }

  @testVisible private static Account createPRCompany(){
    /*return new Account(
      Name = 'Walter\'s Family'
      ,RecordtypeId = S4GUtils.getRecordTypeIdByDeveloperName('Account','CUE_Profesional')
    );*/
    Account ac = new Account(
      Name = 'Walter\'s Family'
      ,RecordtypeId = S4GUtils.getRecordTypeIdByDeveloperName('Account','PR')
    );
    return ac;
  }

  @testVisible private static ServiceResource createServiceResource(String accountId, String userId, String resourceType){
    return new ServiceResource(
      AccountId = accountId
      ,IsActive = true
      //,RSE_LKP_Cuenta__c = accountId
      ,RelatedRecordId = userId
      ,ResourceType = resourceType
    );
  }
  @testVisible private static User createFSLUser(String firstName, String lastName, String email, String profileId){
    return new User(
      FirstName = firstName
      ,LastName = lastName
      ,Email = email
      ,Alias = email.left(4)
      ,Username = email
      ,CommunityNickname = email.left(4)
      ,ProfileID = profileId
      ,LocaleSidKey = 'en_US'
      ,TimeZoneSidKey = 'GMT'
      ,LanguageLocaleKey = 'en_US'
      ,EmailEncodingKey = 'UTF-8'
    );
  } 

  
  @testVisible private static String idRecordType (String recordTypeName){
    RecordType recordtypeid = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName =: recordTypeName LIMIT 1];
    String id = recordtypeid.id;
    return id;
  }
}