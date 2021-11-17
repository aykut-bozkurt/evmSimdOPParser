# evmSimdOPParser
translates simd opcodes to evm bytecode


Takes 4 command line arguments.
* rawPath = Path of input file for scalar operations
* simdPath = Path of input file for simd operations
* rawRepeat = Bytecode generated for scalar input file is repeated rawRepeat times and appended to output file for scalar operations
* simdRepeat = Bytecode generated for simd input file is repeated simdRepeat times and appended to output file for simd operations
