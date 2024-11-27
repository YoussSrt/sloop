import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input"]

  connect() {
    this.inputTarget.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  disconnect() {
    this.inputTarget.removeEventListener("keydown", this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    // Si c'est Entrée sans Shift
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      // Vérifie si le message n'est pas vide (en ignorant les espaces)
      if (this.inputTarget.value.trim() !== "") {
        this.formTarget.requestSubmit()
      }
    }
  }
}
