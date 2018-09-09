require 'fileutils'

module AsanaSnapshot
  class SnapshotGenerator
    attr_reader :snapshot_directory, :file, :project_id, :project

    def initialize(tasks, group:, project_id:)
      @project_id = project_id
      @project = compile tasks

      directory_name = group.downcase.gsub(' ', '_')
      @snapshot_directory = "#{AsanaSnapshot.configuration.base_dir}/snapshots/#{directory_name}"

      file_name = project[:name].gsub(' ', '_').gsub('&', 'and')
      @file = "#{snapshot_directory}/#{file_name}.md"
    end

    def write
      setup_directory

      File.open(file, "w") do |f|
        f.puts '## Stats'
        f.puts "Complete: #{project[:stats][:complete]}"
        f.puts "Incomplete: #{project[:stats][:incomplete]} (#{project[:stats][:unassigned]} unassigned)"
        f.puts ''

        f.puts '## Tasks'
        project[:tasks].each do |task|
          f.puts "[#{task.completed? ? 'X' : ' '}] #{task}"
        end
      end

      AsanaSnapshot.persistence_store.mark_for_save file
    end

    private

    def setup_directory
      return if ::File.directory? snapshot_directory
      ::FileUtils.mkdir_p(snapshot_directory)
      ::FileUtils.chmod 0755, snapshot_directory
    end

    def compile(tasks)
      tasks.sort_by(&:id).reduce({
        name: nil,
        tasks: [],
        stats: {
          complete: 0,
          incomplete: 0,
          unassigned: 0
        }
      }) do |memo, task|
        task.project_columns.reject do |project_column|
          project_column.project_id.to_i != project_id.to_i
        end.each do |project_column|
          memo[:name] ||= project_column.project_name
          memo[:tasks].push task
          memo[:stats][:complete]+=1 if task.completed?
          memo[:stats][:incomplete]+=1 unless task.completed?
          memo[:stats][:unassigned]+=1 if task.assignee_name.nil?
        end
        memo
      end
    end
  end
end
