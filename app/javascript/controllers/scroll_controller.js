import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    this.element.addEventListener("DOMNodeInserted", this.scrollToBottom)
  }

  disconnect() {
    this.element.removeEventListener("DOMNodeInserted", this.scrollToBottom)
  }

  scrollToBottom = () => {
    this.element.scrollTop = this.element.scrollHeight
  }
}
