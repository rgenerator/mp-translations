# Sources controller to take care of CRUD operations
class SourcesController < ApplicationController
  before_action :populate_source, only: [:edit, :show, :update, :destroy]
  after_action :allow_iframe
  skip_before_action :verify_authenticity_token, :update_by_text_and_lang

  def index
    @sources = Source.where('text LIKE ?', "%#{params[:text]}%")
    @sources = @sources.where(language: params[:language]) if params[:language].present?
    @sources.paginate(page: params[:page], per_page: params[:per_page])
    flash.now[:alert] = 'No results found with given search criteria' if @sources.empty?
  end

  def new
    @source = Source.new
    @translations = @source.translations.build
  end

  def create
    @source = Source.new(source_params)
    if @source.save
      redirect_to @source, notice: 'Source and translations are saved successfully'
    else
      render action: 'new'
    end
  end

  def update
    if @source.update_attributes(source_params)
      redirect_to @source, notice: 'Source and translations are updated successfully'
    else
      render action: 'edit'
    end
  end

  def update_by_text_and_lang
    @source = Source.where(text: source_params[:original], language: source_params[:language]).first
    if @source
      if @source.update_attributes(source_params.except(:original))
        redirect_to @source, notice: 'Source text updated successfully'
      else
        render action: 'error', status: 500, locals: {message: "Unable to update source text."}
      end
    else
      render action: 'error', status: 200, locals: {message: "No translations found for source: <#{params[:original]}>"}
    end
  end

  def destroy
    @source.destroy
    redirect_to sources_url, notice: 'Source and translations destroyed successfully'
  end

  private

  def populate_source
    @source = Source.find(params[:id])
  end

  def source_params
    params.require(:source)
      .permit(:language, :text, :context, :original,
              translations_attributes: [:language, :text, :context, :id, :source_id])
  end

  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end
end
