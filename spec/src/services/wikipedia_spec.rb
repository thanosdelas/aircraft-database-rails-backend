# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/TrailingWhitespace Style/MultilineBlockChain
RSpec.describe ::Services::Wikipedia do
  subject do
    described_class.new
  end

  describe '#extract_infobox' do
    context 'when data does not contain an infobox' do
      let(:infobox_raw) do
        '{{aaa}} bbb ccc {{ddd}}'
      end

      it 'extracts the infoboxes' do
        infoboxes = subject.extract_infoboxes(infobox_raw)

        expect(infoboxes.length).to eq 0
      end
    end

    context 'when infobox raw is missing closing double curly braces' do
      let(:infobox_raw) do
        'data before the infobox {{Infobox aaa {{bbb ccc ddd}} data after the infobox'
      end

      it 'raises error' do
        expect do
          subject.extract_infoboxes(infobox_raw)
        end.to raise_error do |error|
          expect(error.message).to eq 'Reached the end of the string. Provided infobox raw is missing closing double curly braces.'
        end
      end
    end

    context 'when infobox raw contains no nested double curly braces' do
      let(:infobox_raw) do
        'data before the infobox {{Infobox aaa bbb ccc ddd}} data after the infobox'
      end

      it 'extracts the infoboxes' do
        infoboxes = subject.extract_infoboxes(infobox_raw)

        expect(infoboxes.length).to eq 1
        expect(infoboxes).to eq ['{{Infobox aaa bbb ccc ddd}}']
      end
    end

    context 'when infobox raw contains one level nested double curly braces' do
      let(:infobox_raw) do
        'data before the infobox {{Infobox {{aaa}} bbb ccc ddd}} data after the infobox'
      end

      it 'extracts the infoboxes' do
        infoboxes = subject.extract_infoboxes(infobox_raw)

        expect(infoboxes.length).to eq 1
        expect(infoboxes).to eq ['{{Infobox {{aaa}} bbb ccc ddd}}']
      end
    end

    context 'when infobox raw contains one level nested double curly braces' do
      let(:infobox_raw) do
        'data before the infobox {{Infobox {{aaa with {{sub-aa}} aaa}} bbb ccc ddd}} data after the infobox'
      end

      it 'extracts the infoboxes' do
        infoboxes = subject.extract_infoboxes(infobox_raw)

        expect(infoboxes.length).to eq 1
        expect(infoboxes).to eq ['{{Infobox {{aaa with {{sub-aa}} aaa}} bbb ccc ddd}}']
      end
    end

    context 'when infobox raw for Airbus A320 contains no nested double curly braces' do
      let(:infobox_raw) do
        <<-TEXT
          {{Short description|European airliner family}}
          {{Other uses|A320 (disambiguation)}}
          {{For|the series currently in production|Airbus A320neo family}}
          {{Use dmy dates|date=May 2024}}
          {{Use British English|date=August 2024}}

          {{Infobox aircraft 
          | name = Airbus A320
          | logo = Logo Airbus A320.svg
          | image = Airbus_A320-214,_Airbus_Industrie_JP7617615.jpg
          | image_caption = An A320 prototype in flight: a [[low-wing]] airliner with twin underwing [[turbofan]]s
          | aircraft_role = [[Narrow-body airliner]]
          | national_origin = Multi-national
          | manufacturers = [[Airbus]]
          | status = In service
          | primary_user = [[American Airlines]]
          }}

          The '''Airbus A320 family''' is a series of [[narrow-body airliner]]s developed and produced by [[Airbus]].

          The A320 was launched in March 1984, [[Maiden flight|first flew]] on 22 February 1987, and was introduced in April 1988 by [[Air France]].
          The first member of the family was followed by the stretched A321 (first delivered in January 1994), the shorter A319 (April 1996), and the even shorter A318 (July 2003).
          Final assembly takes place in [[Toulouse]] in France; [[Hamburg]] in Germany; [[Tianjin]] in China since 2009; and [[Mobile, Alabama]] in the United States since April 2016.


          The [[twinjet]] has a six-abreast economy cross-section and came with either [[CFM56]] or [[IAE V2500]] turbofan engines, except the CFM56/[[PW6000]] powered A318.
          The family pioneered the use of digital [[fly-by-wire]] and [[side-stick]] flight controls in airliners.
          Variants offer [[maximum take-off weight]]s from {{convert|68 to 93.5|t|lb}}, to cover a {{convert|3,100-3,750|nmi|lk=in|order=flip}} [[Range (aircraft)|range]].
        TEXT
      end

      it 'extracts the infoboxes' do
        infoboxes = subject.extract_infoboxes(infobox_raw)

        expect(infoboxes).to eq ["{{Infobox aircraft 
          | name = Airbus A320
          | logo = Logo Airbus A320.svg
          | image = Airbus_A320-214,_Airbus_Industrie_JP7617615.jpg
          | image_caption = An A320 prototype in flight: a [[low-wing]] airliner with twin underwing [[turbofan]]s
          | aircraft_role = [[Narrow-body airliner]]
          | national_origin = Multi-national
          | manufacturers = [[Airbus]]
          | status = In service
          | primary_user = [[American Airlines]]
          }}"]
      end
    end

    context 'when infobox raw for Airbus A320 contains nested opening and closing double curly braces' do
      let(:infobox_raw) do
        <<-TEXT
          {{Short description|European airliner family}}
          {{Other uses|A320 (disambiguation)}}
          {{For|the series currently in production|Airbus A320neo family}}
          {{Use dmy dates|date=May 2024}}
          {{Use British English|date=August 2024}}

          {{Infobox aircraft 
          | name = Airbus A320 family {{small|A318/A319/A320/A321}}
          | logo = Logo Airbus A320.svg
          | image = Airbus_A320-214,_Airbus_Industrie_JP7617615.jpg
          | image_caption = An A320 prototype in flight: a [[low-wing]] airliner with twin underwing [[turbofan]]s
          | aircraft_role = [[Narrow-body airliner]]
          | national_origin = Multi-national{{efn|Final assembly in France (Toulouse), Germany (Hamburg), China (Tianjin), and the United States (Mobile, Alabama)}}
          | manufacturers = [[Airbus]]
          | status = In service
          | primary_user = [[American Airlines]]
          | more_users = {{ubl|[[China Eastern Airlines]]|[[EasyJet]]|[[IndiGo]]}}
          | number_built = 11,707 {{as of|2024|10|lc=y}}{{Cite web |url=https://www.airbus.com/en/products-services/commercial-aircraft/market/orders-and-deliveries |title=Airbus Orders and Deliveries |date=31 October 2024 |access-date=7 November 2024 |url-status=live |archive-url=https://web.archive.org/web/20190210065631/https://www.airbus.com/aircraft/market/orders-deliveries.html |archive-date=10 February 2019 |work=[[Airbus]] |format=XLS}}
          | construction_date = {{ubl|1986{{ndash}}present|1986{{ndash}}2021 (ceo)|2012{{ndash}}present (neo)}}
          | introduction = 18 April 1988 with [[Air France]]{{cite magazine|author1=David Learmount|title=A320 in service: an ordinary aeroplane|journal=Flight International|date=3 September 1988|volume=134|issue=4129|pages=132, 133|url=http://www.flightglobal.com/pdfarchive/view/1988/1988%20-%202445.html|publisher=Reed Business Publishing|issn=0015-3710|access-date=18 November 2014|archive-url=https://web.archive.org/web/20141129043316/http://www.flightglobal.com/pdfarchive/view/1988/1988%20-%202445.html|archive-date=29 November 2014|url-status = live}}
          | first_flight = {{start date and age|1987|02|22|df=y}}
          | developed_into = [[Airbus A320neo family]]|[[Airbus A321neo]]
          | related = {{ubl|[[Airbus A318]]|[[Airbus A319]]|[[Airbus A321]]}}
          }}

          The '''Airbus A320 family''' is a series of [[narrow-body airliner]]s developed and produced by [[Airbus]].

          The A320 was launched in March 1984, [[Maiden flight|first flew]] on 22 February 1987, and was introduced in April 1988 by [[Air France]].
          The first member of the family was followed by the stretched A321 (first delivered in January 1994), the shorter A319 (April 1996), and the even shorter A318 (July 2003).
          Final assembly takes place in [[Toulouse]] in France; [[Hamburg]] in Germany; [[Tianjin]] in China since 2009; and [[Mobile, Alabama]] in the United States since April 2016.


          The [[twinjet]] has a six-abreast economy cross-section and came with either [[CFM56]] or [[IAE V2500]] turbofan engines, except the CFM56/[[PW6000]] powered A318.
          The family pioneered the use of digital [[fly-by-wire]] and [[side-stick]] flight controls in airliners.
          Variants offer [[maximum take-off weight]]s from {{convert|68 to 93.5|t|lb}}, to cover a {{convert|3,100-3,750|nmi|lk=in|order=flip}} [[Range (aircraft)|range]].

          The 31.4 m (103 ft) long [[Airbus A318|A318]] typically accommodates 107 to 132 passengers.
          The 124-156 seat [[A319]] is 33.8 m (111 ft) long.
          The A320 is 37.6 m (123 ft) long and can accommodate 150 to 186 passengers.
          The 44.5 m (146 ft) [[A321]] offers 185 to 230 seats.
          The [[Airbus Corporate Jets]] are modified business jet versions of the standard commercial variants.


          In December 2010, Airbus announced the [[re-engine]]d [[Airbus A320neo family|A320neo]] (''new engine option''), which entered service with [[Lufthansa]] in January 2016.
          With more efficient turbofans and improvements including [[winglet|sharklets]], it offers up to 15% better [[fuel economy in aircraft|fuel economy]].
          The previous A320 generation is now called '''A320ceo''' (''current engine option'').


          [[American Airlines]] is the largest A320 operator with 479 aircraft in its fleet, while [[IndiGo]] is the largest customer with 930 aircraft on order. In October 2019, the A320 family surpassed the [[Boeing 737]] to become the highest-selling airliner. 
          {{as of|2024|10}}, a total of 18,994 A320 family aircraft had been [[List of Airbus A320 orders|ordered]] and 11,707 [[List of Airbus A320 operators|delivered]], of which 10,803 aircraft were in service with more than 350 operators. The global A320 fleet had completed more than 176 million flights over 328 million block hours since its entry into service.
          The A320ceo initially competed with the [[737 Classic]] and the [[MD-80]], then their successors, the [[737 Next Generation]] (737NG) and the [[MD-90]] respectively, while the [[737 MAX]] is Boeing's response to the A320neo.
        TEXT
      end

      it 'extracts the infoboxes' do
        infoboxes = subject.extract_infoboxes(infobox_raw)

        expect(infoboxes).to eq ["{{Infobox aircraft 
          | name = Airbus A320 family {{small|A318/A319/A320/A321}}
          | logo = Logo Airbus A320.svg
          | image = Airbus_A320-214,_Airbus_Industrie_JP7617615.jpg
          | image_caption = An A320 prototype in flight: a [[low-wing]] airliner with twin underwing [[turbofan]]s
          | aircraft_role = [[Narrow-body airliner]]
          | national_origin = Multi-national{{efn|Final assembly in France (Toulouse), Germany (Hamburg), China (Tianjin), and the United States (Mobile, Alabama)}}
          | manufacturers = [[Airbus]]
          | status = In service
          | primary_user = [[American Airlines]]
          | more_users = {{ubl|[[China Eastern Airlines]]|[[EasyJet]]|[[IndiGo]]}}
          | number_built = 11,707 {{as of|2024|10|lc=y}}{{Cite web |url=https://www.airbus.com/en/products-services/commercial-aircraft/market/orders-and-deliveries |title=Airbus Orders and Deliveries |date=31 October 2024 |access-date=7 November 2024 |url-status=live |archive-url=https://web.archive.org/web/20190210065631/https://www.airbus.com/aircraft/market/orders-deliveries.html |archive-date=10 February 2019 |work=[[Airbus]] |format=XLS}}
          | construction_date = {{ubl|1986{{ndash}}present|1986{{ndash}}2021 (ceo)|2012{{ndash}}present (neo)}}
          | introduction = 18 April 1988 with [[Air France]]{{cite magazine|author1=David Learmount|title=A320 in service: an ordinary aeroplane|journal=Flight International|date=3 September 1988|volume=134|issue=4129|pages=132, 133|url=http://www.flightglobal.com/pdfarchive/view/1988/1988%20-%202445.html|publisher=Reed Business Publishing|issn=0015-3710|access-date=18 November 2014|archive-url=https://web.archive.org/web/20141129043316/http://www.flightglobal.com/pdfarchive/view/1988/1988%20-%202445.html|archive-date=29 November 2014|url-status = live}}
          | first_flight = {{start date and age|1987|02|22|df=y}}
          | developed_into = [[Airbus A320neo family]]|[[Airbus A321neo]]
          | related = {{ubl|[[Airbus A318]]|[[Airbus A319]]|[[Airbus A321]]}}
          }}"]
      end
    end

    context 'when infobox raw for EADS HC-144 Ocean Sentry contains more than one infoboxes' do
      let(:infobox_raw) do
        <<-TEXT
          {{short description|Maritime patrol and air-sea rescue aircraft}}

          {|{{Infobox aircraft begin
            |name = HC-144 Ocean Sentry
            |image = File:HC-144A Ocean Sentry (2).jpg
            |caption =
          }}{{Infobox aircraft type
            |type = [[Search-and-rescue]] aircraft
            |manufacturer = [[Airbus Military]] (prime contractor [[EADS North America]])
            |national origin=Spain
            |designer =
            |first flight =
            |introduced = 2009
            |retired =
            |status = In active service
            |primary user = [[United States Coast Guard]]
            |more users =
            |produced =
            |number built = 18[http://www.shephardmedia.com/news/imps-news/us-coast-guard-receives-18th-hc-144a-ocean-sentry/ US Coast Guard receives 18th HC-144A Ocean Sentry] {{Webarchive|url=https://web.archive.org/web/20190307112315/https://www.shephardmedia.com/news/imps-news/us-coast-guard-receives-18th-hc-144a-ocean-sentry/ |date=2019-03-07 }} – Shepgardmedia.com, 8 October 2014
            |developed from = [[CASA/IPTN CN-235]]
            |variants with their own articles =
            |developed into=
          }}
          |}

          The '''EADS HC-144 Ocean Sentry''' is a medium-range, twin-engined [[turboprop]] aircraft used by the [[United States Coast Guard]] in the [[search-and-rescue]] and [[maritime patrol]] missions. Based on the [[CASA/IPTN CN-235|Airbus Military CN-235]], it was procured as a \"Medium Range Surveillance Aircraft.\" The HC-144 is supplied by [[Airbus Group, Inc]], formerly EADS North America, and is built in Spain by [[Airbus Defence and Space]].
        TEXT
      end

      it 'extracts the infoboxes' do
        infoboxes = subject.extract_infoboxes(infobox_raw)

        expect(infoboxes.length).to eq 2

        expect(infoboxes[0]).to eq "{{Infobox aircraft begin
            |name = HC-144 Ocean Sentry
            |image = File:HC-144A Ocean Sentry (2).jpg
            |caption =
          }}"

        expect(infoboxes[1]).to eq "{{Infobox aircraft type
            |type = [[Search-and-rescue]] aircraft
            |manufacturer = [[Airbus Military]] (prime contractor [[EADS North America]])
            |national origin=Spain
            |designer =
            |first flight =
            |introduced = 2009
            |retired =
            |status = In active service
            |primary user = [[United States Coast Guard]]
            |more users =
            |produced =
            |number built = 18[http://www.shephardmedia.com/news/imps-news/us-coast-guard-receives-18th-hc-144a-ocean-sentry/ US Coast Guard receives 18th HC-144A Ocean Sentry] {{Webarchive|url=https://web.archive.org/web/20190307112315/https://www.shephardmedia.com/news/imps-news/us-coast-guard-receives-18th-hc-144a-ocean-sentry/ |date=2019-03-07 }} – Shepgardmedia.com, 8 October 2014
            |developed from = [[CASA/IPTN CN-235]]
            |variants with their own articles =
            |developed into=
          }}"
      end
    end
  end
end
# rubocop:enable Layout/TrailingWhitespace
