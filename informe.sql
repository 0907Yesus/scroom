SELECT
  u.id AS 'Identificación',
  CONCAT(u.firstname, ' ', u.lastname) AS 'Nombre',
  c.fullname AS 'Nombre del Curso',
  g.name AS 'Grupo',
  ROUND( (SUM( CASE WHEN cmc.completionstate = 1 THEN 1 ELSE 0 END ) / 
         (SELECT COUNT(*) 
          FROM mdl_course_modules 
          WHERE course = c.id 
          AND completion > 0)) * 100, 2) AS 'Progreso (%)',
  SUM( CASE WHEN cmc.completionstate = 1 THEN 1 ELSE 0 END ) AS 'Actividades Completadas',
  (SELECT COUNT(*) 
     FROM mdl_course_modules 
     WHERE course = c.id 
     AND completion > 0) AS 'Actividades del Curso',
  docdata.data AS 'Tipo de Documento',
  numdocdata.data AS 'Número de Documento',
  caractdata.data AS 'Caracterización'
FROM mdl_user u
LEFT JOIN mdl_user_enrolments ue ON ue.userid = u.id
LEFT JOIN mdl_enrol e ON e.id = ue.enrolid
LEFT JOIN mdl_course c ON c.id = e.courseid
LEFT JOIN mdl_groups_members gm ON gm.userid = u.id
LEFT JOIN mdl_groups g ON g.id = gm.groupid
LEFT JOIN mdl_course_modules_completion cmc ON cmc.userid = u.id AND cmc.coursemoduleid IN (
    SELECT id FROM mdl_course_modules WHERE course = c.id
) 
LEFT JOIN mdl_course_modules cm ON cm.id = cmc.coursemoduleid AND cm.course = c.id
LEFT JOIN mdl_user_info_data docdata ON docdata.userid = u.id AND docdata.fieldid = 5  -- Campo "Tipo de Documento"
LEFT JOIN mdl_user_info_data numdocdata ON numdocdata.userid = u.id AND numdocdata.fieldid = 4  -- Campo "Número de Documento"
LEFT JOIN mdl_user_info_data caractdata ON caractdata.userid = u.id AND caractdata.fieldid = 2  -- Campo "Caracterización"
WHERE c.visible = 1
GROUP BY u.id, c.id, g.id, docdata.data, numdocdata.data, caractdata.data
ORDER BY u.lastname, u.firstname;