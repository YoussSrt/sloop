// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

document.addEventListener("DOMContentLoaded", function() {
  // Ajoutez un écouteur d'événement sur les boutons de soumission
  document.querySelectorAll('.sloopy-form').forEach(function(form) {
    form.addEventListener('submit', function(event) {
      // Vérifier si le bouton contient l'attribut `data-confirm`
      const confirmMessage = form.querySelector('input[type="submit"]').getAttribute('data-confirm');
      if (confirmMessage && !confirm(confirmMessage)) {
        event.preventDefault();  // Empêche l'envoi du formulaire si l'utilisateur annule
      }
    });
  });
});

document.addEventListener("turbo:load", () => {
  const saveButtons = document.querySelectorAll(".btn-save-toggle");

  saveButtons.forEach(button => {
    button.addEventListener("click", () => {
      if (!button.disabled) {
        button.disabled = true;
        button.classList.add("disabled");
      }
    });
  });
});


document.addEventListener("turbo:load", () => {
  const forms = document.querySelectorAll(".sloopy-form");

  forms.forEach(form => {
    form.addEventListener("submit", function (event) {
      const btn = form.querySelector("input[type='submit']");
      if (btn && btn.value.includes("Done")) {
        const confirmMessage = "Are you sure you want to mark this Sloopy as Done?";
        if (!confirm(confirmMessage)) {
          event.preventDefault();
        }
      }
    });
  });
});
