({
    getClients : function(component) {
        var self = this;
        var action = component.get('c.getAccounts');
        
        action.setParams({
              companyId : component.get("v.companyName")
            , identificador: component.get("v.identificador")
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
    }
})