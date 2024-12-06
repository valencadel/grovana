class SalesUploadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sales_upload, only: [:show, :destroy]

  def index
    @sales_uploads = current_company.sales_uploads.with_attached_image.order(created_at: :desc)
  end

  def show
  end

  def new
    @sales_upload = current_company.sales_uploads.build
  end

  def create
    @sales_upload = current_company.sales_uploads.build(sales_upload_params)

    if @sales_upload.save
      render json: {
        success: true,
        image_url: url_for(@sales_upload.image)
      }
    else
      render json: {
        error: @sales_upload.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @sales_upload.destroy
    redirect_to sales_uploads_path, notice: 'Invoice successfully deleted.'
  rescue ActiveRecord::RecordNotFound
    redirect_to sales_uploads_path, alert: 'Invoice not found'
  end

  private

  def set_sales_upload
    @sales_upload = current_company.sales_uploads.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to sales_uploads_path, alert: 'Invoice not found'
  end

  def current_company
    @current_company ||= if current_user
                          current_user.companies.first
                        elsif current_employee
                          current_employee.company
                        end
  end

  def sales_upload_params
    params.require(:sales_upload).permit(:image)
  end
end 
