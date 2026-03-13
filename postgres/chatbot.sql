CREATE TABLE IF NOT EXISTS historial_chat (
    id SERIAL PRIMARY KEY,
    usuario_id VARCHAR(50),
    pregunta TEXT,
    intencion VARCHAR(50),
    respuesta_final TEXT,
    fecha TIMESTAMP DEFAULT NOW()
);