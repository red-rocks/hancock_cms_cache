if Hancock.mongoid?

  module Hancock::Cache::Snapshotable
    extend ActiveSupport::Concern

    included do

      scope :cutted, -> {
        without(:snapshot, :last_snapshot_time)
      }

      field :last_dump_snapshot_time, type: DateTime
      field :last_restore_snapshot_time, type: DateTime
      field :snapshot, type: String, localize: false

      def get_snapshot(prettify = true)
        _data = self.snapshot || ""
        (prettify ? "<pre>#{CGI::escapeHTML(Nokogiri::HTML.fragment(_data).to_xhtml(indent: 2))}</pre>".html_safe : _data)
      end
      def dump_snapshot
        self.snapshot = self.data(false)
      end
      def dump_snapshot!
        self.dump_snapshot
        self.last_dump_snapshot_time = Time.new
        self.save
      end

      def restore_snapshot
        Rails.cache.write(self.name, self.get_snapshot(false))
      end
      def restore_snapshot!
        self.restore_snapshot
        self.last_restore_snapshot_time = Time.new
        self.save
      end
    end

  end

end
