({
	doInit : function(component, event, helper) {
        console.log('Init');
		var actionAPI = component.find("quickActionAPI");
        var args = { actionName :"ServiceAppointment.LogCall" }; 
        //var args = {"recordId":"0035E00000tggUqQAI" ,"targetName":"Contact","actionName":"Contact.Call","success":false,"parentContext":null};
        /*actionAPI.selectAction(args).then(function(result) {
            console.log('Success');
        }).catch(function(e) {
            if (e.errors) {
				console.log('Error: ' + JSON.stringify(e.errors));
            }
		});*/
    },
    
    logcall : function(component, event, helper){
        console.log('logcall');
    }
})