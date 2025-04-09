# Haystack-OPEA

This package contains the Haystack integrations for OPEA Compatible [OPEA](https://opea.dev/) Microservices.

## Installation

You can install Haystack OPEA package in several ways:

### Install from Source

To install the package from the source, run:

```bash
pip install poetry && poetry install --with test
```

### Install from Wheel Package

To install the package from a pre-built wheel, run:

1. **Build the Wheels**: Ensure the wheels are built using Poetry.
    ```bash
    poetry build
    ```
2. **Install via Wheel File**: Install the package using the generated wheel file.
    ```bash
    pip install dist/haystack_opea-0.1.0-py3-none-any.whl
    ```

## Examples

See [Examples][./samples/] folder for a RAG and summarization notebooks, including a simple docker compose configuration for starting the OPEA backend.

## Embeddings

The classes `OPEADocumentEmbedder` and `OPEATextEmbedder` are introduced.

```python
from haystack_opea import OPEATextEmbedder

text_to_embed = "I love pizza!"

text_embedder = OPEATextEmbedder(api_url="http://localhost:6006")
text_embedder.warm_up()

print(text_embedder.run(text_to_embed)
```

And similarly:

```python
from haystack import Document
from haystack_opea import OPEADocumentEmbedder

doc = Document(content="I love pizza!")

document_embedder = OPEADocumentEmbedder(api_url="http://localhost:6006")
document_embedder.warm_up()

result = document_embedder.run([doc])
print(result["documents"][0].embedding)
```

## LLMs

The class `OPEAGenerator` is introduced:

```python
from haystack_opea import OPEAGenerator

generator = OPEAGenerator(
    "http://localhost:9009",
    model_arguments={
        "temperature": 0.2,
        "top_p": 0.7,
        "max_tokens": 1024,
    },
)
generator.warm_up()
result = generator.run(prompt="What is the answer?")
```

For more information, see [Haystack Docs](https://docs.haystack.deepset.ai/docs/intro) and [OPEA](https://opea.dev).
