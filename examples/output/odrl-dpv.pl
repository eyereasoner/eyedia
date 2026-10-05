decision('ex:r3', deny(prohibited_by('ex:noMarketing'))).
decision('ex:r6', deny(prohibited_by('ex:noTransferUS'))).
conflict('ex:r6', resolved_by('odrl:prohibit', 'ex:noTransferUS', overrides('ex:research'))).
decision('ex:r1', permit('ex:research')).
decision('ex:r2', deny(not_permitted([unmet('ex:forResearch', 'odrl:purpose', 'dpv:PersonalisedAdvertising', 'odrl:isA', 'dpv:ResearchAndDevelopment')]))).
decision('ex:r4', deny(not_permitted([unmet('ex:consentGiven', 'ex:consentStatus', 'dpv:ConsentWithdrawn', 'odrl:eq', 'dpv:ConsentGiven')]))).
decision('ex:r5', deny(not_permitted([unmet('ex:pseudonymised', 'ex:technicalMeasure', 'dpv:Encryption', 'odrl:eq', 'dpv:Pseudonymisation'), unmet('ex:before2027', 'odrl:dateTime', 20270301, 'odrl:lt', 20270101)]))).
duty('ex:r1', 'odrl:delete', within_days(90)).
