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
         