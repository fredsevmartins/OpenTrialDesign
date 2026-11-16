# Usability and accessibility evaluation

Status: automated browser checks executed as recorded in CI; **no real-user
study has been performed**. Recruit trial statisticians and clinical researchers
with varied R experience and accessibility needs; obtain appropriate consent.
Do not use patient information in test projects.

Test tasks: specify a directional trial; distinguish total from one-sided alpha;
identify binding futility; compare a sensitivity grid; assess simulation MCSE;
cancel/restart a batch; export/import the exact project; identify model limits.

Collect completion without assistance, interpretation errors, elapsed time,
keyboard/screen-reader barriers and participant feedback. Record actual
observations in usability-results.csv; retain failures, not only successes.
Review by task and participant group; prioritize mistakes that alter scientific
interpretation over cosmetic preferences. Repeat affected tasks after fixes.

Automated acceptance covers keyboard focus/skip navigation, labels, tab
semantics, live job status, mobile overflow and axe WCAG A/AA violations in key
states. It does not replace screen-reader evaluation or observation with users.
