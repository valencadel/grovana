# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "sweetalert2", to: "https://ga.jspm.io/npm:sweetalert2@11.7.2/dist/sweetalert2.all.js"
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.1.3/app/assets/javascripts/activestorage.esm.js"
