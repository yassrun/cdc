-- ============================================================
-- Database Initialization Script for ATD Application
-- ============================================================
-- This file is automatically executed when PostgreSQL container starts
-- It creates the necessary database and schemas for the ATD application

-- Create template schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS template;

-- Create keycloak database if it doesn't exist
CREATE DATABASE IF NOT EXISTS keycloak
  WITH
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE keycloak TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA template TO postgres;

-- Switch to postgres database to create schema
\c postgres;

-- Create template schema for ATD application
CREATE SCHEMA IF NOT EXISTS template AUTHORIZATION postgres;

-- ============================================================
-- Create Tables
-- ============================================================

-- Users table
CREATE TABLE IF NOT EXISTS template.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(255) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles table
CREATE TABLE IF NOT EXISTS template.roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User-Role mapping
CREATE TABLE IF NOT EXISTS template.user_roles (
  user_id UUID NOT NULL REFERENCES template.users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES template.roles(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_username ON template.users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON template.users(email);
CREATE INDEX IF NOT EXISTS idx_roles_name ON template.roles(name);

-- ============================================================
-- Insert Sample Data (for development)
-- ============================================================

-- Insert sample roles
INSERT INTO template.roles (name, description) VALUES
  ('ADMIN', 'Administrator role'),
  ('USER', 'Standard user role'),
  ('VIEWER', 'Read-only viewer role')
ON CONFLICT (name) DO NOTHING;

-- Insert sample users
INSERT INTO template.users (username, email, first_name, last_name) VALUES
  ('admin', 'admin@example.com', 'Admin', 'User'),
  ('user1', 'user1@example.com', 'John', 'Doe'),
  ('user2', 'user2@example.com', 'Jane', 'Smith')
ON CONFLICT (username) DO NOTHING;

-- Assign roles to users
INSERT INTO template.user_roles (user_id, role_id)
SELECT u.id, r.id FROM template.users u, template.roles r
  WHERE u.username = 'admin' AND r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO template.user_roles (user_id, role_id)
SELECT u.id, r.id FROM template.users u, template.roles r
  WHERE u.username LIKE 'user%' AND r.name = 'USER'
ON CONFLICT DO NOTHING;

-- ============================================================
-- Permissions
-- ============================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA template TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA template TO postgres;
