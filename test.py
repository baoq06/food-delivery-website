with open('src/main/webapp/WEB-INF/views/shipper/dashboard.jsp', 'rb') as f:
    text = f.read().decode('utf-8')
for line in text.split('\n'):
    if 'Phương Tiện' in line:
        pass
        # I can just use line instead
    if 'Giấy Tờ' in line:
        print(line.encode('ansi', errors='ignore'))
