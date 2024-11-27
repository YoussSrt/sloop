import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.scrollToBottom();
    this.setupObserver();
  }

  setupObserver() {
    // Observer pour détecter les nouveaux messages
    this.observer = new MutationObserver(() => {
      this.scrollToBottom();
    });

    // Observer les changements dans le conteneur de messages
    this.observer.observe(this.element, {
      childList: true,
      subtree: true
    });
  }

  // Appelé quand Turbo Stream met à jour le contenu
  messageTargetConnected() {
    this.scrollToBottom();
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      this.element.scrollTop = this.element.scrollHeight;
    });
  }
}
