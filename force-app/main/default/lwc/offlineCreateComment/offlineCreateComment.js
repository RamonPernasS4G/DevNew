/**
 * @File Name          : offlineCreateComment.js
 * @Description        : 
 * @Author             : ismael.ocana@s4g.es
 * @Group              : 
 * @Last Modified By   : ismael.ocana@s4g.es
 * @Last Modified On   : 16/10/2019 10:09:02
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/10/2019   ismael.ocana@s4g.es     Initial Version
**/
import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createComentario from '@salesforce/apex/CreateComment.createComentario';



export default class OfflineCreateComment extends LightningElement {
    @api recordId;
    @api workOrderId;

	pendingActions = new Set();
	comment = [];
	
	connectedCallback(){
		
		window.addEventListener('online', () => {
			if(this.pendingActions.size > 0){
				this.showToast('Creando Comentario','','info');
				this.pendingActions.forEach((pa) =>{
					if(pa === 'createComment'){
						this.createComment();
					}
				});
			}
			
		});
		window.addEventListener('offline', () => {
			this.showToast('Conexion perdida','','error');
		});
	}

	showToast(title,message,variant){
		const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
		});
        this.dispatchEvent(evt);
	}

	handleComment(event){
        this.comment = event.detail.value;
        console.log('this.comment', JSON.stringify(this.comment));
	}

	createCommentHandler(){
        console.log('comment handler');
		if(navigator.onLine){
            console.log('online');
			this.createComment();
		} else {
			this.showToast('Se ha encolado la subida de los ficheros','','info');
			this.pendingActions.add('createComment');
		}
		
	}

	createComment(){ 
        console.log('createComment');
		createComentario({workOrderId: this.workOrderId, com: this.comment}).then(function(result){
            console.log('result', result);
        }
        ).catch(function(error){
            console.log('error', JSON.stringify(error));
        });
	}
}