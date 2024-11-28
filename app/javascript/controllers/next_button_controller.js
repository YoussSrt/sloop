import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="next-button"
export default class extends Controller {
  connect() {
    console.log("NextButton controller connected!")
  }

  next(event) {
    event.preventDefault()
    console.log("Next button clicked!")
  }
}

