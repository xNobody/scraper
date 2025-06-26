require "nokogiri"
require "open-uri"
require "cgi"

class HtmlScraper
  def self.call(url:, fields:)
    api_key = "46cd9258e9e1e2a892d1e5e40a6135bd" # or use ENV
    proxy_url = "https://api.scraperapi.com?api_key=#{api_key}&url=#{CGI.escape(url)}"

    html = URI.open(proxy_url).read
    doc = Nokogiri::HTML.parse(html)

    result = fields.each_with_object({}) do |(key, selector_or_names), out|
      if key == "meta"
        out["meta"] = selector_or_names.each_with_object({}) do |meta_name, meta_result|
          tag = doc.at("meta[name='#{meta_name}']") || doc.at("meta[property='#{meta_name}']")
          meta_result[meta_name] = tag&.[]("content")
        end
      else
        out[key] = doc.at_css(selector_or_names)&.text&.strip
      end
    end

    result
  end
end
