require_relative 'abstract_formatter'

class ColorBlockFormatter < AbstractFormatter
    COLORS = {
        now:   167,
        next:  131,
        soon:  95,
        later: 59
    }

    def color(s, code)
        "\033[48;5;#{code}m\033[38;5;252m#{s}\033[0m"
    end
    
    def pad(s, width)
        padding = width - s.size
        s += (" " * padding) if padding > 0
        s
    end

    def format_now(s)
        line = "now:   - #{s}"
        color(pad(line, 60), COLORS[:now])
    end

    def format_next(s)
        line = "next:  - #{s}"
        color(pad(line, 60), COLORS[:next])
    end

    def format_soon(s)
        line = if first_soon?
            "soon:  - #{s}"
        else
            "         #{s}"
        end
        color(pad(line, 60), COLORS[:soon])
    end

    def format_later(s)
        line = if first_later?
            "later: - #{s}"
        else
            "         #{s}"
        end
        color(pad(line, 60), COLORS[:later])
    end
end
