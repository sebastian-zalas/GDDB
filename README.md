# Gender Board Diversity Dataset
This repository contains dataset and STATA programs written for its production.


## Authors and contact
The authors of the programs are Hubert Drążkowski and Sebastian Zalas. 
In case of question and comments, please send an e-mail to s.zalas@grape.org.pl.


## Dataset description
The GBDD includes two files: a sectoral file and country file. 

### The sectoral file includes indicators for `country`, `year` and 2-digit NACE code (`nace2`). In each of those cells, we report the following variables:
- share of women in senior management `female_share_senmen` computed as an average share share of women holding senior management (executive) positions across firms; this is an unweighted share from all firms

- share of women in supervisory boards `female_share_supboard`, computed analogously for positions in supervisory (non-executive) boards 

- share of women in all boards combined `female_share_boards` computed analogously; note that individuals in ambiguous positions are included as well

- share of women in senior management `female_share_ind_senmen` computed as a share of women holding senior management (executive) positions over the total number of individuals with such positions; this is a weighted share

- share of women in supervisory boards `female_share_ind_supboard`, computed analogously for positions in supervisory (non-executive) boards 

- share of women in all boards combined `female_share_ind_boards` computed analogously; note that individuals in ambiguous positions are included as well

- share of firms without women in management (executive) positions `zero_share_senmen`

- share of firms without women in supervisory (non-executive) positions `zero_share_supboard` 

- share of firms without women in any board `zero_share_boards`

### Analogously, in the country file we include indicators for `country`, and `year`. The data is reported as an aggregate across all types of firms (variables with suffix `_all`) and separately for stock-listed firms (`_stl`) and private (not listed) ones (`_prv`).


## Codes description
Processing data about managers was the main axis our of work, but we also organized other areas of the Orbis database. Thus first, we describe codes written for processing managers data. Then we introduce other programs. We worked on STATA 17.

### Codes for mangement data processing 
These codes constitute a complete sequence; output from predecessor is an input for the next code.

- `_managers_1_prepare.do` - this code extracts variables describing managers data from each wave of Amadeus/Orbis database

- `_managers_2_bycountry.do` - this code connects manager data from all waves and saves them in separate file for each country 

- `_managers_3_legalform.do` - this code we predicts wheter firm should have management board and (or) supervisory board. We use legal form reported by the company itself and gathered information on corporate system in given country. At this stage we drop firms which should not have boards according to legal system.
							
- `_managers_4_function.do` -  basing on variables which describe function and position of manager, we assign them to board categories. Later, from this assignment we build three board categories: management board, supervisory board and ambigous board. The last one is the category with managers which take top-management positions in companies, but due to lack of information we were not able to assign them to management or supervisory board.

- `_managers_5_gender.do` - this code assigns gender to managers. This code prepares names and surnames of managers, cleans them from diacrytic signs, detects and drops legal persons.

- `_managers_6_person_level.do` - this code assigns to each manager a time in which she/he was present in assigned board and thus produces a firm-person level database

- `_managers_7_firm_level.do` - this code collapse person level data from previous step to firm level.

- `_gender_board_diversity_dataset.do` - this code produces **Gender Board Diversity Dataset** at country-industry-year level.

- `_gender_board_diversity_dataset_country_stock.do` - this code produces **Gender Board Diversity Dataset** by country-year level, for stocklisted and private firms

### Additional routines
- `_nace.do` - prepares a NACE rev. 2 industry code for firms. Due to the fact that NACE classification changed over time, we adjust all codes with NACE rev. 2 classification.

- `_nace_crosswalk_nace1_to_nace11.do` and `_nace_crosswalk_nace1_to_nace11.do` contain crosswalks between NACE rev. 1, NACE rev. 1.1 and NACE rev. 2

- `_listed.do` - this code gathers the information from all waves wheterf firm was listed on stock exchange and in which years
