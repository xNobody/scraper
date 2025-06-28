require 'rails_helper'
require "open-uri"

HTML_CONTENT = File.read(Rails.root.join('spec/fixtures/alza_product.html')).freeze
MOCK_URL = 'https://mocked-url.com'.freeze
HEADERS = { 'CONTENT_TYPE' => 'application/json' }.freeze
VALID_FIELDS = {
  price: '.price-box__price',
  rating_count: '.ratingCount',
  rating_value: '.ratingValue'
}.freeze
EXPECTED_PRICE = '18290'.freeze
EXPECTED_RATING_COUNT = '7 hodnocení'.freeze
EXPECTED_RATING_VALUE = '4,9'.freeze
ERROR_KEY = 'error'.freeze

RSpec.describe 'Data API', type: :request do
  before do
    allow(URI).to receive(:open).and_return(StringIO.new(HTML_CONTENT))
  end

  describe 'POST /api/data' do
    context 'with valid payload' do
      before do
        post '/api/data', params: { url: MOCK_URL, fields: VALID_FIELDS }.to_json, headers: HEADERS
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes price in response' do
        expect(JSON.parse(response.body)['price']).to eq(EXPECTED_PRICE)
      end

      it 'includes rating_count in response' do
        expect(JSON.parse(response.body)['rating_count']).to eq(EXPECTED_RATING_COUNT)
      end

      it 'includes rating_value in response' do
        expect(JSON.parse(response.body)['rating_value']).to eq(EXPECTED_RATING_VALUE)
      end
    end

    context 'with missing fields' do
      before do
        post '/api/data', params: { url: MOCK_URL }.to_json, headers: HEADERS
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include(ERROR_KEY)
      end
    end

    context 'with missing url' do
      before do
        post '/api/data', params: { fields: VALID_FIELDS }.to_json, headers: HEADERS
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include(ERROR_KEY)
      end
    end

    context 'with malformed JSON' do
      before do
        post '/api/data', params: 'not a json', headers: HEADERS
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include(ERROR_KEY)
      end
    end
  end

  describe 'GET /api/data' do
    context 'with valid query params' do
      before do
        get '/api/data', params: { url: MOCK_URL, fields: VALID_FIELDS }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes price in response' do
        expect(JSON.parse(response.body)['price']).to eq(EXPECTED_PRICE)
      end

      it 'includes rating_count in response' do
        expect(JSON.parse(response.body)['rating_count']).to eq(EXPECTED_RATING_COUNT)
      end

      it 'includes rating_value in response' do
        expect(JSON.parse(response.body)['rating_value']).to eq(EXPECTED_RATING_VALUE)
      end
    end

    context 'with missing fields' do
      before do
        get '/api/data', params: { url: MOCK_URL }
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include(ERROR_KEY)
      end
    end

    context 'with missing url' do
      before do
        get '/api/data', params: { fields: VALID_FIELDS }
      end

      it 'returns 400 status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes error message' do
        expect(JSON.parse(response.body)).to include(ERROR_KEY)
      end
    end
  end

  describe 'PUT /api/data (unsupported method)' do
    it 'returns 404 status' do
      put '/api/data', params: { url: MOCK_URL, fields: VALID_FIELDS }.to_json, headers: HEADERS
      expect(response).to have_http_status(:not_found)
    end
  end
end
