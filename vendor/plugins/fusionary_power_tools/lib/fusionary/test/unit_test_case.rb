class Fusionary::Test::UnitTestCase < Fusionary::Test::TestCase

  # Calls creation_method with nil values for field_names and asserts that
  # the resulting object was not saved and that errors were added for that field.
  #
  #  assert_required_fields :create_article, :subject, :body, :author
  def assert_required_fields(creation_method, *field_names)
    field_names.each do |field|
      record = send(creation_method, field => nil)
      deny record.valid?
      assert_not_nil record.errors.on(field)
    end
  end

  # See assert_required_fields
  def assert_numeric_fields(creation_method, *field_names)
    field_names.each do |field|
      record = send(creation_method, field => "A")
      deny record.valid?
      assert_not_nil record.errors.on(field)
    end
  end

  def assert_invalid_value_for_field(obj, value, field)
    obj.send("#{field}=", value)
    deny obj.valid?
    assert obj.errors.invalid?(field)
  end

  def assert_valid_value_for_field(obj, value, field)
    obj.send("#{field}=", value)
    obj.valid? # Calling this activates validations and populates relevant errors
    deny obj.errors.invalid?(field)
  end

  def assert_invalid(model, attribute, *values)
    if values.empty?
      deny model.valid?, "Object is valid with value: #{model.send(attribute)}"
      deny model.save, "Object saved."
      assert model.errors.invalid?(attribute.to_s), "#{attribute} has no attached error"
    else
      values.flatten.each do |value|
        obj = model.dup
        obj.send("#{attribute}=", value)
        assert_invalid obj, attribute
      end
    end
  end

  def assert_valid(model, attribute=nil, *values)
    if values.empty?
      unless attribute.nil?
        assert model.valid?, "Object is not valid with value: #{model.send(attribute)}"
      else
        assert model.valid?, model.errors.full_messages
      end
      assert model.errors.empty?, model.errors.full_messages
    else
      m = model.dup # the recursion was confusing mysql
      values.flatten.each do |value|
        obj = m.dup
        obj.send("#{attribute}=", value)
        assert_valid(obj, attribute)
      end
    end
  end

  def assert_error_on(field, model)
  	deny model.errors[field.to_sym].nil?, "No validation error on the #{field.to_s} field."
  end

  def assert_no_error_on(field, model)
  	assert model.errors[field.to_sym].nil?, "Validation error on #{field.to_s}."
  end

end