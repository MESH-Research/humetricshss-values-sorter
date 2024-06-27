#!/bin/bash
set -eu

echo $'\n== Copying sample files =='
if [ ! -f prod.env ]
then
  cp sample.env prod.env
fi

echo $'\n== Ensuring database initialization requirements are met =='
if grep -Fq "{postgres_password_placeholder}" prod.env
then
  echo "Press return to generate a strong password for Postgres, or enter one if desired:"
  read -p "password: " pg_pass
  if [ -z $pg_pass ]
  then
    echo "generating a password..."
    pg_pass="$(cat /dev/urandom | base64 | tr -cd "[:upper:][:lower:][:digit:]" | head -c 32)"
  fi
  # TRICKY: MacOS' sed becomes very indignant when we even _consider_ using -i without making a backup. Don't EVEN go
  # there. It surely knows what's best for you.
  sed -i.bkp "s/{postgres_password_placeholder}/$pg_pass/g" prod.env
  rm -f prod.env.bkp
fi

echo $'\n== Building Docker container =='
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache

echo $'\n== Setting up the database =='
docker-compose -f docker-compose.yml -f docker-compose.prod.yml run web bash -c "../wait && bin/rails db:setup"

echo $'\n== Regenerating secret key =='
rm -f config/credentials.yml.enc
docker-compose -f docker-compose.yml -f docker-compose.prod.yml run web bash -c "../wait && EDITOR=vim bin/rails credentials:edit"

echo $'\n== Cleaning up =='
docker-compose -f docker-compose.yml -f docker-compose.prod.yml run web bash -c "../wait && bin/rails log:clear tmp:clear"
docker-compose -f docker-compose.yml -f docker-compose.prod.yml down

echo $'\n==    Setup finished successfully!     =='
echo    "== ----------------------------------- =="
echo    "==    Please examine your prod.env     =="
echo    "==   and fill in the empty variables   =="
echo    "==   with values that will work for    =="
echo    "==     your deployment environment     =="
echo    "== ----------------------------------- =="
echo    "== bin/prod_start.bash to start server =="
echo    "==    0.0.0.0:3000 to visit homepage   =="
