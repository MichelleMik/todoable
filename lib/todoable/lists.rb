 module Todoable
   class Client
    module Lists

      #gets all lists

      def get_lists
        JSON.parse(api_request(method: :get, path: 'lists'))['lists']
      end

      #uses a list_id to return one list

      def get_list(list_id:)
        JSON.parse(api_request(method: :get, path: "lists/#{list_id}"))
      end

      #creates a list with a list name

      def create_list(name:)
        JSON.parse(api_request(method: :post, path: "lists", params: list_params(name)))
      end

      #updates a list using a list_id and name

      def update_list(list_id:, name:)
        api_request(method: :patch, path: "lists/#{list_id}", params: list_params(name))
      end

      #deletes a list via the list_id

      def delete_list(list_id:)
        api_request(method: :delete, path: "lists/#{list_id}")
      end

      private

      def list_params(name)
        params = {
          "list" => {
            "name" => name
          }
        }
      end
    end
   end
 end
