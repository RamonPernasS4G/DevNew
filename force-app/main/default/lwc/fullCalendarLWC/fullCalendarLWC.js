/* eslint-disable no-unused-vars */
import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import { getRecord } from "lightning/uiRecordApi";
import { updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import getSA from "@salesforce/apex/FullCalendarLWC.getSA";
import FULLCALENDAR from "@salesforce/resourceUrl/FullCalendar";

const WEEK_DAYS = ["Lu", "Ma", "Mie", "Ju", "Vi", "Sá", "Dom"];

// eslint-disable-next-line vars-on-top
// eslint-disable-next-line no-use-before-define
var parentThis;

export default class FullCalendarLWC extends LightningElement {
  horaInicioCalendario = "06:00";
  horaFinCalendario = "20:00";
  @api saList = [];
  @track eventList = [];
  @api showModal = false;
  @api workOrderId;
  @track horaInicio;
  @track horaFin;
  @track checkUrgente = false;
  @track createAbsence = false;
  modstamp = '';
  @track valueOptions = '';

  @track opcionesCreacion = [

  ];
  @track showCombo = false;

  @wire(getSA, {})
  wiredGetSA({ error, data }) {
    //console.log(JSON.stringify(data));
    if (data) {
      this.saList = data.evtList;
      this.horaInicioCalendario = data.startDate;
      this.horaFinCalendario = data.endDate;
      //console.log(JSON.stringify(data));
      parentThis = this;
      this.renderCalendar();
      this.updateTimeFrameCalendar();
      console.log(this.workOrderId);
      if(this.workOrderId){
        this.opcionesCreacion = [{label:'Cita de Servicio', value : 'ServiceAppointment'}, {label : 'Ausencia', value : 'ResourceAbsence'}];
        this.valueOptions = 'ServiceAppointment';
        console.log('this.opcionesCreacion', JSON.stringify(this.opcionesCreacion));
        console.log('this.valueOptions', JSON.stringify(this.valueOptions));
        this.showCombo = true;
      }else{
        this.opcionesCreacion = [{label : 'Ausencia', value : 'ResourceAbsence'}];
        this.valueOptions = 'ResourceAbsence';
        console.log('this.opcionesCreacion', JSON.stringify(this.opcionesCreacion));
        console.log('this.valueOptions', JSON.stringify(this.valueOptions));
        this.showCombo = true;
      }
    } else if (error) {
      console.log("error", JSON.stringify(error));
    }
  }

  updateTimeFrameCalendar() {
    if (this.isCalendarInitialized()) {
      this.$j(this.divCalendar).fullCalendar("option", "businessHours", {
        dow: [1, 2, 3, 4, 5],
        start: this.horaInicio,
        end: this.horaFin
      });
    }
  }

  isCalendarInitialized() {
    return this.fullCalendarInitialized && this.$j;
  }

  handleChangeCreacion(event){
    this.valueOptions = event.detail.value;    
  }
  renderCalendar() {
    console.log("renderedCallback");
    if (self.fullCalendarInitialized) {
      return;
    }

    this.fullCalendarInitialized = true;
    Promise.all([
      loadScript(this, FULLCALENDAR + "/fullcalendar-3.10.0/lib/jquery.min.js"),
      loadScript(this, FULLCALENDAR + "/fullcalendar-3.10.0/lib/moment.min.js"),
      loadScript(
        this,
        FULLCALENDAR + "/fullcalendar-3.10.0/fullcalendar.min.js"
      ),
      loadStyle(
        this,
        FULLCALENDAR + "/fullcalendar-3.10.0/fullcalendar.min.css"
      )
    ])
      .then(() => {
        loadScript(this, FULLCALENDAR + "/fullcalendar-3.10.0/locale-all.js")
          .then(() => {
            this.saList.forEach(value => {
              console.log('value llamada', value.llamada);
              var newEvent = {
                id: value.Id,
                title: value.title,
                start: moment(value.startDateTime),
                end: moment(value.endDateTime),
                description: value.description,
                owner: value.owner,
                status : value.status,
                urgente : value.urgente,
                llamada : value.tipoLLamada
              };
              this.eventList.push(newEvent);
            });
            this.initJquery();
            this.initFullCalendar();
          })
          .catch(error => {
            console.error("Error Loading Full Calendar Locale", error);
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error loading Full Calendar Locale",
                message: error,
                variant: "error"
              })
            );
          });
      })
      .catch(error => {
        console.error("Error Loading Full Calendar", error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error loading Full Calendar",
            message: error,
            variant: "error"
          })
        );
      });
  }

  handleAusencia(event){
    this.createAbsence = event.detail.checked;
  }

  initJquery() {
    this.$j = jQuery.noConflict();
  }

  initFullCalendar() {
    console.log("init full calendar");
    let start = this.horaInicioCalendario;
    let end = this.horaFinCalendario;
    this.divCalendar = this.template.querySelector("div.fullCalendar");
    this.$j(this.divCalendar).fullCalendar({
      header: {
        left: "today prev,next",
        center: "title",
        right: "agendaDay, agendaWeek"
      }, 
      //pasarlo a label
      locale: "es",
      //,dayNamesShort : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      businessHours: {
        // days of week. an array of zero-based day of week integers (0=Sunday)
        dow: [ 1, 2, 3, 4, 5 ], // Monday - Thursday
      
        start: this.horaInicioCalendario, // a start time (10am in this example)
        end: this.horaFinCalendario, // an end time (6pm in this example)
      },
      defaultDate: moment().format("YYYY-MM-DD"),
      navLinks: true, 
      slotLabelFormat: "H:mm",
      slotDuration: "00:30:00",
      displayEventTime: true,
      defaultView: "agendaWeek",
      firstDay: 1
      ,editable : false
      ,eventStartEditable : false
      ,eventDurationEditable : false
      ,droppable : false
      ,minTime:'00:00'
      ,maxTime:'24:00'
      ,weekends: true
      , hiddenDays : [0]
      ,columnHeaderFormat: "ddd",
      allDaySlot: false,
      nowIndicator: true, 
      events: this.eventList,
      height: "auto",
      dayClick: this.showModalHelper,
      eventRender : this.eventRenderLWC
    });
  }

  showModalHelper(date, jsEvent, view) {
    parentThis.showModal = true;
    if (date._f == "YYYY-MM-DD") {
      parentThis.horaInicio = moment(date.format())
        .add(12, "hours")
        .format();
      parentThis.horaFin = moment(date.format())
        .add(14, "hours")
        .format();
    } else {
      parentThis.horaInicio = moment(date.format()).format();
      parentThis.horaFin = moment(date.format())
        .add(2, "hours")
        .format();
    }
  }
  openModal(event) {
    this.showModal = true;
  }
  handleCloseModal(event) {
    this.showModal = false;
  }
  setShowModal(param) {
    this.showModal = param;
  }
  handleEventCreated(event){
    let evt = event.detail.record;
    let newEvent = {
      id: evt.Id,
      title: evt.title,
      start: moment(evt.startDateTime),
      end: moment(evt.endDateTime),
      description: evt.description,
      owner: evt.owner,
      status : evt.status,
      urgente : evt.urgente,
      llamada : evt.tipoLLamada
    };
    this.$j(this.divCalendar).fullCalendar( 'renderEvent', newEvent);
    this.setShowModal(false);
  }

  eventRenderLWC(event, element) {
    console.log('event', event);
    console.log('element',element);
    console.log('event urg', event.urgente);
    console.log('event status', event.status);
    console.log('event llamada', event.llamada);
    if(event.urgente == true){
      console.log('in urgente', event.title);
      element.css('background-color', '#ff1111');
    }else if(event.llamada === true){
      element.css('background-color', '#AF007A');
    }
    else{
      switch(event.status){
        case "Enviado" : element.css('background-color', '#009999'); break;
        case "En curso" : element.css('background-color', '#339933'); break;
        case "Completado" : element.css('background-color', '#0000cc'); break;
        case "Vacaciones" : element.css('background-color', '#6FD100'); break;
        default : console.log("default");
      }
    }
  }
  handleUrgenteChange(event){
    console.log('event', event.detail);
    this.checkUrgente = event.detail.checked;
    console.log('this.checkUrgente', this.checkUrgente);
  }
  buscar(event){
    console.log('buscar');
    let date = new Date();
    this.modstamp = date.getTime();
    getSA({urgente:this.checkUrgente, modstamp:this.modstamp }).then((data) => {
      this.eventList = [];
        data.forEach(value => {
          var newEvent = {
            id: value.Id,
            title: value.title,
            start: moment(value.startDateTime),
            end: moment(value.endDateTime),
            description: value.description,
            owner: value.owner,
            status : value.status,
            urgente : value.urgente
          };
          this.eventList.push(newEvent);
        });
        console.log('data', data);
        console.log('dathis.eventList.ta', this.eventList);
        this.$j(this.divCalendar).fullCalendar( 'removeEvents');
        this.$j(this.divCalendar).fullCalendar( 'renderEvents', this.eventList);
      }
    ).catch(error => {
      console.log('error', error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading events",
          message: error,
          variant: "error"
        })
      );
    });
  }
}