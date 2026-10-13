Aliases, or power search commands, enable you to target your query against specific fields, such as the date, title or
subject. The alias is a label for the field. The query value is the data or text you want to search. The alphabetical
list below describes the available aliases.

The syntax for a power search is**alias:queryvalue**. For example,

date:17/03/2010

The alias is always lowercase. There should be no space between the
colon at the end of the alias and the query value. Query values made up
of more than one word should be enclosed in quotation marks.

summary:\"school meals"

Aliases can be used in combination with each other. Boolean queries are
supported.

> type:\"research briefings\" title:(\"election timetables\" OR
> \"election results\")

This query could also be written as:

> type:\"research briefings\" (title:\"election timetables\" OR
> title:\"election results\")

The [Librarian
tools](https://beta-search.parliament.uk/meta/librarian-tools) feature
provides information about what was actually searched for. Please refer
to [Coverage](https://beta-search.parliament.uk/meta/coverage) to find
out more about the available data.

### answeredby

Search for members, departments or arm's length bodies answering oral or
written questions or responding to debates.

> answeredby:\"Home Office\"
>
> answeredby:"Vince Cable"
>
> answeredby:"UK Statistics Authority"

### answeringmember

Search for members answering oral or written questions or responding to
debates.

> answeringmember:\"Blunkett, David\"

### answeringmemberparty

Search by the party of members answering oral or written questions or
responding to debates.

> answeringmemberparty:\"Liberal Democrat\"

### answertext

Search for words or phrases within the answer to oral or written
questions.

> answertext:motorways
>
> answertext:(\"common land\" NOT \"village greens\")

### askedby

Search for members asking oral or written questions.

> askedby:\"Bradshaw, Ben"

### author

Search for documents, questions, contributions, early day motions or
proceedings by personal or corporate author.

> author:DWP
>
> author:"Baroness Primarolo"

### certifiedcategory

Search for bills or statutory instruments certified by the Speaker, by
the type of certification.

> certifiedcategory:"Money bills"
>
> certifiedcategory:\"Applies to England and Wales\"
>
> certifiedcategory:\"Applies to England only\"
>
> certifiedcategory:\"Applies to England, Wales and Northern Ireland \"
>
> certifiedcategory:\"Applies to Scotland only\"
>
> certifiedcategory:\"Not certified under English Votes for English
> Law\"

### chair

Search for contributions and proceedings made by the Speaker and members
acting as chair.

> chair:yes

### chamberorcommittee

Search for contributions or proceedings by place. The available values
are General committees, House of Commons chamber, House of Commons Grand
Committees, House of Lords chamber, House of Lords Grand Committee,
Standing committees, and Westminster Hall.

> chamberorcommittee:\"Westminster Hall\"
>
> chamberorcommittee: (\"House of Lords chamber\" NOT \"House of Lords
> Grand Committee\")

### comingintoforce

Search for statutory instruments and parliamentary papers by the date on
which they come into force. Search for a specific date, or a relative
date range such as \'this month\', or within a date range. See date for
more examples.

> comingintoforce:17/03/2025
>
> comingintoforce:01/01/2026..31/03/2026
>
> comingintoforce:thismonth

### commonsapproved

Search for statutory instruments and parliamentary papers by the date on
which they were approved in the Commons. Search for a specific date, or
a relative date range such as \'this month\', or within a date range.
See date for more examples.

> commonsapproved:2024
>
> commonsapproved:lastweek

### contributor 

Search for briefings and research published by the Commons Library, the
Lords Library or the Parliamentary Office of Science and Technology
(POST)by contributor name.

contributor:\"Andrew Mackley"

### corrected

Search for answered questions or written statements which were
subsequently corrected.> corrected:true

### date

Search for a specific date, or a relative date range such as \'this
month\', or within a date range. The format for entering a date is
flexible. 31/12/2007 is equivalent to 31-12-2007, and to 2007/12/31, and
to 2007-12-31. January/2019 is equivalent to jan/2019.

> date:31/01/2012
>
> date:01/04/2016..31/04/2016 (between)
>
> date:\*..September/2021 (up to)
>
> date:Jan/2026..\* (onwards)
>
> date:yesterday
>
> date:thisweek(from Monday of this week to today)
>
> date:lastweek(from the previous Monday to Friday)
>
> date:thismonth(from the 1st of this month to date)
>
> date:lastmonth(anytime during the last calendar month)
>
> date:thisyear(from the 1st of January of this year to date)
>
> date:lastyear(from the 1st of January to 31st of December of last
> year)

Custom relative date period can be searched for by using the Solr
"date_dt" queries.

> type:"Members\' contributions" date_dt:\[NOW-6MONTHS TO NOW\]
>
> last 6 months of members' contributions
>
> dateTabled_dt:\[NOW-10DAYS TO NOW\]
>
> EDMs tabled in the past 10 days: type:EDMs
>
> dateForAnswer_dt:\[NOW TO \"NOW+10DAYS\"\]
>
> any written question with a date for answer in the next 10 days:

### dateanswered

Search for oral or written questions by the date of answer. Search for a
specific date, or a relative date range such as \'this month\', or
within a date range. See date for more examples.

> dateanswered:19/03/2025
>
> dateanswered:thismonth

### dateforanswer

Search for oral or written questions by the date on which the answer is
expected. Search for a specific date, or a relative date range such as
\'this month\', or within a date range. See date for more examples.

> dateforanswered:19/03/2025
>
> dateforanswer:thismonth

### datemade

Search for statutory instruments and parliamentary papers by the date on
which they were made. Search for a specific date, or a relative
date range such as \'this month\', or within a date range. See date for
more examples.

> datemade:24/02/2025
>
> datemade:lastmonth

### dateoriginated

Search for deposited papers and Transport and Works Act order
applications by the date the paper was written. Search for a specific
date, or a relative date range such as \'this month\', or within a date
range. See date for more examples.

> dateoriginated:01/01/2025..31/01/2025

### datereceived

Search for deposited papers by the date the Commons and Lords Libraries
received the paper. Search for a specific date, or a relative date range
such as \'this month\', or within a date range. See date for more
examples.

> datereceived:01/01/2025..31/01/2025

### datesigned

Search for early day motions signed on a date or within a relative, or
specific, date range. Combining this alias with a search for a member
will return EDMs signed on the date specified which were also signed by
that member; not EDMs signed by the member on the specified date.

> datesigned:03/02/2025

### datesponsored

Search for early day motions signed by a sponsor on a date or within a
relative, or specific, date range. The first six members who have signed
in support of the motion are the sponsors. Combining this alias with a
search for a member will return EDMs sponsored on the date specified
which were also signed by that member; not EDMs signed by the member on
the specified date.

> datesponsored:03/02/2025

### datetabled

Search by date of tabling for early day motions, written or oral
questions tabled in the Commons, and from the 14/15 session for written
questions tabled in the Lords. Search for a specific date, or a relative
date range such as \'this month\', or within a date range. See date for
more examples.

> datetabled:lastmonth

### dept

Search for documents, questions, contributions, early day motions or
proceedings by department or answering body.

> dept:PM
>
> dept:\"Department for Transport\"

### explanatorymemorandum

Search for bills, statutory instruments and parliamentary papers for
which an explanatory memorandum has been produced.

> explanatorymemorandum:yes

### from

Search for content from a date.

> from:01/03/2025

### groupedanswer

Search for written questions that have been grouped for answer by a
minister. Similar or identical questions from members may be given the
same response.

> groupedanswer:yes

### holdinganswer

Search for Commons written questions which have received, or are
currently in receipt of, a holding answer. A holding answer to a written
question may be issued by a minister ahead of a substantive or final
answer.

> holdinganswer:yes

### house

Search for parliamentary business by the House in which the business
occurred.

> house:"House of Lords"
>
> house:(\"House of Commons\" AND \"House of Lords\")

### impactassessment

Search for statutory instruments and parliamentary papers for which an
impact assessment has been produced.

> impactassessment:yes

### legstage

Search for legislative proceedings by legislative stage.

> legstage:"first reading"
>
> legstage:"second reading"
>
> legstage:"third reading\"
>
> legstage:"committee stage"
>
> legstage:"report stage"
>
> legstage:"commons amendments"
>
> legstage:"lords amendments"
>
> legstage:"royal assent"

### legtitle

Search using the title of an item of legislation to find material
relating to or about that item of legislation.

> legtitle:"Proceeds of Crime Act 2002"
>
> legtitle:"Counsellors of State Bill (HL) 2022-23\"
>
> legtitle:"Courts and Tribunals Bill 2024-26 to 2026-27\"

### libraryloc

Search for parliamentary material held by the Commons and Lords
Libraries, by shelfmark or reference denoting location.

> libraryloc:\"UP 805\"

### member

Search for parliamentary material in the Commons or Lords by the name or
title of a member.

> member:"Owen of Alderley Edge, Baroness"
>
> member:\"Baroness Owen of Alderley Edge\"
>
> member:\"Charlotte Owen\"
>
> member:"Owen, Charlotte\"

### memberparty

Search for parliamentary material by party.

> memberparty:Conservative
>
> memberparty:"Independent (affiliation)"

### notes

Search the text of notes added to items, including Coming into force
notes.

> notes:corrected
>
> notes:"Coming into force in accordance with regulation 1"

### notreached

Search for Commons questions not reached during oral question time, for
which a written answer has been provided.

> notreached:yes

### opqtype

Search for lead, first supplementary, other supplementary or all
supplementary oral questions.

> opqtype:lead
>
> opqtype:firstsupp
>
> opqtype:othersupp
>
> opqtype:supp

### othersponsor

Search for early day motions or amendments by members sponsoring, other
than the primary sponsor.

> othersponsor:\"Jim Shannon\"

### place

Search for contributions or proceedings by place. The available values
are General committees, House of Commons chamber, House of Commons Grand
Committees, House of Lords chamber, House of Lords Grand Committee,
Standing committees, and Westminster Hall.

> place:\"Westminster Hall\"
>
> place: (\"House of Lords chamber\" NOT \"House of Lords Grand
> Committee\")

### primarymember

Search for members asking oral or written questions, tabling early day
motions, making statements or leading proceedings.

> primarymember:\"Kemi Badenoch"

### primarymemberparty

Search by the party of members asking oral or written questions, tabling
early day motions, making statements or leading proceedings.

> primarymemberparty:\"Cooperative Party\"

### primarysponsor

Search for early day motions or amendments by primary sponsor.

> primarysponsor:\"Caroline Lucas\"

### procedure

Search for parliamentary business where certain procedures, events or
conventions have occurred.

> procedure:\"Allocation of time motions\"
>
> procedure:"Maiden speeches"
>
> procedure:"Time limits on speeches"

### prorogationanswer

Search for, or exclude, prorogation answers to a written question. These
are answers which may be provided if it has not been possible to provide
a substantive answer in the time available before prorogation.

> prorogationanswer:yes
>
> type:\"written questions\" prorogationanswer:no

### publisher

Search by publisher.

> publisher:"House of Commons"
>
> publisher:"House of Commons Library"
>
> publisher:"House of Lords"
>
> publisher:"House of Lords Library"
>
> publisher:POST

### questiontext

Search for words or phrases within oral or written questions.

> questiontext:horses
>
> questionText:\"impact of traffic levels\"

### ref

Search by reference number, including Hansard volume and column number.

> ref:"SI 2016/983"
>
> ref:"CP 1677"
>
> ref:HCWS346
>
> ref:"59 cc76-1036"
>
> ref:"HL Bill 76 2023-24"

### reginterest

Search for questions, contributions and early day motions where a member
has declared an interest which may be relevant to the subject matter.
Data for EDMs is only available until October 2018.

> reginterest:yes

### resolutionprocedure

Search for statutory instruments and parliamentary papers by procedure.

> resolutionprocedure:Affirmative
>
> resolutionprocedure:"LRO Affirmative"
>
> resolutionprocedure:\"LRO Negative\"
>
> resolutionprocedure:\"LRO Super-Affirmative\"
>
> resolutionprocedure:Negative
>
> resolutionprocedure:None
>
> resolutionprocedure:"Not for Appendix"
>
> resolutionprocedure:\"Regulatory Reform\"
>
> resolutionprocedure:"Special"

### section

Search for briefings published by the Commons Library by team name.

> section:"International Affairs and Defence Section"
>
> section:"Science and Environment Section"

### session

Search for parliamentary business by session. Query values can be
entered in the format 08/09, 08-09, 2008/09, 2008-09, 2008/2009,
2008-2009.

> session:19/21
>
> session:2010-12
>
> session:(19/19 OR 17/19)

### signedby

Search for early day motions or amendments signed by a member.

> signedby:\"Andrew Rosindell\"

### stats

Search for parliamentary business or research which includes statistical
information.

> stats:yes

### status

Search for early day motions or parliamentary questions by status.

> status:answered
>
> status:holding>
> status:open
>
> status:tabled>
> status:withdrawn

### subject

Search by subject.

> subject:housing
>
> subject:(\"Interest rates\" \"economic growth\")

### summary

Search for words or phrases within the summary of parliamentary
proceedings, deposited papers and briefings and research published by
the Commons Library, the Lords Library or the Parliamentary Office of
Science and Technology (POST).> summary:\"privilege amendment\"
                              >
                              > summary:\"deferred divisions\"

### tabledby

Search for members tabling early day motions, or oral or written
questions.

> tabledby:\"Shirley Williams"
>
> tabledby:" Baroness Afshar"

### timestamp

Timestamp refers to the date a record in Parliamentary Search was last
indexed or updated. Search for a specific date, or a relative date range
such as \'this month\', or within a date range.

> timestamp:06/07/2026..\*

### title

for words or phrases within the title.

> title:\"dairy farms\"
>
> title:(\"mobile phones\" AND schools)

### to

> Search for content before a date.
>
> to:01/01/2017

### topic

Search for briefings and research published by the Commons Library, the
Lords Library or the Parliamentary Office of Science and Technology
(POST) by topic.

> topic:charities

### transferred

Search forTop of Form written qquestions which have been transferred by
the answering body to which it was originally tabled to be answered by
another answering body.

> transferred:yes

### type

Search by content type.

> type:(edms OR opqs)
>
> type:"Questions for short debate"
>
> type:"Speaker's statements"

### uin

Search for written statements or oral or written questions by UIN.

> uin:903481
>
> uin:HLWS156

### unstarred

Search for questions in the House of Commons originally selected for
oral answer for which a written answer was subsequently requested.

> unstarred:yes

### witness

Search for witnesses providing oral evidence to select and public bill
committees.

> witness:\"News International\"
>
> witness:\"Tony Blair\"

### wpqtype

Search for Commons written questions by type. Ordinary questions are
usually answered between five and 10 working days after the question has
been tabled. Named day refers to priority questions, to be answered on
the third sitting day after they are tabled.

> wpqtype:\"named day\"
