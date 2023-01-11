FactoryBot.define do
  factory :log_entry, class: Aypex::LogEntry do
    source { build(:order) }
    details { "Some details" }
  end
end
