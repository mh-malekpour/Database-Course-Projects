-- Section1
ALTER TABLE     payments
ADD             comment BIGINT(10);
$$
UPDATE       Payments AS p,
             (SELECT       client_id,
             SUM(CASE WHEN is_valid = 1 THEN 500 WHEN is_valid = 0 THEN 100 ELSE NULL END) AS wage,
             MONTH(created_at) month
             FROM         (SELECT     uc.client_id, c.created_at, v.is_valid
                          FROM        User_Clients AS uc, Clips AS c, Votes AS v
                          WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id) AS t1
             GROUP BY     client_id, MONTH(created_at)
             HAVING       month <= 4) AS t2
SET          p.comment = IF(t2.wage IS NULL, 0, t2.wage - p.wage)
WHERE        t2.client_id = p.client_id AND t2.month = p.month;
$$
UPDATE       Payments AS p
SET          p.wage = p.wage + p.comment
WHERE        p.comment IS NOT NULL;

-- Section2
INSERT INTO  Payments(client_id, wage, month)
SELECT       *
FROM        (SELECT       client_id,
             SUM(IF(is_valid = 1, 500, 100)) AS wage,
             MONTH(created_at) month
             FROM         (SELECT      uc.client_id, c.created_at, v.is_valid
                          FROM        User_Clients AS uc, Clips AS c, Votes AS v
                          WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id) AS t1
             GROUP BY     client_id, MONTH(created_at)
             HAVING       month <= 4) AS t2
WHERE NOT EXISTS(SELECT * FROM Payments WHERE t2.client_id = Payments.client_id AND t2.month = Payments.month);

-- Section3
SELECT      MIN(comment), MAX(comment), SUM(comment), AVG(comment),
            IF(AVG(comment) <= 0, 'creditor', 'debtor')
FROM        payments;

-- Section4
SELECT      MAX(comment)
FROM        Payments
WHERE       ABS(comment) > (SELECT      MAX(IF(comment IS NULL OR comment=0, wage, 0))
                            FROM        Payments)

-- Section5
SELECT      client_id, comment
FROM        Payments;
$$
ALTER TABLE Payments
DROP COLUMN comment;

-- Section6
SELECT      uc.client_id,
            COUNT(IF(v.is_valid = 1, 1, NULL)) / COUNT(c.clip_id) AS total_precision,
            COUNT(CASE WHEN v.is_valid = 1 AND c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY) THEN 1 ELSE NULL END) /
            COUNT(IF(c.created_at > DATE_SUB(NOW(), INTERVAL 6 DAY), 1, NULL)) AS weekly_precision
FROM        User_Clients AS uc, Clips AS c, Votes AS v
WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id
GROUP BY    client_id
HAVING      total_precision > 0.50 AND weekly_precision > 0.70;

-- Section7
SELECT      SUM(Payments.wage) * 0.15
FROM        (SELECT     uc.client_id,
                        COUNT(IF(v.is_valid = 1, 1, NULL)) / COUNT(c.clip_id) AS total_precision
            FROM        User_Clients AS uc, Clips AS c, Votes AS v
            WHERE       c.client_id = uc.client_id AND c.clip_id = v.clip_id
            GROUP BY    client_id
            HAVING      total_precision > 0.60) AS t1 JOIN payments ON t1.client_id = Payments.client_id;
