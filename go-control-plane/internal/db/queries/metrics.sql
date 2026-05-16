-- name: InsertMetric :exec                                                      
INSERT INTO experiment_metrics (experiment_id, step, metric_name, metric_value)  
VALUES ($1, $2, $3, $4);                                                         
                                                                                
-- name: ListMetricsByExperiment :many                                           
SELECT * FROM experiment_metrics                                                 
WHERE experiment_id = $1                                                         
ORDER BY step ASC;                                                               
                                                                                
-- name: ListMetricsByName :many                                                 
SELECT * FROM experiment_metrics                                                 
WHERE experiment_id = $1 AND metric_name = $2                                    
ORDER BY step ASC;                                                               
                                                                                
