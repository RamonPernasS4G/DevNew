/**
 * @File Name          : ProfMapController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 16/10/2019 16:31:51
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    19/9/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class ProfMapController {

    public static String saType = String.valueOf(Schema.ServiceAppointment.getSObjectType());
    public static String woType = String.valueOf(Schema.WorkOrder.getSObjectType());

    @AuraEnabled(cacheable=true)
    /**
    * @description 
    * @author Ismael Ocaña | 19/9/2019 
    * @return List<MarkerWrapper> 
    **/
    public static List<MarkerWrapper> getMarkers(String filt, String timestamp){
        List<MarkerWrapper> mwList = new List<MarkerWrapper>();
        System.debug('filt ' + filt);
        Filter f;
        if(String.isNotBlank(filt)){
            f = (Filter)JSON.deserialize(filt, Filter.class);
        } 
        System.debug('f ' + f);
        String query = 'SELECT id, Status, AppointmentNumber, Street, City, State, PostalCode, Country, Latitude, Longitude, Urgente__c FROM ServiceAppointment ';
        String whereClause = ' WHERE (Street != null OR latitude != null)  ';
        String orderByClause = ' ORDER BY Urgente__c, SchedStartTime DESC ';
        if(f != null){
            whereClause += createWhere(f);
        }
        query += whereClause + orderByClause;
        System.debug('query ' + query);
        List<ServiceAppointment> saList = (List<ServiceAppointment>) Database.query(query);
        System.debug(saList.size());
        System.debug(saList);
        
        for(ServiceAppointment sa : saList){
            mwList.add(new MarkerWrapper(sa.City, sa.Country, sa.PostalCode, sa.State, sa.Street, sa.AppointmentNumber, (String)sa.Id , sa.Urgente__c, saType, sa.Latitude, sa.Longitude));
        }

        for(WorkOrder wo : [SELECT id, Street, City, State, PostalCode, Country, Latitude, Longitude, WorkOrderNumber FROM WorkOrder WHERE (Street != null OR Latitude != null)]){
            mwList.add(new MarkerWrapper(wo.City, wo.Country, wo.PostalCode, wo.State, wo.Street, wo.WorkOrderNumber, (String)wo.Id , false, woType, wo.Latitude, wo.Longitude));
        }

        return mwList;
    }   

    public static String createWhere(Filter f){
        String s = '';
        String desde, hasta;
        System.debug(' f.desde '+ f.desde);
        System.debug(' f.hasta '+ f.hasta);
        if(String.isNotBlank(f.urgente)){
            s += ' AND Urgente__c ='  + f.urgente ;
        }   
        if(String.isNotBlank(f.gremio)){
            s +=  ' AND  Gremio__c =' + '\'' + f.gremio + '\' ';
        }   
        if(f.desde != null){
            desde = f.desde.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            s +=  ' AND  SchedStartTime >= ' + desde + ' ';
        }
        if(f.hasta != null){
            hasta = f.hasta.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            s +=  ' AND  SchedEndTime <= ' + hasta + ' ';
        }
        return s;
    }

    public class MarkerWrapper{
        @AuraEnabled
        public Location location {get; set;}
        
        @AuraEnabled
        public String title {get;set;}
        
        @AuraEnabled
        public String description {get;set;}

        @AuraEnabled
        public String icon {get;set;}

        //@AuraEnabled
        //public String objId {get;set;}

        public MarkerWrapper(String city,String country,String postalCode, String state, String street, String appointmentNumber, String objId, Boolean urgente, String obj, Decimal latitude, Decimal longitude){
            this.location = new Location(city, country, postalCode,  state,  street, latitude, longitude);
            this.description = '';
            this.title = AppointmentNumber;
            this.description = '<p> Estado: En curso </p><p> Urgente: No </p>  ' + '<a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + '/profesionales/s/' + obj.toLowerCase() + '/' + objId + '" target="_blank">' + appointmentNumber + '</a>';
            this.icon = obj == saType ? (urgente ? 'standard:dashboard' : 'standard:cms') : 'standard:customer_360';
            //this.description = '<a href="'+'/' + objId + '">' + appointmentNumber + '</a>';
            //this.objId = objId;
        }
    }
    public class Location{
        @AuraEnabled
        public String City {get; set;}
        
        @AuraEnabled
        public String Country {get; set;}

        @AuraEnabled
        public String PostalCode {get; set;}

        @AuraEnabled
        public String State {get; set;}

        @AuraEnabled
        public String Street {get; set;}

        @AuraEnabled
        public Decimal Latitude {get; set;}

        @AuraEnabled
        public Decimal Longitude {get; set;}

        /*
        City: 'San Francisco',
        Country: 'USA',
        PostalCode: '94105',
        State: 'CA',
        Street: 'The Landmark @ One Market, Suite 300'
        */

        public Location(String city,String country,String postalCode, String state, String street, Decimal latitude, Decimal longitude){
            this.City = city;
            this.Country = country;
            this.PostalCode = postalCode;
            this.State = state;
            this.Street = street;
            if(latitude != null){
                this.Latitude = latitude;
            }
            if(longitude != null){
                this.Longitude = longitude;
            }
        }
    }
    public class Filter{
        @AuraEnabled
        public String urgente {get; set;}
        
        @AuraEnabled
        public String gremio {get; set;}

        @AuraEnabled
        public DateTime desde {get; set;}

        @AuraEnabled
        public DateTime hasta {get; set;}

        public Filter(String urgente, String gremio, DateTime desde, DateTime hasta){
            this.urgente = urgente;
            this.gremio = gremio;
            this.desde = desde;
            this.hasta = hasta;
        }
    }
}