import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="next-button"
export default class extends Controller {
  static targets = ["wrapper"]

  connect() {
    this.wrapperTargets.forEach((element) => {
      if (this.wrapperTargets.indexOf(element) > 0) {
        element.classList.add("d-none")
      }
    })
  }
  next(event) {
    const currentDiv = Array.from(this.wrapperTargets).find((element) => !element.classList.contains("d-none"))
    const currentIndex = this.wrapperTargets.indexOf(currentDiv);
    console.log(currentIndex);
    console.log("Next button clicked!");
    // let el = document.getElementById("sibling").previousElementSibling;

    // static targets = ["element"];
    // toggle() {
    //   this.elementTarget.classList.toggle('d-none');
    // }

    this.wrapperTargets[currentIndex + 1].classList.remove("d-none");
    currentDiv.classList.add('d-none');
  }
}
