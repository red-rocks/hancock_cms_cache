module Hancock::Cache::AjaxCsrf
  extend ActiveSupport::Concern

  included do
    include Hancock::Cache::NoCache      
    skip_before_action :find_page, only: [:csrf_meta]

    def csrf_meta

      set_cache_buster
      # expires_now
      # response.headers["Pragma"] = "no-cache"

      respond_to do |format|
        format.json do
          render json: {
            param: request_forgery_protection_token,
            token: form_authenticity_token
          }
        end
      end
    end
  end

end
