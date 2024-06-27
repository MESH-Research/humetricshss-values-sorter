#The HuMetricsHSS Values Sorter

Funded by The Mellon Foundation, the Values Sorter is a self-guided tool to help the user walk through activities using a values set. Users can register for the sorter and create their own values and activities sets to share with their teams. For more information on HuMetricsHSS please visit https://humetricshss.org.

This software is currently complete and no further development is planned. This is released under a GNU General Public License v3.0. 

# Setup

## Production

This repository provides two scripts to simplify production deployments. Download the repository, navigate to its root directory, and then run `bin/prod_deploy.bash` and follow the instructions. Once this is complete:

- A production-mode image of the application will have been built
- A volume used to persist the image's database will have been initialized and seeded
- Most of the deployment cruft should be removed

Review the contents of prod.env, updating values to match your deployment environment. Once this is done you may run `bin/prod_start.bash` to start a daemonized copy of the app

## Development

This repository replaces the traditional `bin/setup` script created by rails with one which helps simplify getting started with docker-compose. run `bin/setup` and follow the instructions.

- An image of the application will have been built
- A volume used to persist the image's gem dependencies will have been created and populated
- A volume used to persist the image's node module dependencies will have been created and populated
- A volume used to persist the image's database will have been initialized and seeded
- Most of the deployment cruft should be removed

Image rebuilds during development should not be necessary under most circumstances. The following scenarios are already covered:

- **Code changes:** Code is mounted as a local volume, so changes will automatically be made available to any containers running the image
- **Dependency changes:** Dependencies are mounted as named volumes. When changes are made just run e.g. `bundle install` inside a container to update the volume's contents
- **Database changes:** The database contents are mounted as a named volume. Data will persist between containers, and migrations can be run within a container to change its structure

Other small additions have been added to make working on the containerized application a little less painful:

- Bash and Rails histories are maintained in files outside the image so they can persist between containers
- The `docker.bashrc` file is used in place of root's .bashrc file within containers, allowing per-dev additions to the container's command line (helpful for e.g. aliases)
