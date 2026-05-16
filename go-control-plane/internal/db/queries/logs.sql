-- name: InsertLog :exec                                                         
INSERT INTO experiment_logs (experiment_id, content)                             
VALUES ($1, $2);                                                                 
                                                                                
-- name: ListLogs :many                                                          
SELECT * FROM experiment_logs                                                    
WHERE experiment_id = $1                                                         
ORDER BY logged_at ASC;                                                          
                                                                                
-- name: ListLogsSince :many                                                     
SELECT * FROM experiment_logs                                                    
WHERE experiment_id = $1 AND id > $2                                             
ORDER BY id ASC;             