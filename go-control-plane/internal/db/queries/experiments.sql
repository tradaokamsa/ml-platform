-- name: CreateExperiment :one                                                   
INSERT INTO experiments (name, status, config, gpu_count)                        
VALUES ($1, 'created', $2, $3)                                                   
RETURNING *;                                                                     
                                                                                
-- name: GetExperiment :one                                                      
SELECT * FROM experiments WHERE id = $1;              
                                                                                
-- name: GetExperimentByTaskQueueJobID :one                                      
SELECT * FROM experiments WHERE taskqueue_job_id = $1;                           
                                                                                
-- name: SetTaskQueueJobID :exec                                                 
UPDATE experiments                                                               
SET taskqueue_job_id = $2, status = 'queued'                                     
WHERE id = $1;                                                                   
                                                                                
-- name: UpdateExperimentStatus :exec                                            
UPDATE experiments                                                               
SET status = $2                                                                  
WHERE id = $1;                                                                   
                                                                                
-- name: StartExperiment :exec                                                   
UPDATE experiments                                                               
SET status = 'training', started_at = now(), worker_id = $2                      
WHERE id = $1;                                                                   
                                                                                
-- name: CompleteExperiment :exec                                                
UPDATE experiments                                    
SET status = 'completed', completed_at = now()                                   
WHERE id = $1;                                                                   

-- name: FailExperiment :exec                                                    
UPDATE experiments                                    
SET status = 'failed', completed_at = now()                                      
WHERE id = $1;                                                                   
                                                                                
-- name: ListExperiments :many                                                   
SELECT * FROM experiments                                                        
ORDER BY created_at DESC                                                         
LIMIT $1 OFFSET $2;             