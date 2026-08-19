ADDRESS_FIELDS_TO_REMOVE_FOR_CONFIDENTIAL_SCHEME = %w[
      uprn
      uprn_known
      uprn_confirmed
      uprn_selection
      address_line1
      address_line2
      town_or_city
      county
      postcode_full
      postcode_known
      address_line1_input
      postcode_full_input
      address_line1_as_entered
      address_line2_as_entered
      town_or_city_as_entered
      county_as_entered
      postcode_full_as_entered
      la_as_entered

      is_la_inferred
      la
      address_search_value_check
    ].freeze


scope = LettingsLog
          .joins(:scheme)
          .where(schemes: { sensitive: true })
          .where(
            ADDRESS_FIELDS_TO_REMOVE_FOR_CONFIDENTIAL_SCHEME.map { |field| "#{LettingsLog.table_name}.#{field} IS NOT NULL" }.join(" OR ")
          )

scope.find_each do |log|
  log.reset_address_fields!
  log.uprn_selection = nil
  log.postcode_known = nil

  log.la = log.la

  log.save!
end
