require 'rails_helper'

RSpec.describe HtmlScraper do
  describe 'scraping from local HTML' do
    let(:fixture_path) { Rails.root.join('spec/fixtures/alza_product.html').to_s }
    let(:fields) do
      {
        price: '.price-box__price',
        rating_count: '.ratingCount',
        rating_value: '.ratingValue'
      }
    end

    subject(:result) { described_class.call(url: fixture_path, fields: fields) }

    it 'returns the expected values from the HTML fixture' do
      expect(result[:price]).to eq('18290')
      expect(result[:rating_count]).to eq('7 hodnocení')
      expect(result[:rating_value]).to eq('4,9')
    end
  end
end
