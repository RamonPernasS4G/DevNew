({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Nombre', fieldName: 'name', type: 'string'},
            {label: 'Dirección', fieldName: 'address', type: 'string'},
            {label: 'Procedencia', fieldName: 'procedencia', type: 'string'},
            {label: 'Num Póliza', fieldName: 'polizaName', type: 'string'},
            {label: 'Producto', fieldName: 'producto', type: 'string'},
            //{label: 'Fecha de Vencimiento', fieldName: 'fechaVencimiento', type: 'date'},
            {label: 'Activo', fieldName: 'activo', type: 'boolean'}
        ]);
        console.log(JSON.stringify(component.get("v.columns")));
        helper.getClients(component).then(function(result){
            console.log(JSON.stringify(result));
            component.set("v.accList", result.value);
        }).catch(function(error){

        });
    },
    handleSelectedRow : function(component, event){
        let comp = event.getParams().recordId;
        console.log(comp);
        console.log('comp.name ' + comp.name);
        console.log('comp.address ' + comp.address);
        component.set("v.name", comp.name);
        component.set("v.address", comp.address);

        console.log('comp.address ' + component.get("v.address"));
        //component.set("v.clientId", event.getParams().recordId);
    }
})