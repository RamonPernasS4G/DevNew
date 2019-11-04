({
    createCaseHelper : function(component) {
        var self = this;
        var action = component.get('c.createNewCase');
        //createNewCase(String companyId, String clientId, String description, String subject, String motivo)
        action.setParams({
              companyId : component.get("v.companyId")
            , clientId: component.get("v.clientId")
            , description: component.get("v.descripcion")
            , subject: component.get("v.asunto")
            , motivo: component.get("v.motivo")
            , name : component.get("v.name")
            , address : component.get("v.address")
            , relacion : component.get("v.relacion")
        });
        return new Promise(function(resolve, reject){
            action.setCallback(self, function(response){
                let resp = {"state" : "", "value" : ""};
                if(response.getState() === 'SUCCESS'){
                    resp.state = response.getState();
                    resp.value = response.getReturnValue();
                    resolve(resp);
                }else{
                    resp.state = response.getState();
                    resp.value = response.getError()[0];
                    reject(resp);
                }
            });
            $A.enqueueAction(action);
        });
    },
    showToast: function(title, message, type, duration, mode, key){
        //Preset
        type = (type != null ? type : 'info');
        duration = (duration != null ? duration : 5000);
        mode = (mode != null ? mode : 'dismissible');
        key = (key != null ? key : 'info_alt');
        
        //Function
        var toast = $A.get("e.force:showToast");
        toast.setParams({ title: title, message: message, type: type, duration: duration, mode: mode, key: key});
        toast.fire();
    }
})