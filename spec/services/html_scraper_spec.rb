require 'rails_helper'

describe HtmlScraper do
  let(:fixture_path) { Rails.root.join('spec/fixtures/alza_product.html').to_s }

  before do
    html_content = File.read(fixture_path)
    allow(URI).to receive(:open).and_return(StringIO.new(html_content))
  end

  describe 'scraping from local HTML' do
    let(:fields) do
      {
        price: '.price-box__price',
        rating_count: '.ratingCount',
        rating_value: '.ratingValue'
      }
    end

    let(:result) { described_class.call(url: fixture_path, fields: fields) }

    it 'returns the expected values from the HTML fixture' do
      expect(result[:price]).to eq('18290')
      expect(result[:rating_count]).to eq('7 hodnocení')
      expect(result[:rating_value]).to eq('4,9')
    end
  end

  fdescribe 'scraping meta tags' do
    let(:meta_fields) do
      {
        "meta" => [ "keywords", "twitter:image" ]
      }
    end

    let(:result) { described_class.call(url: fixture_path, fields: meta_fields) }

    it 'extracts meta tag content by name and property' do
      expect(result["meta"]).to include(
        "keywords" => "Parní pračka AEG 7000 ProSteam",
        "twitter:image" => "https://example.com/image.jpg"
      )
    end
  end
end
