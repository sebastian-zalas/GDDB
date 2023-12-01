# Gender Board Diversity Dataset
This repository contains dataset and STATA programs written for its production.


## Authors and contact
The authors of the programs are Hubert Drążkowski and Sebastian Zalas. 
In case of question and comments, please send them an e-mail.

## Dataset description
*to do*

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

- `_gender_board_diversity_dataset` - this code produces **Gender Board Diversity Dataset**, which is uploaded in this repository

### Additional routines
- `_nace.do` - prepares a NACE rev. 2 industry code for firms. Due to the fact that NACE classification changed over time, we adjust all codes with NACE rev. 2 classification.
- `_nace_crosswalk_nace1_to_nace11.do` and `_nace_crosswalk_nace1_to_nace11.do` contain crosswalks between NACE rev. 1, NACE rev. 1.1 and NACE rev. 2

- `_listed.do` - this code gathers the information from all waves wheterf firm was listed on stock exchange and in which years
