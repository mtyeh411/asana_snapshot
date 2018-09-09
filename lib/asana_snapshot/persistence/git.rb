require 'git'

class AsanaSnapshot::Persistence::GitAdapter
  def initialize
    @repo = Git.init(AsanaSnapshot.configuration.base_dir, log: AsanaSnapshot.configuration.logger)
  end

  def mark_for_save(file)
    @repo.add file
    true
  end

  def save(group)
    today = Time.now.strftime('%Y-%m-%d')
    @repo.commit "[#{group}] Snapshot: #{today}"

    if @repo.tags.include?(today)
      @repo.delete_tag today
    end
    @repo.add_tag today
    true
  end
end
