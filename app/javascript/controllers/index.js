// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import SalesUploadController from "./sales_upload_controller"
eagerLoadControllersFrom("controllers", application)
application.register("sales-upload", SalesUploadController)
