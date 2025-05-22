![GitHub License](https://img.shields.io/github/license/opea-project/haystack-opea)
![PyPI - Version](https://img.shields.io/pypi/v/haystack-opea)
![PyPI - Python Version](https://img.shields.io/pypi/pyversions/haystack-opea)

# Haystack-OPEA

This package contains the Haystack integrations for OPEA Compatible [OPEA](https://opea.dev/) Microservices. At its core, OPEA offers a suite of containerized microservices—including components for LLMs, embedding, retrieval, and reranking—that can be orchestrated to build sophisticated AI workflows like Retrieval-Augmented Generation (RAG). These microservices are designed for flexibility, supporting deployment across various environments such as cloud platforms, data centers, and edge devices.​

For more information, see [Getting Started with OPEA](https://opea-project.github.io/latest/getting-started/README.html), [OPEA Components](https://github.com/opea-project/GenAIComps) and [Full Examples](https://github.com/opea-project/GenAIExamples).

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

See the [Examples](./samples/) folder; it contains two jupyter notebooks, using an OPEA LLM and text embedder. The folder also includes a docker compose configuration for starting the OPEA backend.

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
