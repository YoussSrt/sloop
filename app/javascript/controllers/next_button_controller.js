import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="next-button"
export default class extends Controller {
  static targets = ["wrapper"]

  static values = {
    currentIndex: Number,
    default: 0
  }

  connect() {
    const firstDiv = this.wrapperTargets[0].parentElement
    firstDiv.classList.remove("d-none")
  }

  next() {
    const currentDiv = this.wrapperTargets[this.currentIndexValue].parentElement
    const nextDiv = this.wrapperTargets[this.currentIndexValue + 1].parentElement

    currentDiv.classList.add('d-none');
    nextDiv.classList.remove("d-none");

    this.currentIndexValue += 1;
  }
}
