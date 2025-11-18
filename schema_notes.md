# Data Structure Notes

## output specs
- each element in array is a segment
- a segment is an option for a trip (i.e., not the individual legs of a trip)
- in the data model this would correspond to a journey or in some cases possibly an alternative

## input specs
- journeys represent options for a whole trip
  - will have staggered departure times
  - if simple a to b, likely one section with one alternative each
- legs represent the legs of the trip (surprise)
- sections have many alternatives and represent the options for a "superleg" of a trip/journey
- sections are supersets of legs between the edge nodes of a journey. E.g. return trips, out and back are separate sections
  - Sections appear to represent trip portions which happen on one ticket across compatible agencies. I.e., one ticket can work on both Deutsche Bahn and ÖBB, but if you have to change to Flixbus to reach the destination, then there is another section for the incompatible stretch. This is the case in the munich-stockholm data
  - maybe multiple also happens when you've selected a superstation, e.g., Munich (any) to Stockholm (any), so Munich Hbf to Stockholms centralstation is a different section from Munich ZOB to Stockholm Cityterminalen
  - perhaps also if a journey has multiple paths with a first leg on one vehicle but diverge later on (so they share a departure time/vehicle but not arrival time/vehicle)
  - if this is the case journeys, alternatives, and sections both should all iterated to build response as they all contain differing options to complete a trip: they are all supersets of legs to get from one place to another
- alternatives are different options to complete an entire section. Belongs to sections (?)
  - THIS IS THE OPTION FOR DIFFERENT FARE CLASSES! E.g. first vs. economy
  - has many fares (though I only saw one fare each. Perhaps multiple if multiple passengers)
  - contains prices
  - references fares, which contain terms/classes
  - alternatives/billable units correspond to a fare leg id and contain a price
- fares contain the fare conditions, classes, etc. (but not the prices)
  - belongs to alternatives (?)
  - fare has many fare legs
    - Presumably a fare has multiple fare legs if all legs have compatible fare classes, e.g. no mixed first and economy or whatever
    - and thus many legs
  - fare legs are 1:1 with legs
  - FARES CONTAIN THE ORIGIN AND DESTINATION!

# Output Example

```ruby
{
  # fare
  :departure_station => "Ashchurch For Tewkesbury",
  # journey
  :departure_at => #<DateTime: 2025-04-26T06:09:00+00:00 ((2456774j,22140s,0n),+0s,2299161j)>,
  # fare
  :arrival_station => "Ash",
  # journey
  :arrival_at => #<DateTime: 2025-04-26T09:37:00+00:00 ((2456774j,34620s,0n),+0s,2299161j)>,
  # carrier
  :service_agencies => ["thetrainline"],
  # journey
  :duration_in_minutes => 208,
  # legs CAUTION: fencepost problem
  :changeovers => 2,
  # legs > transport modes
  :products => ["train"],
  :fares => [
    {
      # fare type (class is in fare)
      :name => "Advance Single",
      # alternative CAUTION requires conversion
      :price_in_cents => 1939,
      # alternative
      :currency => "GBP",
      ...
    },
  ]
}
```

# Response Object Schema

This schema was written 100% manually with no AI assistance whatsoever
I did put some of the response objects into claude and chatgpt but their interpretations were not reliable
The AI bots did however provide a bit of insight into the meaning of the different parts of the data model (e.g. what is the difference between a section and alternative)

Partial schema. Missing a few items we don't need like pagination
all keys camelCase (I wrote it with spaces for readability)
examples pasted directly, data types or explanations parenthesized
I don't know why I chose to document the schema in this format, but that's what I ended up with so that's what we're using

(this looks much more ordered in my text editor, if you're viewing it on github it looks terrible)

Data
  Journey Search {}
    - id "46b125d6-81d0-4209-94e4-a56f8a23c522"
    Passengers {"pid-0": {}}
      - id "pid-0"
      - date of birth "1990-11-11T00:00:00"
    Journeys {"journey-9dbed88e-acf1-486b-9282-1991d056d225": {}}
      - id "journey-9dbed88e-acf1-486b-9282-1991d056d225"
      - sections ["section-b615d328-f667-490c-8d33-05ad3ec518c9"]
      - legs ["leg-d5bc004e-753d-49a4-8d30-0165002d336d"]
      - depart at "2025-11-12T03:49:00+01:00"
      - arrive at "2025-11-13T08:10:00+01:00"
      - duration "P1DT4H21M" (iso8601 duration format https://docs.digi.com/resources/documentation/digidocs/90001488-13/reference/r_iso_8601_duration_format.htm)
      - hash "b11+ntUS2bQ=" (no idea what this is)
      - has first class recommended station pair (boolean)
      - distance in km (int)
    Alternatives {"38b0ef18-5dd0-4e19-9dd2-d68761694330%alternative-dad3f0a0-e26c-4410-81ef-4e7a9e2102c1": {}}
      - id "38b0ef18-5dd0-4e19-9dd2-d68761694330%alternative-dad3f0a0-e26c-4410-81ef-4e7a9e2102c1"
      - price {}
        - amount 217.99
        - currency code "EUR"
        - currency conversion applied (boolean)
      - fullPrice {}
        - amount 217.99
        - currency code "EUR"
        - currency conversion applied (boolean)
      - fares ["fare-3156f381-cf0b-4037-891d-4d6788b63816"]
      - is partial (boolean)
      - vendor information {} (hash is NOT sub-keyed with ids, so one vendor per alternative, I guess)
        - id "58fdbad08428c787b9b6f7c6c515dd56c7c5ad1c"
        - code "urn:trainline:db_pst:vendor:db_pst",
        - name "DB PST"
        - description (often null)
      - billable units [{}]
        - correlation token "f40959814d96d3d91f5f33bd3c6b4bb379d0d308"
        - fare leg ids ["fare-leg-0da35302-d0bf-4969-afb4-0e76029051ed"]
        - original price (see above)
        - price (see above)
        - passenger ids ["pid-0"]
    Fares {"fare-3156f381-cf0b-4037-891d-4d6788b63816": {}}
      - id "fare-3156f381-cf0b-4037-891d-4d6788b63816"
      - fare legs [{}]
        - id "fare-leg-0da35302-d0bf-4969-afb4-0e76029051ed"
        - leg id "leg-d5bc004e-753d-49a4-8d30-0165002d336d"
        - travel class {}
          - id "c65e042eee0820ddbb90cf54686d84ac2c85b18a"
          - code "urn:trainline:db_pst:class:first"
          - name "First"
        - comfort (?? no idea what this key name means)
          - id "8ee034965c6ad781cfb9ef1deb6f53955756b77c"
          - code "urn:trainline:db_pst:comfort:first"
          - name "1st class"
        - reservation type "none"
        - local transport []
      - fare type "23544e0a31769c50273938e56bdf3ccc9f32500c"
      - origin "513d081e9027698b209c70e3969b0665e3207a41"
      - destination "761eb4af195705c5e924b1b6a1294d067f77904c"
      - availability {"status": "available"}
      - vouchers []
      - non contractual terms []
      - hash "H0J+LbFDkBM="
      - delivery options []
    Legs {"leg-d5bc004e-753d-49a4-8d30-0165002d336d": {}}
      - id "leg-d5bc004e-753d-49a4-8d30-0165002d336d"
      - duration "PT6H4M"
      - depart at "2025-11-12T03:49:00+01:00"
      - arrive at "2025-11-12T09:53:00+01:00"
      - timetable id "888" (train number)
      - transport designation "ICE" (product short name)
      - arrival location "8c4490a500065e0110d26fd2dfe83b1e04fa5eef"
      - departure location "513d081e9027698b209c70e3969b0665e3207a41"
      - carrier "519a2eb764bab72bb11bab4e612b42c6d9287b13"
      - vendor quota identifier "ICE 888" (transport designation + timetable id)
      - transport mode "8aa9ed677ae8353527f54ebafc1371cab2ac31da"
      - brand "840967a151abf34ae9c4c3dce08eae81386b3cba"
      - co2EmissionInGramsPerPassenger 11620
    Sections {"section-b615d328-f667-490c-8d33-05ad3ec518c9": {}}
      - id "section-b615d328-f667-490c-8d33-05ad3ec518c9"
      - alternatives ["38b0ef18-5dd0-4e19-9dd2-d68761694330%alternative-dad3f0a0-e26c-4410-81ef-4e7a9e2102c1"]
      - mixed leg comforts (boolean)
  Brands {"840967a151abf34ae9c4c3dce08eae81386b3cba": {}}
    - id "840967a151abf34ae9c4c3dce08eae81386b3cba"
    - code "urn:trainline:db_pst:brand:ice"
    - name "ice"
  Carriers {"519a2eb764bab72bb11bab4e612b42c6d9287b13": {}}
    - id "519a2eb764bab72bb11bab4e612b42c6d9287b13"
    - code "urn:trainline:db_pst:carrier:other"
    - name "Deutsche Bahn", "Other", "FlixBus"
  Locations {"8c4490a500065e0110d26fd2dfe83b1e04fa5eef": {}}
    - id "8c4490a500065e0110d26fd2dfe83b1e04fa5eef"
    - code "urn:trainline:db_pst:loc:8002549"
    - location type "station" ("city" if parent location)
    - name "Hamburg Hbf", "Hamburg"
    - short name (often null)
    - latitude 53.5527,
    - longitude 10.0069,
    - timezone "Europe/Berlin", "Europe/Copenhagen"
    - country code "DE",
    - language (often null)
    - address (often null, when not, lines of address split into array)
    - aliases (often null, when not, array)
    - parents [{}] (all the same fields as locations, because it is a location. unsure if could be multiple parents)
  Fare Types {"23544e0a31769c50273938e56bdf3ccc9f32500c": {}}
    - id "23544e0a31769c50273938e56bdf3ccc9f32500c"
    - code "urn:trainline:db_pst:fare:367544309a61083ed92768bd0b3b312b"
    - name "Super Sparpreis Europa"
    - conditions summary "Your ticket cannot be cancelled."
    - conditions [{}]
      - title "DESCRIPTION"
      - description "Your ticket cannot be cancelled"
    - fare pricing category "default"
    - secondary fare (often null)
    - validity periods (often null)
  Transport Modes {"8aa9ed677ae8353527f54ebafc1371cab2ac31da": {}}
    - id "8aa9ed677ae8353527f54ebafc1371cab2ac31da",
    - code "urn:trainline:db_pst:tramod:train",
    - name "Train", "Coach"
    - mode "train", "bus"
  Passenger Types {"7f9212e98506ecf63cd6735033fb000cf30a47a6": {}}
    - id "7f9212e98506ecf63cd6735033fb000cf30a47a6",
    - name "adult"
    - code "urn:trainline:db_pst:psgr:adult",
    - age restriction {"lowerBound": 27}
  Applied Discounts {}

# Request Body for /api/journey-search

```json
{
    "passengers": [],
    "isEurope": true,
    "cards": [],
    "transitDefinitions": [
        {
            "direction": "outward",
            "origin": "urn:trainline:generic:loc:7686",
            "destination": "urn:trainline:generic:loc:19102",
            "journeyDate": {
                "type": "departAfter",
                "time": "2025-11-11T15:00:59"
            }
        }
    ],
    "type": "single",
    "maximumJourneys": 5,
    "includeRealtime": true,
    "dpiCookieId": "3BBONDWS8NSV5REI4EI2TBJO",
    "transportModes": [
        "mixed"
    ],
    "directSearch": false,
    "composition": [
        "through",
        "interchangeSplit"
    ],
    "autoApplyCorporateCodes": false,
    "origin": "urn:trainline:generic:loc:7686",
    "destination": "urn:trainline:generic:loc:19102",
    "searchSpecificRequests": {
        "includeCheaperSlowerJourneys": true,
        "maxSplitPoints": 1
    },
    "requestedCurrencyCode": "EUR"
}
```