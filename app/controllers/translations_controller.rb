# Sources controller to take care of CRUD operations
class TranslationsController < ApplicationController
  before_action :populate_source, only: [:destroy]

  def destroy
    @translation.destroy
    render :nothing => true
  end

  private

  def populate_source
    @translation = Translation.find(params[:id])
  end
end
