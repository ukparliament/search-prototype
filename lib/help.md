Each word of your search query matters and will be used to retrieve the relevant results.

The default operator is AND. For queries of more than two words - for example, a search for _social housing_ - material where both of these words appear will be returned.

Search is case insensitive. _London_ is the same as _london_ is the same as _LoNDon_.

Words that are commonly used, such as _the_, _a_, _is_, and _for_, are usually ignored. 

Stemming may be applied to your query. For example, _running_ will return results for _running_, _run_, and _runs_.

Your search query may be expanded to include synonyms. For example, a search for _farming_ will include results for _farming OR agriculture_. Searching for _social welfare_ will include results for _"social welfare" OR "welfare state"_. This is known as query expansion. Query expansion can be disabled by placing square brackets around the search term, for example _[farming]_. The [Librarian tools](/meta/librarian-tools) feature provides information about what was searched for.

Generally, any punctuation is ignored.

Accented characters are not ignored. For example, searching for _resumé_ will return different results to a search for _resume_.


## Phrases
Queries within quotation marks will retrieve phrases; the words in the order specified. 

Stemming is applied to phrase searching; the query may not return an exact match of text entered. For example, _"social network"_ may return _"social networks"_ or _"social networking"_. 

Stop words, that is words that are commonly used, such as _the_, _a_, _is_, and _for_ will be ignored. For example, for a query for _"is it legal"_, the words _is_ and _it_ will be ignored. Only the word _legal_ will be searched for.

## Boolean operators

Boolean search is a method that uses operators like AND, OR, and NOT to refine search results by including, broadening, or excluding specific terms. Boolean operators must be in uppercase. If you combine AND/OR/NOT in the same search, the search will be processed in the order NOT/AND/OR. You can use brackets to override the default order (see Grouping).

### AND
By default, if your query consists of a number of words, the words are combined using a logical AND operator. This means all words must be present in order to satisfy a match. 

Where words used in your query are controlled as a phrase in the Commons Library thesaurus, the search engine will look for these words as a phrase. For example, _care homes_ will be combined as _"care homes"_ rather than _care AND homes_. Adding the Boolean operator AND between the words in your query will override this. 

### OR
To allow matches against any one of several words, use the OR operator. For example, _cats OR dogs OR horses_ returns results that have one, two or all of those words.

### NOT
The NOT operator excludes the word which appears after it. For example, a query _cats NOT dogs_ says _cat_ must be present and excludes material mentioning _dogs_. The minus symbol can be used instead of the NOT operator. For example, _cats -dogs_.


## Wild cards

### Single character match
A question mark at the start or end of a word matches any single character.

_?arrier_ will return results for _barrier_, _carrier_, _farrier_, and so on. 

_mar?_ will return matches including _Mars_, _Mark_, _Marc_, _mare_, _marking_, and so on.

### Multiple character match
An asterisk symbol at the start or end of a word matches zero or more sequential characters.

_tro*_ will return results for words starting with _tro_, such as _tropical_, _troops_, _trout_, and so on.

_*land_ will return results for words ending with _land_, such as _England_, _Ireland_, _Scotland_, and so on. 


======= ANYA UP TO HERE =========

## Grouping
When a query uses more than one operator, parentheses and to nest other grouped queries.

For example, to search for _olympics_ and either or both _London_ or _Paris_: _olympics (london OR paris)_

This could also be written as _(olympics london) OR (olympics paris)_.

To return results for olympic material for London, or Commonwealth games material for Glasgow:

(olympics London) OR ("commonwealth games" Glasgow)


When a query mixes AND and OR, parentheses decide the order in which the operators are applied — just as they do in arithmetic. Without them, a database may interpret your search in a way you did not intend. Compare these two queries:

Query	How it is read
(diet OR nutrition) AND children	Either “diet” or “nutrition”, and it must mention children — the intended result.
diet OR nutrition AND children	Anything mentioning “diet”, plus anything mentioning both “nutrition” and “children” — far too broad.
The rule of thumb is simple: whenever you use OR inside a larger search, wrap that OR group in parentheses. This keeps each concept self-contained and your overall logic predictable, which matters most when you are documenting a search for Resesarch Paper Writing Services or a formal systematic review.

Parentheses can be used to override the default order of NOT then AND then OR in which Boolean operators are processed: ((A OR B) AND (C OR D)) OR ((E AND F) NOT(G OR H))