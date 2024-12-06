class UploadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_upload, only: [ :show, :destroy ]

  def index
    @uploads = current_company.uploads.order(created_at: :desc)
  end

  def show
  end

  def new
    @upload = current_company.uploads.build
    respond_to do |format|
      format.html { render partial: "form", locals: { upload: @upload } }
    end
  end

  def create
    @upload = current_company.uploads.build(upload_params)

    if @upload.save
      render json: {
        success: true,
        image_url: url_for(@upload.image)
      }
    else
      render json: {
        error: @upload.errors.full_messages.join(", ")
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @upload.destroy
    redirect_to uploads_path, notice: "Imagen eliminada exitosamente."
  end

  private

  def set_upload
    @upload = current_company.uploads.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to uploads_path, alert: "Imagen no encontrada"
  end

  def current_company
    @current_company ||= if current_user
                          current_user.companies.first
    elsif current_employee
                          current_employee.company
    end
  end

  def upload_params
    params.require(:upload).permit(:image)
  end
end
