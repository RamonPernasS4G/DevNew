/**
 * @File Name          : llegadaController.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 17/10/2019 10:59:42
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    17/10/2019   ismael.ocana@s4g.es     Initial Version
**/
({
    doInit : function(component, event, helper) {
        //title, message, type, duration, mode, key
        helper.showToast("Ya has registrado la llegada.", "Ya se ha registrado la llegada a ésta Cita.", "error", 10000);
    }
})