class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    unless EMAIL_REGEX.match?(value)
      record.errors.add(attribute, :invalid, value: value, **options)
    end
  end
end
