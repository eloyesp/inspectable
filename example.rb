# test framework

def assert_equal expected, actual
  if expected == actual
    puts "ok"
  else
    puts 'not ok'
    puts expected.to_s.each_line.map{ |l| l.prepend "# " }
    puts '# !='
    puts actual.to_s.each_line.map{ |l| l.prepend "# " }
    puts '# ---'
  end
end

def test description
  yield
end

# Main code

module Inspectable
  def inspectable *attributes
    define_method :inspect do
      get_value = proc do |attr|
        if self.respond_to? attr
          self.send(attr)
        else
          self.instance_variable_get("@#{ attr }")
        end
      end
      details = attributes.map{ |a| "#{ a }=#{ get_value[a].inspect }" }.join(', ')
      %Q$#<#{ self.class.name }:#{ '%#016x' % (self.object_id << 1) } #{ details }>$
    end
  end
end

Module.include Inspectable

# Sample code

require 'set'

HOBBIES = %w[ programming design soccer ping-pong ]

class Person

  def initialize email
    @email = email
    @hobbies = Set.new
  end

  def add_hobby name
    hobby_reference = HOBBIES.index name
    @hobbies << hobby_reference if hobby_reference
  end

  def hobbies
    @hobbies.map{ |ref| HOBBIES[ref] }
  end

end

# Tests

person = Person.new 'matz@ruby-lang.com'
person.add_hobby 'programming'
person.add_hobby 'design'

test 'default inspect works' do
  expected = %Q$#<Person:#{ '%#016x' % (person.object_id << 1) } @email="matz@ruby-lang.com", @hobbies=#<Set: {0, 1}>>$
  assert_equal expected, person.inspect
end

class Person
  inspectable :email, :hobbies
end

test 'inspect only the interesting stuff' do
  expected = %Q$#<Person:#{ '%#016x' % (person.object_id << 1) } email="matz@ruby-lang.com", hobbies=["programming", "design"]>$
  assert_equal expected,
    person.inspect
end
