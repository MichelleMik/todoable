require 'spec_helper'

RSpec.describe Todoable::Client do
  let(:username) { "mmikhalevsky@gmail.com" }
  let(:password) { "todoable" }

  describe "Using username and password" do
    describe 'Lists' do
      let(:client) { Todoable::Client.new(username: username, password: password) }

      it "should return a list of lists on todoable server for user" do
        expect(client.get_lists).to be_an(Array)
      end

      it "can create a list" do
        name = SecureRandom.hex
        list = client.create_list(name: name)
        expect(list["name"]).to eq(name)
        cleanup_lists(client, list["id"])
      end

      it 'can get a specific list by list_id' do
        name = SecureRandom.hex
        id = client.create_list(name: name)["id"]
        expect(client.get_list(list_id: id)["name"]).to eq(name)
        cleanup_lists(client, id)
      end

      it 'can update a list name' do
        name = SecureRandom.hex
        id = client.create_list(name: name)["id"]
        new_name =  SecureRandom.hex
        expect(client.update_list(list_id: id, name: new_name).code).to eq(200)
        cleanup_lists(client, id)
      end

      it 'will not let you create two lists with the same name' do
        name = SecureRandom.hex
        list = client.create_list(name: name)
        expect{ (client.create_list(name: name)) }.to raise_error(Todoable::UnprocessableEntityError)
        cleanup_lists(client, list["id"])
      end

      it 'allows you to delete existing list via list_id' do
        name = SecureRandom.hex
        list_id = client.create_list(name: name)["id"]
        expect(client.delete_list(list_id: list_id).code).to eq(204)
      end

      it 'will return NotFoundError if list not found' do
        name = SecureRandom.hex
        id = client.create_list(name: name)["id"] + "a"
        expect { (client.get_list(list_id: id)) }.to raise_error(Todoable::NotFoundError)
        cleanup_lists(client, id[0..-2])
      end
    end

    describe 'Items' do
      let(:client) { Todoable::Client.new(username: username, password: password) }
      let(:list_id){client.create_list(name: SecureRandom.hex)["id"]}

      it 'can create a list item' do
        item_name = SecureRandom.hex
        item = client.create_item(list_id: list_id, name: item_name)
        expect(item["name"]).to eq(item_name)
        cleanup_list_items(client, list_id, item["id"])
      end

      it 'can mark a list item finished' do
        item_name = SecureRandom.hex
        item_id = client.create_item(list_id: list_id, name: item_name)["id"]
        expect(client.finish_item(list_id: list_id, item_id: item_id).code).to eq(200)
        cleanup_list_items(client, list_id, item_id)
      end

      it 'can delete a list item' do
        item_name = SecureRandom.hex
        item_id = client.create_item(list_id: list_id, name: item_name)["id"]
        expect(client.delete_item(list_id: list_id, item_id: item_id).code).to eq(204)
      end

      it 'can mark a list item finished' do
        item_name = SecureRandom.hex
        item_id = client.create_item(list_id: list_id, name: item_name)["id"]
        expect(client.finish_item(list_id: list_id,item_id: item_id).code).to eq(200)
        cleanup_list_items(client, list_id, item_id)
      end

      it 'will return NotFoundError if incorrect item id given' do
        item_name = SecureRandom.hex
        item_id = client.create_item(list_id: list_id, name: item_name)["id"] + "a"
        expect { (client.finish_item(list_id: list_id,item_id: item_id)) }.to raise_error(Todoable::NotFoundError)
        cleanup_list_items(client, list_id, item_id[0..-2])
      end
    end
  end

  describe "Using a token" do
    before(:each) do
      @token = Todoable::Client.new(username: username, password: password).token
    end

    it 'can be instantiated with just a token' do
      expect{ (Todoable::Client.new(token: @token)) }.not_to raise_error(Todoable::NoCredentialsError)
    end

    it 'will raise UnauthorizedError if token is incorrect or expired when trying to access todoable server' do
      wrong_token = @token + "a"
      expect{ (Todoable::Client.new(token: wrong_token).get_lists) }.to raise_error(Todoable::UnauthorizedError)
    end

  end
end

def cleanup_lists(client, list_id)
  client.delete_list(list_id: list_id)
end

def cleanup_list_items(client, list_id, item_id)
  client.delete_item(list_id: list_id, item_id: item_id)
end
