# 使用輕量且安全的 nginx:alpine 作為基礎映像檔
FROM nginx:alpine

# 將 sre.txt 複製到 Nginx 預設的網頁根目錄 /usr/share/nginx/html/
# 使用者可以透過 http://<host>/sre.txt 路徑存取此檔案
COPY sre.txt /usr/share/nginx/html/sre.txt

# 開放 80 埠供 Nginx 服務使用
EXPOSE 80
