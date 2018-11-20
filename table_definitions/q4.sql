-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW FirstBracket AS 
SELECT country_id, COUNT(Party.id) AS r0_2
FROM Party LEFT OUTER JOIN party_position ON id
WHERE (party_position.left_right >= 0) AND (party_position.left_right < 2)
GROUP BY country_id;

CREATE VIEW SecondBracket AS 
SELECT country_id, COUNT(Party.id) AS r2_4
FROM Party LEFT OUTER JOIN party_position ON id
WHERE (party_position.left_right >= 2) AND (party_position.left_right < 4)
GROUP BY country_id;

CREATE VIEW ThirdBracket AS 
SELECT country_id, COUNT(Party.id) AS r4_6
FROM Party LEFT OUTER JOIN party_position ON id
WHERE (party_position.left_right >= 4) AND (party_position.left_right < 6)
GROUP BY country_id;

CREATE VIEW FourthBracket AS 
SELECT country_id, COUNT(Party.id) AS r6_8
FROM Party LEFT OUTER JOIN party_position ON id
WHERE (party_position.left_right >= 6) AND (party_position.left_right < 8)
GROUP BY country_id;

CREATE VIEW FifthBracket AS 
SELECT country_id, COUNT(Party.id) AS r8_10
FROM Party LEFT OUTER JOIN party_position ON id
WHERE (party_position.left_right >= 8) AND (party_position.left_right <= 10)
GROUP BY country_id;

CREATE VIEW PreInsertion AS
SELECT FirstBracket.country_id, r0_2, r2_4, r4_6, r6_8, r8_10
FROM FirstBracket, SecondBracket, ThirdBracket, FourthBracket, FifthBracket
WHERE (FirstBracket.country_id = SecondBracket.country_id = ThirdBracket.country_id, 
		FourthBracket.country_id, FifthBracket.country_id);



-- the answer to the query 
INSERT INTO q4 
(SELECT Country.name, r0_2, r2_4, r4_6, r6_8, r8_10
 FROM PreInsertion, Country 
 WHERE PreInsertion.country_id = Country.id);

