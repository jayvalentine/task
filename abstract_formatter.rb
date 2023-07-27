class AbstractFormatter
    def initialize(tasks)
        @tasks = tasks
    end

    def result
        lines = []
        lines << format_now(@tasks.now)
        lines << format_next(@tasks.next)
        
        @first_soon = true
        if @tasks.soon.empty?
            lines << format_soon("")
        else
            @tasks.soon.each do |t|
                lines << format_soon(t)
                @first_soon = false
            end
        end

        @first_later = true
        if @tasks.later.empty?
            lines << format_later("")
        else
            @tasks.later.each do |t|
                lines << format_later(t)
                @first_later = false
            end
        end

        lines.join("\n") + "\n\n"
    end

    def first_soon?
        @first_soon
    end

    def first_later?
        @first_later
    end

    def format_now(s)
        raise "Must be implemented by subclass"
    end

    def format_next(s)
        raise "Must be implemented by subclass"
    end

    def format_soon(s)
        raise "Must be implemented by subclass"
    end

    def format_later(s)
        raise "Must be implemented by subclass"
    end
end
