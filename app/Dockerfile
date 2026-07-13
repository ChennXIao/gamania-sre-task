# Use lightweight and secure nginx:alpine as the base image
FROM nginx:alpine

# Copy sre.txt to Nginx's default web root directory, accessible via http://<host>/sre.txt
COPY sre.txt /usr/share/nginx/html/sre.txt

# Expose port 80 for the Nginx service
EXPOSE 80
