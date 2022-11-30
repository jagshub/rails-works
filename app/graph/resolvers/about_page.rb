# frozen_string_literal: true

module Graph::Resolvers
  class AboutPage < Base
    type Graph::Types::AboutPageType, null: false

    def resolve
      {
        members: members,
        thankful: find_by_ids(THANKFUL_IDS),
        angel_investors: find_by_ids(ANGEL_INVESTORS_IDS),
      }
    end

    private

    def members
      find_by_ids(TEAM_IDS.keys).inject([]) do |acc, user|
        member = {
          user: user,
          title: TEAM_IDS[user.id.to_s],
          country_code: get_country_code(user),
        }

        if ['Founder', 'CEO'].include?(member[:title])
          acc.unshift(member)
        else
          acc << member
        end

        acc
      end
    end

    def find_by_ids(ids)
      User.visible.where(id: ids).shuffle
    end

    # Note(TC): To get the country emoji we extract the country-code (eg. FR, US, AUS, CA) from
    # browser logs that we apply to the end of user-agent strings in curly brances
    # The country code can then be easily mapped to its flag emoji on frontend.
    def get_country_code(member)
      return if member.last_user_agent.nil?

      country_code = member.last_user_agent.match(/(?<=\{)(.*?)(?=\})/)
      return if country_code.nil?

      country_code[0]
    end

    TEAM_IDS = {
      '2' => 'Founder',                            # Ryan Hoover
      '73648' => 'CEO',                            # Ashley
      '91873' => 'President',                      # Josh Buckley
      '62068' => 'Head of Engineering',            # Radoslav Stankov
      '94352' => 'Engineering Lead',               # Vladimir Vladimirov
      '1509649' => 'Software Engineer',            # David
      '39775' => 'Software Engineer',              # Rahul
      '4248' => 'Head of Design',                  # Julie Chabin
      '151696' => 'Community',                     # Jacq von Tesmar
      '234457' => 'COO',                           # Emily Hodgins
      '294167' => 'Community',                     # Jake Crump
      '1439429' => 'Sales / Business Development', # Lanre Akinyemi
      '138764' => 'Designer',                      # Kyle Frost
      '4046477' => 'Software Engineer',            # Jagadeesh
      '3837950' => 'Software Engineer',            # Alan Simon
      '3192969' => 'Content Lead',                 # Sarah Wright
      '3208719' => 'Community',                    # Aditya Vardhan Singh Choudhary
      '3266338' => 'Software Engineer',            # Andrew Radev
      '805906' => 'Software Engineer',             # Rajkumar Balakrishnan
      '3475458' => 'Product Manager',              # Michael Silber
      '4110317' => 'Product Manager',              # Daniel Ferro
      '3864161' => 'Social Media',                 # Shawn Myers
      '3808187' => 'Engineering Lead',             # John Grange
      '3774512' => 'People Ops',                   # Leeann
      '3895909' => 'Software Engineer',            # Mike Ciesielka
      '760239' => 'Software Engineer',             # Alexis Bronchart
      '2823267' => 'Engineering Lead',             # Ryan Osgood
      '3985304' => 'Marketing',                    # Cristina Bunea
      '3958513' => 'Head of Data Science',         # Peggy Fan
      '3797522' => 'Software Engineer',            # Julian Lord
      '3972361' => 'Software Engineer',            # Richard Siwady
      '1741138' => 'Designer',                     # Kyler Phillips
      '4460942' => 'Software Engineer',            # Bharat Chhabra
      '4114307' => 'VP of Marketing',              # Laura Mesa
      '4223657' => 'People Ops',                   # Becky Heyward
      '4247592' => 'Account Executive',            # Brittany Radtke
      '726999' => 'Community',                     # Aaron O'Leary
      '4327674' => 'Marketing',                    # Jamie Sprowl
      '4107391' => 'Data Science',                 # Emmett Storts
      '4461075' => 'Engineering Lead',             # Sachindra Ariyasinghe
      '4399713' => 'Software Engineer',            # Taha Elaradi
      '4469173' => 'Software Engineer',            # Denis Tsuman
      '3734139' => 'Community',                    # Suman Choudhary
      '4418655' => 'Community',                    # Pamela Garza
      '4728399' => 'Chief of Staff',               # Katie Talwar
    }.freeze

    THANKFUL_IDS = [
      '108',             # Robert Shedd
      '16056',           # Eric Willis
      '47518',           # Corley Hughes
      '787',             # Mike Coutermarsh
      '98516',           # Steph Bain
      '8319',            # Erik Torenberg
      '12',              # Zack Shapiro
      '1',               # Nathan Bashaw
      '1880',            # Ben Lang
      '4062005',         # Ben Tossell
      '22891',           # Tiffany Zhong
      '24323',           # Lukas Fittl
      '8483',            # David McKinney
      '239385',          # Lejla Bajgoric
      '85553',           # Shaun Modi
      '48747',           # Amit Jain
      '10748',           # Nichole Elizabeth
      '2081',            # Bram Kanstein
      '239747',          # Andrew Ettinger
      '25634',           # Alex Carter
      '10349',           # Riccardo Arvizzigno
      '862',             # Jonno Riekwel
      '31387',           # Michiel de Graaf
      '254861',          # Melissa Joy Kong
      '4557',            # Andreas Klinger
      '67838',           # Ayrton De Craene
      '103684',          # Korbin Hoffman
      '8412',            # Veselin Todorov
      '946',             # Niv Dror
      '151665',          # Kate Segrin
      '250100',          # Nick Abouzeid
      '71',              # Chad Whitaker
      '47229',           # Kristian Freeman
      '20046',           # Kai Gradert
      '1114145',         # Brett Bolkowy
      '382113',          # Justin Potts
      '213986',          # Amrith Shanbhag
      '186194',          # Thomas Groutars
      '269621',          # Abadesi Osunsade
      '963533',          # Taylor Majewski
      '86915',           # Dhruv Parmar
      '1405568',         # Lizzie MacNeill
      '1973817',         # Nikolay Valchanov
      '13621',           # Dan Edward
      '788110',          # Josh Vandergrift
      '84553',           # Gabe Perez
      '165894',          # Leandro
      '1457505',         # Timothy Carambat
      '3250422',         # Emil Emilov
      '3766461',         # Alfredo Contreras
      '169410',          # Seth Williams
      '577471',          # Audrey Lo
      '1074431',         # Naman Kumar
      '1132395',         # Sharath Kuruganty
      '127',             # Ryan Gilbert
      '3413326',         # Alex Shebar
      '514245',          # Calum Webb
      '4393700',         # Veronica Berisha
      '780095',          # Cindy Qiu
    ].freeze

    ANGEL_INVESTORS_IDS = [
      '8660',            # Alexis Ohanian
      '28',              # Andrew Chen
      '33659',           # Abdur Chowdhury
      '8052',            # Brenden Mulligan
      '666245',          # Jack Altman
      '29570',           # Naval Ravikant
      '9',               # Nir Eyal
    ].freeze
  end
end
