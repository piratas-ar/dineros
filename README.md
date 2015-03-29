Dineros
=======

Dineros es una miniaplicación para llevar la cuenta de quién tiene
cuánto.  No lleva autenticación pero envía recibos por mail para tener
un historial distribuido.


Configuración
-------------

* Generar el archivo .env con las siguientes variables (ver
  .env.example)

```bash
  # el dominio completo
  FQDN=dineros.dominio.org
  # necesitamos gpg1, no gpg2
  GPG_BIN=/path/a/gpg1
  # la contraseña de gpg1
  GPG_PASSWORD="una contraseña dificil"
  # opcional si queremos tener la llave de dineros separada de la
  # nuestra o de otras aplicaciones
  GNUPGHOME=./gnupg
```

* Instalar las gemas

```bash
  bundle install
```

* Migrar la base de datos

```bash
bundle exec rake mr:migrate
```

* Generar la llave gpg

```bash
bundle exec rake gpg:generate
```

* Iniciar la aplicación

```bash
bundle exec padrino s
```
