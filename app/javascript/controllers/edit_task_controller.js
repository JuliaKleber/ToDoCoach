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

  // update(event) {
  //   event.preventDefault()
  //   const url = this.formTarget.action
  //   fetch(url, {
  //     method: "PATCH",
  //     headers: { "Accept": "text/plain" },
  //     body: new FormData(this.formTarget)
  //   })
  //     .then(response => response.text())
  //     .then((data) => {
  //       this.cardTarget.outerHTML = data
  //     })
  // }
}
