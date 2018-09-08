module AsanaSnapshot
  class Task
    extend Forwardable

    def_delegators :@task, :id, :name

    def initialize(task_response)
      @task = OpenStruct.new(task_response)
    end

    def assignee_name
      @task.assignee&.send(:[], 'name')
    end

    def completed?
      completed_task? || completed_column?
    end

    def project_columns
      @project_columns ||= @task.memberships.map do |m|
        OpenStruct.new(
          project_id: m['project']['id'],
          project_name: m['project']['name'],
          column_name: m['section']['name']
        )
      end
    end

    def to_s
      "#{id} #{project_columns.map(&:column_name)} - #{assignee_name || 'Unassigned'} - #{name}"
    end

    def completed_task?
      @task.completed
    end

    def completed_column?
      project_columns.map do |project_column|
        project_config = AsanaSnapshot.projects.detect do |project|
          project['id'] == project_column.project_id
        end
        project_config && project_config['columns']['complete']&.include?(project_column.column_name)
      end.any?
    end
  end
end
