// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
// import * as bootstrap from "bootstrap"

// // Make bootstrap available globally
// window.bootstrap = bootstrap

// // Initialize Bootstrap components after DOM content loaded and after Turbo navigation
// document.addEventListener("DOMContentLoaded", initBootstrap)
// document.addEventListener("turbo:render", initBootstrap)

// function initBootstrap() {
//   // Dropdowns
//   const dropdownTriggers = document.querySelectorAll('[data-bs-toggle="dropdown"]')
//   dropdownTriggers.forEach(element => {
//     new bootstrap.Dropdown(element)
//   })

//   // Add other Bootstrap components initialization here if needed
// }