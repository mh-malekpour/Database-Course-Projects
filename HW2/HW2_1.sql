 -- Section1
SELECT      CONCAT(uc.first_name, ' ', uc.last_name) AS username,
	        COUNT(IF(v.is_valid = 1, 1, NULL)) AS 'up vote', 
	        COUNT(IF(v.is_valid = 0, 1, NULL)) AS 'down vote'
FROM        User_Clients AS uc, Clips AS c, Votes AS v 
WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id 
GROUP BY    username;

-- Section2
SELECT      uc.client_id,
            COUNT(IF(v.is_valid = 1, 1, NULL)) / COUNT(c.clip_id) AS 'total precision', 
            COUNT(CASE WHEN v.is_valid = 1 AND c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY) THEN 1 ELSE NULL END) /
            COUNT(IF(c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY), 1, NULL)) AS 'weekly precision'
FROM        User_Clients AS uc, Clips AS c, Votes AS v 
WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id 
GROUP BY    client_id;

-- Section3
SELECT      p.client_id,
            IF(p.weekly_precision >= p.total_precision, 'appropriate', 'inappropriate') AS 'improvement status'
FROM        (SELECT     uc.client_id,
                        COUNT(IF(v.is_valid = 1, 1, NULL)) / COUNT(c.clip_id) AS total_precision, 
                        COUNT(CASE WHEN v.is_valid = 1 AND c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY) THEN 1 ELSE NULL END) /
                        COUNT(IF(c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY), 1, NULL)) AS weekly_precision
            FROM        User_Clients AS uc, Clips AS c, Votes AS v 
            WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id 
            GROUP BY    client_id) AS p;

-- Section4
SELECT      age, AVG(total_precision)
FROM        (SELECT     uc.client_id, uc.age,
                        COUNT(IF(v.is_valid = 1, 1, NULL)) / COUNT(c.clip_id) AS total_precision, 
                        COUNT(CASE WHEN v.is_valid = 1 AND c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY) THEN 1 ELSE NULL END) /
                        COUNT(IF(c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY), 1, NULL)) AS weekly_precision
            FROM        User_Clients AS uc, Clips AS c, Votes AS v 
            WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id 
            GROUP BY    client_id) AS p
GROUP BY age;

-- Section5
SELECT      age
FROM        (SELECT     age, COUNT(clip_id) AS Cnum
            FROM        Clips NATURAL JOIN User_Clients
            GROUP BY    age) AS age_clip
ORDER BY    Cnum DESC
LIMIT 1;

-- Section6
SELECT      age
FROM        (SELECT     client_id, age, COUNT(clip_id) AS Cnum
            FROM        Clips NATURAL JOIN User_Clients
            GROUP BY    client_id) AS age_clip
ORDER BY    Cnum DESC
LIMIT 1;
