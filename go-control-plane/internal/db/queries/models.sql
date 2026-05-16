-- name: RegisterModel :one                                                      
INSERT INTO models (name, version, model_type, artifact_uri,                     
parent_base_model_id, parent_experiment_id, metadata)                            
VALUES ($1, $2, $3, $4, $5, $6, $7)                                              
RETURNING *;                                                                     
                                                    
-- name: GetModel :one                                                           
SELECT * FROM models WHERE id = $1;                   
                                                                                
-- name: ListModels :many                                                        
SELECT * FROM models                                                             
ORDER BY created_at DESC                                                         
LIMIT $1 OFFSET $2;                                                              
                                                                                
-- name: UpdateModelStage :one                                                   
UPDATE models                                                                    
SET stage = $2                                                                   
WHERE id = $1                                         
RETURNING *;   