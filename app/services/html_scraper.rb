require "nokogiri"
require "open-uri"
require "cgi"

class HtmlScraper
  def self.call(url:, fields:)
     # NOTE: In production, move this to Rails credentials or ENV
     api_key = "46cd9258e9e1e2a892d1e5e40a6135bd"
     proxy_url = "https://api.scraperapi.com?api_key=#{api_key}&url=#{CGI.escape(url)}"

     html = URI.open(proxy_url).read

     doc = Nokogiri::HTML.parse(html)

    fields.each_with_object({}) do |(key, selector), result|
      result[key] = doc.at_css(selector)&.text&.strip
    end
  end
end
