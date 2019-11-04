({
    created : function(component, event, helper) {
        console.log('CREATED');
        helper.created(component, event);
    },
    renderCalendar : function(component, event, helper) {
        console.log('RENDER CALENDAR');
        var eventsMap = component.get("v.events");
        $(document).ready(function(){
            var eventArray = [];
            $.each(eventsMap, function(index, value){
                var newEvent = {
                    id : value.Id,
                    title : value.title,
                    start : moment(value.startDateTime),
                    end : moment(value.endDateTime),
                    description : value.description,
                    owner : value.owner,
                    woId : component.get("v.woId")
                }
                eventArray.push(newEvent);
            });
            var calendarButtons = component.get('v.calendarButtons');
            console.log('calendarButtons',calendarButtons);
            $('#calendar').fullCalendar({
                header: {
                    left: 'today prev,next',
                    center: 'title',
                    right: calendarButtons
                },
                defaultDate: moment().format("YYYY-MM-DD"),
                navLinks: true, // can click day/week names to navigate views
                editable: true,
                eventLimit: false, // allow "more" link when too many events
                weekends: component.get('v.weekends'),
                eventBackgroundColor: component.get('v.eventBackgroundColor'),
                eventBorderColor: component.get('v.eventBorderColor'),
                eventTextColor: component.get('v.eventTextColor'),
                events: eventArray,
                eventClick: function(calEvent, jsEvent, view) {
                    console.log('-- event click --');
                    component.set('v.titleVal', calEvent.title);
                    component.set('v.descriptionVal', calEvent.description);
                    component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                    component.set('v.endDateTimeVal', moment(calEvent.start._d + 1).format());
                    component.set('v.idVal', calEvent.id);
                    component.set('v.newOrEdit', 'Edit');
                    helper.openModal(component, event);
                },
                eventDrop: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).add(delta).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description,
                        "woId" : component.get("v.woId")
                    };
                    helper.upsertEvent(component, evObj);
                },
                eventResize: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description,
                        "woId" : component.get("v.woId")
                    };
                    helper.upsertEvent(component, evObj);
                },
                dayClick: function(date, jsEvent, view) {
                    console.log('-+-day click-+-');
                    console.log('date', JSON.stringify(date));
                    if (date._f == "YYYY-MM-DD"){
                        component.set('v.startDateTimeVal', moment(date.format()).add(12, 'hours').format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(14, 'hours').format());
                    } else {
                        component.set('v.startDateTimeVal', moment(date.format()).format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(2, 'hours').format());
                    }
                    console.log('before new or edit');
                    component.set('v.newOrEdit', 'New');
                    console.log('before open modal');
                    helper.openModal(component, event);
                }
            });
        });
    },
    createRecord : function(component, event, helper) {
        console.log('createRecord');
        var evObj = {
            "title" : component.get('v.titleVal'),
            "startDateTime" : moment(component.get('v.startDateTimeVal')).format(),
            "endDateTime" : moment(component.get('v.endDateTimeVal')).format(),
            "description" : component.get('v.descriptionVal'),
            "woId" : component.get("v.woId")
        };
        if (component.get('v.idVal')) {
            evObj.id = component.get('v.idVal');
            $('#calendar').fullCalendar( 'removeEvents', component.get('v.idVal') );
        }
        helper.upsertEvent(component, evObj, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var newEvent = {
                    id : response.getReturnValue().Id,
                    title : response.getReturnValue().title,
                    start : moment(response.getReturnValue().startDateTime),
                    end : moment(response.getReturnValue().endDateTime),
                    description : response.getReturnValue().description,
                    owner : response.getReturnValue().owner
                }
                $('#calendar').fullCalendar( 'renderEvent', newEvent );
                helper.closeModal(component, event);
                component.set('v.titleVal','');
                component.set('v.idVal','');
                component.set('v.startDateTimeVal','');
                component.set('v.endDateTimeVal','');
                component.set('v.descriptionVal','');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
    },
    deleteRecord : function(component, event, helper) {
        console.log('deleteRecord');
        helper.deleteEvent(component, event, event.getSource().get("v.value"), function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#calendar').fullCalendar( 'removeEvents', response.getReturnValue());
                helper.closeModal(component, event);
                component.set('v.titleVal','');
                component.set('v.idVal','');
                component.set('v.startDateTimeVal','');
                component.set('v.endDateTimeVal','');
                component.set('v.descriptionVal','');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
    },
    openModal : function(component, event, helper) {
        console.log('OPEN MODAL');
        helper.openModal(component, event);
    },
    closeModal : function(component, event, helper) {
        console.log('deleteRecord');
        helper.closeModal(component, event);
    }
})