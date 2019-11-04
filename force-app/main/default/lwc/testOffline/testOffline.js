import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/OfflineController.uploadFile';

export default class TestOffline extends LightningElement {

	@api recordId;

	pendingActions = new Set();
	selectedFiles = [];
	
	connectedCallback(){
		
		window.addEventListener('online', () => {
			if(this.pendingActions.size > 0){
				this.showToast('Subiendo ficheros','','info');
				this.pendingActions.forEach((pa) =>{
					if(pa === 'uploadFiles'){
						this.uploadFiles();
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

	handleFiles(event){
		this.selectedFiles = this.template.querySelector('input').files;
	}

	uploadPhoto(){
		if(navigator.onLine){
			this.uploadFiles();
		} else {
			this.showToast('Se ha encolado la subida de los ficheros','','info');
			this.pendingActions.add('uploadFiles');
		}
		
	}

	uploadFiles(){
		for(let i = 0; i< this.selectedFiles.length ;i++){

			let file = this.selectedFiles[i];

			const reader = new FileReader();
			reader.onload = (event) => {
				let data = event.target.result;
				data = data.split(',');
				
				const params = {
					'recordId' : this.recordId,
					'fileName' : file.name,
					'fileData' : data[1]
				};

				uploadFile(params)
				.then(() => {
					this.showToast('Fichero subido correctamente','','success');
				})
				.catch((error) => {
					console.log(JSON.stringify(error));
					this.showToast('No se ha podido subir el siguiente fichero',error,'error');
				})
				
			};
			reader.readAsDataURL(file);
		}
		


		
	}
}