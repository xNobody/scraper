require "nokogiri"
require "open-uri"

class HtmlScraper
  def self.call(url:, fields:)
    html = URI.open(url).read
    doc = Nokogiri::HTML.parse(html)

    fields.each_with_object({}) do |(key, selector), result|
      result[key] = doc.at(selector)&.text&.strip
    end
  end
end
