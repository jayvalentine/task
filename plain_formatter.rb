require_relative 'abstract_formatter'

class PlainFormatter < AbstractFormatter
    WIDTH = 45
    PADDING_BEFORE = WIDTH / 3
    PADDING_AFTER = WIDTH - PADDING_BEFORE

    def title(text)
        s = "=" * PADDING_BEFORE
        s += " #{text} "
        s += "=" * (PADDING_AFTER + 7 - (text.size + 2))
        s
    end

    def format_now(s)
        "#{title("now")}\n- #{s}"
    end

    def format_next(s)
        "\n#{title("next")}\n- #{s}"
    end

    def format_soon(s)
        line = if first_soon?
            "\n#{title("soon")}\n"
        else
            ""
        end

        line + "- #{s}"
    end

    def format_later(s)
        line = if first_later?
            "\n#{title("later")}\n"
        else
            ""
        end

        line + "- #{s}"
    end
end
