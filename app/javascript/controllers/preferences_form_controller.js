import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="preferences-form"
export default class extends Controller {
  connect() {
    console.log("Hi from preferences form controller")
    this.inputs = this.element.querySelectorAll('.form-check-input');

  }

  check(event) {
  
    console.log("preferences checked")
    const selectedInputs = Array.from(this.inputs).filter(input => input.checked);
   

    if (selectedInputs.length >= 4 && event.currentTarget.checked) {
      event.preventDefault();
      event.currentTarget.checked = false;
      alert('You already made 3 choices for this question');
    }
    // else {
    //   this.element.submit();
    }
  }

