module Todoable
  class Client
    module Items

      #create a new item on an existing list using list_id and item name

      def create_item(list_id:, name:)
        JSON.parse(api_request(method: :post, path: "lists/#{list_id}/items", params: params(name)))
      end

      #mark an item finished using list_id and item_id

      def finish_item(list_id:, item_id:)
        api_request(method: :put, path: "lists/#{list_id}/items/#{item_id}/finish")
      end

      #delete an item off an existing list using list_id and item_id

      def delete_item(list_id:, item_id:)
        api_request(method: :delete, path: "lists/#{list_id}/items/#{item_id}")
      end

      private

      def params(name)
        params = {
          "item" => {
           "name" => name
          }
        }
      end
    end
  end
end
