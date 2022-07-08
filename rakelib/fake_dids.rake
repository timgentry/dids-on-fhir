file FAKE_DIDS_CSV_FILENAME => [FAKE_PATIENTS_YAML_FILENAME] do |t|
  require 'active_support/all'
  require 'csv'
  require 'faker'
  require 'yaml'

  patients = YAML.load_file(FAKE_PATIENTS_YAML_FILENAME)
  nicip_codes = YAML.load_file('nicip.yml')
  snomed_codes = YAML.load_file('snomedct.yml')

  CSV.open(t.name, 'w') do |csv|
    60_000.times do
      patient_index = rand(patients.length)
      patient = patients[patient_index]
      birth_date = Date.parse(patient['birth_date'])
  
      test_date = Faker::Date.between(from: 3.months.ago, to: 1.month.ago)
      report_date = Faker::Date.between(from: test_date, to: 1.week.since(test_date))
      request_received_date = Faker::Date.between(from: 3.weeks.before(test_date), to: 1.week.before(test_date))
      test_request_date = Faker::Date.between(from: 1.week.before(request_received_date), to: request_received_date)

      nicip_code = nil
      snomed_code = nil
      if rand(2) == 1
        nicip_code = nicip_codes[rand(nicip_codes.length)]
      else
        snomed_code = snomed_codes[rand(snomed_codes.length)]
      end

      row = [
        patient['nhs_number'], # NHS NUMBER
        patient['nhs_number_status_indicator_code'], # NHS NUMBER STATUS INDICATOR CODE
        patient['birth_date'], # PERSON BIRTH DATE
        patient['ethnic_category'], # ETHNIC CATEGORY
        patient['gender'], # PERSON GENDER CODE CURRENT
        patient['postcode'], # POSTCODE OF USUAL ADDRESS
        'A12345', # GENERAL MEDICAL PRACTICE CODE (PATIENT REGISTRATION)
        '01', # PATIENT SOURCE SETTING TYPE (DIAGNOSTIC IMAGING)
        'C9999998', # REFERRER CODE
        'RXD', # REFERRING ORGANISATION CODE
        test_request_date.strftime("%Y-%m-%d"), # DIAGNOSTIC TEST REQUEST DATE
        request_received_date.strftime("%Y-%m-%d"), # DIAGNOSTIC TEST REQUEST RECEIVED DATE
        test_date.strftime("%Y-%m-%d"), # DIAGNOSTIC TEST DATE
        nicip_code, # IMAGING CODE (NICIP)
        snomed_code, # IMAGING CODE (SNOMED CT)
        report_date.strftime("%Y-%m-%d"), # SERVICE REPORT ISSUE DATE
        'RH802', # SITE CODE (OF IMAGING)
        SecureRandom.alphanumeric(20), # RADIOLOGICAL ACCESSION NUMBER
      ]
      csv << row
    end
  end
end
CLEAN << FAKE_DIDS_CSV_FILENAME
