
try:
    with open('key_output.txt', 'r', encoding='utf-16') as f:
        content = f.read()
        for line in content.splitlines():
            if 'SHA1:' in line:
                print(line.strip())
except Exception as e:
    print(f"Error: {e}")
