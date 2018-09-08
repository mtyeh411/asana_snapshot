require 'yaml'
require 'logger'
require 'asana_snapshot/task_searcher'
require 'asana_snapshot/snapshot_generator'

module AsanaSnapshot
  @@projects = []
  @@logger = Logger.new STDOUT

  def self.projects=(projects)
    @@projects = projects
  end

  def self.projects
    @@projects
  end

  def self.logger
    @@logger
  end

  def self.execute(config_file)
    unless ENV['ASANA_SNAPSHOT_TOKEN']
      @@logger.error "No Asana token configured."
    else
      config = YAML.load_file config_file

      AsanaSnapshot.projects = config['projects']

      AsanaSnapshot.projects.each do |project|
        tasks = AsanaSnapshot::TaskSearcher.new(
          token: ENV['ASANA_SNAPSHOT_TOKEN'],
          workspace_id: config['workspace']
        ).search(
          'tags.any' => config['filters']['tags'],
          'projects.any' => project['id'],
          'is_subtask' => false
        )

        if tasks.any?
          AsanaSnapshot::SnapshotGenerator.new(
            tasks,
            config_name: config['name'],
            project_id: project['id']
          ).write
          @@logger.info "Successfully created snapshot for #{project['name']}"
        else
          @@logger.info "No tasks found."
        end
      end
    end
  end
end
