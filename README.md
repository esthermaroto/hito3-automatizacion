# Proyecto A: Sistema RAG Educativo 
Proyecto realizado por Esther Maroto Torres

---

## 📋 Descripción del Proyecto

Sistema inteligente de Retrieval-Augmented Generation (RAG) diseñado para vectorizar y procesar documentos educativos (PDF/TXT/DOC/DOCX), permitiendo responder preguntas basadas exclusivamente en el conocimiento extraído de esos archivos. El sistema garantiza respuestas contextuales y precisas mediante búsqueda vectorial avanzada.

## 🏗️ Stack Tecnológico

- **n8n**: Orquestación y automatización de workflows RAG
- **Ollama**: Modelos de lenguaje de Jarvis para embeddings y generación de respuestas
- **Qdrant**: Base de datos vectorial para búsqueda semántica de documentos
- **PostgreSQL**: Almacenamiento de metadatos 

## 🔄 Estructura del Workflow RAG

### 1. **Ingesta de Documentos**

```
Documento → Chunks → Embeddings → Qdrant + Metadata en PostgreSQL → Mensaje de confirmación
```

- Lectura de documentos (PDF/TXT/DOC/DOCX)
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
 fecha_procesado TIMESTAMP DEFAULT NOW()
);
```


![creación de tabla](docs/capturas/creacion-tabla.png)

> Creo la tabla según las recomendaciones de moodle
![estructura tabla](docs/capturas/schema-tbla.png)


---

## 🔗 Explicación del workflow

Al contrario de las recomendaciones de Moodle he decidido realizar el proceso de ingesta y de búsqueda dentro de un mismo workflow. 
Además al no tener un ordenador que soporte bien los modelos de ollama, aún habiendo añadido el contenedor de ollama al contenedor del proyecto hemos decidido utilizar los modelos de Jarvis para que el proyecto funcionara correctamente.

He utilizado el modelo `qwen2.5:7b-instruct` para el flujo de las consultas.

Para los embeddings he utilizado el modelo `nomic-embed-text` que también está conectado al vector retriever del flujo de búsqueda. 

**¿Por qué estos modelos?**

El modelo `nomic-embed-text` es el que mejor funciona a la hora de hacer los embeddings y ya lo hemos utilizado en otras ocasiones.

El modelo `qwen2.5:7b-instruct` es fácil de limitar y soporta tools como es *Qdrant Vector Store* que es necesario para el proceso de búsqueda, también probé con los modelos `llama3.2`, `llama3` y `mistral`, pero los modelos de llama no soportan los tools de los agentes y mistral me daba problemas a la hora de mandar la petición al tool y daba error. 

### Explicación por nodos

#### Ingesta de documentos

![ingesta de documentos](docs/capturas/ingesta-rag.png)

- **Upload Form**: está configurado para aceptar archivos `.pdf, .txt, .doc, .docx`. 
Al ejecutarse el flujo salta una tab con esta url `http://localhost:5679/webhook-test/upload-document/n8n-form` donde podemos subir los archivos que deseemos para la ingesta.

- **Store in Qdrant**: con la credencial de nuestro contenedor de qdrant, seleccionamos el *operation mode* como `Insert Documents` y desde la lista que habrá cargado de nuestras *collections* seleccionamos (en mi caso) `educational_docs` y marcamos el *Embedding batch size* con 100. Guarda los vectores en la collection

    - <u>Embeddings Ollama</u>: convierte cada fragmento de texto en un vector numérico.
    - <u>Load Documents</u>: carga el documento y lo convierte en texto.
    - <u>Chunk Documents</u>: divide el documento en *chunks* (trozos pequeños), en nuestro caso los chunks son de 500 palabras.

- **Code in JavaScript**: extrae los datos necesarios para pasarle al nodo de postgres.
```javascript
return [
 {
  json: {
   nombre: $items()[0].json.metadata.source,
   num_chunks: $items().length
  }
 }
];
```
- **Save to PostgreSQL**: con la tabla indicada `documentos` mapea los campos que han de ser rellenados y podemos pasar los datos extraídos del nodo anterior, para guardarlos en la tabla.

- **Extract Metadata**: muestra en los logs un mensaje de confirmación de que se ha realizado bien el proceso y devuelve la siguiente información: 

```json
{
 "status": "success",
 "mensaje": "Documento vectorizado correctamente",
 "documento": "{{$json.nombre}}",   <--- el nombre del propio documento subido
 "chunks": "{{$json.num_chunks}}",  <--- el número de chunks que se han generado 
 "vector_store": "Qdrant",
 "embeddings": "Ollama"
} 
```

### Resultado final 
![qdrant dashboard](docs/capturas/qdrant-dashboard.png)
<br>

#### Consulta RAG

![consulta rag](docs/capturas/consulta-rag.png)

- **When chat message received**: se activa cuando se escribe un mensaje por el chat de n8n.

- **RAG Agent**: recibe el mensaje del usuario y aplica el prompt que tiene. 

    - <u>Ollama LLM</u>: proporciona el modelo para que funcione el agente.
    - <u>Qdrant Vector Store</u>: busca los chunks más parecidos a la pregunta.
    Ejemplo:

            Pregunta:

            ¿Qué es la fotosíntesis?

            Encuentra:

            Chunk 1: explicación de fotosíntesis
            Chunk 2: proceso en plantas
            Chunk 3: clorofila

         Recupera el contexto relevante.
Está conectado al mismo modelo de embeddings que el flujo de la ingesta para que los vectores coincidan.

> El agente no consta de memoria del chat para obligarlo a buscar cada pregunta en la colección y no recupere respuestas de la memoria que puedan ser erróneas, de esta forma también se limita mucho más el que el modelo divague con la información que devuelve.

### Muestras de interacción con el agente

![chat rag](docs/capturas/caht-rag.png)

Tiene especificado en el prompt que debe responder en caso de no encontrar coincidencia con la pregunta hecha y que no debe *inventar* en caso de no encontrar respuesta o de devolver información no añadir nada más.

---

### Dificultades encontradas

La principal dificultad de este proyecto han sido los fallos con los modelos hasta que he dado con el que funcionaba correctamente para los requisitos que le estaba pidiendo, dependiendo del modelo daba un error diferente por lo tanto era bastante frustrante.

También a la hora de hacer el prompt he tenido que ir añadiendo bastantes detalles hasta que he conseguido un prompt que limita lo que necesito y al que el modelo puede ceñirse al pie de la letra.

La decisión de eliminar también la memoria de chat ha venido de un problema con el agente, al cargar "una vez" los chunks con la primera pregunta, dejaba de entrar en el tool de qdrant por lo que empezaba a divagar y a inventar información. Al eliminar la memoria, el agente no "retiene" por lo que siempre se ve obligado a acudir a la colección y no da información inventada.