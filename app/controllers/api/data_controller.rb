module Api
  class DataController < ApplicationController
    ERROR_RESPONSE = { error: "Missing 'url' or 'fields'" }.freeze

    def index
      url, fields = extract_params

      if url.blank? || fields.blank?
        render json: ERROR_RESPONSE, status: :bad_request
        return
      end

      fields = normalize_fields(fields)
      result = HtmlScraper.call(url: url, fields: fields)

      render json: result
    end

    private

    def extract_params
      if request.get?
        [ params[:url], params[:fields] || {} ]
      elsif request.post?
        json = parse_json_body
        [ json["url"], json["fields"] || {} ]
      else
        [ nil, {} ]
      end
    end

    def parse_json_body
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      {}
    end

    def normalize_fields(fields)
      fields.is_a?(ActionController::Parameters) ? fields.permit!.to_h : fields
    end
  end
end
