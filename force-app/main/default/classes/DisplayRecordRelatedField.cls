public class DisplayRecordRelatedField {
    @AuraEnabled(cacheable=true)
    public static String getValue(String recordId,String fieldToDisplay,String objectApiName){
        try{
            String res=null;      
            String query='select '+fieldToDisplay+' from '+objectApiName;
            query+=' where Id = :recordId';
            query+=' limit 1';
            System.debug(query);
            sObject result=Database.query(query);
            if(fieldToDisplay.contains('.')){
                String[] aux=fieldToDisplay.split('\\.');
                System.debug(aux);
                res=(String)result.getSObject(aux[0]).get(aux[1]);
            }else{
                res=(String)result.get(fieldToDisplay);
            }
            return res;    
        }
        catch(Exception e){
            System.debug(e);
            return null;
        }
    }
}