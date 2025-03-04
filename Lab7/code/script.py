import re

def generate_verilog(mem_file, asm_file):
    with open(asm_file, 'r') as asm_f, open(mem_file, 'w') as mem_f:
        lines = asm_f.readlines()
        
        index = 0
        
        for line in lines:
            line = line.strip()
            if not line or line.startswith('file format'):
                continue 

            match = re.match(r'^([0-9a-fA-F]+):\s+([0-9a-fA-F]{8})\s+(.+)$', line)
            if match:
                instruction = match.group(2)
                comment = match.group(3) if match.group(3) else ''
                mem_f.write(f"inst_mem[{index}] = 32'h{instruction};        // {comment}\n")
                index += 1
            else:
                print(f"Invalid instruction format || {line}")


asm_file = 'sort_machine.s'
mem_file = 'instruction.text'


generate_verilog(mem_file, asm_file)
