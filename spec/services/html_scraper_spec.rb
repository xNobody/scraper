require 'rails_helper'

describe HtmlScraper do
  let(:fixture_path) { Rails.root.join('spec/fixtures/alza_product.html').to_s }
  let(:fields) do
    {
      price: '.price-box__price',
      rating_count: '.ratingCount',
      rating_value: '.ratingValue'
    }
  end

  before do
    html_content = File.read(fixture_path)
    allow(URI).to receive(:open).and_return(StringIO.new(html_content))
  end

  let(:result) { described_class.call(url: fixture_path, fields: fields) }

  describe 'scraping from local HTML' do
    it 'returns the expected values from the HTML fixture' do
      expect(result[:price]).to eq('18290')
      expect(result[:rating_count]).to eq('7 hodnocení')
      expect(result[:rating_value]).to eq('4,9')
    end
  end
end
