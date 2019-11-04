/**
 * @File Name          : navigateTo.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 22/10/2019 13:38:42
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { FlowNavigationBackEvent } from 'lightning/flowSupport';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';


const NAVIGATE_STANDARD_OBJECT_PAGE = 'standard__objectPage';
const NAVIGATE_STANDARD_RECORD_PAGE = 'standard__recordPage';
const NAVIGATE_STANDARD_RELATED = 'standard__recordRelationshipPage';
const NAVIGATE_STANDARD_TAB = 'standard__navItemPage';
const NAVIGATE_STANDARD_WEB = 'standard__webPage';
const LIST = 'list';

export default class NavigateTo extends NavigationMixin(LightningElement) {

    @api objName;
    @api filterName;
    @api actionName;
    @api recordId;
    @api relationName;
    @api tabApiName;
    @api url;

    @api isFlow;
    @api navigation;
    @api flowStep;

    @api navigateToListView(objName, filterName){
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_OBJECT_PAGE,
            attributes: {
                objectApiName: objName,
                actionName: LIST
            },
            state: {
                filterName: filterName
            },
        });
    }

    @api navigateToObjectHome(objName, filterName) {
        // Navigate to the Case object home page.
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_OBJECT_PAGE,
            attributes: {
                objectApiName: objName,
                actionName: filterName
            }
        });
    }

    @api navigateToNewRecordPage(objName, actionName) {
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_OBJECT_PAGE,
            attributes: {
                objectApiName: objName,
                actionName: actionName
            }
        });
    }

    @api navigateToRecordViewPage(recordId, objName, actionName) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_RECORD_PAGE,
            attributes: {
                recordId: recordId,
                objectApiName: objName, // objectApiName is optional
                actionName: actionName
            }
        });
    }

    @api navigateToRecordEditPage(recordId, objName, actionName) {
        // Opens the Account record modal
        // to view a particular record.
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_RECORD_PAGE,
            attributes: {
                recordId: recordId,
                objectApiName: objName, // objectApiName is optional
                actionName: actionName
            }
        });
    }

    @api navigateToRelatedList(recordId, objName, relationName, actionName) {
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_RELATED,
            attributes: {
                recordId: recordId,
                objectApiName: objName,
                relationshipApiName: relationName,
                actionName: actionName
            }
        });
    }

    @api navigateToTabPage(tabApiName) {
        // Navigate to a specific CustomTab.
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_TAB,
            attributes: {
                apiName: tabApiName
            }
        });
    }

    @api navigateToWebPage(url) {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: NAVIGATE_STANDARD_WEB,
            attributes: {
                url: url
            }
        },
        false
      );
    }

    renderedCallback(){
        if(this.validateNavigation()){
            this.handleSelection();
            this.handleNextStep();
        }
    }

    validateNavigation(){
        return this.isFlow === true && this.navigation != null && this.navigation != undefined && this.navigation != "";
    }

    handleSelection(){
        switch (this.navigation) {
            case "Vista de lista" : this.navigateToListView(this.objName, this.filterName); break;
            case "Página de objeto" : this.navigateToObjectHome(this.objName, this.filterName); break;
            case "Nuevo" : this.navigateToNewRecordPage(this.objName, this.actionName); break;
            case "Registro" : this.navigateToRecordViewPage(this.recordId, this.objName, this.actionName); break;
            case "Edición" : this.navigateToRecordEditPage(this.recordId, this.objName, this.actionName) ; break;
            case "Lista relacionada" : this.navigateToRecordEditPage(this.recordId, this.objName, this.actionName); break;
            case "Ficha" : this.navigateToTabPage(this.tabApiName); break;
            case "Web" : this.navigateToWebPage(this.url); break;
            default : break;
        }
    }

    handleNextStep(){
        switch(this.flowStep){
            case "Siguiente" : this.dispatchEvent(new FlowNavigationNextEvent()); break;
            case "Finalizar" : this.dispatchEvent(new FlowNavigationFinishEvent()); break;
            case "Atrás" : this.dispatchEvent(new FlowNavigationBackEvent()); break;
            default : break;
        }
    }
}