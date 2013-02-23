#!/opt/third-party/bin/ruby
#
# calc.rb
#
# Author: Greg Millam (gmillam@amazon.com)
#
# Written for amazon.com programming challenge.
#
# Takes each line of input, processes it for 'rithmetic, and returns.
#

class String
  class DivisionByZero < Exception
  end

  PARENS_REGEXP=/\([^()]*\)/

  # One by one, replace all parens in the string,
  # starting with the innermost parentheses, replacing
  # it with whatever is returned from the yield.
  def replace_parens
    new = self
    new = new.gsub(PARENS_REGEXP) do |pattern|
      yield pattern.delete('()')
    end while PARENS_REGEXP.match(new)
    new
  end

  # The priorities for different artithmetic expressions.
  @@priorities = {
    '^' => 3, # highest
    '*' => 2,
    '/' => 2,
    '+' => 1,
    '-' => 1,
    nil => 0  # End of expression.
    }

  # The functional calculators for the arithmetic expressions.
  @@calculators = {
    '^' => lambda { |i,j| i**j },
    '*' => lambda { |i,j| i*j },
    '/' => lambda { |i,j|
	  raise DivisionByZero if (j == 0)
	  (i/j)
	},
    '-' => lambda { |i,j| i-j },
    '+' => lambda { |i,j| i+j }
    }

  # The beef of the work
  def calculate
    # The regexp that looks for:
    # [negative] Number <action>, action being one of -+*/^
    rx = /^(\-?(\d+\.)?\d+)([\-\+\*\/\^])?/

    # Don't do it on self (it's not calculate!, but eval :D)
    new = self.gsub(/\s/,'') # Delete all white space
    # Put the entire string in a parens, for safety.
    new = "(#{new})"
    begin
      score = new.replace_parens do |expression|
	# Required to be a non-negative number at this point.
	m = rx.match(expression)

	# If it doesn't match, it's an empty parens, return 0.
	if m
	  # The stack of numbers and operations.
	  stack = []

	  # The first number
	  sum = 0
	  sum = m[1].to_f
	  # The first action
	  action = m[3]

	  # Iterate through the entire expression.
	  expression = m.post_match
	  while action && (m = rx.match(expression))
	    # New number, new action.
	    num = m[1].to_f
	    newaction = m[3]

	    # If new action is higher priority than current action,
	    # push the current action and sum onto the stack and
	    # hold it there until an equal or lesser priority action
	    # is in place.

	    if (@@priorities[newaction] > @@priorities[action])
	      # higher priority action
	      stack.push [sum,action]
	      sum = num
	    else
	      # Equal or lesser.
	      sum = @@calculators[action].call(sum,num)

	      # Go back on the stack if possible.
	      while (stack.length > 0 && (@@priorities[stack[-1][1]] >= @@priorities[newaction]))
		num, action = stack.pop
		sum = @@calculators[action].call(num,sum)
	      end
	    end
	    # Set the current action and get the next expression.
	    action = newaction
	    expression = m.post_match
	  end
	  # Clean up the stack.
	  while (stack.length > 0)
	    num, action = stack.pop
	    sum = @@calculators[action].call(num,sum)
	  end
	  sum
	else
	  "0"
	end
      end
      return score.to_s
    rescue DivisionByZero => er
      return "error: divison by zero"
    end
  end
end

if File.basename(__FILE__) == $0
  ARGF.each do |expr|
    puts expr.calculate.sub(/\.0+$/,'')
  end
end
