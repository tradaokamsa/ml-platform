-- +goose Up                                                                     
                                                                                   
CREATE TYPE experiment_status AS ENUM (                                          
    'created', 'queued', 'training', 'evaluating',                                 
    'completed', 'failed', 'cancelled'                                             
);                                                                               
                                                                                
CREATE TYPE model_stage AS ENUM (                                                
    'none', 'staging', 'production', 'archived'                                    
);                                                                               
                                                    
CREATE TYPE model_type AS ENUM (                                                 
    'base', 'lora_adapter', 'merged'                    
);                                                                               
                                                    
CREATE TABLE experiments (                                                       
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name             TEXT NOT NULL,                                                
    status           experiment_status NOT NULL DEFAULT 'created',                 
    config           JSONB NOT NULL,                                               
    taskqueue_job_id UUID,                                                         
    worker_id        TEXT,                                                         
    gpu_count        INTEGER NOT NULL DEFAULT 1,                                   
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),                           
    started_at       TIMESTAMPTZ,                                                  
    completed_at     TIMESTAMPTZ                                                   
);                                                                               
                                                                                
CREATE TABLE experiment_metrics (                                                
    id             BIGSERIAL PRIMARY KEY,               
    experiment_id  UUID NOT NULL REFERENCES experiments(id),                       
    step           INT NOT NULL,                                                   
    metric_name    TEXT NOT NULL,                                                  
    metric_value   DOUBLE PRECISION NOT NULL,                                      
    recorded_at    TIMESTAMPTZ NOT NULL DEFAULT now()                              
);                                                                               
                                                                                
CREATE INDEX idx_experiment_metrics_lookup                                       
    ON experiment_metrics(experiment_id, metric_name, step);
                                                                                
CREATE TABLE experiment_logs (                                                   
    id             BIGSERIAL PRIMARY KEY,                                          
    experiment_id  UUID NOT NULL REFERENCES experiments(id),                       
    content        TEXT NOT NULL,                                                  
    logged_at      TIMESTAMPTZ NOT NULL DEFAULT now()                              
);                                                                               
                                                                                
CREATE INDEX idx_experiment_logs_lookup                                          
    ON experiment_logs(experiment_id, logged_at);       
                                                                                
CREATE TABLE models (                                                            
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),              
    name                  TEXT NOT NULL,                                           
    version               TEXT NOT NULL,                                           
    stage                 model_stage NOT NULL DEFAULT 'none',                     
    model_type            model_type NOT NULL,                                     
    artifact_uri          TEXT NOT NULL,                                           
    parent_base_model_id  UUID REFERENCES models(id),                              
    parent_experiment_id  UUID REFERENCES experiments(id),                         
    metadata              JSONB DEFAULT '{}',                                      
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),                      
    UNIQUE (name, version)                                                         
);                                                                               
                                                                                
CREATE TABLE serving_configs (                                                   
    id             BIGSERIAL PRIMARY KEY,               
    model_name     TEXT NOT NULL,                                                  
    traffic_splits JSONB NOT NULL,                                                 
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()                              
);                                                                               
                                                                                
CREATE TABLE audit_log (                                                         
    id          BIGSERIAL PRIMARY KEY,                  
    entity_type TEXT NOT NULL,                                                     
    entity_id   UUID NOT NULL,                                                     
    action      TEXT NOT NULL,                                                     
    actor       TEXT NOT NULL,                                                     
    details     JSONB,                                                             
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()                                 
);                                                                               
                                                                                
CREATE INDEX idx_audit_log_entity                                                
    ON audit_log(entity_type, entity_id);               
                                                                                
-- +goose Down                                                                   
                                                                                
DROP TABLE IF EXISTS audit_log;                                                  
DROP TABLE IF EXISTS serving_configs;                 
DROP TABLE IF EXISTS models;                                                     
DROP TABLE IF EXISTS experiment_logs;                                            
DROP TABLE IF EXISTS experiment_metrics;                                         
DROP TABLE IF EXISTS experiments;                                                
DROP TYPE IF EXISTS model_type;                                                  
DROP TYPE IF EXISTS model_stage;                                                 
DROP TYPE IF EXISTS experiment_status;   