module Hancock::Cache::Fragments
  extend ActiveSupport::Concern
  included do
    @@hancock_cache_fragments = nil
    # before_action :load_fragments

    helper_method :hancock_cache_fragments
    def hancock_cache_fragments(reload = false)
      # @hancock_cache_fragments ||= Hancock::Cache::Fragment.cutted.all.to_a.map { |f| [f.name, f] }.to_h
      if reload
        Hancock::Cache::Fragment.reload!
        @@hancock_cache_fragments = Hancock::Cache::Fragment.loaded_info
      elsif Hancock::Cache::Fragment.loaded
        @@hancock_cache_fragments ||= Hancock::Cache::Fragment.loaded_info
      else
        Hancock::Cache::Fragment.load!
        @@hancock_cache_fragments = Hancock::Cache::Fragment.loaded_info
      end
      @@hancock_cache_fragments
    end
  end

  class_methods do
    def reload_fragments
      Hancock::Cache::Fragment.reload!
      @@hancock_cache_fragments = Hancock::Cache::Fragment.loaded_info
    end
  end

  protected
  def load_fragments
    hancock_cache_fragments(true)
  end
end
