decision(in_force, v1, no_consent_needed, basis(['ePrivacy Art. 5(3)'])).
decision(in_force, v2, ask_for_consent, basis(['ePrivacy Art. 5(3)'])).
decision(in_force, v3, ask_for_consent, basis(['ePrivacy Art. 5(3)'])).
decision(in_force, v4, ask_for_consent, basis(['ePrivacy Art. 5(3)'])).
decision(in_force, v5, ask_for_consent, basis(['ePrivacy Art. 5(3)'])).
decision(in_force, v6, ask_for_consent, basis(['ePrivacy Art. 5(3)'])).
decision(in_force, v7, ask_for_consent, basis(['ePrivacy Art. 5(3)'])).
decision(in_force, b1, notify(authority(none), people(none)), basis(['GDPR Art. 33(1)', 'GDPR Art. 34(1)'])).
decision(in_force, b2, notify(authority(within_hours(72)), people(none)), basis(['GDPR Art. 33(1)', 'GDPR Art. 34(1)'])).
decision(in_force, b3, notify(authority(within_hours(72)), people(without_undue_delay)), basis(['GDPR Art. 33(1)', 'GDPR Art. 34(1)'])).
decision(omnibus_proposal, v1, no_consent_needed, basis(['GDPR Art. 88a(3)(b)'])).
decision(omnibus_proposal, v2, no_consent_needed, basis(['GDPR Art. 88a(3)(c)'])).
decision(omnibus_proposal, v3, ask_for_consent, basis(['GDPR Art. 88a(1)'])).
decision(omnibus_proposal, v4, refused_by_signal, basis(['GDPR Art. 88a(1)', 'GDPR Art. 88b(1)-(2)'])).
decision(omnibus_proposal, v5, ask_for_consent, basis(['GDPR Art. 88a(1)', 'GDPR Art. 88b(3)'])).
decision(omnibus_proposal, v6, do_not_ask_again, basis(['GDPR Art. 88a(1)', 'GDPR Art. 88a(4)(c)'])).
decision(omnibus_proposal, v7, ask_for_consent, basis(['GDPR Art. 88a(1)', 'GDPR Art. 88a(4)(c)'])).
decision(omnibus_proposal, b1, notify(authority(none), people(none)), basis(['GDPR Art. 33(1) as amended', 'GDPR Art. 34(1)'])).
decision(omnibus_proposal, b2, notify(authority(none), people(none)), basis(['GDPR Art. 33(1) as amended', 'GDPR Art. 34(1)'])).
decision(omnibus_proposal, b3, notify(authority(within_hours_via_single_entry_point(96)), people(without_undue_delay)), basis(['GDPR Art. 33(1) as amended', 'GDPR Art. 34(1)'])).
changed(v2, from(ask_for_consent), to(no_consent_needed), because(['GDPR Art. 88a(3)(c)'])).
changed(v4, from(ask_for_consent), to(refused_by_signal), because(['GDPR Art. 88a(1)', 'GDPR Art. 88b(1)-(2)'])).
changed(v6, from(ask_for_consent), to(do_not_ask_again), because(['GDPR Art. 88a(1)', 'GDPR Art. 88a(4)(c)'])).
changed(b2, from(notify(authority(within_hours(72)), people(none))), to(notify(authority(none), people(none))), because(['GDPR Art. 33(1) as amended', 'GDPR Art. 34(1)'])).
changed(b3, from(notify(authority(within_hours(72)), people(without_undue_delay))), to(notify(authority(within_hours_via_single_entry_point(96)), people(without_undue_delay))), because(['GDPR Art. 33(1) as amended', 'GDPR Art. 34(1)'])).
