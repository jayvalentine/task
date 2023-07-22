require 'yaml'

# Container for tasks.
class TaskContainer
    def initialize()
        @now = nil
        @next = nil
        @soon = []
        @later = []
    end

    def self.from_h(h)
        t = self.new
        t.now = h[:now] unless h[:now].nil?
        t.next = h[:next] unless h[:next].nil?
        h[:soon].each { |task| t.soon << task }
        h[:later].each { |task| t.later << task }

        t
    end

    def to_h
        h = {}
        h[:now] = @now unless @now.nil?
        h[:next] = @next unless @next.nil?
        h[:soon] = @soon
        h[:later] = @later
        
        h
    end

    # The task that needs to be done now - i.e. is "in progress"
    # (or about to be).
    #
    # Only one task can be "now" - because you can only do one thing at once.
    # Setting "now" when another task is already "now" makes the existing task "next"
    def now; @now; end
    def now=(s)
        if @now.nil?
            @now = s
        else
            self.next = @now
            @now = s
        end
    end

    # The task that needs to be done next (after "now")
    #
    # Only one task can be "next" - because time is linear.
    # Setting "next" when another task is already "next" makes the existing task "soon"
    def next; @next; end
    def next=(s)
        if @next.nil?
            @next = s
        else
            @soon.unshift(@next)
            @next = s
        end
    end

    def soon; @soon; end
    def later; @later; end
end

def get_task
    ARGV[1..-1].join(" ")
end

if $0 == __FILE__
    # Should have at least one argument.
    if ARGV.size < 1
        puts "usage: task <command> [<task>]"
        puts ""
        puts "commands for adding a new task:"
        puts "    now:    add a new task to do right now"
        puts "    next:   add a new task to do next"
        puts "    soon:   add a new task to do soon"
        puts "    later:  add a new task to do later"
        puts ""
        puts "for interacting with existing tasks:"
        puts "    status: display current tasks"
        puts "    done:   mark task as done"

        exit 1
    end

    COMMAND = ARGV[0]
    TASKFILE = "tasks.yaml"

    # Load current tasks from YAML file if it exists.
    tasks = if File.exist?(TASKFILE)
        TaskContainer::from_h(YAML::load(File.read(TASKFILE)))
    else
        TaskContainer.new
    end

    # Perform the user's command.
    if COMMAND == "now"
        tasks.now = get_task()
    elsif COMMAND == "next"
        tasks.next = get_task()
    elsif COMMAND == "soon"
        tasks.soon << get_task()
    elsif COMMAND == "later"
        tasks.later << get_task()
    elsif COMMAND == "status"
        puts "now:   #{tasks.now}"
        puts "next:  #{tasks.next}"
        puts "soon:"
        tasks.soon.each { |t| puts "    #{t}" }
        puts "later:"
        tasks.later.each { |t| puts "    #{t}" }
    end

    # Save current tasks back to YAML file.
    File.write(TASKFILE, YAML::dump(tasks.to_h))
end
