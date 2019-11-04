global class CaseEmailService implements Messaging.InboundEmailHandler { 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        /*
        System.debug('email.toAddresses');
        for(String s:email.toAddresses){
            System.debug(s);
        }
        System.debug('email.ccAddresses');
        if(email.ccAddresses != null){
            for(String s:email.ccAddresses){
                System.debug(s);
            }
        }
        
        
        System.debug('email.fromAddress');
        System.debug(email.fromAddress);
        
        System.debug(email);
        
        
        System.debug(envelope);
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        if(checkRegex('(?i)DNI:[\\s\\S][A-Za-z0-9]*',email.plainTextBody)){
            result.success=true;
        }else{
            result.success=false;
            result.message=email.plainTextBody;
        }*/
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success=true;
        return result;
    }
    
    private static Boolean checkRegex(String regex,String text){
        Pattern MyPattern = Pattern.compile(regex);
        
        Matcher MyMatcher = MyPattern.matcher(text);
        
        if(MyMatcher.find()){
            System.debug(MyMatcher.group(0));
            return true;
        }
        else{
            System.debug('No hay nada');
        }
        return false;
    }
    
    
    
}