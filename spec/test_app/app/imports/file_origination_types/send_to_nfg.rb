# frozen_string_literal: true

module FileOriginationTypes
  class SendToNfg < FileOriginationTypes::Base

    class << self
      def name
        'Send To Network for Good for Processing'
      end

      def logo_path
        "http://placehold.it/280x200"
      end

      def description
        'Not sure if you got the chops to do your own import? Let NFG handle the import for you.'
      end
    end
  end
end