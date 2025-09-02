-- PostgreSQL Initialization Script for Agentgateway
-- This script runs when the PostgreSQL container starts for the first time

-- Create extension for UUID generation (commonly needed)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create extension for JSON operations (commonly needed for modern apps)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Set timezone
SET timezone = 'America/New_York';

-- Create schemas if needed (uncomment and modify as needed)
-- CREATE SCHEMA IF NOT EXISTS agentgateway;
-- CREATE SCHEMA IF NOT EXISTS audit;

-- Example table creation (uncomment and modify as needed)
-- CREATE TABLE IF NOT EXISTS users (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     email VARCHAR(255) NOT NULL UNIQUE,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );

-- Create indexes (uncomment and modify as needed)
-- CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users(email);
-- CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Insert seed data if needed (uncomment and modify as needed)
-- INSERT INTO users (email) VALUES 
--     ('admin@agentgateway.local'),
--     ('test@agentgateway.local')
-- ON CONFLICT (email) DO NOTHING;

-- Grant permissions (uncomment and modify as needed)
-- GRANT USAGE ON SCHEMA agentgateway TO agentgateway;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA agentgateway TO agentgateway;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA agentgateway TO agentgateway;

-- Log completion
\echo 'PostgreSQL initialization completed successfully'