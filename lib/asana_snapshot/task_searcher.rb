require 'asana'
require_relative './task'

module AsanaSnapshot
  class TaskSearcher
    include Asana::Resources::ResponseHelper
    extend Asana::Resources::ResponseHelper

    attr_reader :client, :workspace_id

    TASK_FIELDS = {
      fields: [
        'completed',
        'name',
        'assignee.name',
        'memberships.(project|section).name'
      ]
    }.freeze

    def initialize(token: required('token'), workspace_id: required('workspace_id'))
      @client = Asana::Client.new do |c|
        c.authentication :access_token, token
      end
      @workspace_id = workspace_id
    end

    def search(search_options = {})
      endpoint = "/workspaces/#{workspace_id}/tasks/search"
      search_results = parse client.get(endpoint, params: search_options, options: TASK_FIELDS)
      search_results.first.map do |search_result|
        AsanaSnapshot::Task.new search_result
      end
    end
  end
end
