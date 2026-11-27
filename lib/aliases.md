Aliases, or power search commands, enable you to target your query against specific fields, such as the date, title or subject. The alphabetical list below describes the available aliases. 

The syntax for a power search is **alias:queryvalue**. An alias is a label for the field. The data or text you want to search for is known as the query value. 

> [date:17/03/2010](/search?query=date%3A17%2F03%2F2010)

The alias is always lowercase. There should be no space between the colon at the end of the alias and the query value. Query values made up of more than one word should be enclosed in quotation marks.

> [summary:"school meals"](/search?query=summary%3A%22school%20meals%22)

Aliases can be used in combination with each other. Boolean queries are supported.

> [type:"research briefings" title:("election timetables" OR "election results")](/search?query=type%3A%22research%20briefings%22%20title%3A%28%22election%20timetables%22%20OR%20%22election%20results%22%29)

This query could also be written as:

> [type:"research briefings" (title:"election timetables" OR title:"election results")](/search?query=type%3A%22research%20briefings%22%20%28title%3A%22election%20timetables%22%20OR%20title%3A%22election%20results%22%29)

Search for members, departments or arm's length bodies answering oral or written questions, or responding to debates.

> [answeredby:"Home Office"](/search?query=answeredby%3A%22Home%20Office%22)
>
> [answeredby:"Vince Cable"](/search?query=answeredby%3A%22Vince%20Cable%22)
>
> [answeredby:"UK Statistics Authority"](/search?query=answeredby%3A%22UK%20Statistics%20Authority%22)

## answeringmember

Search for members answering oral or written questions, or responding to debates.

> [answeringmember:"Blunkett, David"](/search?query=answeringmember%3A%22Blunkett%2C%20David%22)

## answeringmemberparty

Search by the party of members answering oral or written questions, or responding to debates.

> [answeringmemberparty:"Liberal Democrat"](/search?query=answeringmemberparty%3A%22Liberal%20Democrat%22)

## answertext

Search for words or phrases within the answers to oral or written questions.

> [answertext:motorways](/search?query=answertext%3Amotorways)
>
> [answertext:("common land" NOT "village greens")](/search?query=answertext%3A%28%22common%20land%22%20NOT%20%22village%20greens%22%29)

## askedby

Search for members asking oral or written questions.

> [askedby:"Bradshaw, Ben"](/search?query=askedby%3A%22Bradshaw%2C%20Ben%22)

## author

Search for documents, questions, contributions, early day motions or proceedings by personal or corporate author.

> [author:DWP](/search?query=author%3ADWP)
>
> [author:"Baroness Primarolo"](/search?query=author%3A%22Baroness%20Primarolo%22)

## certifiedcategory

Search for bills or statutory instruments certified by the Speaker, by the type of certification.

> [certifiedcategory:"Money bills"](/search?query=certifiedcategory%3A%22Money%20bills%22)
>
> [certifiedcategory:"Applies to England and Wales"](/search?query=certifiedcategory%3A%22Applies%20to%20England%20and%20Wales%22)
>
> [certifiedcategory:"Applies to England only"](/search?query=certifiedcategory%3A%22Applies%20to%20England%20only%22)
>
> [certifiedcategory:"Applies to England, Wales and Northern Ireland"](/search?query=certifiedcategory%3A%22Applies%20to%20England%2C%20Wales%20and%20Northern%20Ireland%22)
>
> [certifiedcategory:"Applies to Scotland only"](/search?query=certifiedcategory%3A%22Applies%20to%20Scotland%20only%22)

## chair

Search for contributions and proceedings made by the Speaker and members acting as chair.

> [chair:yes](/search?query=chair%3Ayes)

## chamberorcommittee

Search for contributions or proceedings by place. The available values are General committees, House of Commons chamber, House of Commons Grand Committees, House of Lords chamber, House of Lords Grand Committee, Standing committees, and Westminster Hall.

> [chamberorcommittee:"Westminster Hall"](/search?query=chamberorcommittee%3A%22Westminster%20Hall%22)
>
> [chamberorcommittee:(“House of Lords chamber” NOT “House of Lords Grand Committee”)](/search?query=chamberorcommittee%3A%28%E2%80%9CHouse%20of%20Lords%20chamber%E2%80%9D%20NOT%20%E2%80%9CHouse%20of%20Lords%20Grand%20Committee%E2%80%9D%29)




## comingintoforce

Search for statutory instruments and parliamentary papers by the date on which they come into force. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [comingintoforce:17/03/2025](/search?query=comingintoforce%3A17%2F03%2F2025)
>
> [comingintoforce:01/01/2026..31/03/2026](/search?query=comingintoforce%3A01%2F01%2F2026..31%2F03%2F2026)
>
> [comingintoforce:thismonth](/search?query=comingintoforce%3Athismonth)

## commonsapproved

Search for statutory instruments and parliamentary papers by the date on which they were approved in the Commons. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [commonsapproved:2024](/search?query=commonsapproved%3A2024)
>
> [commonsapproved:lastweek](/search?query=commonsapproved%3Alastweek)

## contributor

Search for briefings and research published by the Commons Library, the Lords Library, or the Parliamentary Office of Science and Technology (POST) by contributor name.

> [contributor:"Andrew Mackley"](/search?query=contributor%3A%22Andrew%20Mackley%22)

## corrected

Search for answered questions or written statements which were subsequently corrected.

> [corrected:true](/search?query=corrected%3Atrue)

## date 

Search for a specific date, a relative date range such as 'this month', or within a date range. The format for entering a date is flexible: 31/12/2007 may be expressed as 31-12-2007, or 2007/12/31, or 2007-12-31. 

> [date:31/01/2012](/search?query=date%3A31%2F01%2F2012)
>
> [date:01/04/2016..30/04/2016](/search?query=date%3A01%2F04%2F2016..30%2F04%2F2016) _(between two dates)_
>
> [date:*..09/2021](/search?query=date%3A%2A..09%2F2021) _(up to a date)_
>
> [date:01/2026..*](/search?query=date%3A01%2F2026..%2A) _(from a date)_

### relative date ranges

> [date:yesterday](/search?query=date%3Ayesterday)
>
> [date:thisweek](/search?query=date%3Athisweek) _(from Monday of this week to today)_
>
> [date:lastweek](/search?query=date%3Alastweek) _(from the previous Monday to Friday)_
>
> [date:thismonth](/search?query=date%3Athismonth) _(from the first of this month to today)_
>
> [date:lastmonth](/search?query=date%3Alastmonth) _(anytime during the last calendar month)_
>
> [date:thisyear](/search?query=date%3Athisyear) _(from the 1st of January this year to today)_
>
> [date:lastyear](/search?query=date%3Alastyear) _(from the 1st of January to 31st of December of last year)_

### custom relative date ranges 

The query values are case-sensitive.

> [date_dt:[NOW-6MONTHS TO NOW]](/search?query=date_dt%3A%5BNOW-6MONTHS%20TO%20NOW%5D) _(during the last 6 months)_
>
> [dateTabled_dt:[NOW-10DAYS TO NOW]](/search?query=dateTabled_dt%3A%5BNOW-10DAYS%20TO%20NOW%5D) _(tabled during the last 10 days)_
>
> [dateForAnswer_dt:[NOW TO "NOW+10DAYS"]](/search?query=dateForAnswer_dt%3A%5BNOW%20TO%20%22NOW%2B10DAYS%22%5D) _(due for answer in the next 10 days)_

## dateanswered

Search for oral or written questions by the date of answer. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [dateanswered:19/03/2025](/search?query=dateanswered%3A19%2F03%2F2025)
>
> [dateanswered:thismonth](/search?query=dateanswered%3Athismonth)

## datecertified 

Search for public bills certified by the Speaker as money bills by the date of certification. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples. 

> [datecertified:lastyear](/search?query=datecertified%3Alastyear)
>
> [datecertified:2020](/search?query=datecertified%3A2020)

## dateforanswer

Search for oral or written questions by the date on which the answer is expected. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [dateforanswer:19/03/2025](/search?query=dateforanswer%3A19%2F03%2F2025)
>
> [dateforanswer:thismonth](/search?query=dateforanswer%3Athismonth)

## datemade

Search for statutory instruments and parliamentary papers by the date on which they were made. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [datemade:24/02/2025](/search?query=datemade%3A24%2F02%2F2025)
>
> [datemade:lastmonth](/search?query=datemade%3Alastmonth)

## dateoriginated

Search for deposited papers and Transport and Works Act order applications by the date the paper was written. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [dateoriginated:01/01/2025..31/01/2025](/search?query=dateoriginated%3A01%2F01%2F2025..31%2F01%2F2025)

## datereceived

Search for deposited papers by the date the Commons and Lords Libraries received the paper. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [datereceived:01/01/2025..31/01/2025](/search?query=datereceived%3A01%2F01%2F2025..31%2F01%2F2025)

## datesigned

Search for early day motions signed on a date, within a date range, or within a relative date range such as ‘this month’. Combining this alias with a search for a member will return EDMs signed on the date specified which were also signed by that member; not EDMs signed by the member on the specified date.

> [datesigned:03/02/2025](/search?query=datesigned%3A03%2F02%2F2025)

## datesponsored

Search for early day motions signed on a date, within a date range, or within a relative date range such as ‘this month’. Sponsors are the first six members who have signed in support of the motion. Combining this alias with a search for a member will return EDMs sponsored on the date specified which were also signed by that member; not EDMs sponsored by the member on the specified date.

> [datesponsored:03/02/2025](/search?query=datesponsored%3A03%2F02%2F2025)

## datetabled

Search by date of tabling for early day motions, written or oral questions tabled in the Commons, and from the 14/15 session for written questions tabled in the Lords. Search for a specific date, a relative date range such as 'this month', or within a date range. See **date** for more examples.

> [datetabled:lastmonth](/search?query=datetabled%3Alastmonth)

## dept

Search for documents, questions, contributions, early day motions or proceedings by department or answering body.

> [dept:PM](/search?query=dept%3APM)
>
> [dept:"Department for Transport"](/search?query=dept%3A%22Department%20for%20Transport%22)

## explanatorymemorandum

Search for bills, statutory instruments and parliamentary papers for which an explanatory memorandum has been produced.

> [explanatorymemorandum:yes](/search?query=explanatorymemorandum%3Ayes)

## from

Search for content from a date.

> [from:01/03/2025](/search?query=from%3A01%2F03%2F2025)

## groupedanswer

Search for written questions that have been grouped for answer by a minister. Similar or identical questions from members may be given the same response.

> [groupedanswer:yes](/search?query=groupedanswer%3Ayes)

## holdinganswer

Search for Commons written questions which have received, or are currently in receipt of, a holding answer. A holding answer to a written question may be issued by a minister ahead of a substantive or final answer.

> [holdinganswer:yes](/search?query=holdinganswer%3Ayes)

## house

Search for parliamentary business by the House in which the business occurred.

> [house:"House of Lords"](/search?query=house%3A%22House%20of%20Lords%22)
>
> [house:("House of Commons" AND "House of Lords")](/search?query=house%3A%28%22House%20of%20Commons%22%20AND%20%22House%20of%20Lords%22%29)

## impactassessment

Search for statutory instruments and parliamentary papers for which an impact assessment has been produced.

> [impactassessment:yes](/search?query=impactassessment%3Ayes)

## legstage

Search for legislative proceedings by legislative stage.

> [legstage:"first reading"](/search?query=legstage%3A%22first%20reading%22)
>
> [legstage:"second reading"](/search?query=legstage%3A%22second%20reading%22)
>
> [legstage:"third reading"](/search?query=legstage%3A%22third%20reading%22)
>
> [legstage:"committee stage"](/search?query=legstage%3A%22committee%20stage%22)
>
> [legstage:"report stage"](/search?query=legstage%3A%22report%20stage%22)
>
> [legstage:"commons amendments"](/search?query=legstage%3A%22commons%20amendments%22)
>
> [legstage:"lords amendments"](/search?query=legstage%3A%22lords%20amendments%22)
> 
> [legstage:"royal assent"](/search?query=legstage%3A%22royal%20assent%22)

## legtitle

Search using the title of an item of legislation to find material relating to or about that item of legislation.

> [legtitle:"Proceeds of Crime Act 2002"](/search?query=legtitle%3A%22Proceeds%20of%20Crime%20Act%202002%22)
>
> [legtitle:"Counsellors of State Bill (HL) 2022-23"](/search?query=legtitle%3A%22Counsellors%20of%20State%20Bill%20%28HL%29%202022-23%22)
>
> [legtitle:"Courts and Tribunals Bill 2024-26 to 2026-27"](/search?query=legtitle%3A%22Courts%20and%20Tribunals%20Bill%202024-26%20to%202026-27%22)

## libraryloc

Search for parliamentary material held by the Commons and Lords Libraries, by shelfmark or reference denoting location.

> [libraryloc:"UP 805"](/search?query=libraryloc%3A%22UP%20805%22)

## member

Search for parliamentary material in the Commons or Lords by the name or title of a member.

> [member:"Owen of Alderley Edge, Baroness"](/search?query=member%3A%22Owen%20of%20Alderley%20Edge%2C%20Baroness%22)
>
> [member:"Baroness Owen of Alderley Edge"](/search?query=member%3A%22Baroness%20Owen%20of%20Alderley%20Edge%22)
>
> [member:"Charlotte Owen"](/search?query=member%3A%22Charlotte%20Owen%22)
>
> [member:"Owen, Charlotte"](/search?query=member%3A%22Owen%2C%20Charlotte%22)

## memberparty

Search for parliamentary material by party.

> [memberparty:Conservative](/search?query=memberparty%3AConservative)
>
> [memberparty:"Independent (affiliation)"](/search?query=memberparty%3A%22Independent%20%28affiliation%29%22)







## notes

Search the text of notes added to items, including 'coming into force' notes for statutory instruments and parliamentary papers.

> notes:corrected
>
> notes:"Coming into force in accordance with regulation 1"

## notreached

Search for Commons questions not reached during oral question time, for which a written answer has been provided.

> notreached:yes

## opqtype

Search for lead, first supplementary, other supplementary or all supplementary oral questions.

> opqtype:lead
>
> opqtype:firstsupp
>
> opqtype:othersupp
> 
> opqtype:supp

## othersponsor

Search for early day motions or amendments by members sponsoring, other than the primary sponsor.

> othersponsor:"Jim Shannon"

## place

Search for contributions or proceedings by place. The available values are General committees, House of Commons chamber, House of Commons Grand Committees, House of Lords chamber, House of Lords Grand Committee, Standing committees, and Westminster Hall.

> place:"Westminster Hall"
>
> place:(“House of Lords chamber” NOT “House of Lords Grand Committee”)

## primarymember

Search for members asking oral or written questions, tabling early day motions, making statements or leading proceedings.

> primarymember:"Kemi Badenoch"

## primarymemberparty

Search by the party of members asking oral or written questions, tabling early day motions, making statements or leading proceedings.

> primarymemberparty:"Cooperative Party"

## primarysponsor

Search for early day motions or amendments by primary sponsor.

> primarysponsor:"Caroline Lucas"

## procedure

Search for parliamentary business where certain procedures, events or conventions have occurred.

> procedure:"Allocation of time motions"
>
> procedure:"Time limits on speeches"

## prorogationanswer

Search for, or exclude, prorogation answers to a written question. These are answers which may be provided if it has not been possible to provide a substantive answer in the time available before prorogation.

> prorogationanswer:yes
>
> type:"written questions" prorogationanswer:no

## publisher

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

## questiontext

Search for words or phrases within oral or written questions.

> questiontext:horses
>
> questiontext:“Impact of traffic levels”

## ref

Search by reference number, including Hansard volume and column number.

> ref:"SI 2016/983"
>
> ref:"CP 1677"
>
> ref:HCWS346
>
> ref:“726 c456”

replace: ref:“59 cc76-1036"
>
> ref:"HL Bill 76 2023-24"

## reginterest

Search for questions, contributions and early day motions where a member has declared an interest which may be relevant to the subject matter. Data for EDMs is only available until October 2018.

> reginterest:yes

## resolutionprocedure

Search for statutory instruments and parliamentary papers by procedure.

> resolutionprocedure:Affirmative
>
> resolutionprocedure:"LRO Affirmative"
>
> resolutionprocedure:"LRO Negative"
>
> resolutionprocedure:"LRO Super-Affirmative"
>
> resolutionprocedure:Negative
>
> resolutionprocedure:None
> 
> resolutionprocedure:"Not for Appendix"
> 
> resolutionprocedure:"Regulatory Reform"
> 
> resolutionprocedure:"Special"

## section

Search for briefings published by the Commons Library by team name.

> section:"International Affairs and Defence Section"
>
> section:"Science and Environment Section"

## session

Search for parliamentary business by session. Query values can be entered in the format 08/09, 08-09, 2008/09, 2008-09, 2008/2009, 2008-2009.

> session:19/21
>
> session:2010-12
>
> session:(19/19 OR 17/19)

## signedby

Search for early day motions or amendments signed by a member.

> signedby:"Andrew Rosindell"

## stats

Search for parliamentary business or research which includes statistical information.

> stats:yes

## status

Search for early day motions or parliamentary questions by status.

> status:answered
>
> status:holding
>
> status:open
> 
> status:tabled
>
> status:withdrawn

## subject

Search by subject.

> subject:housing
>
> subject:("Interest rates" "economic growth")

## summary

Search for words or phrases within the summary of parliamentary proceedings, deposited papers and briefings and research published by the Commons Library, the Lords Library or the Parliamentary Office of Science and Technology (POST).

> summary:"privilege amendment"
>
> summary:"deferred divisions"

## tabledby

Search for members tabling early day motions, or oral or written questions.

> tabledby:"Shirley Williams"
>
> tabledby:"Baroness Afshar"

## timestamp

Timestamp refers to the date a record in Parliamentary Search was last indexed or updated. Search for a specific date, a relative date range such as 'this month', or within a date range.

> timestamp:06/07/2026..\*

## title

Search for words or phrases within a title.

> title:"dairy farms"
>
> title:("mobile phones" AND schools)

## to

Search for content before a date.

> to:01/01/2017

## topic

Search for briefings and research published by the Commons Library, the Lords Library or the Parliamentary Office of Science and Technology (POST) by topic.

> topic:charities

## transferred

Search for written questions which have been transferred by the answering body to be answered by another answering body.

> transferred:yes

## type

Search by content type.

> type:(edms OR opqs)
>
> type:"Questions for short debate"
>
> type:"Speaker's statements"

## uin

Search for written statements or oral or written questions by UIN.

> uin:903481
>
> uin:HLWS156

## unstarred

Search for questions in the House of Commons originally selected for oral answer for which a written answer was subsequently requested.

> unstarred:yes

## witness

Search for witnesses providing oral evidence to select and public bill committees.

> witness:"News International"
>
> witness:"Tony Blair"

## wpqtype

Search for Commons written questions by type. Ordinary questions are usually answered between five and 10 working days after the question has been tabled. Named day refers to priority questions, to be answered on the third sitting day after they are tabled.

> wpqtype:"named day"
