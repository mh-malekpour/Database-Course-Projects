-- Section1
SELECT      id, first_name, last_name
FROM        Actor AS ac
WHERE       EXISTS      (SELECT     a.id
                        FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
                                     JOIN Movie m ON c.mid = m.id)
                        WHERE       year BETWEEN 1980 AND 1995 AND ac.id = a.id)
            AND EXISTS
                        (SELECT     a.id
                        FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
                                    JOIN Movie m ON c.mid = m.id)
                        WHERE       year BETWEEN 2005 AND 2010 AND ac.id = a.id);

-- Section2
SELECT      id, title
FROM        Movie
WHERE       year = (SELECT year FROM Movie WHERE title = 'ALABAMA DEVIL')
            AND rating > (SELECT rating FROM Movie WHERE title = 'ALABAMA DEVIL');

-- Section3
SELECT      a.id, first_name, last_name
FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
            JOIN Movie m ON c.mid = m.id)
WHERE       m.title = 'ALASKA PHANTOM';

-- Section4
SELECT      d.id, first_name, last_name, COUNT(mid)
FROM        Director AS d LEFT JOIN Movie_Director AS md ON d.id = md.did
GROUP BY    d.id, first_name, last_name
ORDER BY    4 DESC, d.id ASC;

-- Section5
SELECT      title, COUNT(a.id)
FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
            JOIN Movie m ON c.mid = m.id)
GROUP BY    title
ORDER BY    2 DESC
LIMIT       1;

-- Section6
SELECT      a.id, first_name, last_name, COUNT(DISTINCT did) AS director_num
FROM        (((Actor a JOIN Cast c ON a.id = c.pid) 
    	    JOIN Movie m ON c.mid = m.id)
	        JOIN Movie_Director md ON c.mid = md.mid)
GROUP BY    a.id
HAVING      director_num >= 10;

-- Section7
SELECT      mid, title
FROM        (SELECT      mid, title,
                        COUNT(IF(gender='male', 1, NULL)) AS male,
                        COUNT(IF(gender='female', 1, NULL)) AS female
            FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
                        JOIN Movie m ON c.mid = m.id)
            GROUP BY    mid, title) AS movie_gender
WHERE       female > male;

-- Section8
SELECT      a1.first_name, a1.last_name , a2.first_name, a2.last_name, COUNT(*) AS num
FROM	    (((Actor a1 JOIN Cast c1 ON a1.id = c1.pid) 
            JOIN Movie m1 ON c1.mid = m1.id) 
            JOIN ((Actor a2 JOIN Cast c2 ON a2.id = c2.pid) 
            JOIN Movie m2 ON c2.mid = m2.id) ON m1.title = m2.title)
WHERE       (a1.gender = 'male' AND a2.gender = 'female')
GROUP BY    a1.id, a2.id
ORDER BY    num DESC, a2.id, a1.id;


-- Section9
SELECT      first_name, last_name, title
FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
    	    JOIN Movie m ON c.mid = m.id)
WHERE       year IN (SELECT     MIN(year)
                    FROM	    ((Actor ac JOIN Cast c ON ac.id = c.pid) 
                                JOIN Movie m ON c.mid = m.id)
                    WHERE       ac.id = a.id)
ORDER BY    last_name;

-- Section10
SELECT      id, first_name, last_name
FROM        Actor AS ac
WHERE       EXISTS      (SELECT     a.id
                        FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
                                    JOIN Movie m ON c.mid = m.id)
                        WHERE       year < 2000 AND ac.id = a.id)
            AND NOT EXISTS 
                        (SELECT     a.id
                        FROM        ((Actor a JOIN Cast c ON a.id = c.pid) 
                                    JOIN Movie m ON c.mid = m.id)
                        WHERE       year > 2000 AND ac.id = a.id);
