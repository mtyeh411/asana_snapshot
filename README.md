## Asana Snapshot

[Asana](https://www.asana.com) is a great, versatile task management system.  However, like many similar task management systems, being able to track meaningful progress across one or more projects; burn-down charts are great, but are not built to extract any immediate, actionable decisions.  Tracking the progress of a project over a specified period of time can be quite cumbersome, if not impossible.  This becomes even more difficult in Asana when using Boards that might all have different names for the swim lanes/columns or that have different terminology for what tasks are 'complete' and 'incomplete'.

Asana Snapshot has chosen to solve this issue by leveraging a change-tracking tool that is likely a part of most of our daily lives: [git](https://git-scm.com/).  Using git comparisons, one can gather information to drive useful & productive conversations about the progress of a given project, such as, overall velocity, project completeness and burndown, which specific tasks were completed in that time period, which specific tasks are at-risk (eg, which ones are assigned, but not completed or which remain unassigned within that given time period), etc.

From a technical side, this gem will fetch all tasks based on a specific set of user-provided conditions, write to a text-based project snapshot file (ie, using Markdown), commit & tag those project snapshot files into a git repository, while doing so in a simple and repeatable manner.

### Sample snapshot

```
## Stats
Complete: 12
Incomplete: 23 (12 unassigned)

## Tasks
[X] 473716394 ["Done"] - Joe Smith - provision test server
[ ] 473716485 ["In Progress"] - John Doe - implement authentication service
[ ] 473164858 ["Ready To Dev"] - Unassigned - develop profitable feature
```

Tasks are ordered by Asana task id, and so should almost always remain on the same line within a snapshot file, making tasks updates easier to parse out from the git tag comparisons.

### Installation

```
gem install asana_snapshot
```

or if you are using Bundler add the following to your Gemfile

```
gem 'asana_snapshot'
```

### Configuration

| Config        | Description                                                           | Default             |
| ------------- | --------------------------------------------------------------------- | -------------------:|
| logger        | gem logging destination                                               |  Logger.new STDOUT  |
| token         | Asana API Personal Access Token                                       |  nil                |
| base_dir      | file directory where snapshots will be saved                          |  Dir.pwd            |
| persistence   | Hash specifying the persistence store (requires an `adapter` key)     |  {adapter: :git}    |

Example:
```
AsanaSnapshot.configure do |config|
  config.logger   = Logger.new('logfile.log')
  config.token    = '_my_personal_token_'
  config.base_dir = '/path/to/where/i/save/snapshots'
end
```

### Usage

There are two primary entry points for executing AsanaSnapshot: via its Ruby API or via the shipped executable file.

In both cases, it expects the presence of a YAML config file which supplies information about the Asana workspace & projects upon which it will search for tasks.  AsanaSnapshot will only search for tasks (as opposed to sub-tasks) that belong to the projects in the YAML file and which contain any tags defined in the YAML file.

#### Anatomy of a snapshot YAML file

```
title: 'Acme Boards'
```
The `title` key identifies how the snapshots will be organized.  The sub-directory of the configured `base_dir` in which snapshots are saved will be an underscored version of this `title`.

```
workspace: 123456789
```
The `workspace` key identifies which Asana workspace id to query for tasks.

```
filters:
  tags: 234567890, 345678901
```
The `filters` key groups the possible query filters.  As of now, only `tags` are supported.  `tags` are a comma-delimited list of Asana tag id's that a task may contain.

```
projects:
  - id: 4567890123
    name: 'Phase 2 Widgets'
    columns:
      complete:
        - 'Done'
      incomplete:
        - 'In Discovery'
        - 'In Progress'
```
The `projects` key identifies the set of projects that will be searched.  It contains the Asana project id, a helpful `name` to identify it in the YAML file (which would likely match the name of the project in Asana, but it can be anything you want), and a `columns` key which identifies the names of the Asana sections of the project board should be considered as `complete` or `incomplete`.

#### Ruby API

Example:
```
AsanaSnapshot.configure do |config|
  config.token = '_my_personal_token_'
end

AsanaSnapshot.execute './config/acme_boards.yml'
```

#### Executable

The gem ships with an executable named `snap`.  `snap` takes a single argument, which is the path to the `asana_snapshot` config file.

The `snap` executable uses the following environment variables to override the default AsanaSnapshot configuration:

| ENV                     | Config  |
| ----------------------- |:-------:|
| ASANA_SNAPSHOT_LOGGER   | logger  |
| ASANA_SNAPSHOT_TOKEN    | token   |

Example:
```
ASANA_SNAPSHOT_TOKEN='_my_personal_token_' snap './config/acme_boards.yml'
```
