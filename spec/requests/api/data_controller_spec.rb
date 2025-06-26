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
      it 'returns scraped data' do
        post '/api/data', params: { url: url, fields: valid_fields }.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json).to include(
          'price' => '18290',
          'rating_count' => '7 hodnocení',
          'rating_value' => '4,9'
        )
      end
    end

    context 'with missing fields' do
      it 'returns 400 for missing fields' do
        post '/api/data', params: { url: url }.to_json, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'with missing url' do
      it 'returns 400 for missing url' do
        post '/api/data', params: { fields: valid_fields }.to_json, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'with malformed JSON' do
      it 'returns 400 for invalid JSON' do
        post '/api/data', params: 'not a json', headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end

  describe 'GET /api/data' do
    context 'with valid query params' do
      it 'returns scraped data' do
        get '/api/data', params: { url: url, fields: valid_fields }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['price']).to eq('18290')
        expect(json['rating_count']).to eq('7 hodnocení')
        expect(json['rating_value']).to eq('4,9')
      end
    end

    context 'with missing fields' do
      it 'returns 400 for missing fields' do
        get '/api/data', params: { url: url }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'with missing url' do
      it 'returns 400 for missing url' do
        get '/api/data', params: { fields: valid_fields }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end

  describe 'PUT /api/data (unsupported method)' do
    it 'returns 404 for unsupported methods' do
      put '/api/data', params: { url: url, fields: valid_fields }.to_json, headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
