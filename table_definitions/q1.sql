-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS ElectionNarrowed CASCADE;
DROP VIEW IF EXISTS VotesByPartyByYear CASCADE;
DROP VIEW IF EXISTS PreInsertion CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW ElectionNarrowed AS
SELECT id, EXTRACT(YEAR FROM Election.e_date) AS year, country_id, votes_valid
FROM Election
WHERE (EXTRACT(YEAR FROM Election.e_date) >= 1996) AND (EXTRACT(YEAR FROM Election.e_date) <= 2006);

CREATE VIEW VotesByPartyByYear AS
SELECT election_id AS id, party_id, SUM(votes) AS votes
FROM ElectionResults, ElectionNarrowed
WHERE ElectionResults.election_id == ElectionNarrowed.id;
GROUP BY election_id, party_id, year;

CREATE VIEW PreInsertion AS
SELECT year, Country.name AS countryName, Party.name AS partyName, votes, votes_valid
FROM (SELECT * 
	FROM ElectionNarrowed, VotesByPartyByYear
	WHERE Election Narrowed.id == VotesByPartyByYear.id) ElectionWithParty, Party, Country
WHERE (ElectionWithParty.country_id == Country.id) AND (ElectionWithParty.party_id == Party.id)
GROUP BY countryName, partyName, year;

-- the answer to the query 
insert into q1 (year, countryName, partyName)
	(SELECT year, countryName, partyName
 	 FROM PreInsertion)

update q1
set voteRange = '(0-5]'
where (year = PreInsertion.year) and (countryName = PreInsertion.countryName)
	and (partyName = PreInsertion.partyName) and (PreInsertion. votes / PreInsertion.votes_valid <= 0.05);

update q1
set voteRange = '(5-10]'
where (year = PreInsertion.year) and (countryName = PreInsertion.countryName)
	and (partyName = PreInsertion.partyName) and (PreInsertion. votes / PreInsertion.votes_valid <= 0.1)
	and (PreInsertion. votes / PreInsertion.votes_valid > 0.05);

update q1
set voteRange = '(10-20]'
where (year = PreInsertion.year) and (countryName = PreInsertion.countryName)
	and (partyName = PreInsertion.partyName) and (PreInsertion. votes / PreInsertion.votes_valid <= 0.20)
	and (PreInsertion. votes / PreInsertion.votes_valid > 0.10);

update q1
set voteRange = '(20-30]'
where (year = PreInsertion.year) and (countryName = PreInsertion.countryName)
	and (partyName = PreInsertion.partyName) and (PreInsertion. votes / PreInsertion.votes_valid <= 0.30)
and (PreInsertion. votes / PreInsertion.votes_valid > 0.20);

update q1
set voteRange = '(30-40]'
where (year = PreInsertion.year) and (countryName = PreInsertion.countryName)
	and (partyName = PreInsertion.partyName) and (PreInsertion. votes / PreInsertion.votes_valid <= 0.40)
	and (PreInsertion. votes / PreInsertion.votes_valid > 0.30);

update q1
set voteRange = '(40-100]'
where (year = PreInsertion.year) and (countryName = PreInsertion.countryName)
	and (partyName = PreInsertion.partyName) and (PreInsertion. votes / PreInsertion.votes_valid > 0.40);





