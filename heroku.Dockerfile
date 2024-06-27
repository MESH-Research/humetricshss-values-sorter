# TRICKY: this file is necessarily different than the one used in other environments due to Heroku's lack of support
# for crucial Docker infrastructure (e.g. Volumes). The steps between the MATCHING DOCKERFILE comments should be made
# to match those in ./Dockerfile when changes are made. Test-only dependecies - such as Chrome - can be skipped
# by Heroku to speed up deployment

# BEGIN MATCHING DOCKERFILE

# keep this in-sync with .tool-versions!
FROM ruby:2.7.3-buster

# set up app root
WORKDIR /root/values_sorter

# Add wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait ../wait
RUN chmod +x ../wait

# use node LTS, not 10 (Debian default)
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
# add yarn source to apt package sources
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
# update apt package lists
    apt-get update && \
# install packages
#  - nodejs for npm registry access
#  - yarn for js package management
#  - less for paging in dev consoles
    apt-get install nodejs yarn less

# END MATCHING DOCKERFILE

# copy the app files
ADD . .

# install gems
RUN bundle install --jobs 20 --retry 5

# install yarn packages
RUN bin/yarn install

# pack assets
RUN bin/rails assets:precompile
