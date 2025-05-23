# syntax=docker/dockerfile:1

FROM composer:lts AS deps
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts

FROM composer:lts AS test
WORKDIR /app
COPY . .
RUN composer install --prefer-dist --no-interaction --no-scripts
RUN ./vendor/bin/phpunit || true

FROM php:8.2-apache AS final
RUN docker-php-ext-install pdo pdo_mysql
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --from=deps /app/vendor/ /var/www/html/vendor/
COPY ./src /var/www/html/
USER www-data
