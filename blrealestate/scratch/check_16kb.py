import zipfile
import struct
import sys

def check_elf_alignment(data):
    # Check magic
    if data[:4] != b'\x7fELF':
        return None
    
    # 32 or 64 bit?
    is_64 = data[4] == 2
    endian = '<' if data[5] == 1 else '>'
    
    e_phoff = struct.unpack(endian + ('Q' if is_64 else 'I'), data[32:40] if is_64 else data[28:32])[0]
    e_phentsize = struct.unpack(endian + 'H', data[54:56] if is_64 else data[42:44])[0]
    e_phnum = struct.unpack(endian + 'H', data[56:58] if is_64 else data[44:46])[0]
    
    alignments = []
    
    for i in range(e_phnum):
        offset = e_phoff + i * e_phentsize
        if offset + e_phentsize > len(data):
            break
        ph_entry = data[offset:offset+e_phentsize]
        p_type = struct.unpack(endian + 'I', ph_entry[:4])[0]
        
        # PT_LOAD is 1
        if p_type == 1:
            if is_64:
                p_align = struct.unpack(endian + 'Q', ph_entry[48:56])[0]
            else:
                p_align = struct.unpack(endian + 'I', ph_entry[28:32])[0]
            alignments.append(p_align)
            
    return alignments

def main(aab_path):
    print(f"Checking {aab_path} for 16KB page support...\n")
    try:
        with zipfile.ZipFile(aab_path, 'r') as z:
            so_files = [f for f in z.namelist() if f.endswith('.so')]
            
            if not so_files:
                print("No native libraries (.so files) found in the AAB.")
                print("CONCLUSION: The app SUPPORTS 16KB pages by default since it uses only Kotlin/Java code.")
                return
            
            all_support_16kb = True
            
            for so_file in so_files:
                # Read enough data for ELF headers
                with z.open(so_file) as f:
                    data = f.read(8192)
                
                alignments = check_elf_alignment(data)
                if alignments is None:
                    print(f"[SKIP] {so_file} (Not a valid ELF file)")
                    continue
                
                if not alignments:
                    print(f"[SKIP] {so_file} (No PT_LOAD segments)")
                    continue
                
                max_align = max(alignments)
                
                if max_align < 16384:
                    print(f"[FAIL] {so_file.ljust(60)} : max alignment {max_align} (< 16384)")
                    all_support_16kb = False
                else:
                    print(f"[OK]   {so_file.ljust(60)} : max alignment {max_align}")
                    
            if all_support_16kb:
                print("\nCONCLUSION: The app SUPPORTS 16KB page sizes. All native libraries are correctly aligned.")
            else:
                print("\nCONCLUSION: The app DOES NOT support 16KB page sizes.")
                print("Some native libraries are built with a smaller page size alignment (e.g., 4096 / 4KB).")
                print("They need to be recompiled with 16KB page alignment (using NDK r27 or adding -z max-page-size=16384 to the linker flags).")

    except Exception as e:
        print(f"Error reading AAB: {e}")

if __name__ == "__main__":
    main(sys.argv[1])
