# WASM

[Webassembly][1] provides sandboxing by design. [Standard ABI's][3] such
as WASI can be used to provide capabilities to the sandbox.

Install [wasmedge][2], one of many wasm runtime implementation:

    sh -x recipe/wasmedge.sh

Test basic functionality by compiling a go program to wasm and running
it with [wasmedge][2]:

    sh -x wasmedge/cmd.build.sh
    sh -x wasmedge/cmd.run.sh Hello WASI

[Wasmedge][2] was chosen as runtime because it supports various LLM
focused backends, including GPU acceleration such as CUDA.

Projects such as [LlamaEdge][4], demonstrate how to leverage the
[wasmedge][2] to run LLM workloads via simple terminal chat and open ai
api compatible web server.

Install a [llama][5] model and the terminal chat wasm binary:

    sh -x recipe/llama.sh

Then start a chat session using wasmedge to run the app:

    sh -x cmd.chat.sh

[1]: https://webassembly.org/
[2]: https://wasmedge.org/
[3]: https://www.webassembly.guide/webassembly-guide/webassembly/wasm-abis
[4]: https://github.com/LlamaEdge/LlamaEdge
[5]: https://github.com/ggml-org/llama.cpp
