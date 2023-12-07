import { Controller } from "@hotwired/stimulus"
import Snap from "snapjs";

// Connects to data-controller="edit-task"
export default class extends Controller {

  static targets = ["modal", "inner"];

  taskId = this.data.get('id');
  threshold = 100;
  // startX;
  // endX;
  CSRF_TOKEN = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  bsTarget= document.querySelector('#modal-target')
  myModal = new bootstrap.Modal(document.getElementById('staticBackdrop'), {});

  connect() {
    // this.enableSwipe()
    this.snapper = new Snap ({
      element: this.innerTarget,
      maxPosition: 50,
      minPosition: -50,
      resistance: 1,
    })

    // this.snapper = new Snap({
    //   element: this.innerTarget,
    //   maxPosition: 50,
    //   minPosition: -50,
    //   disable: 'right'
    // })
  }

  displayForm() {
    this.myModal.show();
  }

  // enableSwipe(){
  //   this.taskCardTarget.addEventListener('touchstart', (e)=> this.startX = e.touches[0].clientX );
  //   this.taskCardTarget.addEventListener('touchmove', (e)=> this.endX = e.touches[0].clientX );
  //   this.taskCardTarget.addEventListener('touchend', this.handleSwipe());
  // }

  deleteTask() {
    console.log("triggered delete");
    fetch(`/tasks/${this.taskId}`, {
      method: "DELETE",
      headers: {
        'X-CSRF-Token': this.CSRF_TOKEN,
        'Content-Type': 'application/json',
      },
    }).then(()=>{
      window.location.reload();
    })
    if(this.startX + this.threshold > this.endX){
    } else if (this.startX + 100 < this.endX) {
      this.displayForm()
    }
  }

}
