Hancock.rails_admin_configure do |config|
  config.action_visible_for :hancock_cache_clear, 'Hancock::Cache::Fragment'
  config.action_visible_for :hancock_touch, Proc.new { false }
end
