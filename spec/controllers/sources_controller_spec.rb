require 'rails_helper'

RSpec.describe SourcesController, type: :controller do
  let(:valid_attributes) { Fabricate.attributes_for(:source) }

  describe 'GET #index' do
    it 'assigns sources as @sources' do
      get :index
      expect(assigns(:sources)).to be_kind_of(ActiveRecord::Relation)
    end

    it 'returns first source from @sources' do
      2.times { Fabricate(:source) }
      get :index
      expect(assigns(:sources).first).to be_kind_of(Source)
    end

    it 'returns translations from first source from @sources' do
      2.times { Fabricate(:source) }
      get :index
      expect(assigns(:sources).first.translations.first).to be_kind_of(Translation)
    end
  end

  describe 'GET #new' do
    it 'assigns a new source as @source' do
      get :new, {}
      expect(assigns(:source)).to be_a_new(Source)
    end

    it 'assigns translations as @translations' do
      get :new, {}
      expect(assigns(:translations)).to be_a_new(Translation)
    end
  end

  describe 'POST #create' do
    describe 'with valid params' do
      it 'returns 302 response for successful creation' do
        post :create, source: valid_attributes
        expect(response.status).to eq(302)
      end

      it 'changes the count of Source translations by one on successful creation' do
        expect do
          post :create, source: valid_attributes
        end.to change { Source.count }.by(1)
      end

      it 'redirects to source translation page upon successful creation of source' do
        post :create, source: valid_attributes
        expect(response).to redirect_to(Source.last)
      end
    end

    describe 'with invalid params' do
      describe 'source attributes' do
        it 'should raise exception if required params are not passed' do
          expect do
            post :create
          end.to raise_error(ActionController::ParameterMissing)
        end

        it 'assigns a newly created but unsaved source translation as @source' do
          post :create, source: { language: 'zy', text: Faker::Lorem.paragraph }
          expect(assigns(:source)).to be_a_new(Source)
        end

        it 're-renders new template' do
          post :create, source: { language: 'zy', text: Faker::Lorem.paragraph }
          expect(response).to render_template(:new)
        end
      end

      describe 'translations attributes' do
        let(:source_params) do
          {  language: 'en-US',
             text: Faker::Lorem.paragraph,
             translations_attributes:
               {
                 '0' => {
                   text: Faker::Lorem.paragraph
                 }
               }
            }
        end

        it 'assigns a newly created but unsaved source translation as @source' do
          post :create, source: source_params
          expect(assigns(:source)).to be_a_new(Source)
        end

        it 'assigns a newly created but unsaved source translation as @source' do
          source_params[:translations_attributes]['0'][:language] = 'abc'
          post :create, source: source_params
          expect(assigns(:source)).to be_a_new(Source)
        end

        it 're-renders new template' do
          post :create, source: source_params
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET #show' do
    it 'assigns source as @source' do
      source = Fabricate(:source)
      get :show, id: source.id
      expect(assigns(:source)).to be_kind_of(Source)
    end
  end

  describe 'GET #edit' do
    it 'assigns source as @source' do
      source = Fabricate(:source)
      get :edit, id: source.id
      expect(assigns(:source)).to be_kind_of(Source)
    end
  end

  describe 'PATCH #update' do
    describe 'with valid attributes' do
      it 'updates the source record by id' do
        source = Fabricate(:source)
        source_params = Fabricate.attributes_for(:source)
        source_params[:text] = Faker::Lorem.paragraph
        source_params[:language] = 'en-GB'
        patch :update, source: source_params, id: source.id
        source.reload
        expect(source.text).to eq(source_params[:text])
        expect(source.language).to eq(source_params[:language])
      end

      it 'redirects to show page' do
        source = Fabricate(:source)
        source_params = Fabricate.attributes_for(:source)
        patch :update, source: source_params, id: source.id
        expect(response).to redirect_to(source)
      end
    end

    describe 'with invalid attributes' do
      it 'raises exception if given no params' do
        source = Fabricate(:source)
        expect do
          patch :update, id: source.id
        end.to raise_error(ActionController::ParameterMissing)
      end

      it 'assigns source to @source' do
        source = Fabricate(:source)
        source_params = {}
        source_params[:text] = Faker::Lorem.paragraph
        source_params[:language] = 'abc'
        patch :update, source: source_params, id: source.id
        expect(assigns(:source)).to be_kind_of(Source)
      end

      it 're-renders the edit page' do
        source = Fabricate(:source)
        source_params = {}
        source_params[:text] = Faker::Lorem.paragraph
        source_params[:language] = 'abc'
        patch :update, source: source_params, id: source.id
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'PATCH #update_by_text_and_lang' do
    describe 'with valid attributes' do
      it 'updates the source record by text and language' do
        source = Fabricate(:source)
        source_params = Fabricate.attributes_for(:source)
        source_params[:text] = Faker::Lorem.paragraph
        source_params[:language] = 'en-US'
        patch :update_by_text_and_lang, source: source_params, original: source.text, language: source.language
        source.reload
        expect(source.text).to eq(source_params[:text])
        expect(source.language).to eq(source_params[:language])
      end

      it 'redirects to show page' do
        source = Fabricate(:source)
        source_params = Fabricate.attributes_for(:source)
        patch :update_by_text_and_lang, source: source_params, original: source.text, language: source.language
        expect(response).to redirect_to(source)
      end
    end

    describe 'with invalid attributes' do
      it 'raises exception if given no params' do
        source = Fabricate(:source)
        expect do
          patch :update_by_text_and_lang, original: source.text, language: source.language
        end.to raise_error(ActionController::ParameterMissing)
      end

      it 'assigns source to @source' do
        source = Fabricate(:source)
        source_params = {}
        source_params[:text] = Faker::Lorem.paragraph
        source_params[:language] = 'abc'
        patch :update_by_text_and_lang, source: source_params, original: source.text, language: source.language
        expect(assigns(:source)).to be_kind_of(Source)
      end
    end  
  end
  
  describe 'DELETE #destroy' do
    let!(:source) { Fabricate(:source) }
    it 'decreases the count by -1' do
      expect do
        delete :destroy, id: source.id
      end.to change(Source, :count).by(-1)
    end

    it 'redirects to index page' do
      delete :destroy, id: source.id
      expect(response).to redirect_to(sources_url)
    end
  end
end
