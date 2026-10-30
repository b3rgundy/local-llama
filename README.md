# Local LLM

A bundle to run local LLM's on a modern MacBook.

## Table of Contents

- [Local LLM](#local-llm)
	- [Table of Contents](#table-of-contents)
	- [Introduction](#introduction)
	- [Running](#running)
		- [Prerequisites](#prerequisites)
		- [Instructions](#instructions)
- [FAQ](#faq)

## Introduction

This is a bundling of existing open-source AI frameworks for development purposes, namely the following:

- [Ollama](https://ollama.com) (performant model inference on Mac Silicon)
- [open-webui](https://github.com/open-webui/open-webui) (broadly supported extensibel front end)
- [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) (wrapper of personal favorite Kokoro TTS)

The idea is to have a quick, easy to setup and run development stack for **local Large Language Models**.

## Running

### Prerequisites

- [Docker Compose](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Ollama](https://ollama.com/download) installed (`brew install ollama`)

### Instructions

1. Copy `.env.example` file:
   ```
	 cp .env.example .env
	 ````
2. Assign the model you want to use to the `OLLAMA_MODEL` environment variable (e.g. `llama3.2:3b`)
3. Run the script:
   
	 ```
	 bash ./scripts/run.sh
	 ```

This pulls the model via Ollama (if not already present locally) and starts the full stack.

# FAQ

**Q: Why no Ollama container?**

**A: Docker has no Silicon GPU accelleration: [source](https://chariotsolutions.com/blog/post/apple-silicon-gpus-docker-and-ollama-pick-two/)**


**Q: Can this run on my old MacBook?**

**A: Yes, but: you may want to go for a smaller model.**