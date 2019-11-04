({
    init : function(component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
            type: "comm__namedPage",
            attributes: {
                "pageName" : "calendario-lwc"
            },
            state : {
                "workOrderId" : component.get("v.recordId")
            }
        };
        component.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        let defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
                navService.navigate(pageReference);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));

    } 
})