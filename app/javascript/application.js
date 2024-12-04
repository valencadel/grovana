// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
// import "@nathanvda/cocoon"
import "chartkick"
import "Chart.bundle"
import "@rails/activestorage"
import * as ActiveStorage from "@rails/activestorage"

// Inicializar Active Storage
ActiveStorage.start()
