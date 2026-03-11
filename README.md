# Proyecto A: Sistema RAG Educativo 

## 📋 Descripción del Proyecto

Sistema inteligente de Retrieval-Augmented Generation (RAG) diseñado para vectorizar y procesar documentos educativos (PDF/TXT), permitiendo responder preguntas basadas exclusivamente en el conocimiento extraído de esos archivos. El sistema garantiza respuestas contextuales y precisas mediante búsqueda vectorial avanzada.

## 🏗️ Stack Tecnológico

- **n8n**: Orquestación y automatización de workflows RAG
- **Ollama**: Modelos de lenguaje locales para embeddings y generación de respuestas
- **Qdrant**: Base de datos vectorial para búsqueda semántica de documentos
- **PostgreSQL**: Almacenamiento de metadatos y gestión de documentos

## 🔄 Estructura del Workflow RAG

### 1. **Ingesta de Documentos**

```
Documento → Chunks → Embeddings → Qdrant + Metadata en PostgreSQL
```

- Lectura de documentos (PDF/TXT)
- División en chunks procesables
- Generación de embeddings vectoriales
- Almacenamiento simultáneo en Qdrant y PostgreSQL

### 2. **Procesamiento de Consultas**

```
Pregunta → Búsqueda Vectorial → Contexto Relevante → Respuesta LLM
```

- Vectorización de la pregunta del usuario
- Búsqueda semántica en Qdrant
- Recuperación de contexto relevante
- Generación de respuesta mediante LLM

## 📊 Esquema SQL

```sql
CREATE TABLE documentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255),
    num_chunks INTEGER,
    fecha TIMESTAMP DEFAULT NOW()
);
```

---


