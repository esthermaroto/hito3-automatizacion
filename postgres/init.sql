CREATE TABLE documentos (
 id SERIAL PRIMARY KEY,
 nombre VARCHAR(255),
 num_chunks INTEGER,
 fecha_procesado TIMESTAMP DEFAULT NOW()
);

