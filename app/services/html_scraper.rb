require "nokogiri"
require "open-uri"
require "cgi"

class HtmlScraper
  def self.call(url:, fields:)
    html = fetch_html(url)
    doc = Nokogiri::HTML.parse(html)

    fields.each_with_object({}) do |(key, selector_or_names), out|
      if key == "meta"
        out["meta"] = selector_or_names.each_with_object({}) do |meta_name, meta_result|
          tag = doc.at("meta[name='#{meta_name}']") || doc.at("meta[property='#{meta_name}']")
          meta_result[meta_name] = tag&.[]("content")
        end
      else
        out[key] = doc.at_css(selector_or_names)&.text&.strip
      end
    end
  end

  def self.fetch_html(url)
    api_key = "46cd9258e9e1e2a892d1e5e40a6135bd"
    proxy_url = "https://api.scraperapi.com?api_key=#{api_key}&url=#{CGI.escape(url)}"

    Rails.cache.fetch("scraper:#{url}", expires_in: 10.minutes) do
      URI.open(proxy_url).read
    end
  end
end
