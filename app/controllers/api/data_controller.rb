module Api
  class DataController < ApplicationController
    def index
      url, fields = extract_params

      if url.blank? || fields.blank?
        render json: { error: "Missing 'url' or 'fields'" }, status: :bad_request
        return
      end

      fields = fields.is_a?(ActionController::Parameters) ? fields.permit!.to_h : fields
      result = HtmlScraper.call(url: url, fields: fields)

      render json: result
    end

    private

    def extract_params
      if request.get?
        [ params[:url], params[:fields] || {} ]
      elsif request.post?
        json = JSON.parse(request.body.read) rescue {}
        [ json["url"], json["fields"] || {} ]
      else
        [ nil, {} ]
      end
    end
  end
end
