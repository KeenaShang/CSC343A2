-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS NumPartElec CASCADE;
DROP VIEW IF EXISTS NotWon CASCADE;
DROP VIEW IF EXISTS Won CASCADE;
DROP VIEW IF EXISTS WonThreeTimes CASCADE;
DROP VIEW IF EXISTS PreInsertion CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW NumPartElec AS 
SELECT Country.id AS country_id, COUNT(Party.id) AS num_parties, COUNT(election.id) AS num_elections
FROM Country, Party, election
WHERE (Party.country_id = Country.id) AND (Party.country_id = election.country_id)
GROUP BY Country.id;

CREATE VIEW NotWon AS
SELECT er1.election_id, er1.party_id
FROM election_result er1, election_result er2
WHERE (er1.election_id = er2.election_id) AND (er1.votes < er2.votes)
GROUP BY er1.election_id, er1.party_id;

CREATE VIEW Won AS
SELECT election_id, party_id
FROM election_result
WHERE (votes IS NOT NULL) AND (party_id NOT IN NotWon) AND (election_id NOT IN NotWon);

CREATE VIEW WonThreeTimes AS
SELECT election_id, party_id
FROM Won, NumPartElec, Party
WHERE (Won.party_id = Party.id) AND (Party.country_id = NumPartElec.country_id)
AND (COUNT(Won.election_id) >= 3 * (cast(num_elections as decimal) / num_parties))
GROUP BY party_id, country_id, election_id;

CREATE VIEW PreInsertion AS
SELECT Party.name AS partyName, Country.name AS countryName, COUNT(WonThreeTimes.election_id) AS wonElections,
 party_family.family AS partyFamily, elecion.id AS mostRecentlyWonElectionId, EXTRACT(YEAR FROM election.e_date) AS mostRecentlyWonElectionYear
FROM Pary, Country, WonThreeTimes, party_family, election_id
WHERE (Party.id IN WonThreeTimes) AND (Party.id = party_family.party_id) AND (Party.country_id = Country.id) AND
(election.id = Party.election_id) AND (election.e_date = MAX(e_date));


-- the answer to the query 
insert into q2 
	(SELECT *
	FROM PreInsertion);


