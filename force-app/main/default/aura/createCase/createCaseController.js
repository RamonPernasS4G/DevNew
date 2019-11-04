({
    doInit : function(component, event, helper) {
        //helper.createCaseHelper(component).then(function(result){
        let msg = 'Caso creado correctamente. Por favor pulse en finalizar.'
        component.set("v.respuesta", msg);
        helper.showToast("Caso creado.", msg, "success", null, null, null );
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": $A.get("$Label.c.Demo_case"),    
            "slideDevName": "detail"
        });
        navEvt.fire();

       /* }).catch(function(error){
            let msg = 'Error en el proceso. Por favor pulse en finalizar para volverlo a intentar.'
            helper.showToast("Error", msg, "error", null, null, null );
            component.set("v.respuesta", msg);
        });*/
    }
})