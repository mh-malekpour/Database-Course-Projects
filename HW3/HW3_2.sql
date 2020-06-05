-- Section1
CREATE TRIGGER      sex
BEFORE INSERT ON    actor
FOR EACH ROW
BEGIN
    IF NEW.gender IS NULL THEN
    SET NEW.gender = 'other';
    END IF;
END;

-- Section2
SELECT      t1.id, MIN(t2.year - t1.year) AS dif
FROM        (SELECT      a.id, m.id mid, year
            FROM        ((Actor a JOIN Cast c ON a.id = c.pid)
                        JOIN Movie m ON c.mid = m.id)) AS t1
            JOIN
            (SELECT      a.id, m.id mid, year
            FROM        ((Actor a JOIN Cast c ON a.id = c.pid)
                        JOIN Movie m ON c.mid = m.id)) AS t2
            ON t1.id = t2.id
WHERE       t1.mid != t2.mid AND t2.year >= t1.year
GROUP BY    t1.id
ORDER BY    dif DESC , id ASC;

-- Section3
SELECT      did, d.first_name, d.last_name, COUNT(DISTINCT a.id) AS num
FROM        (((Actor a JOIN Cast c ON a.id = c.pid)
	        LEFT JOIN Movie_Director md ON c.mid = md.mid)
	        LEFT JOIN Director d ON d.id = did)
GROUP BY    did
ORDER BY    num DESC, did ASC
LIMIT       3;

-- Section4
CREATE VIEW Actors_View AS
SELECT      a.first_name, a.last_name, table1.num,
            (SELECT COUNT(id) FROM director) - table2.num AS dnum, table3.lastName
FROM        actor AS a LEFT JOIN
            (SELECT     a.id, COUNT(DISTINCT m.id) AS num
            FROM        actor AS a LEFT JOIN cast AS c ON a.id = c.pid
                        LEFT JOIN movie As m ON c.mid = m.id
            GROUP BY a.id) AS table1 ON a.id = table1.id LEFT JOIN
            (SELECT     a.id, COUNT(DISTINCT d.id) AS num
            FROM        actor AS a LEFT JOIN cast AS c ON a.id = c.pid
                        LEFT JOIN movie As m ON c.mid = m.id
                        LEFT JOIN movie_director AS md ON m.id = md.mid
                        LEFT JOIN director AS d ON md.did = d.id
            GROUP BY a.id) AS table2 ON a.id = table2.id LEFT JOIN
            (SELECT     table4.ID , MIN(table4.last_name) AS lastName, table4.NUM
            FROM        (SELECT     a1.id AS ID, a2.last_name, COUNT(DISTINCT c1.mid) AS NUM
                        FROM        actor AS a1, cast AS c1, cast AS c2, actor AS a2
                        WHERE       a1.id = c1.pid AND c1.mid = c2.mid AND c2.pid = a2.id AND a1.id <> a2.id
                        GROUP BY    a1.id, a2.last_name) AS table4 NATURAL JOIN
                        (SELECT     table6.id AS ID, MAX(table6.num) AS NUM
                        FROM        (SELECT a1.id, COUNT(DISTINCT c1.mid) AS num
                                    FROM actor AS a1, cast AS c1, cast AS c2, actor AS a2
                                    WHERE a1.id = c1.pid AND c1.mid = c2.mid AND c2.pid = a2.id AND a1.id <> a2.id
                                    GROUP BY a1.id, a2.last_name) AS table6
                        GROUP BY table6.id) AS table5
            GROUP BY table4.ID, table4.NUM) AS table3 ON a.id = table3.ID;

-- Section5
ALTER TABLE Cast
ADD COLUMN last_modified DATETIME;
$$
CREATE TRIGGER      i_modified
BEFORE INSERT ON    Cast
FOR EACH ROW
BEGIN
   SET NEW.last_modified = NOW();
END;
$$
CREATE TRIGGER      u_modified
BEFORE UPDATE ON    Cast
FOR EACH ROW
BEGIN
   SET NEW.last_modified = NOW();
END;
