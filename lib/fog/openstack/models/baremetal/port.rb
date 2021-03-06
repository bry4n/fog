require 'fog/core/model'

module Fog
  module Baremetal
    class OpenStack
      class Port < Fog::Model
        identity :uuid

        attribute :address
        attribute :uuid

        #detailed
        attribute :created_at
        attribute :updated_at
        attribute :extra
        attribute :node_uuid

        def initialize(attributes)
          # Old 'connection' is renamed as service and should be used instead
          prepare_service_value(attributes)
          super
        end

        def save
          requires :address, :node_uuid
          identity ? update : create
        end

        def create
          requires :address, :node_uuid
          merge_attributes(service.create_port(self.attributes).body)
          self
        end

        def update(patch=nil)
          requires :uuid
          if patch
            merge_attributes(service.patch_port(uuid, patch).body)
          else
            # TODO implement update_node method using PUT method and self.attributes
            # once it is supported by Ironic
            raise ArgumentError, ('You need to provide patch attribute. Ironic does '
                                  'not support update by hash yet, only by jsonpatch.')
          end
          self
        end

        def destroy
          requires :uuid
          service.delete_port(self.uuid)
          true
        end

        def metadata
          requires :uuid
          service.get_port(self.uuid).headers
        end
      end
    end
  end
end
