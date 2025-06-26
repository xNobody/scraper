require 'rails_helper'

describe HtmlScraper do
  let(:fixture_path) { Rails.root.join('spec/fixtures/alza_product.html').to_s }
  let(:html_content) { File.read(fixture_path) }
  let(:url) { fixture_path }

  let(:css_fields) do
    {
      price: '.price-box__price',
      rating_count: '.ratingCount',
      rating_value: '.ratingValue'
    }
  end

  let(:meta_fields) do
    {
      "meta" => [ "keywords", "twitter:image" ]
    }
  end

  before do
    allow(URI).to receive(:open).and_return(StringIO.new(html_content))
    Rails.cache.clear
  end

  describe 'scraping CSS selectors' do
    subject(:result) { described_class.call(url: url, fields: css_fields) }

    it 'returns expected values from the HTML fixture' do
      expect(result).to include(
        price: '18290',
        rating_count: '7 hodnocení',
        rating_value: '4,9'
      )
    end
  end

  describe 'scraping meta tags' do
    subject(:result) { described_class.call(url: url, fields: meta_fields) }

    it 'extracts meta tag content by name and property' do
      expect(result["meta"]).to include(
        "keywords" => "Parní pračka AEG 7000 ProSteam",
        "twitter:image" => "https://example.com/image.jpg"
      )
    end
  end

  describe 'caching behavior' do
    it 'uses Rails.cache to store HTML content' do
      expect(Rails.cache).to receive(:fetch)
        .with("scraper:#{url}", expires_in: 10.minutes)
        .and_call_original

      described_class.call(url: url, fields: css_fields)
    end
  end
end
