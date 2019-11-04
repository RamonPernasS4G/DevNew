/**
* @File Name          : PocAsignacion.cls
* @Description        : 
* @Author             : daniel.vazquez@s4g.es
* @Group              : 
* @Last Modified By   : daniel.vazquez@s4g.es
* @Last Modified On   : 10/24/2019, 10:53:39 AM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    9/24/2019   daniel.vazquez@s4g.es     Initial Version 
**/
public with sharing class PocAsignacion {

	public static final String OPERATING_HOURS_NAME = 'Claims standard';
	public static final String SCHEDULING_POLICY_NAME = 'Claims standard';
	public static final String COMPANY_NAME = 'SegurCaixa';
	public static final String TERRITORY_NAME = 's4g';
	public static final Integer LIMITE_SERVICIOS_MES = 15;

	public static final String[] PERMISIONS_SET_PR = new String[]{'FSL_Community_Dispatcher_Permissions','FSL_Community_Dispatcher_License','New_Salesforce_Mobile_APP','FSL_Resource_Permissions','FSL_Resource_License'};
	public static final String[] PERMISIONS_SET_SR = new String[]{'FSL_Resource_Permissions','FSL_Resource_License','New_Salesforce_Mobile_APP'};

	private String prProfileId;
	private String srProfileId;

	private String ohId;
	private String rtPRId;
	private String gremio;
	private String territoryId;
	private String skillId;
	private String workTypeId;
	private String schedulingPolicyId;
	private String companyId;

	private Integer nTotalPRs;
	private Integer nFranquiciados;
	private Integer nMizad;
	private Integer nZipCodes;
	private Integer nServicios;
	private Integer nServiciosMizad;

	private Integer nScheduled;

	private static Set<String> serviceAppointmentIdsSet;


	public PocAsignacion(String gremio, Integer nTotalPRs, Integer nFranquiciados, Integer nMizad, Integer nZipCodes,Integer nServicios, Integer nServiciosMizad, Integer nScheduled){

		for(Profile p : [
			SELECT Id, Name 
			FROM Profile 
			WHERE Name LIKE 'Profesional %' 
			ORDER BY Name ASC
		]){
			if(String.isBlank(this.prProfileId)){
				this.prProfileId = p.Id;
			} else {
				this.srProfileId = p.Id;
			}
		}

		this.ohId = [SELECT Id FROM OperatingHours WHERE Name = :OPERATING_HOURS_NAME LIMIT 1].Id;
		this.rtPRId = S4GUtils.getRecordTypeIdByDeveloperName('Account', 'PR');
		this.territoryId = [SELECT Id FROM ServiceTerritory WHERE IsActive = true AND Name = :TERRITORY_NAME LIMIT 1].Id;

		this.schedulingPolicyId = getSchedulingPolicyId();
	

		Worktype wt = [SELECT Id, (SELECT SkillId,SkillLevel FROM SkillRequirements)FROM WorkType ORDER BY Name ASC LIMIT 1];
		this.workTypeId = wt.Id;

		if(wt.SkillRequirements != null && !wt.SkillRequirements.isEmpty()){
			this.skillId = wt.SkillRequirements[0].SkillId;
		}

		this.gremio = gremio;
		this.nTotalPRs = nTotalPRs;
		this.nFranquiciados = nFranquiciados;
		this.nMizad = nMizad;
		this.nZipCodes = nZipCodes;
		this.nServicios = nServicios;
		this.nServiciosMizad = nServiciosMizad;
		this.nScheduled = nScheduled;
		this.companyId = getCompanyId();
	}

	//A TODO los técnicos y servicios se les asignará al menos una skill requerida
	//Los PR se iran diviendo en los territorios
	//El número de franquiciados y mizad debe ser menos al número total de PR
	//Todos los PR tendrán el mismo límite por gremio, y serán del mismo gremio
	public static void runMe(String gremio, Integer nTotalPRs, Integer nFranquiciados, Integer nMizad, Integer nZipCodes,Integer nServicios, Integer nServiciosMizad, Integer nScheduled){

		Savepoint sp = Database.setSavepoint();
		try {
			PocAsignacion pocAsignacion = new PocAsignacion(gremio,nTotalPRs,nFranquiciados,nMizad,nZipCodes,nServicios,nServiciosMizad, nScheduled);
			pocAsignacion.prepareData();    
		} catch(Exception e) {
			Database.rollback(sp);
			throw e;
		}
	}

	public static void cleanServiceAppointments(){
		delete [SELECT Id FROM WorkOrder WHERE POC_Asignacion__c = true];
		delete [SELECT Id FROM ServiceAppointment WHERE POC_Asignacion__c =true];
	}

	public static void cleanGremioSettings(){
		Gremio_Settings__c[] gremioSettings = [SELECT Id,ServiciosCursoMes__c FROM Gremio_Settings__c WHERE ServiciosCursoMes__c >0];
		for(Gremio_Settings__c gs : gremioSettings){
			gs.ServiciosCursoMes__c = 0;
		}

		update gremioSettings;
	}

	public static void cleanGremioServiceResource(){
		Gremio_Service_Resource__c[] gremioSRs = [SELECT Id,Fin_Actividad__c FROM Gremio_Service_resource__c WHERE Fin_Actividad__c != null];
		for(Gremio_Service_Resource__c gsr : gremioSRs){
			gsr.Fin_Actividad__c = null;
		}

		update gremioSRs;
	}

	public static void createServiceAppointmentData(Integer nServicios, Integer nServiciosMizad, Integer nScheduled){
		createServiceAppointmentData(nServicios,nServiciosMizad,nScheduled,null,null,null,null);
	}

	public static void createServiceAppointmentData(Integer nServicios, Integer nServiciosMizad, Integer nScheduled, Datetime earliestStartTime, Datetime dueDate, Datetime arrivalWindowStart, Datetime arrivalWindowEnd){
		Zip_Code__c[] zipCodes = [SELECT Id FROM Zip_Code__c WHERE POC_Asignacion__c = true];
		Gremio__c guild = [SELECT id FROM Gremio__c WHERE Poc_Asignacion__c = true LIMIT 1];

		PocAsignacion poc = new PocAsignacion('Fontanero',0,0,0,0,nServicios,nServiciosMizad, nScheduled);

		WorkOrder[] workOrders = poc.createWorkOrders(guild.Id,zipCodes);
		insert workOrders;

		ServiceAppointment[] sas= poc.updateServiceAppointments(workOrders,zipCodes,earliestStartTime,dueDate,arrivalWindowStart,arrivalWindowEnd);
		update sas;

		if(!serviceAppointmentIdsSet.isEmpty()){
			scheduleServiceAppointments();
		}
	}


	public static void inactiveServiceResource(){
		//desactivamos los usuarios
		Savepoint sp = Database.setSavepoint();
		try{
			ServiceResource[] resources = [SELECT Id,isActive,AccountId,Name FROM ServiceResource WHERE POC_Asignacion__c = true AND isActive = true];
			for(ServiceResource sr :resources){
				sr.isActive = false;
				sr.AccountId = null;
				sr.Name += '_DELETED';
			}
			update resources;  
		} catch(Exception e){
			Database.rollback(sp);
			throw e;
		}

	}
	public static void inactiveUsers(){
		//desactivamos los usuarios
		Savepoint sp = Database.setSavepoint();
		try{
			User[] users = [SELECT Id,isActive,UserRoleId,UserName,CommunityNickname FROM User WHERE POC_Asignacion__c = true AND IsActive = true];
			for(User u : users){
				Datetime d=Datetime.now();
				u.IsActive = false;
				u.IsPortalEnabled = false;
				u.UserName += '_disabled';
				u.CommunityNickname+='_disabled_'+d.getTime();
			}
			update users;  
		} catch(Exception e){
			Database.rollback(sp);
			throw e;
		}

	}

	public static void cleanData(){
		Savepoint sp = Database.setSavepoint();
		try{
			SObject[] data = new SObject[]{};

			//Borramos miembros de citas 
			//Borramos citas
			data.addAll([SELECT Id FROM ServiceAppointment WHERE POC_Asignacion__c = true]);
			
			//borramos territorios
			data.addAll([SELECT Id FROM ServiceTerritory WHERE POC_Asignacion__c = true]);
			
			//borramos contactos
			data.addAll([SELECT Id FROM Contact WHERE POC_Asignacion__c = true]);
			
			//borramos cuenta
			data.addAll([SELECT Id FROM Account WHERE POC_Asignacion__c = true]);

			//boramos los zipCode
			data.addAll([SELECT Id FROM Zip_Code__c WHERE POC_Asignacion__c = true]);
				
			//boramos los work order
			data.addAll([SELECT Id FROM WorkOrder WHERE POC_Asignacion__c = true]);

			delete data;
		} catch(Exception e){
			Database.rollback(sp);
			throw e;
		}
	}

	private void prepareData(){

		//Crearemos tantas cuentas y contactos como el total de PR
		Account[] prs = createPRs();
		insert prs;


		Contact[] contacts = createContacts(prs);
		insert contacts;

		//Creamos el gremio necesario
		Gremio__c guild = createGuild(this.gremio);
		insert guild;

		//Crearemos el objeto limite asociado a la cuenta por gremio
		Gremio_Settings__c[] gremioSettings = createGremioSettings(guild.Id,prs);
		insert gremioSettings;

		//Crearemos los usuarios de comunidad para los contactos
		User[] users = createCommunityUsers(contacts);
		insert users;

		//Asignacion de PermissionSets a los usuarios
		List<Id> PRusers=new List<Id>();
		List<Id> SRusers=new List<Id>();
		for(User user:users){
			if(user.LastName.contains('SR')){
				SRusers.add(user.Id);
			}else{
				PRusers.add(user.Id);
			}
		}

		assignPermissionSets(PRusers, PERMISIONS_SET_PR);
		assignPermissionSets(SRusers, PERMISIONS_SET_SR);

		//Crearemos tantos SR como PR y SR
		ServiceResource[] srs = createServiceResources(users);
		insert srs;

		//Creamos los zip code
		Zip_Code__c[] zipCodes = createZipCodes();
		insert zipCodes;

		//Asignamos a cada service resource un zip Code
		Zip_Code_Member__c[] zipCodeMembers = createZipCodeMembers(zipCodes,srs);
		insert zipCodeMembers;

		//Asignaremos la skill al SR
		ServiceResourceSkill[] srSkills = createServiceResourceSkills(srs);
		insert srSkills;

		//Crear territorymember por cada sr creado
		ServiceTerritoryMember[] stMembers = createServiceTerritoryMembers(srs);
		insert stMembers;

		//Crearemos tantas wo con citas asignadas al territorio por orden, si el numero es mizad esa cita se creara como mizad
		WorkOrder[] wos = createWorkOrders(guild.Id, zipCodes);
		insert wos;

		ServiceAppointment[] sas= updateServiceAppointments(wos,zipCodes,null,null,null,null);
		update sas;

		if(!serviceAppointmentIdsSet.isEmpty()){
			scheduleServiceAppointments();
		}
	}

	private ServiceTerritory[] createTerritories(){
	ServiceTerritory[] territories = new ServiceTerritory[]{};
	for(Integer i = 0; i<this.nZipCodes; i++){
		territories.add(createTerritory(i));
	}
	return territories;
	}

	private ServiceTerritory createTerritory(Integer nTerritory){
		return new ServiceTerritory(
			Name = 'Territorio '+nTerritory+' POC Asignación'
			,isActive= true
			,OperatingHoursId = this.ohId
			,POC_Asignacion__c =true
			,Description = 'Territorio creado para la prueba de Asignación'
		);
	}

	private Account[] createPRs(){
		Account[] acs = new Account[]{};
		for(Integer i=0; i<this.nTotalPRs;i++){
			acs.add(createAccount(i));
		}
		return acs;
	}

	private Account createAccount(Integer i){
		return new Account(
			RecordTypeId = this.rtPRId
			,Name = 'PR_'+i
			,Activo__c = true
			,POC_Asignacion__c = true
			,BillingStreet = 'Calle María de Molina 37'
			,BillingPostalCode = '27006'
			,BillingCity = 'Madrid'
			,BillingState = 'Madrid'
			,BillingCountry = 'España'
			,ID_HomeServe__c='PR_'+i+'_'+Math.random()
		);
	}

	private Contact[] createContacts(Account[] acs){
		Contact[] contacts = new Contact[]{};
		Integer pos = 0;
		for(Account ac : acs){
			contacts.add(createContact(ac,'PR',pos));
			contacts.add(createContact(ac,'SR',pos));
			pos++;
		}
		return contacts;
	}

	private Contact createContact(Account ac,String type, Integer pos){
		Contact c = new Contact(
			AccountId = ac.Id
			,POC_Asignacion__c = true
			,Lastname = ac.Name +'_'+type + pos
		);
		c.Email = c.Lastname + '@homeserve.es.poc';
		return c;
	}

	private Gremio_Settings__c[] createGremioSettings(String guildId, Account[] prs){
		Gremio_Settings__c[] gremioSettings = new Gremio_Settings__c[]{};
		for(Account pr : prs){
			gremioSettings.add(createGremioSetting(guildId,pr));
		}

		return gremioSettings;
	}

	private Gremio_Settings__c createGremioSetting(String guildId,Account pr){
		return new Gremio_Settings__c(
			Gremio__c = guildId
			,PR__c = pr.Id
			,Limite_Servicios_Mes__c = LIMITE_SERVICIOS_MES
			,POC_Asignacion__c = true
		);
	}

	private User[] createCommunityUsers(Contact[] contacts){
		User[] users = new User[]{};

		for(Contact c : contacts){
			users.add(createCommunityUser(c));
		}

		return users;
	}

	private User createCommunityUser(Contact contact){
		User u = new User(
			Firstname = contact.FirstName
			,Lastname = contact.LastName
			,Email = contact.Email
			,ProfileId = contact.LastName.contains('SR') ? this.srProfileId : this.prProfileId
			,ContactId = contact.Id
			,CommunityNickname = contact.LastName
			,TimeZoneSidKey = 'Europe/Paris'
			,LocaleSidKey = 'es_ES'
			,EmailEncodingKey = 'ISO-8859-1'
			,LanguageLocaleKey = 'es'
			,POC_Asignacion__c = true
		);

		u.Username = u.Email;
		u.Alias = u.Username.left(5);
		if(Test.isRunningTest()){
			u.Username+='__Test';
			u.CommunityNickname+='__Test';
		}
		return u;
	}

	private ServiceResource[] createServiceResources(User[] users){
		ServiceResource[] resources = new ServiceResource[]{};
		Integer pos = 0;
		for(User u : users){
			resources.add(createServiceResource(u,pos));
			pos++;
		}
		return resources;
	}

	private ServiceResource createServiceResource(User u,Integer pos){
		ServiceResource sr = new ServiceResource(
			RelatedRecordId = u.Id
			,Name = u.Lastname
			,Limite_Franquicia__c = this.nFranquiciados > 0 ? 2 : 0
			,Prioridad_Mizad__c = this.nFranquiciados <= 0 && this.nMizad >= 0 ? 1 : 100
			,POC_Asignacion__c = true
			,Ranking__c = pos
			,IsActive = true
		);

		if(this.nFranquiciados <= 0){
			this.nMizad --;
		}

		this.nFranquiciados--;

		return sr;
	}

	private Zip_Code__c[] createZipCodes(){
		Zip_Code__c[] zipCodes = new Zip_Code__c[]{};
		for(Integer i = 0; i<this.nZipCodes; i++){
			zipCodes.add(createZipCode(i));
		}
		return zipCodes;
	}

	private Zip_Code__c createZipCode(Integer nZipCode){
		return new Zip_Code__c(
			Name = String.valueOf(nZipCode)
			,POC_Asignacion__c = true
		);
	}

	private Zip_Code_Member__c[] createZipCodeMembers(Zip_Code__c[] zipCodes, ServiceResource[] srs){
		Zip_Code_Member__c[] zcMembers = new Zip_Code_Member__c[]{};
		Integer pos = 0;
		for(ServiceResource sr : srs){
			zcMembers.add(createZipCodeMember(sr,zipCodes,pos));
			pos++;
		}
		return zcMembers; 
	}

	private Zip_Code_Member__c createZipCodeMember(ServiceResource sr, Zip_Code__c[] zipCodes, Integer pos){
		Integer zipSize = zipCodes.size();
		Integer zipCodePos = pos > 0 ? Math.mod(pos,zipSize) : 0;

		return new Zip_Code_Member__c(
			Service_Resource__c = sr.Id
			,Zip_Code__c = zipCodes[zipCodePos].Id
		);
	}

	private ServiceResourceSkill[] createServiceResourceSkills(ServiceResource[] srs){
		ServiceResourceSkill[] srSkills = new ServiceResourceSkill[]{};
		for(ServiceResource sr : srs){
			srSkills.add(createServiceResourceSkill(sr));
		}
		return srSkills;
	}

	private ServiceResourceSkill createServiceResourceSkill(ServiceResource sr){
		return new ServiceResourceSkill(
			SkillId = this.skillId
			,ServiceResourceId = sr.Id
			,EffectiveStartDate = Date.today().addDays(-1)
		);
	}

	private ServiceTerritoryMember[] createServiceTerritoryMembers(ServiceResource[] srs){
	ServiceTerritoryMember[] stMembers = new ServiceTerritoryMember[]{};

	for(ServiceResource sr : srs){
		stMembers.add(createServiceTerritoryMember(sr));
	}
	return stMembers;
	} 

	private ServiceTerritoryMember createServiceTerritoryMember(ServiceResource sr){
		return new ServiceTerritoryMember(
			ServiceTerritoryId = this.territoryId
			,ServiceResourceId = sr.Id
			,POC_Asignacion__c = true
			,TerritoryType = 'P'
			,EffectiveStartDate = Date.today().addDays(-1)
			,Latitude=getLatitude()
			,Longitude=getLongitude()
		);
	}

	private WorkOrder[] createWorkOrders(String guildId, Zip_Code__c[] zipCodes){
		WorkOrder[] wos = new WorkOrder[]{};

		for(Integer i=0; i<this.nServicios;i++){
			wos.add(createWorkOrder(guildId,zipCodes,i));
		}

		return wos;
	}

	private WorkOrder createWorkOrder(String guildId, Zip_Code__c[] zipCodes, Integer pos){

		Datetime earliestStart = Datetime.now();
		Datetime dueDate = earliestStart.addDays(7);

		Integer zipCodePos = pos > 0 ? Math.mod(pos,zipCodes.size()) : 0;
		WorkOrder wo = new WorkOrder(
			StartDate = earliestStart
			,EndDate = dueDate
			,Gremio__c = guildId
			,WorkTypeId = this.workTypeId
			,POC_Asignacion__c=true
			,AccountId = this.companyId
		);

		return wo;     
	}

	private Gremio__c createGuild(String skillName){
		return new Gremio__c(
			Name = skillName
			,Nombre_Skill__c = skillName
			,POC_Asignacion__c = true
		);
	}

	@future
	public static void assignPermissionSets(List<Id> userIds, String[] permisisionSetNames){
		List<PermissionSet> permissions=[select Id from PermissionSet where Name IN :permisisionSetNames];
		List<PermissionSetAssignment> permissionAssignements=new List<PermissionSetAssignment>();
		if(userIds.size()>0 && permissions.size()>0){
			for(Id userId:userIds){
				for(PermissionSet permission:permissions){
					PermissionSetAssignment psa= new PermissionSetAssignment();
					psa.AssigneeId=userId;
					psa.PermissionSetId=permission.Id;
					permissionAssignements.add(psa);
				}
			}
		}

		Database.Error[] errors = new Database.Error[]{};
		for(Database.SaveResult sr:Database.insert(permissionAssignements,false)){
			if(!sr.isSuccess()){
				errors.addAll(sr.getErrors());
			}
		}

		if(!errors.isEmpty()){
			throw new S4GUtils.wsException(S4GUtils.joinErrors(errors));
		}
	}

	public static Decimal getLatitude(){
		Decimal lat=Math.round(Math.random()*106355);
		lat+=40370730;
		lat/=1000000;
		return lat;
	}
	public static Decimal getLongitude(){
		Decimal lon=Math.round(Math.random()*53423);
		lon+=3662957;
		lon/=1000000;
		lon*=-1;
		return lon;
	}

	private ServiceAppointment[] updateServiceAppointments(WorkOrder[] workOrders,Zip_Code__c[] zipCodes, Datetime earliestStartTime, Datetime dueDate, Datetime arrivalWindowStart, Datetime arrivalWindowEnd){
		ServiceAppointment[] sas = [SELECT POC_Asignacion__c,Mizad__c,Latitude,Longitude,Zip_Code__c,DueDate,EarliestStartTime,ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN :workOrders];
		Integer pos = 0, rand = 0;
		Datetime startDate, now = DateTime.now();
		Integer zipCodePos = pos > 0 ? Math.mod(pos,zipCodes.size()) : 0;
		Integer [] hoursList = new List<Integer>{8,10,12,14,16,18,20};
		Map<String,WorkOrder> workOrderById = new Map<String,WorkOrder>(workOrders);


		serviceAppointmentIdsSet = new Set<String>();

		for(ServiceAppointment sa: sas){
			sa.POC_Asignacion__c=true;
			sa.Mizad__c = this.nServiciosMizad > 0;
			sa.Latitude=getLatitude();
			sa.Longitude=getLongitude();
			sa.Zip_Code__c = zipCodes[zipCodePos].Id;
			sa.Gremio__c = workOrderById.get(sa.ParentRecordId).Gremio__c;

			if(earliestStartTime != null){
				sa.EarliestStartTime = earliestStartTime;
			} else {
				sa.EarliestStartTime = Datetime.newInstance(now.year(), now.month(), now.day(), hoursList.get(getRandomNumber(6)), 0, 0);
				if(sa.EarliestStartTime < Datetime.now()){
					sa.EarliestStartTime = sa.EarliestStartTime.addDays(1);
				}
			}
			
			sa.DueDate = dueDate != null ? dueDate : sa.EarliestStartTime.addDays(5);
			sa.ArrivalWindowStartTime = arrivalWindowStart != null ? arrivalWindowStart : sa.EarliestStartTime.addDays(getRandomNumber(5));
			sa.ArrivalWindowEndTime = arrivalWindowEnd != null ? arrivalWindowEnd :sa.ArrivalWindowStartTime.addMinutes(120);
			this.nServiciosMizad--;
			if(this.nScheduled > 0){
				serviceAppointmentIdsSet.add(sa.Id);
			}
			this.nScheduled--;
			pos++;
		}

		return sas;
	}

	private static void scheduleServiceAppointments(){

		List<String> saList = new List<String>();
		saList.addAll(serviceAppointmentIdsSet);
		
		String schedulingPolicyId = getSchedulingPolicyId();
		
		System.enqueueJob(new PocAsignacion.QueueSchedule(schedulingPolicyId, saList, 0));
	}

	private static Integer getRandomNumber(Integer size){
		Double d = math.random() * size;
		return d.intValue();
	}

	private static String getSchedulingPolicyId(){
		return [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name = :SCHEDULING_POLICY_NAME LIMIT 1].Id;	
	}

	private static String getCompanyId(){
		return [SELECT Id FROM Account WHERE Name = :COMPANY_NAME LIMIT 1].ID;
	}

	public class QueueSchedule implements Queueable{

		private String policyId;
		private List<String> saList;
		private Integer num;

		public QueueSchedule(String policyId,List<String> saList, Integer num){
			this.policyId = policyId;
			this.saList = saList;
			this.num = num;
		}


		public void execute(QueueableContext context) {

			FSL.ScheduleResult scheduleResult = FSL.ScheduleService.schedule(this.policyId,saList[num]);
			System.debug('scheduleResult: '+scheduleResult);
			this.num++;
			if( num < saList.size()){
				System.enqueueJob(new PocAsignacion.QueueSchedule(this.policyId, this.saList, this.num));
			}
		}      
	}
}