# Используется базовый образ Alpine
FROM alpine:latest 
# Обновляем образ и устанавливаем nginx
RUN apk update
RUN apk add nginx
# Создаем нового пользователя и группу "www" для nginx
RUN adduser -D -g 'www' www
# Создаем директорию для html файлов и  меняем владельца папки на пользователя "www"
RUN mkdir /www
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www
# Копируем модифицированный файл конфигурации и index.html в image
COPY nginx.conf /etc/nginx/
COPY index.html /www/
# Команда запуска nginx при запуске контейнера
CMD ["nginx", "-g", "daemon off;"]