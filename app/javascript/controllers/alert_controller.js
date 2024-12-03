import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
  static values = {
    icon: String,
    title: String,
    html: String,
    confirmButtonText: String,
    showCancelButton: Boolean,
    cancelButtonText: String
  }

  initSweetalert(event) {
    event.preventDefault(); // Prevent the form from being submitted after the submit button has been clicked

    Swal.fire({
      icon: this.iconValue,
      title: this.titleValue,
      html: this.htmlValue,
      confirmButtonText: this.confirmButtonTextValue,
      showCancelButton: this.showCancelButtonValue,
      cancelButtonText: this.cancelButtonTextValue,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#d33",
      backdrop: `rgba(173, 216, 230, 0.4)`,
      reverseButtons: true
    }).then((result) => {
      if (result.isConfirmed) {
        event.target.submit(); // Submit the form if the user confirms
        // form.requestSubmit(); // Submit the form using requestSubmit
      }
    })
  }

  confirmDelete(event) {
    event.preventDefault(); // Prevent the default link/button action

    Swal.fire({
      icon: this.iconValue,
      title: this.titleValue,
      html: this.htmlValue,
      confirmButtonText: this.confirmButtonTextValue,
      showCancelButton: this.showCancelButtonValue,
      cancelButtonText: this.cancelButtonTextValue,
      confirmButtonColor: "#3085d6",
      cancelButtonColor: "#d33",
      backdrop: `rgba(173, 216, 230, 0.4)`,
      reverseButtons: true
    }).then((result) => {
      if (result.isConfirmed) {
        fetch(event.target.href, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Accept': 'application/json'
          }
        }).then(response => {
          // window.location.href = '/purchases';
          window.location.reload();
        });
      }
    });
  }
}
