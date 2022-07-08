file FAKE_PATIENTS_YAML_FILENAME do |t|
    require 'faker'
    require 'yaml'

    Faker::Config.locale = 'en-GB'

    class String
      def valid_nhsnumber?
        return true if length == 0
        return false if length != 10
        # return false if %w[0000000000 9999999999].include?(self) && !Rails.env.test? # For testing only
        a = split(//).map(&:to_i)
        chk = 0
        (0..8).each { |i| chk += a[i] * (10 - i) }
        chk = 11 - (chk % 11)
        chk = 0 if chk == 11
        return false if chk == 10
        chk == self[-1].to_i
      end
    end

    def nhsnumber_enumerator
      Enumerator.new do |y|
        a = '3200000000'

        loop do
          y << a if a.valid_nhsnumber?
          # y << a
          a = a.succ
        end
      end
    end

    def select_weighted_random (values)
      weight = values.sum(&:last)
      index = rand(weight)

      weight_running_total = 0
      values.each do |value, weight|
        weight_running_total += weight
        return value if index < weight_running_total
      end
    end

    def nhs_number_status_indicator_code
      select_weighted_random([
        ['01', 90], # Number present and verified
        ['02', 1], # Number present but not traced
        ['03', 1], # Trace required
        ['04', 1], # Trace attempted - No match or multiple match found
        ['05', 1], # Trace needs to be resolved - (NHS Number or patient detail conflict)
        ['06', 1], # Trace in progress
        ['07', 1], # Number not present and trace not required
        ['08', 0] # Trace postponed (baby under six weeks old)
      ])
    end

    def ethnic_category
      select_weighted_random([
        ['A', 645],
        ['B', 6],
        ['C', 101],
        ['D', 5],
        ['E', 4],
        ['F', 5],
        ['G', 10],
        ['H', 34],
        ['J', 26],
        ['K', 10],
        ['L', 22],
        ['M', 8],
        ['N', 24],
        ['P', 9],
        ['R', 11],
        ['S', 28],
        # ['T', 0],
        ['W', 1],
        # ['Z', ?]
        ['99', 51]
      ])
    end

    def person_gender_code_current
      select_weighted_random([
        [
          select_weighted_random([
            ['1', 49],
            ['2', 51]
          ]),
          90
        ],
        ['0', 5],
        ['9', 5]
      ])
    end

    def sensitive
      select_weighted_random([
        [true, 2],
        [false, 98]
      ])
    end

    patients = nhsnumber_enumerator.take(20_000).map do |nhs_number|
      gender = person_gender_code_current
      first_name =
        if gender == '1'
          Faker::Name.male_first_name
        else
          Faker::Name.female_first_name
        end
        landline_number = ''
        until landline_number.match(/\A01/) do
          landline_number = Faker::PhoneNumber.phone_number
        end

      {
        'nhs_number' => nhs_number,
        'nhs_number_status_indicator_code' => nhs_number_status_indicator_code,
        'birth_date' => Faker::Date.birthday(min_age: 18, max_age: 85).strftime("%Y-%m-%d"),
        'ethnic_category' => ethnic_category,
        'gender' => gender,
        'postcode' => Faker::Address.postcode,
        'first_names' => "#{first_name} Test",
        'last_name' => Faker::Name.last_name,
        'landline_number' => landline_number,
        'mobile_number' => Faker::PhoneNumber.cell_phone,
        'sensitive' => sensitive
      }
    end

    # puts patients.inspect
    File.open(t.name, "w") { |file| file.write(patients.to_yaml) }
  end
  CLEAN << FAKE_PATIENTS_YAML_FILENAME
