# Easy Docker Compose Manager Tool `easy_docker_compose.sh`

## Info

- `easy_docker_compose.sh`

## Descripción

Script en Bash diseñado para facilitar la gestión de aplicaciones/proyectos
basados en Docker Compose, especialmente para proyectos que dispongan de
diferentes guiones 'compose.yml' según el perfil/entorno (e.g: compose-dev.yml)
sobre el que se desea usar.

## Uso

```bash
easy_docker_compose.sh <modo> <perfil>
```

Modos contemplados:

* `init`
* `up`
* `restart`
* `stop`
* `delete`
* `logs`
* `status`

Perfil:

Usará ficheros localizado en el directorio de trabajo o, en su defecto, al mismo nivel que el script, que se ajusten al patrón `compose-<perfil>.yml`. Por ejemplo, si el perfil pasado como argumento es `dev`, se usará el fichero `compose-dev.yml`.

### Ejemplo de uso

```bash
easy_docker_compose.sh init dev
```

En este caso, se hará de uso de un fichero `compose-dev.yml` ubicado al mismo
nivel que el script y se encargará inicializar completamente el proyecto de cero,
esto es, primero descargará y construirá (`build`) las imágenes Docker necesarias
y, una vez se haya realizado completa y correctamente este paso, levantará (`up`)
los contenedores correspondientes a los servicios (servicios) definidos en el
en el fichero Docker Compose correspondiente al perfil solicitado (`compose-dev.yml`)
