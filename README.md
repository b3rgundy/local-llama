# Local LLaMA

A bundle to run local LLM's on a modern MacBook.

## Table of Contents

- [Local LLaMA](#local-llama)
	- [Table of Contents](#table-of-contents)
	- [Introduction](#introduction)
	- [Running](#running)
		- [Prerequisites](#prerequisites)
		- [Instructions](#instructions)
- [FAQ](#faq)

## Introduction

This is a bundling of existing open-source AI frameworks for development purposes, namely the following:

- [llama.cpp](https://github.com/ggml-org/llama.cpp) (performant model inference on Mac Silicon)
- [open-webui](https://github.com/open-webui/open-webui) (broadly supported extensibel front end)
- [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) (wrapper of personal favorite Kokoro TTS)

The idea is to have a quick, easy to setup and run development stack for **local Large Language Models**.

## Running

### Prerequisites

- [Docker Compose](https://docs.docker.com/desktop/setup/install/mac-install/)
- A quantized model that can run on your hardware, for example [CodeLlama 7B Instruct](https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF) (login for *Hardware compatibility*)

### Instructions

1. Place your downloaded model in the `/models` directory
2. Assign your model filename to the `LLAMA_MODEL_FILENAME` environment variable.
3. Run the script:
   
	 ```
	 $ bash ./scripts/run.sh
	 ```

# FAQ

**Q: Why no llama.cpp container?**

**A: Docker has no Silicon GPU accelleration: [source](https://chariotsolutions.com/blog/post/apple-silicon-gpus-docker-and-ollama-pick-two/)**


**Q: Can this run on my old MacBook?**

**A: Yes, but: you may want to go for a smaller model and tweak the inference engine using `.env`**