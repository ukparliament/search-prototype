# README

## General notes

- Ruby 3.3, Rails 7.1
- We have intentionally kept dependencies to a minimum.
- This app currrently does not use a database, however future development may necessitate this.
- Unit test suite uses RSpec
- Some request specs have been written for particular 'items' (source data variants), however the task of creating these
  for all object types has not yet been completed.
- Currently the app is deployed via Heroku

## High level overview

This application is the front end for a (Solr 9) search and has two main interfaces: the search page (search#index),
which also displays search results, and the 'item' view (content_objects#show).

The intended route through the app is for a search to be performed, the results to be viewed, filtered and adjusted,
then for a single result to be clicked on. This then takes the user to the item view, which displayed more detailed
information.

## Standard data format

Because the data returned by Solr is often treated differently throughout the application based on the name or type of
Solr field it originated from, most data passing between various methods is in the form of a hash with the data keyed
to 'value' and its Solr field name keyed to 'field_name', instead of simply passing a collection of unaccompanied data. 

## Feature details

### Item pages

An object ID is required, and used to retrieve the data for that object from Solr using an instance of SolrQuery. The
returned data is passed to the ContentObject class, using the 'generate' class method to identify and initialise the
relevant subclass corresponding to the item type (based on its type and subtype SES IDs, type_ses and subtype_ses).

The class, for example WrittenQuestion, contains instance methods used to extract the necessary data to render the page
from the returned JSON. The numerous subclasses of ContentObject are organised in several layers where beneficial, for
example WrittenQuestion inherits from Question, which also has the subclass OralQuestion and holds methods common to
both subclasses. A number of instance methods belong to ContentObject itself, as their behaviour is common across all
object types.

### The search page

The search bar on the main search page makes a request to Solr via an interstitial controller action (search#index) that
does some basic formatting of the query before assembling a Solr query and making a GET request.

The app forms the search query using the SolrSearch class, which is a subclass of ApiCall, which holds generic API
request methods. Solr returns results as JSON (as configured) which can then be parsed by the app. This process is
identical to that described above for the item pages, but a collection of objects is returned instead.

#### Search expansion (yet to be implemented)

The search controller will eventually make a request to the SES API ahead of forming the Solr query. This is to perform
query term expansion using the dictionary of controlled terms.

#### Search filters

Filters are built using a predefined list of facets to request from Solr, that get sent with every query. These can be
found in the facet_field class method on the SolrSearch class. The returned data then contains facet data (a count of
results) for each of these, which can then be populated in the side panel. The facets are limited to 100 for performance
reasons, however a lower number may be appropriate for some fields. Solr documentation details how to configure this
limit per-field.

Current filter behaviour is via AND, reducing the result set rather than expanding it.

#### Search type hierarchy

The first facet-based filter shown on the search results page operates on type_ses & subtype_ses. These types form a
hierarchy, and are represented as an expanding tree the user can explore when applying filters.

Unfortunately the structure of the hierarchy is not readily available, and as such it has to be constructed. We used the
following approach to achieve this:

- Include type_sesrollup in the SolrSearch facet fields, so that the data returned by Solr is faceted by the
  type_sesrollup field, which is an array of SES IDs reflecting the type ID of the item, as well as the type of each of
  its ancestors in the hierarchy. As an example, "type_sesrollup"=>[346697, 346697, 414033] resolves to 'Research
  Briefings' -> 'Commons Briefing Papers'.
- Make a request to SES for all unique SES IDs from all of the returned type_sesrollup fields. This ensures we have
  every ID needed to construct the hierarchy, without having to request everything. This is done by the hierarchy_data
  method on SesLookup. The method also restructures the returned data as a hash with keys in the
  form [<ses_id>, <resolved type name as a string>] and the corresponding hierarchy portion of the SES data as the
  values.
- Interrogate the hierarchy data assembled above and create another hash, with each ID against an array of IDs of all of
  that types children. This information is obtained from the 'narrower terms'. This process is done by the
  organise_hierarchy_data method on HierarchyBuilder.
- Using the same assembled hierarchy data as a source, the top_level_types method on HierarchyBuilder creates an array
  of all types that show the ID 346696 as their parent. 346696 is 'Content Type' and is the root node of the type
  hierarchy. All types referencing it as their parent are therefore at the highest level we want to display. This method
  then filters out types that are not present in the returned Solr data by comparing the complete list to those included
  in the facet data.
- The search index view then renders the hierarchy_level partial for each item in the top_level_types array, passing in
  the relevent data and setting 'tier' to 1. This partial renders the clickable name and count of matching items (from
  facet data) for the given type, and then uses the organise_hierarchy_data hash (loaded as an instance variable) to
  find the IDs of children belonging to the type. If there are none, the rendering process stops there. If there are
  children, another hierarchy_layer partial is rendered for each of them, incrementing the value of 'tier' for each
  level deeper. In this way, a complete tree is constructed from top to bottom, without any additional querying needed.
- The value of tier is used to determine the styling of the otherwise identical partials: those on tier 1 are always
  shown.

At the time of writing, work is underway to refactor a javascript based interactive type hierarchy (using
expand_types_controller.js) to an HTML5 based approach which uses a series of nested 'details' tags.

## Views, partials and helpers

Both item and search pages make use of numerous partials. For the most part the approach has been to keep separate
partials for each item
type even if the content and/or the underlying data query is the same as that for another object. This is because the
requirements for the application are generally quite dynamic and it seemed prudent to avoid patterns that would make
future divergence of what are currently identical views difficult.

### Helpers

At the time of writing, a number of helper methods in ApplicationHelper are yet to be moved to a more suitable location.

#### Link Helper

Used to generate and format the various links used throughout the app. Also includes methods for formatting titles and
names, the latter including disambiguation steps. Some links include depluralisation steps, which can be enabled or
disabled when called.

#### FacetHelper

This helper includes a method to check facets (returned from Solr and used to filter results) and format them if
necessary. This is done by initialising an instance of the relevant subclass of the Facet class. At the time of writing,
the framework for formatting session facets has been implemented, but no business logic added as of yet.

## External APIs

### ApiCall and its subclasses

ApiCall is a class containing common methods for making requests to an external API, handling errors and interpreting
results. It has several subclasses. For each, the object_data method returns the objects as JSON.

- SolrSearch: Performs a Solr search (POST request) and returns all results. Includes all facets supported by the app
  for every search, which are detailed in the class method facet_fields. Optionally accepts query string, filter,
  results count, sort by and page.
- SolrQuery: A simple Solr POST request that accepts an object_uri (primary key in Solr index) and returns the first
  result.
- SolrMultiQuery: A simple Solr POST request that accepts any number of object_uris and returns all results.
- SesLookup: A GET request to the SES API. Accepts any number of integer IDs, and returns a hash of names keyed to their
  SES IDs.

### API endpoints

The Solr and SES API endpoints are protected via an API key (Azure) which is stored in the app encrypted credentials.
There are multiple environments within a single credentials file, as a deliberate choice to avoid the complications
of using environment specific credentials files. The correct key for Solr, for example, is found using:

``` Rails.application.credentials.dig(Rails.env.to_sym, :solr_api, :subscription_key) ```

which will function correctly in any environment, so long as a subsection matching the environment name has been added
to the credentials file and the correct data added within.

The master key is needed to decrypt the credentials file. This should be provided to anyone developing the application
and also included on any servers, usually as an environment variable. Please see the Rails credentials documentation
for more information.

### SES data

Many of the names within the Solr data (Members, Legislatures, Topics etc.) are given as a SES ID (any Solr field name
ending '_ses') which must be resolved using the SES API. This is a Smartlogic Semaphore service. Because it only accepts
GET requests, and most of the integer IDs are 5 or 6 characters in length, we encounter limitations in how many IDs can
be resolved in a single request. The SesLookup class accepts any number of IDs, removes any duplicates, then splits them
into chunks of 250 to ensure the request does not exceed the 2048 character limit for a GET request.

Each chunk of 250 or fewer IDs is assigned a new thread, as it is significantly quicker to make all requests
simultaneously.

As part of performance improvement work to the ContentObjectsController show action, used on item pages, the call to SES
is now only carried out once the SES IDs relevant to items related to the result are collated and added to the list.
This avoids needing to make further SES requests later on, reducing page load times. A similar change will be made to
the SearchController index action, used for the search results page, collating the related item IDs needed to present a
page of results, however this has not yet been implemented.
