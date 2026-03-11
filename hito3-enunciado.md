# 🚀 HITO 3: Automatización Inteligente con n8n + Ollama + PostgreSQL + Qdrant

**Desarrollo de Agentes IA para Web - 2º DAW IES Hermenegildo Lanz**  
**Profesor:** Isaías Fernández Lozano

---

## 📋 Descripción General

En este hito final desarrollarás sistemas de automatización inteligente usando **n8n** como orquestador visual de workflows. Trabajarás con modelos de lenguaje locales (**Ollama**), bases de datos vectoriales (**Qdrant**), y almacenamiento estructurado (**PostgreSQL**) para crear soluciones que demuestran la integración práctica de múltiples tecnologías de IA.

🎯 **Deberás realizar DOS tipos de proyectos:**

1.  **Sistema RAG (Retrieval-Augmented Generation):** Procesa documentos, los vectoriza y permite hacer preguntas sobre su contenido.
2.  **Chatbot Multiherramienta:** Asistente conversacional que decide qué APIs consultar según las preguntas del usuario.

El objetivo es dominar la orquestación visual de workflows complejos, entender cómo funcionan los sistemas RAG y agentes conversacionales, y aprender a integrar múltiples servicios de forma coherente y profesional.

---

## 🎯 Objetivos de Aprendizaje

- [X] Diseñar workflows complejos en n8n con manejo de errores y validaciones
- [X] Integrar Ollama para generación de embeddings y respuestas inteligentes
- [X] Implementar bases de datos vectoriales con Qdrant para búsqueda semántica
- [X] Diseñar esquemas PostgreSQL para persistencia de datos estructurados
- [X] Consumir APIs REST externas y procesar sus respuestas
- [X] Containerizar aplicaciones multi-servicio con Docker Compose
- [X] Documentar proyectos de forma profesional con ejemplos visuales
- [X] Presentar demostraciones técnicas claras y efectivas en vídeo

---

## 🛠 Requisitos Previos

- 🐳 **Docker 24+** y **Docker Compose V2** instalados
- 🔧 **n8n** instalado localmente (via Docker: `docker run -p 5678:5678 n8nio/n8n`)
- 🦙 **Ollama** instalado con modelo descargado (`ollama pull mistral` o `ollama pull llama2`)
- 💻 **Visual Studio Code** o editor similar
- 🌿 **Git** configurado para control de versiones
- 📚 Conocimientos básicos de **SQL** y **APIs REST**

---

## 📚 Proyecto A: Sistema RAG Educativo

Desarrolla un sistema que procesa documentos (PDF, TXT, Markdown), los vectoriza y permite realizar preguntas sobre su contenido. El sistema debe recuperar información relevante y generar respuestas contextualizadas.

### Stack Tecnológico
- **n8n** - Orquestación
- **Ollama** - Embeddings + LLM
- **Qdrant** - Base Vectorial
- **PostgreSQL** - Metadatos

### Arquitectura del Sistema RAG

```mermaid
graph TD
    A[Usuario] --> B[Webhook Ingesta]
    B --> C[Extracción Texto]
    C --> D[Chunking]
    D --> E[Ollama Embeddings]
    E --> F[Qdrant Store]
    F --> G[PostgreSQL Metadata]
    
    A --> H[Webhook Consulta]
    H --> I[Ollama Embedding Pregunta]
    I --> J[Qdrant Search]
    J --> K[Context Retrieval]
    K --> L[Ollama Prompt + Context]
    L --> M[PostgreSQL Log]
    M --> A
```

### Workflow 1: Ingesta de Documentos
📄 Usuario sube PDF/TXT → 🔧 n8n Webhook → 📖 Extracción de texto → ✂️ División en chunks → 🤖 Ollama genera embeddings → 💾 Qdrant guarda vectores → 🗄️ PostgreSQL guarda metadata → ✅ Confirmación

### Workflow 2: Consultas RAG
❓ Usuario hace pregunta → 🔧 n8n Webhook → 🤖 Ollama embedding pregunta → 🔍 Qdrant busca chunks similares → 📝 Recupera textos relevantes → 🤖 Ollama genera respuesta → 🗄️ PostgreSQL guarda consulta → ✅ Devuelve respuesta

### Funcionalidades Obligatorias
- **Workflow de ingesta:** Recibe archivo → extrae texto → divide en chunks → genera embeddings → guarda en Qdrant y metadata en PostgreSQL.
- **Workflow de consulta:** Recibe pregunta → genera embedding → busca en Qdrant chunks similares → envía a Ollama con contexto → devuelve respuesta.
- **Sistema de chunks:** Divide documentos en fragmentos de ~500 palabras con overlap de 50 palabras.
- **Gestión de documentos:** Permite listar documentos procesados, ver sus chunks y eliminarlos si es necesario.
- **Historial de consultas:** Guarda en PostgreSQL cada pregunta, respuesta y documentos utilizados.

### PostgreSQL: Tablas Esenciales

#### Tabla 1: Documentos procesados
```sql
CREATE TABLE documentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ruta_archivo TEXT,
    num_chunks INTEGER,
    fecha_procesado TIMESTAMP DEFAULT NOW()
);

-- Índice para búsquedas rápidas
CREATE INDEX idx_documentos_nombre ON documentos(nombre);
```

#### Tabla 2: Historial de consultas RAG
```sql
CREATE TABLE consultas_rag (
    id SERIAL PRIMARY KEY,
    pregunta TEXT NOT NULL,
    respuesta TEXT NOT NULL,
    documentos_usados TEXT[], -- Array de nombres de docs
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Índice para consultas recientes
CREATE INDEX idx_consultas_timestamp ON consultas_rag(timestamp DESC);
```

---

## 💬 Proyecto B: Chatbot Multiherramienta

Desarrolla un asistente conversacional que analiza las preguntas del usuario y decide qué herramienta externa consultar (clima, información de países, Wikipedia, chistes, etc). El bot mantiene contexto conversacional y responde de forma natural.

### Stack Tecnológico
- **n8n** - Orquestación
- **Ollama** - LLM
- **APIs Gratuitas**
- **PostgreSQL** - Historial

### Arquitectura del Chatbot

```mermaid
graph TD
    A[Usuario] --> B[n8n Webhook]
    B --> C[Ollama Reonocimiento Intención]
    C --> D{Router}
    D -->|Clima| E[OpenMeteo API]
    D -->|Países| F[REST Countries API]
    D -->|Wiki| G[Wikipedia API]
    D -->|Chistes| H[JokeAPI]
    D -->|General| I[Ollama Directo]
    E --> J[Merge Response]
    F --> J
    G --> J
    H --> J
    I --> J
    J --> K[Ollama Natural Language Gen]
    K --> L[PostgreSQL Historial]
    L --> A
```

### APIs Gratuitas Disponibles (confirmadas 100%)
- 🌤️ **OpenMeteo** - Clima mundial (SIN API KEY)  
  `https://api.open-meteo.com/v1/forecast?latitude=40.4168&longitude=-3.7038&current=temperature_2m`
- 🌍 **REST Countries** - Info geográfica (SIN API KEY)  
  `https://restcountries.com/v3.1/name/spain`
- 📚 **Wikipedia API** - Resúmenes (SIN API KEY)  
  `https://es.wikipedia.org/api/rest_v1/page/summary/Madrid`
- 😄 **JokeAPI** - Chistes (SIN API KEY)  
  `https://v2.jokeapi.dev/joke/Programming?lang=es`

### Funcionalidades Obligatorias
- **Análisis de intención:** Ollama decide qué API llamar según la pregunta del usuario.
- **Switch de herramientas:** Usa nodo Switch en n8n para enrutar a la API correcta.
- **Respuestas naturales:** Ollama transforma datos de APIs en texto conversacional.
- **Historial conversacional:** PostgreSQL almacena mensajes y decisiones del bot.
- **Manejo de errores:** Respuestas alternativas si una API falla.

---

## 📁 Estructura del Proyecto

```text
hito3-automatizacion/
│
├── 📂 docker/
│   ├── docker-compose.yml
│   └── .env.example
│
├── 📂 n8n/
│   └── 📂 workflows/
│       ├── rag-ingesta.json
│       ├── rag-consultas.json
│       └── chatbot-multiherramienta.json
│
├── 📂 postgres/
│   └── init.sql
│
├── 📂 tests/
│   └── pruebas.http
│
├── 📂 docs/
│   ├── 📂 capturas/
│   └── DEMO.md
│
├── .gitignore
└── README.md
```

---

## 🎥 Vídeo Demostración (4-6 minutos)

### 📋 Contenido Obligatorio
1.  **Introducción (30 seg):** Presentación del equipo y proyecto elegido.
2.  **Arquitectura (1 min):** Explicación rápida de componentes (n8n, Ollama, Qdrant/APIs, PostgreSQL).
3.  **Demo en vivo (2-3 min):**
    -   **Opción A (RAG):** Subir documento → mostrar en Qdrant → hacer 2-3 preguntas → mostrar tabla PostgreSQL.
    -   **Opción B (Chatbot):** Hacer 4-5 preguntas variadas (clima, país, wiki, chiste) → mostrar tabla PostgreSQL.
4.  **Workflow en n8n (1 min):** Recorrido rápido por los nodos principales.
5.  **Conclusiones (30 seg):** Aprendizajes y posibles mejoras futuras.

### 🎬 Recomendaciones Técnicas
- Grabar con **OBS Studio** o similar (1080p mínimo).
- Audio claro (micrófono decente, sin ruido de fondo).
- Edición básica: cortar pausas largas, añadir títulos de secciones.
- Subir a **YouTube** (no listado) o plataforma del centro.
- Incluir enlace en el **README** y en el **Pull Request**.

---

## 🌿 Git y Control de Versiones

### 📝 Estrategia de Commits
Commits incrementales y descriptivos (mínimo 8-10 commits). Formato de mensajes:
- `feat`: nueva funcionalidad
- `fix`: corrección de bug
- `docs`: actualización documentación
- `config`: cambios en Docker/config

**Ejemplos de buenos commits:**
- `feat: implementar workflow de ingesta de documentos`
- `feat: añadir análisis de intención en chatbot`
- `fix: corregir timeout en llamadas a Ollama`
- `docs: completar README con capturas y ejemplos`
- `config: actualizar docker-compose con volúmenes persistentes`

### 🔀 Trabajo en Equipo
Debe aparecer como autor (usar `Co-authored-by` en commits):
```bash
git commit -m "feat: implementar workflow RAG completo

Co-authored-by: Nombre autor <email@example.com>"
```

### 🎯 Pull Request Final
**Título:** `Entrega HITO 3 - [Nombre proyecto] - [Proyecto A / Proyecto B]`  
**Descripción debe incluir:**
- [ ] Funcionalidades implementadas (con checkboxes ✅)
- [ ] Dificultades y soluciones encontradas
- [ ] 🎥 Enlace al vídeo demostración
- [ ] 🚀 Instrucciones para ejecutar el proyecto

---

## 📊 Rúbrica de Evaluación (Total: 16 puntos)

| # | Criterio | Peso | 🔴 Nivel 1 (33%) | 🟡 Nivel 2 (66%) | 🟢 Nivel 3 (100%) |
|---|----------|------|-------------------|-------------------|-------------------|
| 1 | 🏗 Configuración n8n | 2.0 | Workflow no funciona | Workflow con errores menores | Workflow perfecto |
| 2 | 🔧 Integración Ollama | 2.5 | No conecta o sin errores | Conecta pero falla a veces | Integración robusta |
| 3 | 💾 PostgreSQL | 2.0 | Sin persistencia | Queries incompletos | Diseño y queries óptimos |
| 4 | 🔍 Funcionalidad específica | 3.0 | No funciona correctamente | Funciona con limitaciones | Implementación completa |
| 5 | ✅ Validaciones y Errores | 1.5 | Sin validaciones | Validaciones básicas | Validaciones completas |
| 6 | 🐳 Dockerización | 1.5 | No funciona | Levanta con errores | Perfecto |
| 7 | 📖 Documentación | 1.5 | Incompleto/Confuso | Completo sin ejemplos | Detallado con capturas |
| 8 | 🎥 Vídeo demostración | 1.0 | Incompleto | Explicación confusa | Demostración clara |
| 9 | 🌿 Git y Workflow | 1.0 | < 3 commits | Commits regulares | Commits descriptivos |

**Escala de niveles:**
- ⚫ Sin realizar = 0 puntos
- 🔴 Nivel 1 = 33% del peso máximo
- 🟡 Nivel 2 = 66% del peso máximo
- 🟢 Nivel 3 = 100% del peso máximo

---

## 📤 Entrega

- **Plazo:** 8 de marzo de 2026 a las 23:59.
- **Método:** Pull Request en GitHub/GitLab del centro.
- **Exposición:** Demostración con los vídeos de que funcionan ambos proyectos.

---

## ⚠️ Requisitos Obligatorios para que sea Evaluable

- [ ] PR creado antes de la fecha límite.
- [ ] `docker-compose.yml` funciona sin errores (`docker compose up --build`).
- [ ] Archivo `tests/pruebas.http` con tests documentados.
- [ ] `README.md` completo con capturas e instrucciones.
- [ ] `postgres/init.sql` con esquema de base de datos.
- [ ] Workflows de n8n exportados en `n8n/workflows/`.
- [ ] Archivo `.env` NO está versionado (solo `.env.example`).
- [ ] Vídeo demostración (4-6 min) enlazado en README y PR.
- [ ] Ambos integrantes aparecen como co-autores en commits.
- [ ] Exposición presencial en clase.

---

## 💡 Consejos Finales

### 🎯 Para tener éxito en el proyecto
- ✅ **Empezad por lo básico:** Primero conseguid que 1 workflow funcione end-to-end, luego añadid complejidad.
- ✅ **Testeád frecuentemente:** No esperéis a tener todo completo para probar. Validar cada paso.
- ✅ **Documentad mientras desarrolláis:** Es más fácil escribir el README mientras recordáis cada decisión.
- ✅ **Dividid el trabajo pero revisad juntos:** Cada uno debe entender TODO el código, no solo su parte.
- ✅ **PostgreSQL simple:** No os compliquéis, 2 tablas simples son suficientes si están bien diseñadas.
- ✅ **Ollama: optimizad si tarda:** Si tarda mucho, bajad el contexto o usad un modelo más pequeño (`phi` o `gemma`).

### 🚫 Errores comunes a evitar
- ❌ **No versionar credenciales:** Nunca hacer commit de `.env` con claves reales.
- ❌ **Workflows gigantes:** Mejor 2 workflows pequeños que 1 inmanejable de 30 nodos.
- ❌ **Olvidar manejo de errores:** Todas las integraciones externas pueden fallar. Preparad fallbacks.
- ❌ **README genérico:** No copiéis plantillas. Documentad VUESTRO proyecto específico.
- ❌ **Vídeo improvisado:** Haced un guion antes. 4 minutos bien preparados valen más que 10 divagando.
- ❌ **Commits al final:** No hagáis 1 solo commit con todo. El historial es parte de la evaluación.

---

**🚀 Este es vuestro proyecto final de IA**  
Demostrad todo lo aprendido. ¡Adelante! 💪

**Profesor:** Isaías Fernández Lozano  
**IES Hermenegildo Lanz**