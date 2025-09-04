#!/usr/bin/env node

/**
 * n8n Credential Initialization Script
 * Pre-configures Ollama credentials for Product Managers
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Configuration
const N8N_DATA_DIR = process.env.N8N_DATA_DIR || '/home/node/.n8n';
const DATABASE_FILE = path.join(N8N_DATA_DIR, 'database.sqlite');

// Credential configuration
const OLLAMA_CREDENTIAL = {
    id: crypto.randomUUID(),
    name: 'Local Ollama (Pre-configured)',
    type: 'openAiApi',
    data: {
        apiKey: 'local-ollama-key',
        baseURL: 'http://ollama:11434/v1'
    }
};

/**
 * Log with timestamp
 */
function log(message) {
    console.log(`[n8n-init] ${new Date().toISOString()} - ${message}`);
}

/**
 * Wait for n8n database to be created
 */
async function waitForDatabase(maxAttempts = 30) {
    log('Waiting for n8n database initialization...');
    
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        if (fs.existsSync(DATABASE_FILE)) {
            log(`Database found at ${DATABASE_FILE}`);
            return true;
        }
        
        log(`Attempt ${attempt}/${maxAttempts} - waiting for database...`);
        await new Promise(resolve => setTimeout(resolve, 2000));
    }
    
    log(`Database not found after ${maxAttempts} attempts`);
    return false;
}

/**
 * Check if credential already exists
 */
async function credentialExists() {
    if (!fs.existsSync(DATABASE_FILE)) {
        return false;
    }
    
    try {
        const sqlite3 = require('sqlite3').verbose();
        const db = new sqlite3.Database(DATABASE_FILE);
        
        return new Promise((resolve, reject) => {
            db.get(
                "SELECT COUNT(*) as count FROM credentials_entity WHERE name = ?",
                [OLLAMA_CREDENTIAL.name],
                (err, row) => {
                    db.close();
                    if (err) {
                        reject(err);
                    } else {
                        resolve(row.count > 0);
                    }
                }
            );
        });
    } catch (error) {
        log(`Error checking credentials: ${error.message}`);
        return false;
    }
}

/**
 * Create Ollama credential in database
 */
async function createOllamaCredential() {
    log('Creating pre-configured Ollama credential...');
    
    try {
        const sqlite3 = require('sqlite3').verbose();
        const db = new sqlite3.Database(DATABASE_FILE);
        
        const now = new Date().toISOString();
        const credentialDataJson = JSON.stringify(OLLAMA_CREDENTIAL.data);
        
        return new Promise((resolve, reject) => {
            db.run(
                `INSERT OR REPLACE INTO credentials_entity 
                 (id, name, type, data, createdAt, updatedAt) 
                 VALUES (?, ?, ?, ?, ?, ?)`,
                [
                    OLLAMA_CREDENTIAL.id,
                    OLLAMA_CREDENTIAL.name,
                    OLLAMA_CREDENTIAL.type,
                    credentialDataJson,
                    now,
                    now
                ],
                function(err) {
                    db.close();
                    if (err) {
                        reject(err);
                    } else {
                        log(`✓ Created '${OLLAMA_CREDENTIAL.name}' credential`);
                        log(`  Credential ID: ${OLLAMA_CREDENTIAL.id}`);
                        log(`  Base URL: ${OLLAMA_CREDENTIAL.data.baseURL}`);
                        resolve();
                    }
                }
            );
        });
    } catch (error) {
        log(`Error creating credential: ${error.message}`);
        throw error;
    }
}

/**
 * Main initialization function
 */
async function main() {
    try {
        log('Starting n8n credential initialization...');
        
        // Wait for n8n to initialize
        if (!await waitForDatabase()) {
            log('⚠ Could not initialize credentials - n8n database not ready');
            process.exit(0); // Don't fail container startup
        }
        
        // Check if credentials already exist
        if (await credentialExists()) {
            log('✓ Ollama credentials already configured');
            process.exit(0);
        }
        
        // Create the credential
        await createOllamaCredential();
        
        log('✓ n8n credential initialization complete!');
        log('📚 Product Managers can now use "Local Ollama (Pre-configured)" in workflows');
        
    } catch (error) {
        log(`❌ Error during initialization: ${error.message}`);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = { main, OLLAMA_CREDENTIAL };