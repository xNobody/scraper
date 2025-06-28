require 'rails_helper'

Rails.cache = ActiveSupport::Cache.lookup_store(:memory_store)

FIXTURE_PATH = Rails.root.join('spec/fixtures/alza_product.html').to_s
HTML_URL = File.read(FIXTURE_PATH)
URL = FIXTURE_PATH
CSS_FIELDS = {
  price: '.price-box__price',
  rating_count: '.ratingCount',
  rating_value: '.ratingValue'
}.freeze
META_FIELDS = {
  "meta" => [ "keywords", "twitter:image" ]
}.freeze
EXPECTED_CSS_RESULT = {
  price: '18290',
  rating_count: '7 hodnocení',
  rating_value: '4,9'
}.freeze
EXPECTED_META_RESULT = {
  "keywords" => "Parní pračka AEG 7000 ProSteam",
  "twitter:image" => "https://example.com/image.jpg"
}.freeze

describe HtmlScraper do
  before do
    allow(URI).to receive(:open).and_return(StringIO.new(HTML_URL))
    Rails.cache.clear
  end

  describe 'scraping CSS selectors' do
    subject(:result) { described_class.call(url: URL, fields: CSS_FIELDS) }

    it 'returns expected values from the HTML fixture' do
      expect(result).to include(EXPECTED_CSS_RESULT)
    end
  end

  describe 'scraping meta tags' do
    subject(:result) { described_class.call(url: URL, fields: META_FIELDS) }

    it 'extracts meta tag content by name and property' do
      expect(result["meta"]).to include(EXPECTED_META_RESULT)
    end
  end

  describe 'caching behavior' do
    before do
      allow(Rails.cache).to receive(:fetch).and_call_original
    end

    it 'uses Rails.cache to store HTML content' do
      described_class.call(url: URL, fields: CSS_FIELDS)
      expect(Rails.cache).to have_received(:fetch)
        .with("scraper:#{URL}", expires_in: 10.minutes)
    end

    context 'when HTML is already cached' do
      before do
        Rails.cache.clear
        allow(URI).to receive(:open).and_return(StringIO.new(HTML_URL))
        described_class.call(url: URL, fields: CSS_FIELDS)
      end

      it 'does not fetch HTML again' do
        described_class.call(url: URL, fields: CSS_FIELDS)
        expect(URI).to have_received(:open).once
      end
    end
  end
end
