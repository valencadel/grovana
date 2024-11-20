class PagesController < ApplicationController
  skip_before_action :authenticate_any!, only: :home

  def home
  end

  def dashboard
  end
end
