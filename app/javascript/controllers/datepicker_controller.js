import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

// Connects to data-controller="datepicker"
export default class extends Controller {
  static targets = ["range"]
  connect() {
    flatpickr(this.rangeTarget, {
      dateFormat: "Y-m-d",
      minDate: "today",
      mode: "range",
      })
  }
}
