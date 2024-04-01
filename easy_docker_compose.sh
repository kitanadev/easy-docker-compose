#!/bin/bash

# =============================================================================
# Copyright (c) 2024 kitanadev
#
# Original source code repository: https://github.com/kitanadev/easy-docker-compose
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# =============================================================================

# =============================================================================
# Nombre: easy_docker_compose.sh
#
# Descripción:
#
# Script en Bash diseñado para facilitar la gestión de aplicaciones/proyectos
# basados en Docker Compose, especialmente para proyectos que dispongan de
# diferentes guiones 'compose.yml' según el perfil/entorno (e.g: compose-dev.yml)
# sobre el que se desea usar.
#
# Uso:
#
#   easy_docker_compose.sh <modo> <perfil>
#
# Ejemplo:
#
#   easy_docker_compose.sh init dev
#
# En este caso, se hará de uso de un fichero 'compose-dev.yml' ubicado al mismo
# nivel que el script y se encargará inicializar completamente el proyecto de cero,
# esto es, primero descargará y construirá (build) las imágenes Docker necesarias
# y, una vez se haya realizado completa y correctamente este paso, levantará (up)
# los contenedores correspondientes a los servicios (servicios) definidos en el
# en el fichero Docker Compose correspondiente al perfil solicitado (compose-dev.yml)
# =============================================================================

# -----------------------------------------------------------------------------
# Verificación de paso de argumentos/parámetros
# -----------------------------------------------------------------------------
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 {init|up|restart|stop|delete|logs|status} perfil"
    exit 1
fi

# -----------------------------------------------------------------------------
# Exportar argumentos capturados del STDIN como variables globales al script
# -----------------------------------------------------------------------------
export DOCKER_COMPOSER_ACTION="${1}"
export PROJECT_PROFILE="${2}"
#export PROJECT_PROFILE="local"

# -----------------------------------------------------------------------------
# Construir imágenes asociadas a los servicios del guión de Docker Compose
# como, por ejemplo, 'compose-dev.yaml'
# -----------------------------------------------------------------------------
function build_docker_compose_services_images {
    BUILDKIT_PROGRESS="plain" \
    docker compose \
        -f "compose-${PROJECT_PROFILE}.yaml" build \
        --no-cache \
        --with-dependencies \
        --pull && \
    echo -e "\n==================================================================="
    echo -e "[INFO] Las imágenes Docker necesarias han sido construidas con éxito."
    echo -e "===================================================================\n"
}

# -----------------------------------------------------------------------------
# Levantar (up) los servicios (contenedores)
# -----------------------------------------------------------------------------
function up_docker_compose_services {
    docker compose \
        -f "compose-${PROJECT_PROFILE}.yaml" up \
        --detach \
        --force-recreate \
        --renew-anon-volumes \
        --wait \
        --timestamps && \
    echo -e "\n==================================================================="
    echo -e "[INFO] Los servicios (contenedores) se han iniciado correctamente."
    echo -e "===================================================================\n"
}

# -----------------------------------------------------------------------------
# Detener los servicios (contenedores) asociados al proyecto
# -----------------------------------------------------------------------------
function restart_docker_compose_services {
    docker compose \
        -f "compose-${PROJECT_PROFILE}.yaml" restart && \
    echo -e "\n==================================================================="
    echo -e "[INFO] Se han reanudado todos los servicios (contenedores) asociados al proyecto."
    echo -e "===================================================================\n"
}

# -----------------------------------------------------------------------------
# Detener los servicios (contenedores) asociados al proyecto
# -----------------------------------------------------------------------------
function stop_docker_compose_services {
    docker compose \
        -f "compose-${PROJECT_PROFILE}.yaml" stop && \
    echo -e "\n==================================================================="
    echo -e "[INFO] Se han detenido todos los servicios (contenedores) asociados al proyecto."
    echo -e "===================================================================\n"
}

# -----------------------------------------------------------------------------
# Eliminar tanto los contenedores de los respectivos servicios
# como de las imágenes Docker asociadas a los mismos
# -----------------------------------------------------------------------------
function delete_docker_compose_services_images {
    docker compose -f "compose-${PROJECT_PROFILE}.yaml" down \
        --remove-orphans \
        --rmi all && \
    docker compose -f "compose-${PROJECT_PROFILE}.yaml" rm \
        --force \
        --stop \
        --volumes && \
    sync && \
    echo -e "\n==================================================================="
    echo -e "[INFO] Se han eliminado completamente todos los servicios e imágenes Docker asociadas al proyecto."
    echo -e "===================================================================\n"
}

# -----------------------------------------------------------------------------
# Mostrar el estado de los servicios (contenedores)
# -----------------------------------------------------------------------------
function show_docker_compose_project_status {
    docker compose \
        -f "compose-${PROJECT_PROFILE}.yaml" ls --all
}

# -----------------------------------------------------------------------------
# Mostrar los registros (logs) de los servicios (contenedores)
# -----------------------------------------------------------------------------
function show_docker_compose_project_logs {
    docker compose \
        -f "compose-${PROJECT_PROFILE}.yaml" logs -f
}

# -----------------------------------------------------------------------------
# Mostrar los procesos / servicios (contenedores) activos
# -----------------------------------------------------------------------------
function show_docker_compose_services_status {
    docker compose \
        -f "compose-${PROJECT_PROFILE}.yaml" ps --all
}

# -----------------------------------------------------------------------------
# Función auxiliar encargado de comprobar la existencia de
# un fichero Docker Compose que se ajuste al perfil solicitado
# -----------------------------------------------------------------------------
function check_if_compose_profile_exist {
    local DOCKER_COMPOSE_PROFILE_FILE="compose-${PROJECT_PROFILE}.yaml"

    if [ ! -f "${DOCKER_COMPOSE_PROFILE_FILE}" ]; then
        echo -e "[ERROR] No se ha localizado un fichero '${DOCKER_COMPOSE_PROFILE_FILE}' que se corresponda al perfil solicitado: ${PROJECT_PROFILE}"
        exit 1;
    fi
}

# -----------------------------------------------------------------------------
# Punto de entrada principal del script
# -----------------------------------------------------------------------------
function main {

    # Comprobación previa de la existencia de un guión Docker Compose correspondiente
    # al perfil que se ha solicitado usar
    check_if_compose_profile_exist

    # Realizar acciones en función del primer parámetro
    case "${DOCKER_COMPOSER_ACTION}" in
        "init")
            echo -e "Realizando acción '${DOCKER_COMPOSER_ACTION}' con el parámetro '${PROJECT_PROFILE}'"
            build_docker_compose_services_images && \
            up_docker_compose_services && \
            show_docker_compose_project_status && \
            show_docker_compose_services_status
            ;;
        "up")
            echo -e "Realizando acción '${DOCKER_COMPOSER_ACTION}' con el parámetro '${PROJECT_PROFILE}'"
            up_docker_compose_services && \
            show_docker_compose_project_status && \
            show_docker_compose_services_status
            ;;
        "restart")
            echo -e "Realizando acción '${DOCKER_COMPOSER_ACTION}' con el parámetro '${PROJECT_PROFILE}'"
            restart_docker_compose_services && \
            show_docker_compose_project_status && \
            show_docker_compose_services_status
            ;;
        "stop")
            echo -e "Realizando acción '${DOCKER_COMPOSER_ACTION}' con el parámetro '${PROJECT_PROFILE}'"
            stop_docker_compose_services && \
            show_docker_compose_project_status && \
            show_docker_compose_services_status
            ;;
        "delete")
            echo -e "Realizando acción '${DOCKER_COMPOSER_ACTION}' con el parámetro '${PROJECT_PROFILE}'"
            delete_docker_compose_services_images && \
            show_docker_compose_project_status && \
            show_docker_compose_services_status
            ;;
        "logs")
            echo -e "Realizando acción '${DOCKER_COMPOSER_ACTION}' con el parámetro '${PROJECT_PROFILE}'"
            show_docker_compose_project_logs
            ;;
        "status")
            echo -e "Realizando acción '${DOCKER_COMPOSER_ACTION}' con el parámetro '${PROJECT_PROFILE}'"
            show_docker_compose_project_status && \
            show_docker_compose_services_status
            ;;
        *)
            echo -e "[ERROR] Acción no válida ('${DOCKER_COMPOSER_ACTION}').\nLas acciones disponibles son:\n\t"
            echo -e "'init', 'up', 'restart', 'stop', 'delete', 'logs', 'status'."
            exit 1;
            ;;
    esac

    exit 0;
}

# Invocación de la función principal y punto de entrada del script
main
