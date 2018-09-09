require 'yaml'
require 'logger'

require 'asana_snapshot/task_searcher'
require 'asana_snapshot/snapshot_generator'
require 'asana_snapshot/configuration'
require 'asana_snapshot/persistence'

module AsanaSnapshot
  class << self
    attr_accessor :projects
    attr_writer :configuration, :persistence_store
  end

  def self.configuration
    @configuration ||= AsanaSnapshot::Configuration.new
  end

  def self.persistence_store
    @persistence_store ||= AsanaSnapshot::Persistence.new(adapter: AsanaSnapshot.configuration.persistence[:adapter])
  end

  def self.configure
    yield configuration
  end

  def self.execute(config_file)
    unless self.configuration.token
      self.configuration.logger.error "No Asana token configured."
    else
      config = YAML.load_file config_file

      self.projects = config['projects']
      self.projects.each do |project|
        tasks = AsanaSnapshot::TaskSearcher.new(
          token: self.configuration.token,
          workspace_id: config['workspace']
        ).search(
          'tags.any' => config['filters']['tags'],
          'projects.any' => project['id'],
          'is_subtask' => false
        )

        if tasks.any?
          AsanaSnapshot::SnapshotGenerator.new(
            tasks,
            group: config['title'],
            project_id: project['id']
          ).write
          self.configuration.logger.info "Successfully created snapshot for #{project['name']}"
        else
          self.configuration.logger.info "No tasks found for #{project['name']}"
        end
      end

      self.persistence_store.save config['title']
    end
  end
end
