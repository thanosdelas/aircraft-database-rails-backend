namespace :aircraft do
  desc "Import data from opensky network aircraft database"
  task opensky_network: :environment do
    require 'csv'

    csv_file = "#{Rails.root}/tmp/data/aircraftDatabase.csv"

    counter = 0
    collect_rows = []

    first = OpenskyNetworkRaw.first

    OpenskyNetworkRaw.delete_all

    puts "\nImporting ... "
    CSV.foreach(csv_file, headers: true) do |row|
      counter = counter + 1

      row = OpenskyNetworkRaw.new(row.to_hash)

      row.save

      break if counter == 10000
    end
    puts "\nDone"
  end

  desc "Import data from opensky network aircraft database"
  task list: :environment do
    require 'csv'

    lockheed_martin = [
      "Lockheed Vega",
      "Lockheed Model 10 Electra",
      "Lockheed Model 12 Electra Junior",
      "Lockheed Model 14 Super Electra",
      "Lockheed Model 18 Lodestar",
      "Lockheed Constellation, airliner",
      "Lockheed L-049 Constellation, first model of the Lockheed Constellation",
      "Lockheed L-649 Constellation, improved Lockheed Constellation",
      "Lockheed L-749 Constellation, further improved Lockheed Constellation",
      "Lockheed L-1049 Super Constellation, largest produced model of the Lockheed Constellation",
      "Lockheed L-1649 Starliner, last model of the Lockheed Constellation",
      "Lockheed Saturn",
      "Lockheed L-188 Electra",
      "Lockheed JetStar, business jet",
      "Lockheed L-1011 TriStar, wide-body airliner",
      "Lockheed C-69/Lockheed C-121 Constellation, military transport versions of the Constellation",
      "YC-121F Constellation, experimental turboprop version",
      "Lockheed R6V Constitution, large transport aircraft",
      "Lockheed C-130 Hercules, medium combat transport (AC-130 gunship) (other variants)",
      "Lockheed C-141 Starlifter, long-range jet transport",
      "Lockheed C-5 Galaxy, heavy transport",
      "Flatbed, military transport project, canceled",
      "Lockheed P-38 Lightning, twin-engine propeller fighter",
      "Lockheed P-80 Shooting Star, the United States Air Force's first operational jet fighter",
      "Lockheed T-33 Shooting Star, trainer jet",
      "Lockheed F-94 Starfire, all-weather fighter",
      "Lockheed F-104 Starfighter, interceptor and later a multi-mission fighter, the 'missile with a man in it'",
      "Lockheed F-117 Nighthawk, stealth fighter attack aircraft",
      "General Dynamics F-16 Fighting Falcon, multirole fighter (Originally General Dynamics)",
      "Lockheed F-22, air superiority stealth fighter",
      "Lockheed F-35, air superiority and strike missions",
      "Lockheed Hudson, maritime patrol/bomber",
      "PV-1 Ventura and PV-2 Harpoon, Maritime patrol/bomber",
      "PO-1W/WV-1 Constellation, AWACS version of the Constellation",
      "EC-121/WV-2 Warning Star, AWACS version of the Super Constellation",
      "Lockheed P-2 Neptune, maritime patrol",
      "Lockheed P-3 Orion, ASW patrol",
      "Lockheed CP-140 Aurora, Maritime patrol aircraft",
      "Lockheed U-2/TR-1, reconnaissance",
      "Lockheed SR-71 Blackbird, reconnaissance (A-12) (M-21) (YF-12)",
      "Lockheed S-3 Viking, patrol/attack",
      "YO-3A Quiet Star",
      "Lockheed CL-475, rigid-rotor helicopter",
      "XH-51A/B (Lockheed CL-595/Model 286), compound helicopter testbed",
      "Lockheed AH-56 Cheyenne, prototype attack compound helicopter",
      "UGM-27 Polaris",
      "UGM-73 Poseidon",
      "UGM-89 Perseus",
      "Trident",
      "UGM-96 Trident I",
      "UGM-133 Trident II",
      "High Virgo",
      "Lockheed X-7",
      "Lockheed X-17",
      "Lockheed L-301 (aka X-24C)",
      "Lockheed Star Clipper",
      "Corona",
      "RM-81 Agena",
      "Agena target vehicle",
      "Apollo Launch Escape System",
      "Hubble Space Telescope",
      "Sea Shadow",
      "Odakyu Type 500 monorail for Mukōgaoka-Yūen Monorail (as Nihon-Lockheed Monorail, with Kawasaki Heavy Industries)",
      "Himeji Monorail Type 100/200 (as Nihon-Lockheed Monorail, with Kawasaki Heavy Industries)",
      "Northrop N-3PB",
      "Northrop A-17",
      "Northrop P-61 Black Widow",
      "Northrop XP-56 Black Bullet",
      "Northrop P-64",
      "Northrop XP-79 Flying Ram",
      "Northrop YB-35",
      "Northrop YB-49",
      "Northrop F-5 Freedom Fighter / Tiger II",
      "Northrop T-38 Talon",
      "Northrop YA-9",
      "Northrop Grumman B-2 Spirit",
      "Northrop Grumman E-2 Hawkeye",
      "Northrop Grumman RQ-4 Global Hawk",
      "Northrop Grumman X-47B",
      "Northrop Grumman MQ-8 Fire Scout",
      "Boeing 757",
      "Boeing 767",
      "Boeing 777",
      "Boeing 787 Dreamliner",
      "Boeing 737 Classic series",
      "Boeing 737 Next Generation series",
      "Boeing 737 MAX series",
      "Boeing 747-8",
      "Boeing AH-64 Apache",
      "Boeing E-3 Sentry (AWACS)",
      "Boeing E-767",
      "Boeing EA-18G Growler",
      "Boeing F/A-18E/F Super Hornet",
      "Boeing P-8 Poseidon",
      "Boeing KC-46 Pegasus",
      "Boeing 777X",
      "Boeing T-45 Goshawk",
      "Boeing C-17 Globemaster III",
      "Boeing 717 (formerly McDonnell Douglas MD-95)",
      "Boeing 737 AEW&C",
      "Boeing YAL-1 Airborne Laser",
      "Boeing X-32 (Joint Strike Fighter prototype)",
      "Boeing X-45 (Unmanned Combat Air Vehicle)",
      "Boeing CST-100 Starliner (Spacecraft)",
      "Boeing MQ-25 Stingray",
      "Boeing 737 Business Jet",
      "Boeing 777 Freighter",
      "Boeing 747 Dreamlifter",
      "Boeing 737-700ER",
      "Boeing 787-10 Dreamliner",
      "Boeing T-X (Advanced Pilot Training System)",
      "Boeing 737-800 Boeing Converted Freighter (BCF)",
      "Boeing 737-900ER",
      "Boeing 737 MAX 10",
      "Boeing KC-767",
      "Boeing E-767 Airborne Warning and Control System (AWACS)",
      "Boeing 767-400ER",
      "Boeing 737-900 Boeing Business Jet (BBJ3)",
      "Boeing 737 MAX 200",
      "Boeing T-7 Red Hawk (Advanced Pilot Training System)"
    ]

    Aircraft.delete_all
    lockheed_martin.each do |entry|
      row = Aircraft.new(model: entry)
      row.save
    end

    puts "\nDone"
  end

end
