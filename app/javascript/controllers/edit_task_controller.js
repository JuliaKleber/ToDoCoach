import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-task"
export default class extends Controller {

  static targets = ["info"]

  connect() {
    console.log("hello there!");
  }

  displayForm() {
    this.infoTarget.classList.add("d-none")
    // this.formTarget.classList.remove("d-none")
  }
}
