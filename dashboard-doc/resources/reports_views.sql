CREATE ALGORITHM=UNDEFINED DEFINER=`tech`@`%` SQL SECURITY DEFINER VIEW `ukint_project_amount_launches` AS
SELECT year(`pm_project_event`.`date`) AS `Year`,
       `pm_project_event`.`country` AS `Country`,
       `pm_project_event`.`project_type` AS `Project type`,
       count(0) AS `Total launched`
FROM `pm_project_event`
WHERE ((year(`pm_project_event`.`date`) = _utf8'2013')
       AND (`pm_project_event`.`type` = _utf8'launch'))
GROUP BY `pm_project_event`.`country`,
         `pm_project_event`.`project_type`
ORDER BY `pm_project_event`.`country`,
         `pm_project_event`.`project_type`;
         
CREATE ALGORITHM=UNDEFINED DEFINER=`tech`@`%` SQL SECURITY DEFINER VIEW `ukint_project_amount_launches_by_month` AS
SELECT date_format(`pm_project_event`.`date`,_utf8'%Y-%m') AS `Month`,
       `pm_project_event`.`country` AS `Country`,
       `pm_project_event`.`project_type` AS `Project type`,
       count(0) AS `Total launched`
FROM `pm_project_event`
WHERE ((year(`pm_project_event`.`date`) = _utf8'2013')
       AND (`pm_project_event`.`type` = _utf8'launch'))
GROUP BY date_format(`pm_project_event`.`date`,_utf8'%Y-%m'),
         `pm_project_event`.`country`,
         `pm_project_event`.`project_type`
ORDER BY date_format(`pm_project_event`.`date`,_utf8'%Y-%m'),
         `pm_project_event`.`country`,
         `pm_project_event`.`project_type`;
         
CREATE ALGORITHM=UNDEFINED DEFINER=`tech`@`%` SQL SECURITY DEFINER VIEW `ukint_project_delay_reports` AS
SELECT `a`.`country` AS `Country`,
       ifnull(
                (SELECT date_format(
                                      (SELECT `b`.`date` AS `date`
                                       FROM `pm_project_event` `b`
                                       WHERE ((`a`.`project_id` = `b`.`project_id`)
                                              AND (`b`.`type` = _utf8'launch'))),_utf8'%b/%Y') AS `date_format((SELECT date FROM pm_project_event b WHERE a.project_id = b.project_id AND type = 'launch'), '%b/%Y')`),_utf8'n/a') AS `Month`,
       `a`.`project_id` AS `Ticket`,
       `a`.`project_type` AS `Project type`,
       if(isnull(
                   (SELECT `b`.`date` AS `date`
                    FROM `pm_project_event` `b`
                    WHERE ((`a`.`project_id` = `b`.`project_id`)
                           AND (`b`.`type` = _utf8'launch')))),_utf8'no',_utf8'yes') AS `Launched`,
       ifnull(
                (SELECT cast(date_format(
                                           (SELECT `b`.`date` AS `date`
                                            FROM `pm_project_event` `b`
                                            WHERE ((`a`.`project_id` = `b`.`project_id`)
                                                   AND (`b`.`type` = _utf8'launch'))),_utf8'%d/%m/%Y') AS char(20) charset utf8) AS `convert(date_format((SELECT date FROM pm_project_event b WHERE a.project_id = b.project_id AND type = 'launch'), '%d/%m/%Y'), char(20))`),_utf8'n/a') AS `Real launch date`,
       ifnull(
                (SELECT cast(date_format(substr(`b`.`timelines`,(locate(_utf8'Launch=',`b`.`timelines`) + 7)),_utf8'%d/%m/%Y') AS char(20) charset utf8) AS `convert(date_format(SUBSTRING(timelines, LOCATE('Launch=', timelines) + 7), '%d/%m/%Y'), char(20))`
                 FROM `pm_project_event` `b`
                 WHERE ((`a`.`project_id` = `b`.`project_id`)
                        AND (`b`.`type` = _utf8'baseline'))),_utf8'n/a') AS `Planned launch date`,
       cast(concat(sum(`a`.`impact`),_utf8' days') AS char(200) charset utf8) AS `Accumulated launch delay`
FROM `pm_project_event` `a`
WHERE (`a`.`type` = _utf8'delay')
GROUP BY `a`.`project_id`
ORDER BY `a`.`country`,
         `a`.`project_type`,
         `a`.`project_id`;
         
CREATE ALGORITHM=UNDEFINED DEFINER=`tech`@`%` SQL SECURITY DEFINER VIEW `ukint_project_detailed_delay_reports` AS
SELECT `a`.`country` AS `Country`,
       ifnull(
                (SELECT date_format(
                                      (SELECT `b`.`date` AS `date`
                                       FROM `pm_project_event` `b`
                                       WHERE ((`a`.`project_id` = `b`.`project_id`)
                                              AND (`b`.`type` = _utf8'launch'))),_utf8'%b/%Y') AS `date_format((SELECT date FROM pm_project_event b WHERE a.project_id = b.project_id AND type = 'launch'), '%b/%Y')`),_utf8'n/a') AS `Month`,
       `a`.`project_id` AS `Ticket`,
       `a`.`project_type` AS `Project type`,
       if(isnull(
                   (SELECT `b`.`date` AS `date`
                    FROM `pm_project_event` `b`
                    WHERE ((`a`.`project_id` = `b`.`project_id`)
                           AND (`b`.`type` = _utf8'launch')))),_utf8'no',_utf8'yes') AS `Launched`,
       ifnull(
                (SELECT cast(date_format(
                                           (SELECT `b`.`date` AS `date`
                                            FROM `pm_project_event` `b`
                                            WHERE ((`a`.`project_id` = `b`.`project_id`)
                                                   AND (`b`.`type` = _utf8'launch'))),_utf8'%d/%m/%Y') AS char(20) charset utf8) AS `convert(date_format((SELECT date FROM pm_project_event b WHERE a.project_id = b.project_id AND type = 'launch'), '%d/%m/%Y'), char(20))`),_utf8'n/a') AS `Real launch date`,
       ifnull(
                (SELECT cast(date_format(substr(`b`.`timelines`,(locate(_utf8'Launch=',`b`.`timelines`) + 7)),_utf8'%d/%m/%Y') AS char(20) charset utf8) AS `convert(date_format(SUBSTRING(timelines, LOCATE('Launch=', timelines) + 7), '%d/%m/%Y'), char(20))`
                 FROM `pm_project_event` `b`
                 WHERE ((`a`.`project_id` = `b`.`project_id`)
                        AND (`b`.`type` = _utf8'baseline'))),_utf8'n/a') AS `Planned launch date`,

  (SELECT sum(`b`.`impact`) AS `SUM(impact)`
   FROM `pm_project_event` `b`
   WHERE (`b`.`project_id` = `a`.`project_id`)
   GROUP BY `b`.`project_id`) AS `Total launch delay`,
       cast(date_format(`a`.`date`,_utf8'%d/%m/%Y') AS char(20) charset utf8) AS `Date delay`,
       cast(concat(`a`.`impact`,_utf8' days') AS char(200) charset utf8) AS `Amount delay`,
       ifnull(`a`.`reason`,_utf8'n/a') AS `Delay reason`
FROM `pm_project_event` `a`
WHERE (`a`.`type` = _utf8'delay')
ORDER BY `a`.`country`,
         `a`.`project_type`,
         `a`.`project_id`,
         cast(date_format(`a`.`date`,_utf8'%d/%m/%Y') AS char(20) charset utf8);
         
CREATE ALGORITHM=UNDEFINED DEFINER=`tech`@`%` SQL SECURITY DEFINER VIEW `ukint_project_timelines_reports` AS
SELECT `a`.`country` AS `Country`,
       `a`.`project_id` AS `Ticket`,
       `a`.`date` AS `Start`,
       `a`.`event` AS `Phase`,
       date_format(
                     (SELECT vfget(`pm_project_event`.`timelines` AS `timelines`,`a`.`event` AS `a.event`) AS `vfget(timelines, a.event)`
                      FROM `pm_project_event`
                      WHERE ((`pm_project_event`.`project_id` = `a`.`project_id`)
                             AND (`pm_project_event`.`timelines` <> _utf8''))
                      ORDER BY `pm_project_event`.`date` DESC,`pm_project_event`.`event_id` DESC LIMIT 1),_utf8'%d/%m/%Y') AS `End`,
       (to_days(
                  (SELECT vfget(`pm_project_event`.`timelines` AS `timelines`,`a`.`event` AS `a.event`) AS `vfget(timelines, a.event)`
                   FROM `pm_project_event`
                   WHERE ((`pm_project_event`.`project_id` = `a`.`project_id`)
                          AND (`pm_project_event`.`timelines` <> _utf8''))
                   ORDER BY `pm_project_event`.`date` DESC,`pm_project_event`.`event_id` DESC LIMIT 1)) - to_days(`a`.`date`)) AS `Days`
FROM `pm_project_event` `a`
WHERE (`a`.`type` IN (_utf8'start',_utf8'launch'))
ORDER BY `a`.`country`,
         `a`.`project_id`,
         `a`.`date`,
         `a`.`event_id`;
