require_relative '../task.rb'

require 'test/unit'

class TaskTest < Test::Unit::TestCase
    # When a new TaskContainer is generated...
    #
    # #now should be nil (no task)
    # #next should be nil (no task)
    # #soon should be empty (no tasks)
    # #later should be empty (no tasks)
    #
    def test_empty
        t = TaskContainer.new
        assert_nil(t.now)
        assert_nil(t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end

    # Setting TaskContainer #now when empty
    # should not change any other properties.
    def test_now_when_empty
        t = TaskContainer.new
        t.now = "a task i need to do now"

        assert_equal("a task i need to do now", t.now)
        assert_nil(t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end

    # Setting #now when not empty should push that task
    # into #next
    def test_now_when_full
        t = TaskContainer.new
        t.now = "a new task"
        t.now = "another new task"

        assert_equal("another new task", t.now)
        assert_equal("a new task", t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end

    # Setting #next when empty should not change any other properties.
    def test_next_when_empty
        t = TaskContainer.new
        t.now = "a new task"
        t.next = "another new task"

        assert_equal("a new task", t.now)
        assert_equal("another new task", t.next)
        assert_true(t.soon.empty?)
        assert_true(t.later.empty?)
    end

    # Setting #next when not empty should push the existing task
    # into #soon
    def test_next_when_not_empty
        t = TaskContainer.new
        t.now = "current task"
        t.next = "next task"
        t.next = "oops need to do something else first"

        assert_equal("current task", t.now)
        assert_equal("oops need to do something else first", t.next)
        
        assert_equal(1, t.soon.size)
        assert_equal("next task", t.soon[0])

        assert_true(t.later.empty?)
    end

    # Setting #next when not empty should push the existing task
    # into #soon. Here we make sure that task is the first one in #soon
    def test_next_when_not_empty_first_soon
        t = TaskContainer.new
        t.now = "current task"
        t.soon << "needs doing soon"
        t.next = "needs doing next"
        t.next = "oops need to do something else first"

        assert_equal("current task", t.now)
        assert_equal("oops need to do something else first", t.next)

        assert_equal(2, t.soon.size)
        assert_equal("needs doing next", t.soon[0])
        assert_equal("needs doing soon", t.soon[1])
    end

    # It should be possible to index #soon by range.
    def test_soon_index_range
        t = TaskContainer.new
        t.now = "first task"
        t.next = "second task"

        t.soon << "third task"
        t.soon << "fourth task"
        t.soon << "fifth task"

        assert_equal(2, t.soon[1..-1].size)
        assert_equal("fourth task", t.soon[1..-1][0])
        assert_equal("fifth task", t.soon[1..-1][1])
    end

    # Setting #next when #now is empty should make #now the value of #next.
    def test_next_when_now_empty
        t = TaskContainer.new
        t.next = "current task"

        assert_equal("current task", t.now)
        assert_nil(t.next)
    end

    # Tests that tasks can be loaded from hash.
    def test_from_hash
        h = {
            now: "current task",
            next: "next task",
            soon: [
                "one task",
                "two task"
            ],
            later: [
                "three task",
                "four task"
            ]
        }

        t = TaskContainer::from_h(h)

        assert_equal("current task", t.now)
        assert_equal("next task", t.next)
        
        assert_equal(2, t.soon.size)
        assert_equal("one task", t.soon[0])
        assert_equal("two task", t.soon[1])

        assert_equal(2, t.later.size)
        assert_equal("three task", t.later[0])
        assert_equal("four task", t.later[1])
    end

    # Tests that the 'now' task can be marked as done.
    def test_now_done
        t = TaskContainer.new
        t.now = "current task"

        assert_equal("current task", t.now)

        done = t.done("current task")
        assert_true(done.result)
        assert_equal(1, done.tasks.size)
        assert_equal("current task", done.tasks[0])

        assert_nil(t.now)
    end

    # Tests that tasks can be marked as 'done' by keyword.
    def test_now_done_keywords
        t = TaskContainer.new
        t.now = "a really complicated task"

        assert_equal("a really complicated task", t.now)

        done = t.done("task complicated")
        assert_true(done.result)
        assert_equal(1, done.tasks.size)
        assert_equal("a really complicated task", done.tasks[0])

        assert_nil(t.now)
    end

    # Tests that later tasks can be marked as done.
    def test_later_done
        t = TaskContainer.new
        t.now = "current task"
        t.later << "do something later"

        assert_equal("current task", t.now)
        assert_equal(1, t.later.size)
        assert_equal("do something later", t.later[0])

        done = t.done("later")
        assert_true(done.result)
        assert_equal(1, done.tasks.size)
        assert_equal("do something later", done.tasks[0])

        assert_equal("current task", t.now)
        assert_equal(0, t.later.size)
    end

    # Tests that tasks can be marked as 'done' by keyword.
    def test_later_done_keywords
        t = TaskContainer.new
        t.now = "current task"
        t.later << "do something later for that person"

        assert_equal("current task", t.now)
        assert_equal(1, t.later.size)
        assert_equal("do something later for that person", t.later[0])

        done = t.done("do something for person")
        assert_true(done.result)
        assert_equal(1, done.tasks.size)
        assert_equal("do something later for that person", done.tasks[0])

        assert_equal("current task", t.now)
        assert_equal(0, t.later.size)
    end

    # Tests that 'bump' can bump a task from 'soon' to 'now'.
    def test_bump
        t = TaskContainer.new
        t.now = "current task"
        t.next = "next task"
        t.soon << "some other task"

        assert_equal("current task", t.now)
        assert_equal("next task", t.next)
        assert_equal("some other task", t.soon[0])

        result = t.bump("some other task")
        assert_true(result.result)
        assert_equal(1, result.tasks.size)
        assert_equal("some other task", result.tasks[0])

        assert_equal("some other task", t.now)
        assert_equal("current task", t.next)
        assert_equal("next task", t.soon[0])
    end

    # Tests that 'bump' returns non-success when task not found.
    def test_bump_none
        t = TaskContainer.new
        t.now = "current task"
        t.next = "next task"
        t.soon << "some other task"

        assert_equal("current task", t.now)
        assert_equal("next task", t.next)
        assert_equal("some other task", t.soon[0])

        result = t.bump("doesnt exist")
        assert_false(result.result)
        assert_equal(0, result.tasks.size)

        assert_equal("current task", t.now)
        assert_equal("next task", t.next)
        assert_equal("some other task", t.soon[0])
    end

    # Tests that 'bump' returns non-success when task name is ambiguous.
    def test_bump_ambiguous
        t = TaskContainer.new
        t.now = "current task"
        t.next = "next task"
        t.soon << "some other task"

        assert_equal("current task", t.now)
        assert_equal("next task", t.next)
        assert_equal("some other task", t.soon[0])

        result = t.bump("task")
        assert_false(result.result)
        assert_equal(3, result.tasks.size)

        assert_equal("current task", t.now)
        assert_equal("next task", t.next)
        assert_equal("some other task", t.soon[0])
    end
end
