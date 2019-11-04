public class FCMNotification {

    @InvocableMethod(label='Send FCM Notification' description='Send FCM Notification')
    public static void invocableNotification(List<Notification__c> notificationsToSend){
        List<Id> notificationIds=new List<Id>();
        Integer count=0;
        for(Integer i=0;i<notificationsToSend.size();i++){
            notificationIds.add(notificationsToSend[i].Id);
            count++;
            if(count==99 || i==notificationsToSend.size()-1){
                invocableNotificationAux(notificationIds);
                notificationIds.clear();
                count=0;
            }
        }
    }
    
    @future(callout=true)
    public static void invocableNotificationAux(List<Id> notificationIds){
        //TO-DO Check users and their device Id from FCM
        for(Notification__c notification:[select Id,Name from Notification__c where Id IN :notificationIds]){
            String FCMId='cUXFlaECF80:APA91bEAZBOdyuAsYjon7540CxL37681BPdKKM-wtrNCK8Imry24LvtIihup6xM1yMzNM6A-dL-R_rkJW2TMpXWxqiIzYA0tzAOFfpX1f_jIxgu8PjiizEcMxgNuLapFm6JFEdXBPRMh';
            sendNotification(notification.name,notification.Id,FCMId);
        }
    }
    
    public static void sendNotification(String title,String body,String sendTo){
        try{
            String requestBody='{"to" : "{{sendTo}}","notification" : {"body" : "{{body}}","title": "{{title}}"},"data" : {"body" : "{{body}}","title": "{{title}}","parametro":"{{body}}"}}';
            requestBody=requestBody.replace('{{title}}', title).replace('{{sendTo}}',sendTo).replace('{{body}}',body);
            HttpRequest req= new HttpRequest();
            req.setMethod('POST'); 
            req.setEndpoint('callout:FCM/fcm/send');
            req.setHeader('Authorization', 'key={!$Credential.Password}');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            if(res.getStatusCode()==200){
                System.debug('res.getBody()');
                System.debug(res.getBody());
            }
        }catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getCause());
            System.debug(e.getStackTraceString());
        }
    }
}