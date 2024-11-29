import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="preferences-form"
export default class extends Controller {
  connect() {
    // console.log(this.element)
    this.inputs = this.element.querySelectorAll('.form-check-input')
  }

  check(event) {
    const list = Array.from(this.inputs)
    const filteredList = list.filter((element) => {
      return element.checked === true
    });
    if (filteredList.length >= 4) {
      event.currentTarget.checked = false
      alert('You already did 3 choices for this question')
    }
  }
}
