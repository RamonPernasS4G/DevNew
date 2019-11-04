/**
 * @File Name          : llegadaHelper.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 17/10/2019 11:03:22
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    17/10/2019   ismael.ocana@s4g.es     Initial Version
**/
({
    showToast: function(title, message, type, duration, mode, key){
        //Preset
        type = (type != null ? type : 'info');
        duration = (duration != null ? duration : 5000);
        mode = (mode != null ? mode : 'dismissible');
        key = (key != null ? key : 'info_alt');
        
        //Function
        $A.get("e.force:closeQuickAction").fire();
        var toast = $A.get("e.force:showToast");
        toast.setParams({ title: title, message: message, type: type, duration: duration, mode: mode, key: key});
        toast.fire();
        
        
    }
})