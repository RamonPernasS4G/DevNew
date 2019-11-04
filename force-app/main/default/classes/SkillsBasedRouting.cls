/**
 * @File Name          : SkillsBasedRouting.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 24/9/2019 11:42:39
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/9/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class SkillsBasedRouting {
  @InvocableMethod
  public static void routeUsingSkills(List<String> cases) {
    List<Case> caseObjects = [SELECT Id, Description FROM Case WHERE Id in :cases];
    for (Case caseObj : caseObjects) {
      try {
        // Create a PendingServiceRouting to initiate routing
        createPendingServiceRouting(caseObj);
      } catch(exception e) {
        System.debug('ERROR:' + e.getStackTraceString());
        throw e;
      }
    }
  }
    
  static void createPendingServiceRouting(Case caseObj) {
    // Create a new SkillsBased PendingServiceRouting
    PendingServiceRouting psrObj = new PendingServiceRouting(
      CapacityWeight = 1,
      IsReadyForRouting = FALSE,
      RoutingModel  = 'MostAvailable',
      RoutingPriority = 1,
      RoutingType = 'SkillsBased',
      ServiceChannelId = getChannelId(),
      WorkItemId = caseObj.Id,
      PushTimeout = 0
    );
    insert psrObj;
    psrObj = [select id, IsReadyForRouting from PendingServiceRouting where WorkItemId = : psrObj.id];
      
    // Now add SkillRequirement(s) to the PendingServiceRouting
    SkillRequirement srObj = new SkillRequirement(
      RelatedRecordId = psrObj.id,
      SkillId = getSkillId(),
      SkillLevel = 1
    );
    insert srObj;
    
    // Update PendingServiceRouting as IsReadyForRouting
    psrObj.IsReadyForRouting = TRUE;
    update psrObj; 
  }
  
  static String getChannelId() {
    ServiceChannel channel = [Select Id From ServiceChannel Where RelatedEntity = 'Case'];
    return channel.Id;
  }
  
  static String getSkillId() {
    String skillName = 'Perito'; //Segurcaixa Electricista
    Skill skill = [Select Id From Skill Where DeveloperName = :skillName];
    return skill.Id;
  }
}