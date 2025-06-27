require 'rails_helper'

RSpec.describe 'Data API', type: :request do
  let(:fixture_path) { Rails.root.join('spec/fixtures/alza_product.html') }
  let(:html) { File.read(fixture_path) }
  let(:url) { 'https://mocked-url.com' }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  let(:valid_fields) do
    {
      price: '.price-box__price',
      rating_count: '.ratingCount',
      rating_value: '.ratingValue'
    }
  end

  before do
    allow(URI).to receive(:open).and_return(StringIO.new(html))
  end

  describe 'POST /api/data' do
    context 'with valid payload' do
      before do
        post '/api/data', params: { url: url, fields: valid_fields }.to_json, headers: headers
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes price in response' do
        expect(JSON.parse(response.body)['price']).to eq('18290')
      end

      it 'includes rating_count in response' do
        expect(JSON.parse(response.body)['rating_count']).to eq('7 hodnocení')
      end

      it 'includes rating_value in response' do
        expect(JSON.parse(response.body)['rating_value']).to eq('4,9')
      end
    end

    context 'with missing fields' do
      before do
        post '/api/data', params: { url: url }.to_json, headers: headers
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'with missing url' do
      before do
        post '/api/data', params: { fields: valid_fields }.to_json, headers: headers
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'with malformed JSON' do
      before do
        post '/api/data', params: 'not a json', headers: headers
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end

  describe 'GET /api/data' do
    context 'with valid query params' do
      before do
        get '/api/data', params: { url: url, fields: valid_fields }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes price in response' do
        expect(JSON.parse(response.body)['price']).to eq('18290')
      end

      it 'includes rating_count in response' do
        expect(JSON.parse(response.body)['rating_count']).to eq('7 hodnocení')
      end

      it 'includes rating_value in response' do
        expect(JSON.parse(response.body)['rating_value']).to eq('4,9')
      end
    end

    context 'with missing fields' do
      before do
        get '/api/data', params: { url: url }
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'with missing url' do
      before do
        get '/api/data', params: { fields: valid_fields }
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end

  describe 'PUT /api/data (unsupported method)' do
    it 'returns 404 status' do
      put '/api/data', params: { url: url, fields: valid_fields }.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
