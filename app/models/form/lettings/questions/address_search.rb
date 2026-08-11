class Form::Lettings::Questions::AddressSearch < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn"
    @type = "address_search"
    @copy_key = "lettings.property_information.address_search"
    @plain_label = true
    @bottom_guidance_partial = "address_search"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @hide_question_number_on_page = true
  end

  def answer_options(log = nil, _user = nil)
    return {} unless ActiveRecord::Base.connected?
    return {} unless log&.address_search_options&.any?

    { log.address_search_options.first[:uprn] => { "value" => "#{log.address_search_options.first[:address]} (#{log.address_search_options.first[:uprn]})" } }
  end

  def get_extra_check_answer_value(log)
    return unless log.uprn_known == 1

    value = [
      log.address_line1,
      log.address_line2,
      log.town_or_city,
      log.county,
      log.postcode_full,
      (LocalAuthority.find_by(code: log.la)&.name if log.la.present?),
    ].select(&:present?)

    return unless value.any?

    "\n\n#{value.join("\n")}"
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user).transform_values { |value| value["value"] } || {}
  end

  def unanswered_error_message(log = nil)
    return super unless log&.is_supported_housing?

    I18n.t("validations.lettings.property.address.not_answered_supported_housing")
  end

  QUESTION_NUMBER_FROM_YEAR = { 2024 => 12, 2025 => 16, 2026 => 16 }.freeze
end
